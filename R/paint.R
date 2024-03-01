#' The Colour of a Scene Element
#' 
#' Change the colour of a light or scene object.
#' 
#' @details
#' Paints all polygons of a scene object a specified colour, or alternatively 
#' sets the colour of a light. Transparency is ignored for lights, and transparent 
#' scene objects render much slower than opaque objects.
#' 
#' Additionally, two colours can be given when painting a scene object, upon 
#' which a gradient between the two colours is applied to the object. 
#' This gradient is a linear interpolation in the RGBA colourspace. `scale`, 
#' a numeric vector with an element for each face, specifies how far along this 
#' gradient each face is, and is automatically constrained to lie from 0 to 1. 
#' 
#' By default, `scale` is the degree to which each polygon faces the horizontal axis 
#' orthogonal to the direction the scene object faces.
#' 
#' By default, [light()] creates a white light, and [read_obj()] and [st_as_obj()] 
#' paint the scene objects they return white.
#' 
#' If `x` is a scene, `paint()` will be applied to every element in the scene.
#' 
#' @param x scene object (object of class "scenesetr_obj") or light (object of 
#' class "scenesetr_light") or scene (object of class "scenesetr_scene")
#' @inheritParams light
#' @param scale numeric vector. How far along the gradient is each face?
#' @returns Scene object or light or scene with updated colour.
#' @export

paint <- function(x, col, scale = x$normals[1, ]) UseMethod("paint")

#' @export
paint.scenesetr_obj <- function(x, col, scale = x$normals[1, ]){
  if(length(col) == 1) col <- rep(col, 2)
  col <- grDevices::col2rgb(col, alpha = TRUE)
  scale <- restrict(scale)
  scale[is.na(scale)] <- 0.5
  col <- t(col[, 1] + (col[, 2] - col[, 1]) %o% scale)
  x$col <- col
  x
}

restrict <- function(x) (x - min(x)) / (max(x) - min(x))

#' @export
paint.scenesetr_light <- function(x, col, scale = x$normals[1, ]){
  x$col <- format_col(col)
  x
}

#' @export
paint.scenesetr_scene <- function(x, col, scale = x$normals[1, ]){
  x <- lapply(x, paint, col)
  class(x) <- "scenesetr_scene"
  x
}

#' @export
paint.scenesetr_camera <- function(x, col, scale = x$normals[1, ]){
  warning("camera returned unpainted")
  x
}

format_col <- function(col){
  stopifnot("col must be one colour" = length(col) == 1)
  drop(grDevices::col2rgb(col, alpha = FALSE)) / 255
}