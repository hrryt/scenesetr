#' Which Way is Up?
#' 
#' Returns a vector that describes an axis relative to the direction and roll of 
#' a scene element.
#' 
#' @details
#' When created with default arguments, a scene element faces the positive z 
#' direction with no roll. `skewer(element, "up")` therefore returns `c(0,1,0)`, 
#' vertically upwards. This can change as an element is rotated. `skewer()` is 
#' therefore useful in determining and acting on the orientation of an element.
#' 
#' If `to_rotate` is `TRUE`, `direction` no longer describes the direction the 
#' returned axis faces from the viewpoint of the scene element, but rather the 
#' direction an element would rotate were it to rotate about the returned axis.
#' This is used in [rotate()] when `axis` is given as a character string.
#' 
#' `direction` can only be set to "clockwise" if `to_rotate` is `TRUE`.
#' 
#' @inheritParams behaviours
#' @param direction character string
#' @param to_rotate logical value indicating whether `direction` indicates the 
#' direction of rotation were an element to be rotated about the returned axis, 
#' or whether `direction` simply indicates the direction of the returned axis.
#' @returns numeric vector. 3-D (x,y,z) coordinates describing a vector of unit 
#' length in the direction specified.
#' 
#' @examples
#' cam <- camera()
#' skewer(cam, "left")
#' 
#' (rolled_cam <- rotate(cam, "clockwise", 90))
#' (relative_left <- skewer(rolled_cam, "left"))
#' 
#' move(rolled_cam, relative_left)
#' 
#' @export

skewer <- function(x, direction = c("up", "down", "left", "right", "clockwise"), to_rotate = FALSE){
  dir <- match.arg(direction)
  if(!to_rotate) dir <- switch(
    dir,
    up = "right",
    down = "left",
    left = "up",
    right = "down",
    clockwise = stop("to_rotate must be TRUE if direction is clockwise")
  )
  d <- direction(x)
  axis <- switch(
    dir,
    up = c(-d[3], 0, d[1]),
    down = c(d[3], 0, -d[1]),
    left = c(d[1]*d[2], -sum(d[-2]^2), d[2]*d[3]),
    right = c(-d[1]*d[2], sum(d[-2]^2), -d[2]*d[3]),
    clockwise = d
  )
  roll(x$rotation) %qpq% axis
}
