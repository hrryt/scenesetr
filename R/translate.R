lookup_input <- c(32, 48:57, 65:90, 258:259, 262:265, 340:341, 344:345)
lookup_keys <- c(" ", 0:9, letters, "\t", "\b", "right", "left", "down", "up", "shift", "ctrl", "shift", "ctrl")

translate <- function(input){
  to_change <- input %in% lookup_input
  lookup_keys[match(input[to_change], lookup_input)]
}
