#' Create a Light
#' 
#' Create an object of class "scenesetr_light". A light illuminates a scene to 
#' be seen from the viewpoint of a camera when [record()] is called on the scene.
#' 
#' @details
#' There are four categories of light. Ambient light, directional light, point 
#' light and spotlight. Default arguments return a white ambient light with no behaviour.
#' 
#' If a light is unplaced and has no direction, it is an ambient light, which 
#' exerts equal shading on every polygon.
#' 
#' If a light is unplaced and has a direction, it is a directional light, which
#' acts as a uniform parallel light over the whole scene, similar to the sun.
#' 
#' If a light has a location and no direction, it is a point light, which acts 
#' as an omni-directional light from a point source at its location.
#' 
#' If a light has both a location and a direction, it is a spotlight, which acts 
#' as a point light, but only acting on a cone in the direction specified.
#' 
#' `direction` will be normalised to a 3-D vector of unit length.
#' 
#' @inheritParams camera
#' @param color passed to [grDevices::col2rgb()]
#' @returns Object of class "scenesetr_light".
#' @seealso [camera()], [scene()].
#' @export

light <- function(
    position = NA,
    direction = NA,
    color = "white"){
  color <- format_col(color)
  position <- format_place(position)
  orientation <- dir2q(direction)
  x <- list(
    position = position,
    orientation = orientation,
    behaviours = list(),
    color = color
  )
  class(x) <- "scenesetr_light"
  x
}
