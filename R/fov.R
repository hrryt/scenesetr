#' The Field of View of a Camera
#' 
#' Functions to get or set the field of view of a camera.
#' 
#' @details
#' `fov(x)` returns the field of view of a camera in degrees.
#' 
#' `fov(x) <- value` assigns a value to the field of view of a camera.
#' 
#' By default, [camera()] generates a camera with a sixty degree field of view.
#' 
#' The field of view of a camera in a scene is used by [record()] in configuring 
#' the perspective of the rendered frames from the viewpoint of the camera.
#' 
#' @inheritParams aspect
#' @returns
#' For `fov(x)`, the field of view as a double.
#' 
#' For `fov(x) <- value`, the updated camera. (Note that the value of 
#' `fov(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @export

fov <- function(x) x$fov

#' @rdname fov
#' @export
`fov<-` <- function(x, value){
  stopifnot(
    "value must be length 1" = length(value) == 1,
    "value must be double" = is.double(value)
  )
  x$fov <- value
  x
}
