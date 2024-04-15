#' Create a Camera
#' 
#' Create an object of class "scenesetr_camera". Calling [record()] on a scene with 
#' a camera allows the user to view the scene from the viewpoint of the camera.
#' 
#' @details
#' `direction` will be normalised to a 3-D vector of unit length.
#' 
#' Default arguments return a camera at the origin facing the positive 
#' z direction, with a sixty degree field of view and no 
#' behaviour.
#' 
#' @param position numeric vector. 3-D (x,y,z) coordinates
#' @param direction numeric vector. 3-D (x,y,z) coordinates
#' @param fov numeric value. Field of view in degrees.
#' @returns Object of class "scenesetr_camera".
#' @seealso [fov()], [light()], [scene()], [record()].
#' @export

camera <- function(
    position = c(0,0,0),
    direction = c(0,0,1),
    fov = 60
  ){
  position <- format_place(position)
  orientation <- dir2q(direction)
  fov <- as.double(fov)
  x <- list(
    position = position,
    orientation = orientation,
    behaviours = list(),
    fov = fov
  )
  class(x) <- "scenesetr_camera"
  x
}
