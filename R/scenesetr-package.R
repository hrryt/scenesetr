#' @keywords internal
"_PACKAGE"

Rcpp::loadModule(module = "GLRenderer", TRUE)

.datatable.aware = TRUE

## usethis namespace: start
#' @importFrom grDevices col2rgb
#' @importFrom grDevices colorRamp
#' @importFrom grDevices rgb
#' @importFrom methods new
#' @importFrom Rcpp evalCpp
#' @importFrom rlang !!!
#' @importFrom rlang %||%
#' @importFrom rlang check_installed
#' @importFrom rlang expr
#' @importFrom rlang missing_arg
#' @importFrom utils modifyList
#' @useDynLib scenesetr, .registration = TRUE
## usethis namespace: end
NULL
