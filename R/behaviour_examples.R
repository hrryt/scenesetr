#' Example Behaviours of Scene Elements
#' 
#' Functions to be provided to [behave()] in defining the behaviours of a 
#' scene element, or functions that return behaviour functions when called.
#' 
#' @details
#' It is encouraged to peruse the code bodies of the behaviour functions 
#' in this topic to learn how to define your own behaviours.
#' 
#' All of the functions in this topic except for `spin()` are behaviours.
#' 
#' `spin()` returns a behaviour function for the rotation of an element each frame 
#' about the axis and by the angle specified.
#' 
#' A swarm of elements with the `boid` behaviour will act as a swarm of boids.
#' 
#' An element with the `excited` behaviour will wiggle vertically if a player 
#' (any element with the `wasd` behaviour) is not looking at the object.
#' 
#' An element with the `pushable` behaviour can be pushed horizontally by a player.
#' 
#' An element with the `bullet` behaviour will 'break' any element with the `fragile` 
#' behaviour once in range, upon which the bullet element will be unplaced.
#' The element can be fired from a player using the 'E' key. 'breaking' an 
#' element removes all its behaviours except for those named `pushable`, and 
#' points the element upwards.
#' 
#' An element with the `wasd` behaviour can be moved forward and backward with 
#' the 'W' and 'S' keys, and can be rotated left and right with the 'A' and 'D' 
#' keys. The `arrow_keys` behaviours allows the same control except using the arrow 
#' keys.
#' 
#' An element with the `follow` behaviour follows behind and above a player, with 
#' the same rotation as the player except for a thirty degree negative pitch.
#' 
#' An element with the `float_behind` behaviour floats behind and above a player 
#' with a delayed effect and the same rotation as the player.
#' 
#' An element with the `jump` behaviour can jump vertically from a horizontal 
#' floor defined by the initial location of the object when the ' ' key is held.
#' 
#' An element with the `tilt` behaviour can tilt down and up
#' on the press of keys '1' and '2' respectively.
#' 
#' @param axis the axis or direction of rotation to be passed to the `axis` 
#' argument of `rotate()`
#' @param angle the angle of rotation each frame to be passed to the `angle` 
#' argument of `rotate()`
#' @param quit_after_cycle logical value indicating if the device should be 
#' quit once one full rotation of the element is completed
#' @param element a scene element with the defined behaviour, to be modified by 
#' the behaviour each frame
#' @param scene the entire scene as it was the previous frame
#' @param keys character vector of keys held during the current frame
#' @param last_keys character vector of keys held during the previous frame
#' @param ... ignored
#' @returns
#' For `spin()`, a behaviour function.
#' 
#' For every other function, the modified scene element, to be modified 
#' by further behaviours or rendered in a given frame.
#' @seealso [behave()], [behaves()].
#' @export

spin <- function(axis, angle, quit_after_cycle = FALSE){
  force(axis)
  force(angle)
  if(quit_after_cycle) stop_frame <- 360 / angle
  function(element, frame, ...){
    if(quit_after_cycle && frame == stop_frame) return(quit_device("Cycle completed\n"))
    rotate(element, axis, angle)
  }
}

#' @rdname spin
#' @export
boid <- function(element, scene, ...){
  initial(element$velocity) <- c(0,0,0)
  boids <- scene[scene %behaves% boid]
  location_element <- location(element)
  locations <- sapply(boids, location)
  velocities <- sapply(boids, \(boid) boid$velocity %||% c(0,0,0))
  close <- sapply(boids, in_range, element, 10)
  velocity <- element$velocity +
    0.01 * (rowMeans(locations) - location_element) +
    0.15 * (rowMeans(velocities) - element$velocity) +
    0.50 * (location_element - rowMeans(locations[, close, drop = FALSE]))
  velocity[location_element > 200] <- -5
  velocity[location_element < -200] <- 5
  element$velocity <- velocity
  direction(element) <- velocity
  move(element, velocity)
}

#' @rdname spin
#' @export
excited <- function(element, scene, ...){
  initial(element$time) <- 0
  player <- scene[scene %behaves% wasd][[1]]
  if(looked_at(element, player, 60)) return(element)
  element$time <- element$time + 1
  move(element, c(0, sin(element$time), 0))
}

#' @rdname spin
#' @export
pushable <- function(element, scene, ...){
  player <- scene[scene %behaves% wasd][[1]]
  if(!in_range(player, element, 10)) return(element)
  y <- location(element)[2]
  element <- move(element, 0.15 * (location(element) - location(player)))
  location(element)[2] <- y
  element
}

#' @rdname spin
#' @export
bullet <- function(element, scene, keys, ...){
  player <- scene %behaves% wasd
  bullet <- scene %behaves% bullet
  objs <- scene[sapply(scene, inherits, "scenesetr_obj") & !(player | bullet)]
  player <- scene[player][[1]]
  if("E" %in% keys){
    rotation(element) <- rotation(player)
    location(element) <- location(player)
  }
  hit <- any(sapply(objs, in_range, element, 10))
  if(hit || !in_range(player, element, 50)) return(place(element, NA))
  element <- rotate(element, "clockwise", 20)
  move(element, 2 * direction(element))
}

#' @rdname spin
#' @export
fragile <- function(element, scene, ...){
  bullet <- scene[scene %behaves% bullet][[1]]
  if(!in_range(bullet, element, 10)) return(element)
  behaviours(element)[names(behaviours(element)) != "pushable"] <- NULL
  point(element, c(0,1,0), rotate_to = TRUE)
}

#' @rdname spin
#' @export
wasd <- function(element, keys, ...){
  for(key in keys) switch(
    key,
    W = element <- move(element, direction(element)),
    S = element <- move(element, -direction(element)),
    A = element <- rotate(element, "left", 4),
    D = element <- rotate(element, "right", 4)
  )
  element
}

#' @rdname spin
#' @export
arrow_keys <- function(element, keys, ...){
  for(key in keys) switch(
    key,
    up = element <- move(element, direction(element)),
    down = element <- move(element, -direction(element)),
    left = element <- rotate(element, "left", 4),
    right = element <- rotate(element, "right", 4)
  )
  element
}

#' @rdname spin
#' @export
follow <- function(element, scene, ...){
  player <- scene[scene %behaves% wasd][[1]]
  location(element) <- location(player) - 10 *
    (2 * direction(player) + skewer(player, "up"))
  rotation(element) <- rotation(player)
  rotate(element, "down", 30)
}

#' @rdname spin
#' @export
float_behind <- function(element, scene, ...){
  player <- scene[scene %behaves% wasd][[1]]
  to_player <- location(player) - location(element)
  rotation(element) <- rotation(player)
  move(element, 0.1 * to_player - 2 * direction(player) + skewer(player, "up"))
}

#' @rdname spin
#' @export
jump <- function(element, keys, ...){
  initial(element$floor) <- location(element)[2]
  initial(element$velocity) <- 0
  floor <- element$floor
  velocity <- element$velocity
  y <- location(element)[2]
  if(y < floor){
    location(element)[2] <- floor
  } else {
    velocity <- if(y == floor) if(any(keys == " ")) 1 else 0 else
      velocity - 0.1
    element <- move(element, c(0, velocity, 0))
  }
  element$velocity <- velocity
  element
}

#' @rdname spin
#' @export
tilt <- function(element, keys, last_keys, ...){
  one_down <- any(keys == "1")
  one_old <- any(last_keys == "1")
  two_down <- any(keys == "2")
  two_old <- any(last_keys == "2")
  if((!one_down & one_old) | (two_down & !two_old)) return(rotate(element, "up", 45))
  if((one_down & !one_old) | (!two_down & two_old)) return(rotate(element, "down", 45))
  element
}
