#' Create a Scene
#' 
#' Create an object of class "scenesetr_scene" containing scene elements.
#' 
#' @details
#' A scene is a list of scene elements and can be subset as such with 
#' `[`, `[[` and `$`. A scene may have names.
#' 
#' A scene with lights, scene objects and a camera can be visualised with [see()].  
#' 
#' @param ... scene elements. Camera (object of class "scenesetr_camera") or 
#' light (object of class "scenesetr_light") or 
#' scene object (object of class "scenesetr_obj"). Passed to [list()].
#' @returns Object of class ("scenesetr_scene").
#' @export

scene <- function(...){
  x <- list(...)
  class(x) <- "scenesetr_scene"
  x
}

#' @export
`[.scenesetr_scene` <- function(x, i, ...){
  x <- `[.listof`(x, i, ...)
  class(x) <- "scenesetr_scene"
  x
}