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
#' by [add_normals()].
#' 
#' All returned scene objects are painted white, unplaced, 
#' have no behaviors and face the positive z direction.
#' 
#' @param file a connection object or a character string.
#' @param take_first logical value indicating whether only the first object
#' should read and returned
#' @returns Scene object (object of class "scenesetr_obj") if `take_first` is
#' `TRUE`, otherwise scene (object of class "scenesetr_scene") containing all 
#' scene objects described in the file.
#' @seealso [st_as_obj()], [cube_obj()], [scene()], [record()].
#' @export

read_obj <- function(file, take_first = TRUE) {

  file_lines <- readLines(file)
  m <- strsplit(file_lines, " ")
  m <- sapply(m, "[", seq_len(max(lengths(m))))
  
  starts <- m[1, ] == "o"
  n_objects <- sum(starts)
  objects <- vector("list", n_objects)
  
  starts <- which(starts)
  ends <- c(starts[-1], ncol(m))
  
  objects <- .mapply(m2obj, list(starts + 1, ends), list(m))
  names(objects) <- m[2, starts]
  
  if(take_first) objects <- objects[[1]] else class(objects) <- "scenesetr_scene"
  objects
}

m2obj <- function(start, end, m) {
  
  m <- m[, start:end]
  
  pts <- m[-1, m[1, ] == "v"]
  mode(pts) <- "double"
  is_na <- is.na(pts)
  pts <- pts[
    rowSums(is_na) != ncol(pts),
    colSums(is_na) != nrow(pts),
    drop = FALSE
  ]
  
  n <- m[1, ] == "vn"
  has_normals <- any(n, na.rm = TRUE)
  if(has_normals) {
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
  raw_faces <- faces[
    rowSums(is_na) != ncol(faces),
    colSums(is_na) != nrow(faces),
    drop = FALSE
  ]
  faces <- raw_faces
  
  normal_indices <- NA_integer_
  
  if(any(grepl("/", faces))) {
    faces <- extract_from(raw_faces, ".*?(?=/)")
    if(has_normals) normal_indices <- extract_from(raw_faces, "([^/]*$)")
  } else if(has_normals) {
    warning("normals found but no normal indices found; overwriting normals")
    has_normals <- FALSE
  }
  mode(faces) <- "integer"
  mode(normal_indices) <- "integer"
  
  x <- paint(obj(positions = pts, normals = normals, normal_indices = normal_indices, indices = faces), "white")
  if(!has_normals) x <- add_normals(x)
  triangulate(x)
}

extract_from <- function(faces, pattern) {
  reg <- regexpr(pattern, faces, perl = TRUE)
  replace <- as.numeric(regmatches(faces, reg))
  out <- rep(NA, length(reg))
  out[!is.na(reg)] <- replace
  out <- out - min(out, na.rm = TRUE) + 1
  matrix(out, nrow = nrow(faces))
}
