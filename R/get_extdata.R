get_extdata <- function(path) {
  system.file("extdata", path, package = "scenesetr", mustWork = TRUE)
}
