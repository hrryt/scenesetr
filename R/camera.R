#' Create a Camera
#' 
#' Create an object of class "scenesetr_camera". Calling [see()] on a scene with 
#' a camera allows the user to view the scene from the viewpoint of the camera.
#' 
#' @details
#' `direction` will be normalised to a 3-D vector of unit length.
#' 
#' Default arguments return a camera at the origin facing the positive 
#' z direction, with a sixty degree field of view, 1:1 aspect ratio and no 
#' behaviour.
#' 
#' @param place numeric vector. 3-D (x,y,z) coordinates
#' @param direction numeric vector. 3-D (x,y,z) coordinates
#' @param behaviours named list of behaviour functions
#' @param fov numeric value. Field of view in degrees.
#' @param aspect numeric value. Aspect ratio.
#' @returns Object of class "scenesetr_camera".
#' @seealso [fov()], [aspect()], [light()], [scene()], [see()].
#' @export

camera <- function(
    place = c(0,0,0),
    direction = c(0,0,1),
    behaviours = list(),
    fov = 60,
    aspect = 1
  ){
  place <- format_place(place)
  rotation <- dir2q(direction)
  validate_camera(new_camera(place, rotation, behaviours, fov, aspect))
}

new_camera <- function(
    place = double(),
    rotation = double(),
    behaviours = list(),
    fov = double(),
    aspect = double()){
  stopifnot(
    is.double(place),
    is.double(rotation),
    is.list(behaviours),
    is.double(fov),
    is.double(aspect)
  )
  x <- list(
    place = place,
    rotation = rotation,
    behaviours = behaviours,
    fov = fov,
    aspect = aspect
  )
  class(x) <- "scenesetr_camera"
  x
}

validate_camera <- function(x){
  stopifnot(
    "`x` `place` must be length 4 or NA" = length(x$place) == 4 || anyNA(x$place),
    "The fourth value of the `place` of `x` must be 1" = x$place[4] == 1 || anyNA(x$place),
    "`x` must have one `rotation` of length 4" = length(x$rotation) == 4,
    "The `rotation` of `x` must be a normalised quaternion or NA" = sum(x$rotation^2) == 1 || anyNA(x$rotation),
    "`x` `behaviours` must be a list of functions" = all(sapply(x$behaviours, is.function)),
    "`x` `behaviours` must be a named list" = !any(unnamed(x$behaviours)),
    "`fov` of `x` must be length 1" = length(x$fov) == 1,
    "`aspect` of `x` must be length 1" = length(x$aspect) == 1
  )
  x
}
