files_with <- function(pattern, path = "R", ...) {
  Filter(
    function(file) any(grepl(pattern, readLines(file, warn = FALSE), ...)),
    list.files(path, pattern = "[.]", full.names = TRUE)
  )
}
