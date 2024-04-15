init_renderer <- function(scene, width, height){
  
  object <- scene[sapply(scene, inherits, "scenesetr_obj")][[1]]
  normals <- object$normals[, object$normal_indices]
  vertices <- object$positions[, object$indices]
  vertices <- as.vector(rbind(vertices, normals))
  indices <- seq_len(length(object$indices)) - 1
  
  vertex_shader <- get_extdata("default.vert")
  fragment_shader <- get_extdata("default.frag")
  
  renderer <- new(GLRenderer, "scenesetr render", width, height)
  renderer$SetCameraResolution(width, height)
  renderer$InitShaderProgram(vertex_shader, fragment_shader)
  renderer$InitBuffers(vertices, indices)
  renderer
}