#' Observation of a Scene Element
#' 
#' Test whether a scene element is facing another scene element with a threshold 
#' angle of observation.
#' 
#' @details
#' Tests whether the position of the `lookee` is within a cone from the position 
#' of the `looker` in the direction of the `looker` with a specified threshold 
#' `angle` from the line of sight of the `looker`.
#' 
#' The position and direction of an element can be queried with [position()] and 
#' [direction()] respectively.
#' 
#' Useful in defining behaviours on sight or interaction.
#' 
#' If an element is unplaced, `looked_at()` will return `FALSE`.
#' 
#' @param lookee,looker scene elements. Camera (object of class 
#' "scenesetr_camera") or light (object of class "scenesetr_light") or 
#' scene object (object of class "scenesetr_obj").
#' @param angle numeric value in degrees
#' @returns Logical value indicating whether the `lookee` is looked at by the `looker`.
#' @seealso [in_range()], [behave()], [spin()].
#' @export

looked_at <- function(lookee, looker, angle = 15){
  x <- direction(looker)
  y <- position(lookee) - position(looker)
  out <- sum(x * y) > cospi(angle/180) * sqrt(sum(x^2, y^2))
  if(is.na(out)) return(FALSE)
  out
}
