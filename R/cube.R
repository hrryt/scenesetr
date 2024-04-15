cube <- function(side_length = 1, inverse = FALSE){
  points <- matrix(nrow = 3, c(
     0,0,0,
     0,0,1,
     0,1,0,
     0,1,1,
     1,0,0,
     1,0,1,
     1,1,0,
     1,1,1
  ) * side_length)
  faces <- matrix(nrow = 4, c(
    1,2,4,3,
    1,5,6,2,
    2,6,8,4,
    3,4,8,7,
    5,7,8,6,
    1,3,7,5
  ))
  out <- paint(triangulate(obj(positions = points, indices = faces)), "white")
  if(inverse) out$normals <- -out$normals
  out
}