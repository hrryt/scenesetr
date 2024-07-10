#' Convert Raster to Scene Object
#' 
#' Convert a stars raster object to a scene object with xz coordinates defined 
#' by the raster grid and y coordinates defined by a raster attribute.
#' 
#' @details
#' 
#' `x` must be a raster object with 2 dimensions, x and y, and a number of 
#' specifically named attributes: Either `"paint"` or all of `"red"`, `"green"` 
#' and `"blue"`, and optionally `"relief"` and `"alpha"`. If a third dimension, 
#' `"time"`, is provided, a scene object is returned with [behaviors()] such 
#' that its color switches each frame, quitting after the latest time if 
#' `quit_after_cycle` is `TRUE`. 
#' 
#' If `x$relief` is not supplied, it set to zero where `x$paint` 
#' or `x$red` are not `NA`.
#' 
#' If `x$red`, `x$green` and `x$blue` are supplied, each polygon is shaded based 
#' on these attributes. `x$alpha` can additionally be supplied for this purpose. 
#' Otherwise, [`paint`]`(*, colors, x$paint, ...)` is called on the scene object. 
#' If `x$paint` is not supplied this will paint the object with the 
#' first or only of the `colors` supplied.
#' 
#' If `globe` is `FALSE`, the x and y dimensions of the raster are mapped onto 
#' the x and z axes in 3-D space. 
#' `x$relief` is taken to be the y coordinate at each cell in the xz grid.
#' 
#' If `globe` is `TRUE`, the x and y dimensions of the raster are instead taken 
#' to be longitude and latitude respectively, and are mapped to 3-D Cartesian 
#' coordinated on a sphere with the north pole facing the positive y direction. 
#' To ensure x and y are longitude and latitude, 
#' [`sf::st_transform`]`(crs = "EPSG:4326")` is used.
#' 
#' Surface normals are added to the scene object after triangulation by [add_normals()].
#' 
#' The returned scene object is unplaced, has no behaviors and 
#' faces the positive z direction.
#' 
#' @param x stars raster object
#' @param colors passed to [paint()] with `x$paint` as the `scale`
#' @param globe logical; should the returned object be a sphere of the Earth's 
#' surface based on the [sf::st_crs()] of `x`?
#' @param radius radius of the sphere if `globe` is `TRUE`
#' @param max_color_value maximum value of `x$paint` or 
#' `x$red`, `x$green`, `x$blue` and `x$alpha` 
#' @param use_data_table logical; should `data.table` be used if installed?
#' @param quit_after_cycle logical; if animated, should [quit_device()] be 
#' called after completion?
#' @param ... additional arguments to pass to [paint()].
#' @returns Scene object (object of class "scenesetr_obj").
#' @seealso [read_obj()], [scene()], [record()].
#' @export
st_as_obj <- function(
    x, colors = "white", globe = TRUE, radius = 10,
    max_color_value = 1, use_data_table = TRUE,
    quit_after_cycle = FALSE, ...)
  UseMethod("st_as_obj")

#' @export
st_as_obj.stars <- function(
    x, colors = "white", globe = TRUE, radius = 10,
    max_color_value = 1, use_data_table = TRUE, 
    quit_after_cycle, ...) {
  
  rlang::check_installed(
    c("stars", "sf"), reason = "to manipulate stars and sf objects"
  )
  
  has_time <- "time" %in% (dn <- names(stars::st_dimensions(x)))
  
  if(is.null(x$relief)) {
    x$relief <- x$paint %||% x$red
    x$relief[!is.na(x$relief)] <- 0
  } else if(has_time) {
    s <- split(x["relief"], "time")
    stopifnot(
      "relief must not vary with time" = all(sapply(s, identical, s[[1]]))
    )
  }
  
  if(has_time) {
    indices <- rep(list(rlang::missing_arg()), length(dim(x)))
    ix <- which(dn == "time")[1]
    indices[[ix + 1]] <- 1
    indices[["drop"]] <- TRUE
    x1 <- eval(rlang::expr(x[!!!indices]))
  } else x1 <- x
  
  x1 <- xy2sfc(x1)
  x1 <- sf::st_as_sf(x1)
  
  if(globe && sf::st_crs(x1) != sf::st_crs("EPSG:4326"))
    x1 <- sf::st_transform(x1, "EPSG:4326")
  
  object <- if(use_data_table && requireNamespace("data.table"))
    data_table_as_obj(x1, colors, globe, radius, max_color_value, ...)
  else
    fallback_as_obj(x1, colors, globe, radius, max_color_value, ...)
  
  if(has_time) {
    animation_colors <- lapply(seq_len(dim(x)[[ix]]), function(i) {
      indices[[ix + 1]] <- i
      xi <- eval(rlang::expr(x[!!!indices]))
      xi <- xy2sfc(xi)
      xi <- sf::st_as_sf(xi)
      color <- st_make_colors(colors, xi, max_color_value, ...)
      cbind(color, color)
    })
    n_frames <- length(animation_colors)
    
    animated <- function(element, frame, ...) {
      if(quit_after_cycle && frame == n_frames + 1) return(quit_device("Cycle completed"))
      element$color <- animation_colors[[(frame - 1) %% n_frames + 1]]
      element
    }
    
    object$update_buffer <- TRUE
    object <- behave(object, animated)
  }
  
  object
}

data_table_as_obj <- function(x, colors, globe, radius, max_color_value, ...) {
  coords <- list(sf::st_geometry(x))
  data.table::setDT(coords)
  data.table::set(coords, j="V1", value=lapply(coords$V1, `[[`, 1L))
  coords[, c("L1", "times") := .(seq_len(nrow(coords)), times = vapply(V1, nrow, 0L))]
  coords <- coords[, .(do.call(rbind, V1), L1 = rep(L1, times = times))][duplicated(L1)]
  
  coords[, uniques := !duplicated(coords, by = c("V1", "V2"))]
  coords[, sides := seq_len(.N), by = L1]
  coords[uniques == TRUE, p_ind := seq_len(.N)]
  data.table::setkey(coords, V1, V2)
  coords[, point_index := coords[.(V1, V2), p_ind, mult = "first"]]
  
  faces <- matrix(NA_integer_, 4, coords[, max(L1)])
  faces[coords[, cbind(sides, L1)]] <- coords[, point_index]
  
  coords <- coords[order(p_ind, na.last = NA)]
  coords[, relief := x$relief[L1]]
  x <- sf::st_drop_geometry(x)
  
  if(!globe) {
    points <- coords[, rbind(V1, relief, V2)]
    return(make_globe(points, faces, colors, x, max_color_value, ...))
  }
  
  coords[, c("lon", "lat") := .(V1/180, V2/180)]
  coords[, cospi_lat := cospi(lat)]
  points <- coords[, t((radius + relief) * cbind(-cospi_lat*cospi(lon), sinpi(lat), cospi_lat*sinpi(lon)))]
  make_globe(points, faces, colors, x, max_color_value, ...)
}

fallback_as_obj <- function(x, colors, globe, radius, max_color_value, ...) {
  coords <- coord_2(lapply(sf::st_geometry(x), `[[`, 1))
  coords <- coords[duplicated(coords[, "L1"]), ]
  
  xy_char <- sprintf("%.5f%.5f", coords[, 1], coords[, 2])
  uniques <- !duplicated(xy_char)
  point_index <- match(xy_char, xy_char[uniques])
  
  sides <- rle(coords[, "L1"])$lengths
  faces <- matrix(NA_integer_, max(sides), max(coords[, "L1"]))
  faces[cbind(sequence(sides), coords[, "L1"])] <- point_index
  
  coords <- coords[uniques, ]
  relief <- x$relief[coords[, "L1"]]
  x <- sf::st_drop_geometry(x)
  
  if(!globe) {
    points <- rbind(coords[, 1], relief, coords[, 2])
    return(make_globe(points, faces, colors, x, max_color_value, ...))
  }
  
  lon <- coords[, 1] / 180
  lat <- coords[, 2] / 180
  x_coord <- -cospi(lat) * cospi(lon)
  z_coord <- cospi(lat) * sinpi(lon)
  y_coord <- sinpi(lat)
  points <- t(cbind(x_coord, y_coord, z_coord) * (radius + relief))
  make_globe(points, faces, colors, x, max_color_value, ...)
}

coord_2 <- function(x) {
  cbind(do.call(rbind, x), L1 = rep(seq_along(x), times = vapply(x, nrow, 0L)))
}

make_globe <- function(positions, indices, colors, x, max_color_value, ...) {
  object <- obj(positions = positions, indices = indices)
  object$color <- st_make_colors(colors, x, max_color_value, ...)
  object <- triangulate(object)
  object
}

st_make_colors <- function(colors, x, max_color_value, ...) {
  rgb_a <- c("red", "green", "blue")
  if("alpha" %in% colnames(x)) rgb_a <- c(rgb_a, "alpha")
  if(all(rgb_a %in% colnames(x))) t(x[, rgb_a] * (255 / max_color_value)) else
    make_colors(colors, scale = x$paint / max_color_value, ...)
}
