#' Interactive 3-D Render of a Scene
#' 
#' View a scene from the perspective of a camera. Watch behaviours play out 
#' frame by frame with real-time key inputs from the user.
#' 
#' @details
#' Only available on windows due to the method of obtaining key inputs. This 
#' may change in the future. The use of the [grDevices::X11()] device imposes 
#' additional platform restrictions.
#' 
#' A scene must have a camera for `see()` to function. A scene with no lights 
#' or no scene objects will appear blank.
#' 
#' Although key inputs can be used in the behaviours of scene elements, "R" and 
#' "Q" are reserved for resetting the scene and quitting the device respectively.
#' 
#' @param scene scene (object of class "scenesetr_scene")
#' @returns The scene as it was in the last frame before quitting the device, 
#' invisibly.
#' @seealso [scene()], [read_obj()].
#' @export

see <- function(scene){
  
  obj_index <- sapply(scene, inherits, "scenesetr_obj")
  camera_index <- sapply(scene, inherits, "scenesetr_camera")
  light_index <- sapply(scene, inherits, "scenesetr_light")
  
  stopifnot(
    "OS type must be windows for keyboard input" = .Platform$OS.type == "windows",
    "number of cameras in scene must be one" = sum(camera_index) == 1
  )
  
  objects <- scene[obj_index]
  camera  <- scene[camera_index][[1]]
  lights  <- scene[light_index]
  n_objects <- sum(obj_index)
  n_lights  <- sum(light_index)
  n_scene   <- length(scene)
  no_objects <- n_objects == 0
  
  which_object <- double(n_scene)
  which_object[obj_index] <- seq_len(sum(obj_index))
  
  wsplaces <- matrix(double(), 4, n_objects)
  if(!no_objects){
    max_sides <- max(sapply(objects, \(object) nrow(object$faces)))
    max_polys <- max(sapply(objects, \(object) ncol(object$faces)))
    midpts <- sapply(objects, \(object) rowMeans(object$pts))
    midpts[4, ] <- 0
  }
  
  xylim <- c(-1.5, 1.5)
  c_matrix <- diag(4)
  asp <- 1 / camera$aspect
  f <- 1 / tanpi(camera$fov / 360)
  p_matrix <- matrix(nrow = 4, byrow = TRUE, c(
    f * asp,0,0,0,0,f,0,0,0,0,-1,-2,0,0,1,0
  ))
  wsscene <- scene
  flag <- TRUE
  game_over <- FALSE
  restart <- FALSE
  action_flag <- FALSE
  keys <- NULL
  
  GetKeyboard()
  
  X11(height = 7 * asp)
  par(mar = c(0,0,0,0), bg = 1)
  
  previous_time <- Sys.time()
  
  while(flag){
    
    # key events
    last_keys <- keys
    events <- GetKeyboard()
    keys <- translate(events)
    
    for(key in keys) switch(key, R = wsscene <- scene, Q = flag <- FALSE)
    
    # apply behaviours
    for(e in seq_len(n_scene)){
      
      wselement <- wsscene[[e]]
      behaviours <- wselement$behaviours
      
      for(behaviour in behaviours){
        
        wselement <- behaviour(
          element = wselement,
          scene = wsscene,
          keys = keys,
          last_keys = last_keys
        )
        
        game_over <- identical(wselement, 0)
        restart <- identical(wselement, 1)
        action_flag <- game_over || restart
        if(action_flag) break
      }
      
      if(action_flag) break
      
      wsscene[[e]] <- wselement
      wsplaces[, which_object[e]] <- wselement$place
    }
    
    if(game_over) break
    if(restart) wsscene <- scene
    
    if(no_objects){
      plot.new()
      next
    }
    
    # unpack wsscene
    wsobjects <- wsscene[obj_index]
    wslights  <- wsscene[light_index]
    wscamera  <- wsscene[camera_index][[1]]
    c_matrix[, 4] <- -wscamera$place
    c_rotation <- conjugate(wscamera$rotation)
    
    if(anyNA(c_matrix) || anyNA(c_rotation)){
      plot.new()
      next
    }
    
    wslights <- lapply(wslights, camera_transform, c_matrix, c_rotation)
    
    
    # set object render order
    wsmidpts <- c_matrix %*% (midpts + wsplaces)
    wsmidpts <- c_rotation %qMq% wsmidpts
    wsorder <- order(wsmidpts[3, ], decreasing = TRUE)
    
    # plot objects
    all_poly <- array(double(), c(max_sides, max_polys, 2, n_objects))
    all_col <- vector("list", n_objects)
    
    for(o in seq_len(n_objects)){
      
      object <- wsobjects[[o]]
      
      if(is.null(object) || anyNA(object$place)) next
      if(anyNA(object$col)) stop("Cannot render unpainted objects.")
      
      c_matrix_object <- c_matrix
      c_matrix_object[, 4] <- c_matrix[, 4] + object$place
      
      wspts <- object$pts
      wspts <- object$rotation %qMq% wspts
      wspts <- c_matrix_object %*% wspts
      wspts <- c_rotation %qMq% wspts
      
      wsnormals <- object$normals
      wsnormals <- object$rotation %qMq% wsnormals
      wsnormals <- c_rotation %qMq% wsnormals
      
      faces <- object$faces
      n_sides <- nrow(faces) - 1
      render_order <- order(wspts[3, faces[2, ]], decreasing = TRUE)
      wsfaces <- faces[, render_order, drop = FALSE]
      
      wspts_by_face <- wspts[-4, wsfaces[2, ], drop = FALSE]
      wsnormals_by_face <- wsnormals[, wsfaces[1, ], drop = FALSE]
      facing_camera <- colSums(wsnormals_by_face * wspts_by_face) < 0
      
      wspts_behind <- wspts[3, ] < 0
      behind <- matrix(wspts_behind[wsfaces[-1, ]], nrow = n_sides)
      behind <- colSums(behind, na.rm = TRUE)
      
      render <- facing_camera & !behind
      n_render <- sum(render)
      
      if(n_render < 2) next
      
      wspts <- t(p_matrix %*% wspts)
      wspts <- wspts[, c(1, 2)] / wspts[, 4]
      
      wsfaces <- wsfaces[, render]
      
      all_poly[seq_len(n_sides), seq_len(n_render), , o] <- wspts[wsfaces[-1, ], ]
      
      N <- wsnormals_by_face[, render]
      V_raw <- -wspts_by_face[, render]
      V <- sweep(V_raw, 2, sqrt(colSums(V_raw^2)), `/`, FALSE)
      
      col_0 <- object$col[wsfaces[1, ], ]
      
      col <- matrix(0, nrow(col_0), 3)
      for(wslight in wslights) col <- col + shade(col_0, wslight, N, V, V_raw)
      col <- col / length(wslights)
      all_col[[o]] <- rgb(col, maxColorValue = 255)
    }
    
    all_poly <- all_poly[, , , wsorder, drop = FALSE]
    all_x <- c(all_poly[, , 1, ])
    all_y <- c(all_poly[, , 2, ])
    all_col <- unlist(all_col[wsorder])
    
    plot.new()
    plot.window(xlim = xylim, ylim = xylim)
    polygon(all_x, all_y, col = all_col, border = NA)
    
    current_time <- Sys.time()
    while(current_time - previous_time <= 1/60) current_time <- Sys.time()
    previous_time <- current_time
  }
  
  dev.off()
  invisible(wsscene)
}
