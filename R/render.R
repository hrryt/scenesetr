render <- function(
    scene,
    inputs,
    interactive,
    width,
    height,
    save_to_png,
    filename,
    one_frame) {
  
  renderer <- new(GLRenderer, "scenesetr render", width, height)
  on.exit(renderer$Delete())
  
  init_renderer(renderer, scene, width, height)
  aspect <- width / height
  
  use_sprintf <- has_format(filename)
  initial_scene <- scene
  window_should_close <- FALSE
  keys <- NULL
  frame <- 0
  
  while(!window_should_close) {
    
    frame <- frame + 1
    last_keys <- keys
    
    update_renderer(renderer, scene, aspect)
    
    if(save_to_png) {
      file <- if(use_sprintf) sprintf(filename, frame) else filename
      renderer$SaveImage(file, width, height)
    }
    
    if(interactive) inputs[[frame]] <- input <- renderer$GetInputs() else
      input <- inputs[[frame]]
    
    if(any(input == 256)) window_should_close <- TRUE
    keys <- translate(input)
    
    scene[] <- lapply(scene, apply_behaviors, scene, keys, last_keys, frame)
    if(any(sapply(scene, identical, 0))) window_should_close <- TRUE
    if(any(sapply(scene, identical, 1))) scene <- initial_scene
    if(renderer$WindowShouldClose()) window_should_close <- TRUE
    
    renderer$FramerateLimit(60)
  }
  
  out <- list(
    initial_scene = initial_scene,
    final_scene = scene,
    inputs = inputs
  )
  class(out) <- "scenesetr_recording"
  invisible(out)
}
