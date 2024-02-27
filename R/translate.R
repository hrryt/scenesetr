lookup <- matrix(ncol = 2, c(
  "%", "&", "(", "'", "\001", "\004",
  "\020", "\xa0", "\021", "\xa2", "\xff",
  "left", "up", "down", "right", "left_click", "middle_click",
  "shift", "", "ctrl", "", ""
))

translate <- function(keys){
  to_change <- keys %in% lookup[, 1]
  keys[to_change] <- lookup[match(keys[to_change], lookup[, 1]), 2]
  keys[keys != ""]
}
