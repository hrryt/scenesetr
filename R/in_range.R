#' Test the Proximity of Scene Elements
#' 
#' Test whether two scene elements are within a specified distance in 3-D space.
#' 
#' @details
#' Tests whether the distance between the point locations of elements is less 
#' than a threshold distance specified by `range`. 
#' The location of an element can be queried with [location()].
#' 
#' Useful in defining collision behaviours.
#' 
#' If an element is unplaced, `in_range()` will return `FALSE`.
#' 
#' @param x,y scene elements. Camera (object of class "scenesetr_camera") or 
#' light (object of class "scenesetr_light") or 
#' scene object (object of class "scenesetr_obj").
#' @param range numeric distance value
#' @returns Logical value indicating whether the elements are in range.
#' @export

in_range <- function(x, y, range){
  out <- sqrt(sum((location(x) - location(y))^2)) < range
  if(is.na(out)) return(FALSE)
  out
}