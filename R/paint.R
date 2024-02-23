#' The Colour of a Scene Element
#' 
#' Change the colour of a light or scene object.
#' 
#' @details
#' Paints all polygons of a scene object a specified colour, or alternatively 
#' sets the colour of a light.
#' 
#' Additionally, two colours can be given when painting a scene object, upon 
#' which a gradient between the two colours is applied to the object based on 
#' the degree to which each polygon faces the horizontal axis orthogonal to 
#' the direction the scene object faces. This gradient is a linear interpolation 
#' in the RGB colourspace.
#' 
#' A scene object must be painted to be rendered by [see()].
#' 
#' By default, [light()] creates a white light.
#' 
#' If `x` is a scene, `paint()` will be applied to every element in the scene.
#' 
#' @param x scene object (object of class "scenesetr_obj") or light (object of 
#' class "scenesetr_light") or scene (object of class "scenesetr_scene")
#' @inheritParams light
#' @returns Scene object or light or scene with updated colour.
#' @export

paint <- function(x, col) UseMethod("paint")

#' @export
paint.scenesetr_obj <- function(x, col){
  if(length(col) == 1) col <- rep(col, 2)
  col <- col2rgb(col)
  scale <- (x$normals[1, ] + 1) / 2
  col <- t(col[, 1] + (col[, 2] - col[, 1]) %o% scale)
  x$col <- col
  x
}

#' @export
paint.scenesetr_light <- function(x, col){
  x$col <- format_col(col)
  x
}

#' @export
paint.scenesetr_scene <- function(x, col){
  x <- lapply(x, paint, col)
  class(x) <- "scenesetr_scene"
  x
}

#' @export
paint.scenesetr_camera <- function(x, col){
  warning("camera returned unpainted")
  x
}

format_col <- function(col){
  stopifnot("col must be one colour" = length(col) == 1)
  drop(col2rgb(col)) / 255
}