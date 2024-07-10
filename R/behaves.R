#' Query Behaviors of Scene Elements
#' 
#' Tests if a named behavior is present in the behaviors of a scene element. 
#' If a scene is supplied, `behaves()` will return a logical vector, 
#' one for each element in the scene. `%behaves%` and `behaves()` are synonyms.
#' 
#' @details
#' The `behavior` argument can take either a character variable of the name of 
#' the behavior to be queried, or a variable name to be read by [match.call()]. 
#' This is checked for equality against the names of behavior list of the 
#' scene element.
#' 
#' The logical vector output of `behaves()` when called on a scene can be used 
#' to subset a scene. 
#' 
#' @param x scene element or scene. Camera (object of class "scenesetr_camera") 
#' or light (object of class "scenesetr_light") or scene object (object of class 
#' "scenesetr_obj") or scene (object of class "scenesetr_scene").
#' @param behavior character variable or variable name
#' @returns Boolean indicating whether the scene element has the behavior.
#' @seealso [behave()], [spin()].
#' @export

behaves <- function(x, behavior) {
  UseMethod("behaves") 
}

#' @export
behaves.default <- function(x, behavior) {
  if(!is.character(behavior)) behavior <- as.character(match.call()[[3]])
  any(names(behaviors(x)) == behavior)
}

#' @export
behaves.scenesetr_scene <- function(x, behavior) {
  behavior <- as.character(match.call()[[3]])
  sapply(x, behaves, behavior)
}

#' @rdname behaves
`%behaves%` <- behaves
