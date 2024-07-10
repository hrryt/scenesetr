#' The Position of a Scene Element
#' 
#' Functions to get and set the position of a scene element.
#' 
#' @details
#' 
#' `position(x)` returns a position vector in 3-D (x,y,z) coordinates.
#' 
#' `position(x) <- value` assigns the result of [`place`]`(x, value)`.
#' 
#' @inheritParams direction
#' @returns
#' For `position(x)`, the position vector of the scene element.
#' 
#' For `position(x) <- value`, the updated scene element. (Note that the value of 
#' `position(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @seealso [place()], [move()], [looked_at()], [in_range()].
#' @export

position <- function(x) {
  x$position
}

#' @rdname position
#' @export
`position<-` <- function(x, value) place(x, value)
