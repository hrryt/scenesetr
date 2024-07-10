update_renderer <- function(renderer, scene, aspect) {
  camera <- scene[sapply(scene, inherits, "scenesetr_camera")][[1]]
  lights <- scene[sapply(scene, inherits, "scenesetr_light")]
  objects <- scene[sapply(scene, inherits, "scenesetr_obj")]
  
  camera <- rotate(camera, "right", 180)
  
  renderer$SetLights(pack_lights(lights))
  renderer$SetCamera(pos_na(camera), orientation(camera), camera$fov, aspect)
  renderer$Clear()
  
  for (i in seq_along(objects)) {
    object <- objects[[i]]
    if(isTRUE(object$update_buffer)) update_mesh_buffer(object, i, renderer)
    draw_mesh(object, i, renderer)
  }
  
  renderer$Update()
}

update_mesh_buffer <- function(object, i, renderer) {
  mesh <- unpack_mesh(object)
  renderer$UpdateMeshBuffer(i-1, mesh$vertices)
}

draw_mesh <- function(object, i, renderer) {
  renderer$DrawMesh(i-1, pos_na(object), orientation(object))
}

pack_light <- function(light) {
  c(pos_na(light), direction(light), light$color / 255)
}

pack_lights <- function(lights) {
  do.call(c, lapply(lights, pack_light))
}

triple_nas <- function(x) {
  if(anyNA(x)) return(rep(NA_real_, 3))
  x
}

pos_na <- function(object) {
  triple_nas(position(object))
}
