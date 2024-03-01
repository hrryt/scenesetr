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
#' If `as_sphere = TRUE`, the x and y dimensions of the raster are instead taken 
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
#' @param as_sphere logical value indicating if a sphere should be returned
#' @param radius radius of the sphere if `as_sphere = TRUE`
#' @param raise logical value indicating if height should be scaled by raster attribute 
#' @returns Scene object (object of class "scenesetr_obj").
#' @seealso [read_obj()], [scene()], [record()].
#' @export
st_as_obj <- function(
    x, col = "white", as_sphere = FALSE, radius = 10, raise = TRUE) UseMethod("st_as_obj")

#' @export
st_as_obj.stars <- function(
    x, col = "white", as_sphere = FALSE, radius = 10, raise = TRUE){
  
  rlang::check_installed(
    c("stars", "sf"), reason = "to use `stars:::st_as_sf.stars()`, 
    `sf::st_coordinates()` and `sf::st_transform()`"
  )
  
  x <- sf::st_as_sf(x)
  if(as_sphere) x <- sf::st_transform(x, "EPSG:4326")
  coords <- sf::st_coordinates(x)
  coords <- coords[duplicated(coords[, "L2"]) & coords[, "L1"] == 1, ]
  
  xy_char <- paste0(coords[, "X"], coords[, "Y"])
  uniques <- !duplicated(xy_char)
  point_index <- match(xy_char, xy_char[uniques])
  
  face_index <- coords[, "L2"]
  sides <- rle(face_index)$lengths
  
  faces <- matrix(NA_integer_, max(sides) + 1, max(face_index))
  faces[cbind(sequence(sides) + 1, face_index)] <- point_index
  
  coords <- coords[uniques, ]
  scale <- x[names(x) != "geometry"][[1]]
  x <- coords[, "X"]
  y <- coords[, "Y"]
  point_scale <- raise * scale[coords[, "L2"]]
  
  if(!as_sphere){
    points <- rbind(x, point_scale, y, 1)
    return(paint(add_normals(obj(pts = points, faces = faces)), col, scale))
  }
  
  lon <- x / 180
  lat <- y / 180
  x <- cospi(lat) * cospi(lon)
  z <- cospi(lat) * sinpi(lon)
  y <- sinpi(lat)
  points <- cbind(x, y, z, 1)
  points[, -4] <- points[, -4] * (radius + point_scale)
  points <- t(points)
  paint(add_normals(obj(pts = points, faces = faces)), col, scale)
}
