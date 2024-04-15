render <- function(
    scene,
    inputs,
    interactive,
    width,
    height,
    save_to_png,
    filename){
  
  renderer <- init_renderer(scene, width, height)
  
  use_sprintf <- has_format(filename)
  initial_scene <- scene
  window_should_close <- FALSE
  keys <- NULL
  frame <- 0
  
  while(!window_should_close){
    
    camera <- scene[sapply(scene, inherits, "scenesetr_camera")][[1]]
    renderer <- update_renderer(renderer, camera)
    
    frame <- frame + 1
    last_keys <- keys
    
    if(interactive){
      input <- renderer$GetInputs()
      inputs[[frame]] <- input
    } else input <- inputs[[frame]]
    
    window_should_close <- any(input == 256)
    keys <- translate(input)
    
    scene[] <- lapply(scene, apply_behaviours, scene, keys, last_keys, frame)
    if(any(sapply(scene, identical, 0))) window_should_close <- TRUE
    if(any(sapply(scene, identical, 1))) scene <- initial_scene
    
    if(save_to_png){
      file <- if(use_sprintf) sprintf(filename, frame) else filename
      renderer$saveImage(file, width, height)
    }
    
    renderer$FramerateLimit(60)
  }
  
  renderer$Delete()
  
  out <- list(
    initial_scene = initial_scene,
    final_scene = scene,
    inputs = inputs
  )
  class(out) <- "scenesetr_recording"
  invisible(out)
}
