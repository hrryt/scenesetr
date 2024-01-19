#' Query Behaviours of Scene Elements
#' 
#' Tests if a named behaviour is present in the behaviours of a scene element. 
#' If a scene is supplied, `behaves()` will return a vector of booleans, 
#' one for each element in the scene. `%behaves%` and `behaves()` are synonyms.
#' 
#' @details
#' The `behaviour` argument can take either a character variable of the name of 
#' the behaviour to be queried, or a variable name to be read by [match.call()]. 
#' This is checked for equality against the names of behaviour list of the 
#' scene element.
#' 
#' The boolean vector output of `behaves()` when called on a scene can be used 
#' to subset a scene. 
#' 
#' @param x scene element or scene. Camera (object of class "scenesetr_camera") 
#' or light (object of class "scenesetr_light") or scene object (object of class 
#' "scenesetr_obj") or scene (object of class "scenesetr_scene").
#' @param behaviour character variable or variable name
#' @returns Boolean indicating whether the scene element has the behaviour.
#' @export

behaves <- function(x, behaviour){
  UseMethod("behaves") 
}

#' @export
behaves.default <- function(x, behaviour){
  if(!is.character(behaviour)) behaviour <- as.character(match.call()[[3]])
  any(names(behaviours(x)) == behaviour)
}

#' @export
behaves.scenesetr_scene <- function(x, behaviour){
  behaviour <- as.character(match.call()[[3]])
  sapply(x, behaves, behaviour)
}

#' @rdname behaves
`%behaves%` <- behaves
