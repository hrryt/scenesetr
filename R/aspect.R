#' The Aspect Ratio of a Camera
#' 
#' Functions to get or set the aspect ratio of a camera.
#' 
#' @details
#' `aspect(x)` returns the aspect ratio of a camera.
#' 
#' `aspect(x) <- value` assigns a value to the aspect ratio of a camera.
#' 
#' By default, [camera()] generates a camera with an aspect ratio of 1.
#' 
#' The aspect ratio of a camera in a scene is used by [record()] in setting 
#' the height of the graphics device to its width divided by the aspect ratio.
#' 
#' Using a behaviour to change the aspect ratio of a camera will not change the 
#' height of the graphics device until [record()] is called again on the scene.
#' 
#' @param x camera (object of class "scenesetr_camera")
#' @param value numeric replacement value
#' @returns
#' For `aspect(x)`, the aspect ratio as a double.
#' 
#' For `aspect(x) <- value`, the updated camera. (Note that the value of 
#' `aspect(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @export

aspect <- function(x){
  x$aspect
}

#' @rdname aspect
#' @export
`aspect<-` <- function(x, value){
  stopifnot(
    "value must be length 1" = length(value) == 1,
    "value must be numeric" = is.numeric(value)
  )
  x$aspect <- as.double(value)
  x
}
