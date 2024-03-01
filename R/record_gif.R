#' Record 3-D Render to GIF
#' 
#' Save a recording to GIF or record a scene to GIF.
#' 
#' @details
#' Creates a temporary directory to store PNG files of each frame, which are 
#' then converted to GIF by [gifski::gifski()]. Frames are run using [record()] 
#' with the [grDevices::png()] device.
#' 
#' It is recommended that `x` be a recording from `record()` rather than a scene, 
#' as no visible graphics window is used. 
#' If `x` is a scene, key inputs are logged and used in `record()` as each 
#' frame is calculated.
#' 
#' All arguments except for `x`, `render_order` and `...` are passed to `gifski()`, along with 
#' the height calculated by `record()` from `width` and the aspect of the camera.
#' 
#' @inheritParams gifski::save_gif
#' @inheritParams record
#' @export

record_gif <- function(
    x, gif_file = "animation.gif", width = 800,
    delay = 1/60, loop = TRUE, progress = TRUE, 
    render_order = NULL, ...){
  
  rlang::check_installed("gifski", reason = "to use gifski()")
  imgdir <- tempfile("tmppng")
  dir.create(imgdir)
  on.exit(unlink(imgdir, recursive = TRUE))
  filename <- file.path(imgdir, "tmpimg_%05d.png")
  
  recording <- record(x, device = grDevices::png, width = width, render_order = render_order, filename = filename, ...)
  images <- list.files(imgdir, pattern = "tmpimg_\\d{5}.png", full.names = TRUE)
  
  camera <- get_camera(x)
  height <- width / camera$aspect
  gifski::gifski(
    images, gif_file = gif_file, width = width, height = height,
    delay = delay, loop = loop, progress = progress
  )
  invisible(recording)
}

get_camera <- function(x) UseMethod("get_camera")
get_camera.scenesetr_scene <- function(x) x[sapply(x, inherits, "scenesetr_camera")][[1]]
get_camera.scenesetr_recording <- function(x) get_camera(x$initial_scene)