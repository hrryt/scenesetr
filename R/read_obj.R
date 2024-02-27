#' Data Input from Object File
#' 
#' Create a scene object or a scene from a .obj file.
#' 
#' @details
#' Object files can contain multiple objects. `take_first = FALSE` allows all 
#' objects in an object file to be returned as a scene of named scene objects. 
#' Otherwise, a single scene object is returned.
#' 
#' The vertices, face normals, face normal indices and face vertex indices of 
#' an object are read. All face indices are stored in the same matrix, with 
#' normal indices of each face in the first row.
#' 
#' If no face normals or face normal indices are found, they will be added 
#' by [add_normals].
#' 
#' All returned scene objects are painted white, unplaced, have no behaviours and 
#' face the positive z direction.
#' 
#' @param file a connection object or a character string.
#' @param take_first logical value indicating whether only the first object
#' should read and returned
#' @returns Scene object (object of class "scenesetr_obj") if `take_first` is
#' `TRUE`, otherwise scene (object of class "scenesetr_scene") containing all 
#' scene objects described in the file.
#' @seealso [st_as_obj()], [scene()], [record()].
#' @export

read_obj <- function(file, take_first = TRUE){

  file_lines <- readLines(file)
  m <- strsplit(file_lines, " ")
  m <- sapply(m, "[", seq_len(max(lengths(m))))
  
  starts <- m[1, ] == "o"
  n_objects <- sum(starts)
  objects <- vector("list", n_objects)
  
  starts <- which(starts)
  ends <- c(tail(starts, -1), ncol(m))
  
  objects <- .mapply(m2obj, list(starts + 1, ends), list(m))
  names(objects) <- m[2, starts]
  
  if(take_first) objects <- objects[[1]] else class(objects) <- "scenesetr_scene"
  objects
}

m2obj <- function(start, end, m){
  
  m <- m[, start:end]
  
  pts <- m[-1, m[1, ] == "v"]
  mode(pts) <- "double"
  is_na <- is.na(pts)
  pts <- pts[
    rowSums(is_na) != ncol(pts),
    colSums(is_na) != nrow(pts),
    drop = FALSE
  ]
  pts <- rbind(pts, 1)
  
  n <- m[1, ] == "vn"
  has_normals <- any(n, na.rm = TRUE)
  if(has_normals){
    normals <- m[-1, n, drop = FALSE]
    mode(normals) <- "double"
    is_na <- is.na(normals)
    normals <- normals[
      rowSums(is_na) != ncol(normals),
      colSums(is_na) != nrow(normals),
      drop = FALSE
    ]
  } else {
    warning("no normals found; calculating normals")
    normals <- NA_real_
  }
  
  faces <- m[-1, m[1, ] == "f", drop = FALSE]
  is_na <- is.na(faces)
  faces <- faces[
    rowSums(is_na) != ncol(faces),
    colSums(is_na) != nrow(faces),
    drop = FALSE
  ]
  if(any(grepl("/", faces))){
    
    reg <- regexpr(".*?(?=/)", faces, perl = TRUE)
    replace <- as.numeric(regmatches(faces, reg))
    out <- rep(NA, length(reg))
    out[!is.na(reg)] <- replace
    out <- out - min(out, na.rm = TRUE) + 1
    faces_1 <- faces[1, ]
    faces <- matrix(out, nrow = nrow(faces))
    if(has_normals){
      reg <- regexpr("([^/]*$)", faces_1, perl = TRUE)
      out <- rep(NA, length(reg))
      out[!is.na(reg)] <- as.numeric(regmatches(faces_1, reg))
      out <- out - min(out, na.rm = TRUE) + 1
      faces <- rbind(out, faces)
    } else faces <- rbind(NA, faces)
    
  } else {
    
    if(has_normals){
      warning("normals found but no normal indices found; overwriting normals")
      has_normals <- FALSE
    }
    faces <- rbind(NA, faces)
    
  }
  mode(faces) <- "integer"
  
  out <- paint(obj(pts, normals, faces), "white")
  if(!has_normals) return(add_normals(out))
  out
}
