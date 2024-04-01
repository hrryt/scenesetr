#' Point Cloud
#' 
#' Create a scene object comprising a cloud of points in 3-D space.
#' 
#' @description
#' 
#' The first three columns of `x` are taken to be the x, y and z coordinates 
#' of each point in the cloud.
#' 
#' Returns a scene object of polygons, each with two identically located vertices, 
#' so that each polygon is rendered as a point. As each polygon has zero area, 
#' they are painted transparent and have their borders set to white.
#' 
#' To change the colour of the points, use [set_border()]. To change the size of 
#' the points, use the `lwd` argument of [record()].
#'
#' @param x matrix or data frame of coordinates
#' @returns Scene object (object of class "scenesetr_obj").
#' @seealso [st_as_obj()], [scene()], [record()].
#' @export

point_cloud <- function(x){
  index <- seq_len(nrow(x))
  faces <- rbind(index, index, index)
  points <- t(cbind(x, 1))
  set_border(paint(obj(pts = points, faces = faces), NA), "white")
}

# cube <- function(side_length = 1, inverse = FALSE){
#   points <- rbind(matrix(nrow = 3, c(
#      0,0,0,
#      0,0,1,
#      0,1,0,
#      0,1,1,
#      1,0,0,
#      1,0,1,
#      1,1,0,
#      1,1,1
#   ) * side_length), 1)
#   faces <- rbind(NA, matrix(nrow = 4, c(
#     1,2,4,3,
#     1,5,6,2,
#     2,6,8,4,
#     3,4,8,7,
#     5,7,8,6,
#     1,3,7,5
#   )))
#   out <- paint(add_normals(obj(pts = points, faces = faces)), "white")
#   if(inverse) out$normals <- -out$normals
#   out
# }
