#' Replay a Recording of a Scene
#' 
#' Replay a recording from [see()] and re-record it on a new device.
#' 
#' @details
#' 
#' Recomputes every frame of a recording using the same scene and key inputs 
#' as were used in the recording. These frames are plotted in the specified 
#' device. The `final_scene` element of the recording is not used, and is 
#' provided in case it is of use to the user.
#' 
#' Useful for record gifs, by saving each frame as a png. For example, 
#' `replay(recording, grDevices::png, 800, filename = "frames/frame_%05d.png")`. 
#' This can then be recorded as a gif using for example [gifski::gifski()].
#' 
#' @param recording output of [see()]. Object of class "scenesetr_recording".
#' @inheritParams see
#' @returns `recording`, unchanged.
#' @export

replay <- function(recording, device = grDevices::X11, width = 7, ...){
  make_plots(recording$initial_scene, FALSE, recording$key_inputs, device, width, ...)
}
