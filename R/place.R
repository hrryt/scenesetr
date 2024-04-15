#' Place a Scene Element
#' 
#' Set the position of a scene element in 3-D space.
#' 
#' @details
#' If `anyNA(where)`, the scene element will be unplaced. Otherwise, 
#' `where` must be a numeric vector of length three specifying the 
#' new position of the element in 3-D coordinates (x,y,z).
#' 
#' An unplaced element will not be rendered by [record()].
#' 
#' If `x` is a scene, `place()` will be applied to every element in the scene.
#' 
#' @inheritParams behaves
#' @param where numeric vector or an R object containing `NA`. 
#' 3-D (x,y,z) coordinates.
#' @returns Scene element or scene with updated position.
#' @seealso [move()], [position()].
#' @export

place <- function(x, where) UseMethod("place")

#' @export
place.default <- function(x, where){
  x$position <- format_place(where)
  x
}

#' @export
place.scenesetr_scene <- function(x, where){
  x <- lapply(x, place, where)
  class(x) <- "scenesetr_scene"
  x
}

format_place <- function(place){
  if(anyNA(place)) return(NA_real_)
  stopifnot("place must be length 3 or NA" = length(place) == 3)
  place
}