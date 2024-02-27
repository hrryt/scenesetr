#' Interactive 3-D Render of a Scene
#' 
#' View a scene from the perspective of a camera. Record and replay how behaviours 
#' play out frame by frame with real-time key inputs from the user.
#' 
#' @details
#' Only available on Windows due to the method of obtaining key inputs. This 
#' may change in the future.
#' 
#' Supplying a scene with no camera is an error. A scene with no lights 
#' or no scene objects will appear blank.
#' 
#' Although key inputs can be used in the behaviours of scene elements, "R" and 
#' "Q" are reserved for resetting the scene and quitting the device respectively.
#' 
#' `x` can be a recording returned from `record()` or [record_gif()], 
#' in which case, the initial scene and key inputs will be taken from the recording, 
#' rather than using real-time key inputs.
#' 
#' If `device = `[`grDevices::dev.new`], as default, `noRStudioGD = TRUE` is set, 
#' as the RStudio graphics device does not accept arguments such as `width` and `height`.
#' The `height` argument passed to the device depends on `width` and the aspect of the 
#' camera.
#' 
#' @param x scene (object of class "scenesetr_scene") 
#' or recording (object of class "scenesetr_recording")
#' @param device function. Graphics device to be used.
#' @param width passed to device function
#' @param ... passed to device function
#' @returns Object of class "scenesetr_recording", invisibly. List of three elements:
#' * `initial_scene`: the original scene passed to `record()`,
#' * `final_scene`: the scene as it was in the last frame before quitting the device,
#' * `key_inputs`: a list of key inputs, with one element per frame recorded.
#' @seealso [scene()], [read_obj()], [record_gif()].
#' @export

record <- function(x, device = grDevices::dev.new, width = 7, ...) UseMethod("record")

#' @export
record.scenesetr_scene <- function(x, device = grDevices::dev.new, width = 7, ...){
  make_plots(scene = x, interactive = TRUE, key_inputs = list(), device = device, width = width, ...)
}

#' @export
record.scenesetr_recording <- function(x, device = grDevices::dev.new, width = 7, ...){
  make_plots(x$initial_scene, FALSE, x$key_inputs, device, width, ...)
}