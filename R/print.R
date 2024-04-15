#' @export
summary.scenesetr_scene <- function(object, ...){
  num_objects <- sum(sapply(object, inherits, "scenesetr_obj"))
  num_lights <- sum(sapply(object, inherits, "scenesetr_light"))
  num_cameras <- sum(sapply(object, inherits, "scenesetr_camera"))
  cat(
    "scene with ",
    num_objects," object",if(num_objects != 1)"s",", ",
    num_lights," light",if(num_lights != 1)"s"," and ",
    num_cameras," camera",if(num_cameras != 1)"s",
    sep = ""
  )
}

#' @export
print.scenesetr_light <- function(x, ...){
  place <- x$position
  q <- x$orientation
  has_place <- !anyNA(place)
  has_rotation <- !anyNA(q)
  cat(t(rgb(x$color)))
  if(!has_place && !has_rotation) cat(" ambient ")
  if(!has_place &&  has_rotation) cat(" directional ")
  if( has_place && !has_rotation) cat(" point ")
  if( has_place &&  has_rotation) cat(" spot")
  cat("light")
  if(has_place)
    cat(" at (",place[1],",",place[2],",",place[3],")", sep = "")
  if(has_rotation){
    axis <- round(q %qpq% c(0,0,1), 2)
    cat(" facing (",axis[1],",",axis[2],",",axis[3],")", sep = "")
  }
  cat("\n")
}

#' @export
print.scenesetr_camera <- function(x, ...){
  place <- x$position
  axis <- round(x$orientation %qpq% c(0,0,1), 2)
  cat("camera")
  cat(" at (",place[1],",",place[2],",",place[3],")", sep = "")
  cat(" facing (",axis[1],",",axis[2],",",axis[3],")", sep = "")
  cat("\n")
}

#' @export
print.scenesetr_obj <- function(x, ...){
  place <- x$position
  unplaced <- anyNA(place)
  axis <- round(x$orientation %qpq% c(0,0,1), 2)#
  if(unplaced) cat("unplaced ")
  if(anyNA(x$color)) cat("unpainted ")
  cat(ncol(x$faces), "poly ")
  cat("object")
  if(!unplaced)
    cat(" at (",place[1],",",place[2],",",place[3],")", sep = "")
  cat(" facing (",axis[1],",",axis[2],",",axis[3],")", sep = "")
  cat("\n")
}
