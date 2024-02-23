#' Create a Scene
#' 
#' Create an object of class "scenesetr_scene" containing scene elements.
#' 
#' @details
#' A scene is a list of scene elements, so can be subset with 
#' `[`, `[[` and `$` and combined with `c()`. A scene may have names.
#' 
#' A scene with lights, scene objects and a camera can be visualised with [see()].  
#' 
#' @param ... scene elements. Camera (object of class "scenesetr_camera") or 
#' light (object of class "scenesetr_light") or 
#' scene object (object of class "scenesetr_obj"). Passed to [list()].
#' @param list optional list of scene elements
#' @returns Object of class ("scenesetr_scene").
#' @seealso [camera()], [light()], [see()].
#' @export

scene <- function(..., list = NULL){
  x <- c(list(...), list)
  class(x) <- "scenesetr_scene"
  x
}

#' @export
`[.scenesetr_scene` <- function(x, i, ...){
  x <- `[.listof`(x, i, ...)
  class(x) <- "scenesetr_scene"
  x
}

#' @export
c.scenesetr_scene <- function(x, ...){
  x <- c(unclass(x), ...)
  class(x) <- "scenesetr_scene"
  x
}