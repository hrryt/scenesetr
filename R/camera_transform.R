camera_transform <- function(light, c_matrix, c_rotation){
  place <- light$place
  rotation <- light$rotation
  if(!anyNA(place)){
    place <- c_matrix %*% place
    light$place <- c_rotation %qpq% place[-4]
  }
  if(!anyNA(rotation)){
    light$rotation <- c_rotation %q% rotation
  }
  light
}
