#' Geometric Scene Objects
#' 
#' Create a cubic or pyramidal scene object.
#' 
#' @details
#' Create a cube within the interval `[0, side_length]` in each direction,
#' or a square-based pyramid `[-side_length, side_length]` in each direction 
#' with an apex at `(0, 0, side_length)` if placed at the origin.
#' 
#' `half_cube_obj()` returns the three faces of a `cube_obj()` 
#' that meet at the origin.
#' 
#' `inverse` may be a logical vector recycled over each normal.
#' 
#' @param side_length side length of each square face
#' @param inverse logical; should normals face inwards?
#' @returns Scene object (object of class "scenesetr_obj") 
#' painted white with no position or behavior.
#' @seealso [read_obj()]
#' @export
cube_obj <- function(side_length = 1, inverse = FALSE) {
  points <- matrix(nrow = 3, c(
    0,0,0,
    0,0,1,
    0,1,0,
    0,1,1,
    1,0,0,
    1,0,1,
    1,1,0,
    1,1,1
  ) * side_length)
  faces <- matrix(nrow = 4, c(
    1,2,4,3,
    1,5,6,2,
    2,6,8,4,
    3,4,8,7,
    5,7,8,6,
    1,3,7,5
  ))
  out <- paint(triangulate(obj(positions = points, indices = faces)), "white")
  out$normals[inverse] <- -out$normals
  out
}

#' @rdname cube_obj
#' @export
half_cube_obj <- function(side_length = 1, inverse = FALSE) {
  points <- matrix(nrow = 3, c(
    0,0,0,
    0,0,1,
    0,1,0,
    0,1,1,
    1,0,0,
    1,0,1,
    1,1,0
  ) * side_length)
  faces <- matrix(nrow = 4, c(
    1,2,4,3,
    1,5,6,2,
    1,3,7,5
  ))
  out <- paint(triangulate(obj(positions = points, indices = faces)), "white")
  out$normals[inverse] <- -out$normals
  out
}

#' @rdname cube_obj
#' @export
pyramid_obj <- function(side_length = 1, inverse = FALSE) {
  points <- matrix(nrow = 3, c(
    1,1,-1,
    1,-1,-1,
    -1,-1,-1,
    -1,1,-1,
    0,0,1
  ) * side_length)
  faces <- matrix(nrow = 3, c(
    4,2,1,
    4,3,2,
    1,2,5,
    2,3,5,
    3,4,5,
    4,1,5
  ))
  out <- paint(add_normals(obj(positions = points, indices = faces)), "white")
  out$normals[inverse] <- -out$normals
  out
}