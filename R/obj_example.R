#' Example Object Files
#' 
#' Find the full file name of an example object file or produce a character 
#' vector of the names of every example object file in the "scenesetr" package.
#' 
#' @details
#' If no `path` is provided, `obj_example()` returns a character 
#' vector of the names of every example object file in the "scenesetr" package. 
#' If a `path` character vector matching one or more elements of the returned 
#' vector of `obj_example()` is provided, `obj_example(path)` returns the full 
#' file name(s) of the example object file(s) provided.
#' 
#' Calls [base::system.file()] with the "extdata" subdirectory and "scenesetr" 
#' package.
#' 
#' @param path character vector specifying file(s)
#' @returns Character vector of all file names in the "extdata" subdirectory of 
#' the "scenesetr" package, or a character vector of full file names of queried 
#' example object files in the "extdata" subdirectory.
#' @export

obj_example <- function(path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "scenesetr"))
  } else {
    system.file("extdata", path, package = "scenesetr", mustWork = TRUE)
  }
}