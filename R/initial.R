#' Storing Variables between Frames
#' 
#' Set the initial value of a variable stored within a scene element 
#' between frames.
#' 
#' @details
#' `initial(x) <- value` assigns a value to an element of a list 
#' if it has not yet been set (if `is.null(x)` is `TRUE`).
#' 
#' Scene elements are stored as lists and so user-defined variables can be 
#' appended to them using `$<-` and accessed using `$`.
#' 
#' `initial(element$new_variable) <- value` can be useful in setting the 
#' `value` of a `new_variable` at frame zero in the behavior of an `element`. 
#' The new variable can then be accessed in the current and subsequent frames 
#' using `element$new_variable`.
#' 
#' `initial<-` is currently defined as 
#' `function(x, value) if(is.null(x)) value else x`
#' 
#' @param x a new element of a list. A new variable appended to a scene element.
#' @param value any R object
#' @returns The updated list. (Note that the value of 
#' `initial(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' 
#' @examples
#' count_to_fifty <- function(element, ...) {
#'   initial(element$counter) <- 0
#'   print(element$counter)
#'   if(element$counter == 50) return(game_over("Fifty reached"))
#'   element$counter <- element$counter + 1
#'   element
#' }
#' 
#' cam <- behave(camera(), count_to_fifty)
#' scene <- scene(cam)
#' \dontrun{
#' record(scene)
#' }
#' @seealso [behave()], [spin()].
#' @export

`initial<-` <- function(x, value) {
  if(is.null(x)) value else x
}
