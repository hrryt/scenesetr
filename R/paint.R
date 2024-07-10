#' The Color of a Scene Element
#' 
#' Change the color of a light or scene object.
#' 
#' @details
#' Paints all polygons of a scene object a specified color, or alternatively 
#' sets the color of a light. Transparency is ignored for lights.
#' 
#' If more than one color is supplied to `colors` when painting a scene object, 
#' a [grDevices::colorRamp()] is created and called on the `scale`, 
#' a numeric vector with an element for each polygon.
#' 
#' By default, [light()] creates a white light, and [read_obj()] and [st_as_obj()] 
#' create white scene objects.
#' 
#' If `x` is a scene, `paint()` will be applied to every element in the scene.
#' 
#' @param x scene object (object of class "scenesetr_obj") or light (object of 
#' class "scenesetr_light") or scene (object of class "scenesetr_scene")
#' @inheritParams grDevices::colorRamp
#' @param scale numeric vector. How far along the color gradient is each face?
#' @returns Scene object or light or scene with updated color.
#' @export

paint <- function(x, colors, scale = 0, ...) UseMethod("paint")

#' @export
paint.scenesetr_obj <- function(x, colors, scale = 0, ...) {
  x$color <- make_colors(colors, scale = 0, ...)
  x
}

make_colors <- function(colors, scale = 0, ...) {
  if(is.null(scale) || length(colors) == 1) scale <- 0
  ramp <- grDevices::colorRamp(colors, ...)
  stopifnot(
    "scale must be within the interval [0,1]" = min(scale) >= 0 && max(scale) <= 1
  )
  t(ramp(scale))
}

#' @export
paint.scenesetr_light <- function(x, colors, scale, ...) {
  x$color <- format_color(colors)
  x
}

#' @export
paint.scenesetr_scene <- function(x, colors, scale, ...) {
  x <- lapply(x, paint, colors, scale, ...)
  class(x) <- "scenesetr_scene"
  x
}

#' @export
paint.scenesetr_camera <- function(x, colors, scale, ...) {
  warning("camera returned unpainted")
  x
}

format_color <- function(col) {
  stopifnot("a light can only take one color" = length(col) == 1)
  drop(grDevices::col2rgb(col, alpha = FALSE))
}
