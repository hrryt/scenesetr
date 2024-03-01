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
#' @inheritParams grDevices::col2rgb
#' @inheritParams camera
#' @returns Object of class "scenesetr_light".
#' @seealso [camera()], [scene()].
#' @export

light <- function(
    col = "white",
    place = NA,
    direction = NA,
    behaviours = list()){
  col <- format_col(col)
  place <- format_place(place)
  rotation <- dir2q(direction)
  validate_light(new_light(col, place, rotation, behaviours))
}

new_light <- function(
    col = double(),
    place = double(),
    rotation = double(),
    behaviours = list()){
  stopifnot(
    is.double(col),
    is.double(place),
    is.double(rotation),
    is.list(behaviours)
  )
  x <- list(
    col = col,
    place = place,
    rotation = rotation,
    behaviours = behaviours
  )
  class(x) <- "scenesetr_light"
  x
}

validate_light <- function(x){
  stopifnot(
    "`x` must have one `col` of length 3" = length(x$col) == 3,
    "`x` `place` must be length 4 or NA" = length(x$place) == 4 || anyNA(x$place),
    "The fourth value of the `place` of `x` must be 1" = x$place[4] == 1 || anyNA(x$place),
    "`x` must have one `rotation` of length 4 or NA" = length(x$rotation) == 4 || anyNA(x$rotation),
    "The `rotation` of `x` must be a normalised quaternion or NA" = sum(x$rotation^2) == 1 || anyNA(x$rotation),
    "`x` `behaviours` must be a list of functions" = all(sapply(x$behaviours, is.function)),
    "`x` `behaviours` must be a named list" = !any(unnamed(x$behaviours))
  )
  x
}