#' Quit or Restart a Scene Render
#' 
#' Functions to be called within behaviours to quit or restart [record()].
#' 
#' @details
#' A behaviour that returns the result of `quit_device()` or `restart()` instead 
#' of returning the updated element causes [record()] to quit the graphics device 
#' or return the scene to its original value respectively when it is applied.
#' 
#' Restarting a scene resets all values stored in its elements. See [`initial<-`].
#' 
#' @param ... passed to [cat()]
#' @returns
#' For `quit_device()`, 0.
#' 
#' For `restart()`, 1.
#' 
#' @examples
#' count_to_thirty <- function(element, frame, ...){
#'   print(frame)
#'   if(frame == 30) return(quit_device("Thirty reached\n"))
#'   element
#' }
#' 
#' cam <- behave(camera(), count_to_thirty)
#' scene <- scene(cam)
#' \dontrun{
#' see(scene)
#' }
#' 
#' restart_if_twenty <- function(element, frame, ...){
#'   if(frame == 20) return(restart("Twenty reached\n"))
#'   element
#' }
#' 
#' restarting_cam <- behave(cam, restart_if_twenty)
#' restarting_scene <- scene(restarting_cam)
#' \dontrun{
#' # Restarting doesn't restart the frame number; only restarts the scene
#' see(restarting_scene)
#' }
#' @seealso [behave()], [spin()].
#' @export

quit_device <- function(...){
  cat(...)
  invisible(0)
}

#' @rdname quit_device
#' @export
restart <- function(...){
  cat(...)
  invisible(1)
}
