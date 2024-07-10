# combine_objects <- function(..., list = NULL){
#   objects <- c(list(...), list)
#   max_index <- 0
#   max_normal_index <- 0
#   for(i in seq_along(objects)) {
#     objects[[i]]$indices <- objects[[i]]$indices + max_index
#     objects[[i]]$normal_indices <- objects[[i]]$normal_indices + max_normal_index
#     max_index <- max(objects[[i]]$indices)
#     max_normal_index <- max(objects[[i]]$normal_indices)
#     if(ncol(objects[[i]]$color) == 1){
#       objects[[i]]$color <- objects[[i]]$color[
#         , rep(1, ncol(objects[[i]]$indices)), drop = FALSE
#       ]
#     }
#   }
#   behaviors <- do.call(c, lapply(objects, `[[`, "behaviors"))
#   color <- cbind_elements(objects, "color")
#   positions <- cbind_elements(objects, "positions")
#   indices <- cbind_elements(objects, "indices")
#   normals <- cbind_elements(objects, "normals")
#   normal_indices <- cbind_elements(objects, "normal_indices")
#   obj(
#     position = objects[[1]]$position,
#     orientation = objects[[1]]$orientation,
#     behaviors = behaviors,
#     color = color,
#     positions = positions,
#     indices = indices,
#     normals = normals,
#     normal_indices = normal_indices
#   )
# }
# cbind_elements <- function(objects, element_name){
#   do.call(cbind, lapply(objects, `[[`, element_name))
# }
