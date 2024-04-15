#' Convert Raster to Scene Object
#' 
#' Convert a stars raster object to a scene object with xz coordinates defined 
#' by the raster grid and y coordinates defined by a raster attribute.
#' 
#' @details
#' The raster object is assumed to have 2 dimensions and 1 attribute. 
#' The x and y dimensions of the raster are mapped onto the x and z axes in 3-D space. 
#' The attribute of the raster is taken to be the y coordinate at each cell in the xz grid.
#' 
#' The raster object is first converted by [stars::st_as_sf()] to an sf object 
#' of square polygons, one for each raster cell, with one attribute value per polygon. 
#' The y coordinate of each point is determined by the attribute value of the 
#' polygon in which it is first encountered.
#' 
#' If `globe` is `TRUE`, the x and y dimensions of the raster are instead taken 
#' to be longitude and latitude respectively, and are mapped to 3-D cartesian 
#' coordinated on a sphere with the north pole facing in the positive y direction. 
#' To ensure x and y are longitude and latitude, 
#' [`sf::st_transform`]`(crs = "EPSG:4326")` is used.
#' 
#' Should a vector of two colours be passed to `col`, each polygon will be coloured 
#' on a gradient between the two colours based on the attribute of the raster.
#' 
#' Surface normals are added to the scene object by [add_normals()].
#' 
#' The returned scene object is unplaced, has no behaviours and 
#' faces the positive z direction.
#' 
#' @param x stars raster object
#' @param col passed to [paint()] with `scale` as the raster attribute
#' @param globe logical value indicating if a spherical object should be returned
#' @param radius radius of the sphere if `globe` is `TRUE`
#' @param relief logical value indicating if height should be scaled by raster attribute 
#' @returns Scene object (object of class "scenesetr_obj").
#' @seealso [read_obj()], [scene()], [record()].
#' @export
st_as_obj <- function(
    x, col = "white", globe = TRUE, radius = 10, relief = TRUE) UseMethod("st_as_obj")

#' @export
st_as_obj.stars <- function(
    x, col = "white", globe = TRUE, radius = 10, relief = TRUE){
  
  rlang::check_installed(
    c("stars", "sf"), reason = "to use `stars:::st_as_sf.stars()`, 
    `sf::st_geometry()`, `sf::st_drop_geometry()` and `sf::st_transform()`"
  )
  
  x <- sf::st_as_sf(x)
  if(globe) x <- sf::st_transform(x, "EPSG:4326")
  coords <- coord_2(lapply(sf::st_geometry(x), `[[`, 1))
  coords <- coords[duplicated(coords[, "L1"]), ]
  
  xy_char <- sprintf("%.5f%.5f", coords[, 1], coords[, 2])
  uniques <- !duplicated(xy_char)
  point_index <- match(xy_char, xy_char[uniques])
  
  face_index <- coords[, "L1"]
  sides <- rle(face_index)$lengths
  
  faces <- matrix(NA_integer_, max(sides), max(face_index))
  faces[cbind(sequence(sides), face_index)] <- point_index
  
  coords <- coords[uniques, ]
  scale <- as.numeric(sf::st_drop_geometry(x)[[1]])
  x <- coords[, 1]
  y <- coords[, 2]
  point_scale <- if(relief) scale[coords[, "L1"]] else 0
  
  if(!globe){
    points <- rbind(x, point_scale, y)
    return(make_globe(points, faces, col, scale))
  }
  
  lon <- x / 180
  lat <- y / 180
  x <- -cospi(lat) * cospi(lon)
  z <- cospi(lat) * sinpi(lon)
  y <- sinpi(lat)
  points <- cbind(x, y, z)
  points[, -4] <- points[, -4] * (radius + point_scale)
  points <- t(points)
  make_globe(points, faces, col, scale)
}

coord_2 <- function(x){
  cbind(do.call(rbind, x), L1 = rep(seq_along(x), times = vapply(x, nrow, 0L)))
}

make_globe <- function(positions, indices, col, scale){
  paint(triangulate(obj(positions = positions, indices = indices)), col, scale)
}