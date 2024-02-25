#' Interactive 3-D Render of a Scene
#' 
#' View a scene from the perspective of a camera. Watch behaviours play out 
#' frame by frame with real-time key inputs from the user.
#' 
#' @details
#' Only available on windows due to the method of obtaining key inputs. This 
#' may change in the future.
#' 
#' A scene must have a camera for `see()` to function. A scene with no lights 
#' or no scene objects will appear blank.
#' 
#' Although key inputs can be used in the behaviours of scene elements, "R" and 
#' "Q" are reserved for resetting the scene and quitting the device respectively.
#' 
#' @param scene scene (object of class "scenesetr_scene")
#' @param device function. Graphics device to be used.
#' @param width passed to device function
#' @param ... passed to device function
#' @returns Object of class "scenesetr_recording", invisibly. List of three elements:
#' * `initial_scene`: the original scene passed to `see()`,
#' * `final_scene`: the scene as it was in the last frame before quitting the device,
#' * `key_inputs`: a list of key inputs, with one element per frame recorded.
#' @seealso [scene()], [read_obj()], [replay()].
#' @export

see <- function(scene, device = grDevices::X11, width = 7, ...){
  make_plots(scene, TRUE, list(), device, width, ...)
}
