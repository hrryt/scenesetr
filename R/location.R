#' The Location of a Scene Element
#' 
#' Functions to get and set the location of a scene element.
#' 
#' @details
#' 
#' `location(x)` returns a location vector in 3-D (x,y,z) coordinates.
#' 
#' `location(x) <- value` assigns the result of [`place`]`(x, value)`.
#' 
#' @inheritParams direction
#' @returns
#' For `location(x)`, the location vector of the scene element.
#' 
#' For `location(x) <- value`, the updated scene element. (Note that the value of 
#' `location(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @seealso [place()], [move()], [looked_at()], [in_range()].
#' @export

location <- function(x){
  x$place[-4]
}

#' @rdname location
#' @export
`location<-` <- function(x, value) place(x, value)
