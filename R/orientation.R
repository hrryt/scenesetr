#' The orientation of a Scene Element
#' 
#' Functions to get and set the orientation of a scene element.
#' 
#' @details
#' The orientation of a scene element is stored as a quaternion describing the 
#' rotation required to orient the object from its original orientation. 
#' The original orientation of a scene element is facing the positive z direction.
#' 
#' `orientation(x)` returns the rotation quaternion of an element.
#' 
#' `orientation(x) <- value` assigns a rotation quaternion to an element.
#' 
#' Useful in copying orientation between elements: 
#' `orientation(element2) <- orientation(element1)`. This is safer than 
#' `direction(element2) <- direction(element1)` as it conserves roll.
#' 
#' If `anyNA(value)`, the updated scene element has no orientation.
#' 
#' @inheritParams behaviours
#' @param value numeric replacement vector. 
#' Quaternion or an R object containing `NA`.
#' @returns
#' For `orientation(x)`, the quaternion of the scene element as a numeric vector.
#' 
#' For `orientation(x) <- value`, the updated scene element. (Note that the value of 
#' `orientation(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @seealso [point()], [rotate()], [direction()], [looked_at()], [skewer()].
#' @export

orientation <- function(x){
  x$orientation
}

#' @rdname orientation
#' @export
`orientation<-` <- function(x, value){
  if(anyNA(value)){
    x$orientation <- NA_real_
    return(x)
  }
  stopifnot(
    "value must be length 4 or NA" = length(value) == 4
  )
  x$orientation <- value
  x
}