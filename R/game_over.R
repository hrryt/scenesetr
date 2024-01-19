#' Quit or Restart a Scene Render
#' 
#' Functions to be called within behaviours to quit or restart [see()].
#' 
#' A behaviour that returns the result of `game_over()` or `restart()` instead 
#' of the updated element causes [see()] to quit the graphics device or return 
#' the scene to its original value respectively when it is applied.
#' 
#' @param ... passed to [cat()]
#' @returns
#' For `game_over()`, 0.
#' 
#' For `restart()`, 1.
#' 
#' @examples
#' count_to_fifty <- function(element, ...){
#'   initial(element$counter) <- 0
#'   print(element$counter)
#'   if(element$counter == 50) return(game_over("Fifty reached"))
#'   element$counter <- element$counter + 1
#'   element
#' }
#' 
#' cam <- behave(camera(), count_to_fifty)
#' scene <- scene(cam)
#' \dontrun{
#' see(scene)
#' }
#' 
#' restart_if_forty <- function(element, ...){
#'   if(element$counter == 40) return(restart("Forty reached\n"))
#'   element
#' }
#' 
#' restarting_cam <- behave(cam, restart_if_forty)
#' restarting_scene <- scene(restarting_cam)
#' \dontrun{
#' # Remember that pressing "Q" quits the device
#' see(restarting_scene)
#' }
#' 
#' @export

game_over <- function(...){
  cat(...)
  invisible(0)
}

#' @rdname game_over
#' @export
restart <- function(...){
  cat(...)
  invisible(1)
}
