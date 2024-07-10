init_renderer <- function(renderer, scene, width, height) {
  
  objects <- scene[sapply(scene, inherits, "scenesetr_obj")]
  
  renderer$InitMeshShaderProgram(get_extdata("mesh.vert"), get_extdata("mesh.frag"))
  renderer$UseMeshShaderProgram()
  for(object in objects) init_mesh(renderer, object)
  
}

init_mesh <- function(renderer, object) {
  mesh <- unpack_mesh(object)
  renderer$InitMesh(mesh$vertices, mesh$indices)
}

unpack_mesh <- function(object) {
  normals <- object$normals[, object$normal_indices]
  positions <- object$positions[, object$indices]
  indices <- object$indices
  
  colors <- object$color / 255
  if(nrow(colors) == 3) colors <- rbind(colors, 1)
  col_ind <- if(ncol(colors) == 1) rep(1, ncol(indices)) else seq_len(ncol(colors))
  colors <- colors[, rep(col_ind, each=3), drop=FALSE]
  
  vertices <- as.vector(rbind(positions, normals, colors))
  indices <- seq_along(indices) - 1
  
  list(vertices = vertices, indices = indices)
}
