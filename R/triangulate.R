triangulate <- function(x, add_norms = TRUE) {
  faces <- x$indices
  n_sides <- colSums(!is.na(faces))
  max_sides <- nrow(faces)
  if(max_sides == 3) return(x)
  if(max_sides > 4) {
    warning("polygons with more than four sides will be removed")
    faces <- faces[, n_sides <= 4]
  }
  if(any(n_sides < 3)) {
    warning("polygons with less than three sides will be removed")
    faces <- faces[, n_sides >= 3]
  }
  if(!is.null(x$color)) {
    
  }
  if(!anyNA(x$color) && ncol(x$color) > 1) {
    primary_color <- x$color
    secondary_color <- x$color[, n_sides == 4]
    x$color <- cbind(primary_color, secondary_color)
  }
  primary_triangles <- faces[1:3, ]
  secondary_triangles <- faces[c(3,4,1), n_sides == 4]
  x$indices <- cbind(primary_triangles, secondary_triangles)
  if(add_norms) return(add_normals(x))
  x
}
