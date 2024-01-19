#' The Direction of a Scene Element
#' 
#' Functions to get and set the direction a scene element faces.
#' 
#' @details
#' The rotation of a scene element is stored as a quaternion.
#' 
#' `direction(x)` returns a direction vector of unit length in 3-D (x,y,z) 
#' coordinates derived from the rotation quaternion of an element.
#' 
#' `direction(x) <- value` assigns the result of [`point`]`(x, value)`.
#' 
#' @inheritParams behaviours
#' @param value numeric replacement vector. 3-D (x,y,z) coordinates
#' @returns
#' For `direction(x)`, the direction vector of the scene element.
#' 
#' For `direction(x) <- value`, the updated scene element. (Note that the value of 
#' `direction(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @export

direction <- function(x){
  x$rotation %qpq% c(0,0,1)
}

#' @rdname direction
#' @export
`direction<-` <- function(x, value) point(x, value)
