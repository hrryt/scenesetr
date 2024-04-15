#' Write Normals of Scene Object
#' 
#' Add or edit the surface normal vectors of a scene object.
#' 
#' @details
#' Uses Newell's method to calculate the normal vector of each polygon. 
#' If `smooth` is `TRUE`, each point is assigned a separate normal, 
#' the mean of the normals of the polygons containing the point.
#' 
#' The updated normal vectors are stored in `x$normals`.
#' The index of the normal of each point in a face is stored in `x$normal_indices`.
#' 
#' Used in [read_obj()] if normals cannot be found, and in [st_as_obj()]. 
#' Useful if points or faces have been modified after scene object creation.
#' 
#' @param x scene object (object of class "scenesetr_obj")
#' @param smooth logical value. Should normals be calculated per point rather than per face?
#' @returns Updated scene object.
#' @export
add_normals <- function(x, smooth = FALSE){
  
  pts <- x$positions
  faces <- x$indices
  
  sides <- colSums(!is.na(faces))
  face_seq <- seq_len(ncol(faces))
  face_index <- rep(face_seq, sides)
  
  current_index <- sequence(sides)
  next_index <- c(current_index[-1], current_index[1])
  
  current_pts <- pts[, faces[cbind(current_index, face_index)]]
  next_pts <- pts[, faces[cbind(next_index, face_index)]]
  
  current_minus_next <- current_pts - next_pts
  current_plus_next <- current_pts + next_pts
  n_pts <- current_minus_next[c(2,3,1), ] * current_plus_next[c(3,1,2), ]
  
  normals <- rowsum(t(n_pts), face_index, reorder = FALSE)
  normals <- normals / sqrt(rowSums(normals^2))
  
  if(smooth){
    
    normals <- sapply(seq_len(ncol(pts)), \(n) colMeans(
      normals[colSums(faces == n) != 0, , drop = FALSE]
    ))
    normals <- normals / sqrt(rowSums(normals^2))
    
    normal_indices <- faces
    normal_indices[] <- seq_along(faces)
    x$normal_indices <- normal_indices
    
  } else x$normal_indices <- col(faces)
  
  dimnames(normals) <- NULL
  x$normals <- t(normals)
  
  x
}
