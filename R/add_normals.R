#' Write Normals of Scene Object
#' 
#' Add or edit the surface normal vectors of a scene object.
#' 
#' @details
#' Uses Newell's method to calculate the normal vector of each polygon.
#' The updated normal vectors are stored in `x$normals`.
#' The index of a normal vector is added to each polygon in the first row of `x$faces`.
#' 
#' Used in [read_obj] if normals cannot be found, and in [st_as_obj]. Useful if 
#' normals have been misread by [read_obj], for example in the case that vertex 
#' normals rather than surface normals are supplied in the .obj file. Also useful 
#' if points or faces have been modified after scene object creation.
#' 
#' @param x scene object (object of class "scenesetr_obj")
#' @returns Updated scene object.
#' @export
add_normals <- function(x){
  
  pts <- x$pts[-4, ]
  faces <- x$faces[-1, ]
  
  sides <- colSums(!is.na(faces))
  face_seq <- seq_len(ncol(faces))
  face_index <- rep(face_seq, sides)
  
  current_index <- sequence(sides)
  next_index <- c(tail(current_index, -1), current_index[1])
  
  current_pts <- pts[, faces[cbind(current_index, face_index)]]
  next_pts <- pts[, faces[cbind(next_index, face_index)]]
  
  current_minus_next <- current_pts - next_pts
  current_plus_next <- current_pts + next_pts
  n_pts <- current_minus_next[c(2,3,1), ] * current_plus_next[c(3,1,2), ]
  
  normals <- t(rowsum(t(n_pts), face_index, reorder = FALSE))
  dimnames(normals) <- NULL
  x$normals <- sweep(normals, 2, sqrt(colSums(normals^2)), `/`, FALSE)
  
  x$faces[1, ] <- face_seq
  x
}
