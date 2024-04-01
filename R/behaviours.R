#' The Behaviours of a Scene Element
#' 
#' Functions to get or set the behaviours of a scene element.
#' 
#' @details
#' The behaviours of an element are a named list of functions describing how 
#' an element is modified every frame when [record()] is called on a scene 
#' containing the element. Behaviours are applied to an element each frame 
#' in the order in which they appear in the named list.
#' 
#' `behaviours(x)` returns the behaviours of a scene element. 
#' 
#' `behaviours(x) <- value` assigns a value to the behaviours of a scene element. 
#' Only recommended in setting the behaviours of an element to (a subset of) 
#' the behaviours of another element. 
#' 
#' `behave(x, ...)` returns a scene element with updated behaviours.
#' The functions provided in `...` are added to the named list of behaviours 
#' of the scene element. The name of a new behaviour is set to the name 
#' of the function as captured  by [match.call()]. It is therefore recommended 
#' to specify each behaviour using the name of a predefined variable.
#' 
#' A behaviour can be defined by a user, with care to adhere to the following 
#' principles:
#' 
#' * The arguments of the function must include `...` in addition to the following 
#' optional parameters. `element` is the scene element immediately before the 
#' behaviour is applied. `scene` is the entire scene as it was the previous frame. 
#' `keys` is a character vector of the keys held during 
#' the current frame. `last_keys` is a character vector of the keys held during 
#' the previous frame. `frame` is the frame number of the current frame.
#' 
#' * The function must return the modified scene element. The returned element 
#' is then rendered if the behaviour is the last in the named list, or is passed 
#' to the next behaviour in the list as the `element` argument.
#' 
#' @param x scene element. Camera (object of class "scenesetr_camera") or 
#' light (object of class "scenesetr_light") or 
#' scene object (object of class "scenesetr_obj").
#' @param value named list of replacement behaviour functions
#' @param ... behaviour functions
#' @returns
#' For `behaviours(x)`, a named list of behaviour functions.
#' 
#' For `behaviours(x) <- value`, the updated element. (Note that the value of 
#' `behaviours(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' 
#' For `behaves(x, ...)`, an element with modified behaviours.
#' @seealso [behaves()], [spin()].
#' @export

behaviours <- function(x){
  x$behaviours
}

#' @rdname behaviours
#' @export
`behaviours<-` <- function(x, value){
  x$behaviours <- value
  x
}

#' @rdname behaviours
#' @export
behave <- function(x, ...) UseMethod("behave")

#' @export
behave.default <- function(x, ...){
  behaviours <- list(...)
  unnamed <- unnamed(behaviours)
  names(behaviours)[unnamed] <- as.character(match.call()[-c(1,2)][unnamed])
  x$behaviours <- modifyList(x$behaviours, behaviours)
  x$behaviours[unnamed(x$behaviours)] <- NULL
  x
}

#' @export
behave.scenesetr_scene <- function(x, ...){
  dots <- as.list(match.call()[-c(1,2)])
  x[] <- lapply(x, \(element) do.call(behave, c(list(element), dots)))
  x
}

unnamed <- function(x) !nzchar(names(x) %||% character(length(x)))