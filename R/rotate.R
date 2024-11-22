#' Rotate a Scene Element
#' 
#' Rotate a scene element from its current orientation.
#' 
#' @details
#' If `axis` is specified as a 3-D vector, the element is rotated about its 
#' position about an axis parallel to the specified vector.
#' 
#' `axis` can be specified as a character string describing the direction in 
#' which the object is to be rotated relative to its current direction. 
#' See [skewer()] with `to_rotate = TRUE`.
#'
#' If `x` is a scene, `rotate()` will be applied to every element in the scene.
#' 
#' @inheritParams behaves
#' @param axis numeric vector or character string. 
#' 3-D (x,y,z) coordinates or one of `c("up", "down", "left", "right", "clockwise")`.
#' @param angle numeric value in degrees
#' @returns Scene element or scene with updated rotation.
#' @seealso [point()], [direction()], [orientation()], [looked_at()].
#' @export

rotate <- function(x, axis, angle) UseMethod("rotate")

#' @export
rotate.default <- function(x, axis, angle) {
  stopifnot(
    "axis must be length 3 or character" = length(axis) == 3 || is.character(axis),
    "angle must be length 1" = length(angle) == 1
  )
  if(is.character(axis)) axis <- skewer(x, axis, to_rotate = TRUE)
  if(sum(axis) == 0) return(x)
  orientation <- quaternion_pi(normalise(axis), angle / 360) %q% x$orientation
  if(anyNA(orientation)) orientation <- NA_real_
  x$orientation <- orientation
  x
}

#' @export
rotate.scenesetr_scene <- function(x, axis, angle) {
  x <- lapply(x, rotate, axis, angle)
  class(x) <- "scenesetr_scene"
  x
}
