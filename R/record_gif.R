#' Record 3-D Render to GIF
#' 
#' Save a recording to GIF or record a scene to GIF.
#' 
#' @details
#' Creates a temporary directory to store PNG files of each frame, which are 
#' then converted to GIF by [gifski::gifski()]. Frames are run using [record()] 
#' with `save_to_png = TRUE`.
#' 
#' All arguments except for `x` are passed to `gifski()`.
#' @inheritParams gifski::save_gif
#' @inheritParams record
#' @returns Object of class "scenesetr_recording", invisibly. List of three elements:
#' * `initial_scene`: the original scene passed to `record()`,
#' * `final_scene`: the scene as it was in the last frame before quitting the device,
#' * `key_inputs`: a list of key inputs, with one element per frame recorded.
#' @export

record_gif <- function(
    x, gif_file = "animation.gif", width = 800, height = 600,
    delay = 1/30, loop = TRUE, progress = TRUE) {
  
  rlang::check_installed("gifski", reason = "to use gifski()")
  
  imgdir <- tempfile("tmppng")
  dir.create(imgdir)
  on.exit(unlink(imgdir, recursive = TRUE))
  
  filename <- file.path(imgdir, "tmpimg_%05d.png")
  
  recording <- record(
    x, width = width, height = height, save_to_png = TRUE, filename = filename
  )
  
  images <- list.files(imgdir, pattern = "tmpimg_\\d{5}.png", full.names = TRUE)
  
  gifski::gifski(
    images, gif_file = gif_file, width = width, height = height,
    delay = delay, loop = loop, progress = progress
  )
  
  invisible(recording)
}
