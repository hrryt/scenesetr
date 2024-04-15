#' Interactive 3-D Render of a Scene
#' 
#' View a scene from the perspective of a camera. Record and replay how behaviours 
#' play out frame by frame with real-time key inputs from the user.
#' 
#' @details
#' Creates a window displaying a render for each frame. Use Esc to close the window.
#' 
#' Supplying a scene with no camera is an error. A scene with no lights 
#' or no scene objects will appear blank.
#'
#' @param x scene (object of class "scenesetr_scene") 
#' or recording (object of class "scenesetr_recording")
#' @param width numeric width of window in pixels
#' @param height numeric height of window in pixels
#' @param save_to_png logical value. Should every frame be saved as a PNG file? 
#' @param filename the path of the output PNG file. The frame number is substituted 
#' if a C integer format is included in the character string.
#' @returns Object of class "scenesetr_recording", invisibly. List of three elements:
#' * `initial_scene`: the original scene passed to `record()`,
#' * `final_scene`: the scene as it was in the last frame before quitting the device,
#' * `inputs`: a list of key inputs, with one element per frame recorded.
#' @seealso [scene()], [read_obj()], [record_gif()].
#' @export

record <- function(
    x,
    width = 1920,
    height = 1080,
    save_to_png = FALSE,
    filename = "Rplot%05d.png") UseMethod("record")

#' @export
record.scenesetr_scene <- function(
    x,
    width = 1920,
    height = 1080,
    save_to_png = FALSE,
    filename = "Rplot%03d.png"){
  render(
    x,
    inputs = list(),
    interactive = TRUE,
    width = width,
    height = height,
    save_to_png = save_to_png,
    filename = filename
  )
}

#' @export
record.scenesetr_recording <- function(
    x,
    width = 1920,
    height = 1080,
    save_to_png = FALSE,
    filename = "Rplot%03d.png"){
  render(
    x$initial_scene,
    inputs = x$inputs,
    interactive = FALSE,
    width = width,
    height = height,
    save_to_png = save_to_png,
    filename = filename
  )
}