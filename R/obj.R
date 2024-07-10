obj <- function(
    positions = NA_real_, indices = NA_real_, normals = NA_real_,
    normal_indices = NA_real_, color = NA_real_, position = NA_real_,
    orientation = c(1,0,0,0), behaviors = list()) {
  mode(positions) <- "double"
  mode(indices) <- "integer"
  mode(normals) <- "double"
  mode(normal_indices) <- "integer"
  mode(position) <- "double"
  mode(orientation) <- "double"
  mode(behaviors) <- "list"
  mode(color) <- "double"
  x <- list(
    position = position,
    orientation = orientation,
    behaviors = behaviors,
    color = color,
    positions = positions,
    indices = indices,
    normals = normals,
    normal_indices = normal_indices
  )
  class(x) <- "scenesetr_obj"
  x
}
