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
#' The raster object is first converted by [stars::st_as_sf] to an sf object 
#' of square polygons, one for each raster cell, with one attribute value per polygon. 
#' The y coordinate of each point is determined by the attribute value of the 
#' polygon in which it is first encountered.
#' 
#' Surface normals are added to the scene object by [add_normals].
#' 
#' The returned scene object is painted white, unplaced, has no behaviours and 
#' faces the positive z direction.
#' 
#' @param x stars raster object
#' @returns Scene object (object of class "scenesetr_obj").
#' @seealso [read_obj()], [scene()], [see()].
#' @export
st_as_obj <- function(x) UseMethod("st_as_obj")

#' @export
st_as_obj.stars <- function(x){
  
  rlang::check_installed(
    c("stars", "sf"),
    reason = "to use `stars:::st_as_sf.stars()` and `sf::st_coordinates()`"
  )
  
  x <- stars:::st_as_sf.stars(x)
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
  points <- rbind(coords[, "X"], x[[1]][coords[, "L2"]], coords[, "Y"], 1)
  
  paint(add_normals(obj(pts = points, faces = faces)), "white")
}
