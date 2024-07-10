#' The Behaviors of a Scene Element
#' 
#' Functions to get or set the behaviors of a scene element.
#' 
#' @details
#' The behaviors of an element are a named list of functions describing how 
#' an element is modified every frame when [record()] is called on a scene 
#' containing the element. behaviors are applied to an element each frame 
#' in the order in which they appear in the named list.
#' 
#' `behaviors(x)` returns the behaviors of a scene element. 
#' 
#' `behaviors(x) <- value` assigns a value to the behaviors of a scene element. 
#' Only recommended in setting the behaviors of an element to (a subset of) 
#' the behaviors of another element. 
#' 
#' `behave(x, ...)` returns a scene element with updated behaviors.
#' The functions provided in `...` are added to the named list of behaviors 
#' of the scene element. The name of a new behavior is set to the name 
#' of the function as captured  by [match.call()]. It is therefore recommended 
#' to specify each behavior using the name of a predefined variable.
#' 
#' A behavior can be defined by a user, with care to adhere to the following 
#' principles:
#' 
#' * The arguments of the function must include `...` in addition to the following 
#' optional parameters. `element` is the scene element immediately before the 
#' behavior is applied. `scene` is the entire scene as it was the previous frame. 
#' `keys` is a character vector of the keys held during 
#' the current frame. `last_keys` is a character vector of the keys held during 
#' the previous frame. `frame` is the frame number of the current frame.
#' 
#' * The function must return the modified scene element. The returned element 
#' is then rendered if the behavior is the last in the named list, or is passed 
#' to the next behavior in the list as the `element` argument.
#' 
#' @param x scene element. Camera (object of class "scenesetr_camera") or 
#' light (object of class "scenesetr_light") or 
#' scene object (object of class "scenesetr_obj").
#' @param value named list of replacement behavior functions
#' @param ... behavior functions
#' @returns
#' For `behaviors(x)`, a named list of behavior functions.
#' 
#' For `behaviors(x) <- value`, the updated element. (Note that the value of 
#' `behaviors(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' 
#' For `behaves(x, ...)`, an element with modified behaviors.
#' @seealso [behaves()], [spin()].
#' @export

behaviors <- function(x) {
  x$behaviors
}

#' @rdname behaviors
#' @export
`behaviors<-` <- function(x, value) {
  x$behaviors <- value
  x
}

#' @rdname behaviors
#' @export
behave <- function(x, ...) UseMethod("behave")

#' @export
behave.default <- function(x, ...) {
  behaviors <- list(...)
  unnamed <- unnamed(behaviors)
  names(behaviors)[unnamed] <- as.character(match.call()[-c(1,2)][unnamed])
  x$behaviors <- modifyList(x$behaviors, behaviors)
  x$behaviors[unnamed(x$behaviors)] <- NULL
  x
}

#' @export
behave.scenesetr_scene <- function(x, ...) {
  dots <- as.list(match.call()[-c(1,2)])
  x[] <- lapply(x, \(element) do.call(behave, c(list(element), dots)))
  x
}

unnamed <- function(x) !nzchar(names(x) %||% character(length(x)))
