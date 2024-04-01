obj <- function(
    pts = NA_real_, normals = NA_real_, faces = NA_real_,
    col = NA_real_, place = NA_real_, border = NA,
    rotation = c(1,0,0,0), behaviours = list()){
  mode(pts) <- "double"
  mode(normals) <- "double"
  mode(faces) <- "integer"
  mode(col) <- "double"
  new_obj(pts, normals, faces, col, place, rotation, behaviours, border)
}

new_obj <- function(
    pts = double(),
    normals = double(),
    faces = integer(),
    col = double(),
    place = double(),
    rotation = double(),
    behaviours = list(),
    border = NULL){
  stopifnot(
    is.double(pts),
    is.double(normals),
    is.integer(faces),
    is.double(col),
    is.double(place),
    is.double(rotation),
    is.list(behaviours)
  )
  x <- list(
    pts = pts,
    normals = normals,
    faces = faces,
    col = col,
    place = place,
    rotation = rotation,
    behaviours = behaviours,
    border = border
  )
  class(x) <- "scenesetr_obj"
  x
}
