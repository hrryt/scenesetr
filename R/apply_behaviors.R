apply_behaviors <- function(element, scene, keys, last_keys, frame) {
  behaviors <- element$behaviors
  for(behavior in behaviors) {
    element <- behavior(
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
