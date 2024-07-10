#' Spin an Object
#' 
#' Create a behavior function that rotates a scene element every frame.
#' 
#' @details 
#' `spin()` returns a behavior function for the rotation of an element each frame 
#' about the axis and by the angle specified. 
#' `axis` and `angle` are passed to [rotate()].
#' 
#' @inheritParams rotate
#' @param quit_after_cycle logical value indicating if the device should be 
#' quit once one full rotation of the element is completed
#' @returns A behavior function to pass to [behave()]
#' @export

spin <- function(axis, angle, quit_after_cycle = FALSE) {
  force(axis)
  force(angle)
  if(quit_after_cycle) stop_frame <- 360 / angle
  function(element, frame, ...) {
    if(quit_after_cycle && frame == stop_frame) return(quit_device("Cycle completed\n"))
    rotate(element, axis, angle)
  }
}
