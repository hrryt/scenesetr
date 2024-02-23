obj <- function(
    pts = NA_real_, normals = NA_real_, faces = NA_real_,
    col = NA_real_, place = rep(NA_real_, 3),
    rotation = c(1,0,0,0), behaviours = list()){
  new_obj(pts, normals, faces, col, place, rotation, behaviours)
}

new_obj <- function(
    pts = double(),
    normals = double(),
    faces = integer(),
    col = double(),
    place = double(),
    rotation = double(),
    behaviours = list()){
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
    behaviours = behaviours
  )
  class(x) <- "scenesetr_obj"
  x
}
