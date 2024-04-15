#' @keywords internal
"_PACKAGE"

Rcpp::loadModule(module = "GLRenderer", TRUE)

## usethis namespace: start
#' @importFrom grDevices col2rgb
#' @importFrom grDevices rgb
#' @importFrom methods new
#' @importFrom Rcpp evalCpp
#' @importFrom rlang %||%
#' @importFrom rlang check_installed
#' @importFrom utils modifyList
#' @useDynLib scenesetr, .registration = TRUE
## usethis namespace: end
NULL
