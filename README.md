
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scenesetr

<!-- badges: start -->
<!-- badges: end -->

The goal of scenesetr is to allow R users to interactively explore and
animate custom 3-D scenes. scenesetr provides intuitive tools to define
behaviors of lights, cameras and objects in response to key inputs and
each other, and to record scenes as they pan out in real time. Save
recordings to PNG or GIF.

Scene objects can be read from .obj files and `stars` raster objects.

## Installation

You can install the development version of scenesetr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hrryt/scenesetr")
```

## Usage

``` r
# install.packages("gifski")
library(scenesetr)
```

### Visualize and animate raster data

Set up `stars` raster objects:

``` r
# install.packages(c("sf", "stars", "data.table"))
library(stars)
library(sf)

# Load in Greenland relief data as stars rasters
bed_raster <- greenland_bed * 0.15
ice_raster <- greenland_ice * 0.15
ice_raster <- st_warp(ice_raster, bed_raster)

# RGB raster of NASA's "blue marble", a true-color image of the Earth
# Information: https://visibleearth.nasa.gov/images/57752/blue-marble-land-surface-shallow-water-and-shaded-topography
# Download: https://eoimages.gsfc.nasa.gov/images/imagerecords/57000/57752/land_shallow_topo_8192.tif
blue_marble <- read_stars("land_shallow_topo_8192.tif") |>
  st_downsample(3)
x_dim <- (((st_get_dimension_values(blue_marble, "x")-.5) / nrow(blue_marble))-.5) * 360
y_dim <- (((st_get_dimension_values(blue_marble, "y")+.5) / ncol(blue_marble))-.5) * 180
blue_marble <- blue_marble |>
  st_set_dimensions("x", x_dim) |>
  st_set_dimensions("y", y_dim) |>
  st_set_crs("WGS84") |>
  st_warp(bed_raster) |>
  split("band") |>
  set_names(c("red", "green", "blue"))

bed_raster <- c(bed_raster, blue_marble)

# Add a lake under the Greenland ice cap and lighten the ocean floor
for(colour in names(blue_marble)){
  bed_raster[[colour]][bed_raster$relief < 0 & !is.na(ice_raster$relief)] <- bed_raster[[colour]][[1,1]]
  bed_raster[[colour]][bed_raster$relief < 0 & is.na(ice_raster$relief)] <- 255-(0.8*(255-bed_raster[[colour]][[1,1]]))
}

# NOAA time series data of Arctic sea ice concentration in 2023
# Information: https://polarwatch.noaa.gov/erddap/griddap/nsidcG02202v4nh1day.graph
# Download: https://polarwatch.noaa.gov/erddap/griddap/nsidcG02202v4nh1day.nc?cdr_seaice_conc[(2023-01-01T00:00:00Z):1:(2024-01-01T00:00:00Z)][(5837500.0):1:(-5337500.0)][(-3837500.0):1:(3737500.0)]
sea_raster <- read_ncdf("nsidcG02202v4nh1day.nc", var = "cdr_seaice_conc")
st_crs(sea_raster) <- "EPSG:3411"
names(sea_raster) <- "paint"
units(sea_raster$paint) <- NULL
sea_raster <- st_warp(sea_raster, bed_raster)
sea_colors <- rev(paste0(grDevices::blues9, as.hexmode(255-(0:8)*12)))
```

Use `scenesetr` to create a 3-D scene and record a GIF:

``` r
# The sea_raster stars raster has a time dimension so will be animated
sea_obj <- st_as_obj(sea_raster, colors = sea_colors, quit_after_cycle = TRUE, alpha = TRUE)
bed_obj <- st_as_obj(bed_raster, max_color_value = 255)
ice_obj <- st_as_obj(ice_raster, colors = "#ffffff99", alpha = TRUE)

greenland_objs <- scene(bed_obj, ice_obj, sea_obj) |>
  place(c(0,0,13)) |>
  rotate("up", 75) |>
  rotate("right", 25)

greenland_scene <- c(greenland_objs, scene(
  light() |> 
    point(c(1,0,0)),
  light() |>
    point(c(0,0,1)) |>
    rotate("up", 45) |>
    rotate("right", 90) |>
    paint("lightyellow"),
  camera() |>
    rotate("right", 30)
))

record_gif(greenland_scene, width = 960, height = 540)
```

<figure>
<img src="man/figures/README-greenland.gif"
alt="Timelapse of Arctic sea ice concentration over 2023, with bed topography under the Greenland ice cap" />
<figcaption aria-hidden="true">Timelapse of Arctic sea ice concentration
over 2023, with bed topography under the Greenland ice cap</figcaption>
</figure>

### Simulate complex behavior

``` r
bounding_size <- 10
boid_size <- 0.1
n_boids <- 60

# Define a custom behavior for a scene element
swarm <- function(element, scene, ...) {
  
  # Create a velocity variable to store in each element between frames
  initial(element$velocity) <- c(0,0,0)
  
  # Get the positions and velocities of all the boids in the swarm
  boids <- scene[scene %behaves% swarm]
  positions <- sapply(boids, position)
  velocities <- sapply(boids, function(boid) boid$velocity %||% direction(boid))
  is_close <- sapply(boids, in_range, element, bounding_size / 3)
  close_positions <- positions[, is_close, drop = FALSE]
  
  # Response to other boids
  velocity <- element$velocity + 0.005 * (
    rowMeans(positions) - position(element) +       # cohesion
    position(element) - rowMeans(close_positions) + # separation
    2*(rowMeans(velocities) - element$velocity)     # alignment
  )
  
  # Clamp speed between 1.0 and 0.1
  magnitude <- sqrt(sum(velocity^2))
  if(magnitude > 1.0) velocity <- 1.0 * velocity / magnitude
  if(magnitude < 0.1) velocity <- 0.1 * velocity / magnitude
  
  # Bounce off walls of bounding box
  velocity[position(element) > bounding_size] <- -0.05
  velocity[position(element) < 0] <- 0.05
  
  # Update the velocity variable
  element$velocity <- velocity
  
  # Update the direction and position of the scene element
  direction(element) <- velocity
  move(element, velocity)
}

# All boids will have these properties
boid <- pyramid_obj(boid_size) |>
  paint("lightblue") |>
  behave(swarm)

set.seed(1)
scene <- scene(
  camera() |>
    place(bounding_size * c(0.02,0.7,0.02)) |>
    point(c(1,0,1)) |>
    rotate("right", 5) |>
    rotate("down", 15),
  light() |>
    point(c(1,2,3)),
  light() |>
    paint("lightyellow"),
  cube_obj(bounding_size, inverse = TRUE) |>
    place(c(0,0,0)) |>
    paint("darkolivegreen"),
  list = replicate(n_boids, list(
    # Randomly position boids within bounding box
    place(boid, bounding_size * runif(3))
  ))
)

record_gif(scene)
```

<figure>
<img src="man/figures/README-boids.gif" alt="A swarm of boids" />
<figcaption aria-hidden="true">A swarm of boids</figcaption>
</figure>
