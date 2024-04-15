apply_behaviours <- function(element, scene, keys, last_keys, frame){
  behaviours <- element$behaviours
  for(behaviour in behaviours){
    element <- behaviour(
      element = element,
      scene = scene,
      keys = keys,
      last_keys = last_keys,
      frame = frame
    )
    if(is.numeric(element)) break
  }
  element
}