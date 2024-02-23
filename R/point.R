#' Point a Scene Element in a Direction
#' 
#' Set the direction of a scene element, either ensuring the element remains 
#' upright, or, if `rotate_to` is `TRUE`, ensuring it takes one rotation about 
#' an axis to transition from its current orientation to the specified direction.
#' 
#' @details
#' The rotation of a scene element is stored as a quaternion.
#' 
#' The 3-D `direction` vector is normalised to unit length, and a quaternion is 
#' assigned to the scene element describing its new rotation to face the direction.
#' 
#' By default, `point()` assigns a rotation quaternion with no roll, ensuring the 
#' element is upright once rotated to face the direction. Alternatively, if 
#' `rotate_to` is `TRUE`, the element is rotated about a single axis from its 
#' current orientation to face the new direction, so may not remain upright.
#' 
#' An upright element is defined as having a quaternion that describes a 
#' rotation about the vertical axis, followed by a rotation upwards or downwards 
#' relative to the new direction of the element, so that no roll is described.
#' 
#' If `anyNA(direction)`, the returned element has no rotation. If the `direction` 
#' given is `c(0,0,0)`, the element is set to face the positive z direction.
#' 
#' If `x` is a scene, `point()` will be applied to every element in the scene.
#' 
#' @inheritParams behaves
#' @param direction numeric vector. 3-D (x,y,z) coordinates
#' @param rotate_to logical value indicating whether the element should be 
#' rotated to its new direction from its current orientation.
#' @returns Scene element or scene with updated rotation.
#' @seealso [direction()], [rotate()], [rotation()], [looked_at()], [skewer()].
#' @export

point <- function(x, direction, rotate_to = FALSE) UseMethod("point")

#' @export
point.default <- function(x, direction, rotate_to = FALSE){
  x$rotation <- if(rotate_to) direction(x) %to% direction %q% x$rotation else dir2q(direction)
  x
}

#' @export
point.scenesetr_scene <- function(x, direction, rotate_to = FALSE){
  x <- lapply(x, point, direction, rotate_to)
  class(x) <- "scenesetr_scene"
  x
}
