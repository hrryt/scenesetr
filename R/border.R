#' The Borders of Scene Objects
#' 
#' Functions to get or set the border properties of scene objects.
#' 
#' @details
#' `border(x)` returns the border value of the scene object.
#' 
#' `border(x) <- value` assigns a border value to a scene object.
#' 
#' `set_border` is an alias of `border<-` useful in pipes.
#' 
#' By default, [read_obj()] and [st_as_obj()] generate scene objects with a 
#' border value of `NA`, and [point_cloud()] a border value of `"white"`.
#' 
#' Using [paint()] on a point cloud will not affect its appearance. To change 
#' the colours of a point cloud, the border value must be set, as each point 
#' is rendered as a polygon.
#' 
#' The border value of a scene element is passed to [graphics::polygon()] in 
#' [record()]. `value` can therefore either be length one or a vector with an 
#' element for each polygon in the scene object.
#' 
#' @param x scene object (object of class "scenesetr_camera")
#' @param value replacement value
#' @returns
#' For `border(x)`, the border value of the scene object
#' 
#' For `border(x) <- value`, and `set_border(x, value)`, the updated scene object. 
#' (Note that the value of 
#' `border(x) <- value` is that of the assignment, `value`, not the return 
#' value from the left-hand side.)
#' @export

border <- function(x){
  x$border
}

#' @rdname border
#' @export
`border<-` <- function(x, value){
  x$border <- value
  x
}

#' @rdname border
#' @export
set_border <- `border<-`