#' Move a Scene Element
#' 
#' Change the position of a scene element relative to its current position.
#' 
#' @details
#' If `anyNA(translation)`, the scene element will be unplaced. Otherwise, 
#' `translation` must be a numeric vector of length three specifying the change 
#' in position along each of the basis axes (x,y,z).
#' 
#' If the scene element is already unplaced, `move()` will return the 
#' element unmodified.
#' 
#' An unplaced element will not be rendered by [record()].
#' 
#' If `x` is a scene, `move()` will be applied to every element in the scene.
#' 
#' @inheritParams behaves
#' @param translation numeric vector or an R object containing `NA`. 
#' 3-D (x,y,z) coordinates.
#' @returns Scene element or scene with updated position.
#' @seealso [place()], [position()].
#' @export

move <- function(x, translation) UseMethod("move")

#' @export
move.default <- function(x, translation) {
  if(anyNA(translation)) x$position <- NA_real_
  if(anyNA(x$position)) return(x)
  stopifnot(
    "translation must be length 3 vector or NA" = length(translation) == 3
  )
  x$position[-4] <- x$position + translation
  x
}

#' @export
move.scenesetr_scene <- function(x, translation) {
  x <- lapply(x, move, translation)
  class(x) <- "scene"
  x
}
