has_format <- function(filename) {
  without_percent <- gsub("%%", "", filename, fixed = TRUE)
  grepl("%", without_percent)
}
