#' The Rotation of a Scene Element
#' 
#' Functions to get and set the rotation of a scene element.
#' 
#' @details
#' The rotation of a scene element is stored as a quaternion.
#' 
#' `rotation(x)` returns the rotation quaternion of an element.
#' 
#' `rotation(x) <- value` assigns a rotation quaternion to an element.
#' 
#' Useful in copying rotation between elements: 
#' `rotation(element2) <- rotation(element1)`. This is safer than 
#' `direction(element2) <- direction(element1)` as it conserves roll.
#' 
#' If `anyNA(value)`, the updated scene element has no rotation.
#' 
#' @inheritParams behaviours
#' @param value numeric replacement vector. 
#' Quaternion or an R object containing `NA`.
#' @returns
#' For `rotation(x)`, the quaternion of the scene element as a numeric vector.
#' 
#' For `rotation(x) <- value`, the updated scene element. (Note that the value of 
#' `rotation(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @export

rotation <- function(x){
  x$rotation
}

#' @rdname rotation
#' @export
`rotation<-` <- function(x, value){
  if(anyNA(value)){
    x$rotation <- NA_real_
    return(x)
  }
  stopifnot(
    "value must be length 4 or NA" = length(value) == 4
  )
  x$rotation <- value
  x
}