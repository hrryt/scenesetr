make_plots <- function(scene, render_order, interactive, key_inputs, device, width, lwd, ...){
  
  camera_index <- sapply(scene, inherits, "scenesetr_camera")
  stopifnot(
    "OS type must be windows for keyboard input" = .Platform$OS.type == "windows",
    "number of cameras in scene must be one" = sum(camera_index) == 1
  )
  obj_index <- sapply(scene, inherits, "scenesetr_obj")
  light_index <- sapply(scene, inherits, "scenesetr_light")
  
  camera <- scene[camera_index][[1]]
  objects <- scene[obj_index]
  lights  <- scene[light_index]
  n_objects <- sum(obj_index)
  n_lights  <- sum(light_index)
  n_scene   <- length(scene)
  no_objects <- n_objects == 0
  
  which_object <- double(n_scene)
  which_object[obj_index] <- seq_len(sum(obj_index))
  
  calculate_wsorder <- is.null(render_order)
  wsorder <- render_order
  
  wsplaces <- matrix(double(), 4, n_objects)
  if(!no_objects){
    max_sides <- max(sapply(objects, \(object) nrow(object$faces)))
    max_polys <- max(sapply(objects, \(object) ncol(object$faces)))
    midpts <- sapply(objects, \(object) rowMeans(object$pts))
    midpts[4, ] <- 0
  }
  
  xylim <- c(-1.5, 1.5)
  c_matrix <- diag(4)
  f <- 1 / tanpi(camera$fov / 360)
  asp <- 1 / camera$aspect
  p_matrix <- matrix(nrow = 4, byrow = TRUE, c(
    f * asp,0,0,0,0,f,0,0,0,0,-1,-2,0,0,1,0
  ))
  wsscene <- scene
  flag <- TRUE
  quit_device <- FALSE
  restart <- FALSE
  action_flag <- FALSE
  keys <- NULL
  frame <- 0
  
  height <- width * asp
  if(interactive) GetKeyboard()
  if(identical(device, grDevices::dev.new))
    device(width = width, height = height, noRStudioGD = TRUE, ...) else
      device(width = width, height = width * asp, ...)
  par(mar = c(0,0,0,0), bg = 1)
  previous_time <- Sys.time()
  
  while(flag){
    
    # frame limit
    current_time <- Sys.time()
    while(current_time - previous_time <= 1/60) current_time <- Sys.time()
    previous_time <- current_time
    
    # key events
    frame <- frame + 1
    last_keys <- keys
    if(interactive){
      keys <- translate(GetKeyboard())
      key_inputs[[frame]] <- keys
    } else keys <- key_inputs[[frame]]
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
          last_keys = last_keys,
          frame = frame
        )
        quit_device <- identical(wselement, 0)
        restart <- identical(wselement, 1)
        action_flag <- quit_device || restart
        if(action_flag) break
      }
      if(action_flag) break
      wsscene[[e]] <- wselement
      wsplaces[, which_object[e]] <- wselement$place
    }
    if(quit_device) break
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
    if(calculate_wsorder){
      wsmidpts <- c_matrix %*% (midpts + wsplaces)
      wsmidpts <- c_rotation %qMq% wsmidpts
      wsorder <- order(wsmidpts[3, ], decreasing = TRUE)
    }
    
    # plot objects
    all_poly <- array(double(), c(max_sides, max_polys, 2, n_objects))
    all_col <- vector("list", n_objects)
    all_border <- vector("list", n_objects)
    
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
      
      faces <- object$faces
      n_sides <- nrow(faces) - 1
      render_order <- order(wspts[3, faces[2, ]], decreasing = TRUE)
      wsfaces <- faces[, render_order, drop = FALSE]
      
      wspts_by_face <- wspts[-4, wsfaces[2, ], drop = FALSE]
      
      wsnormals <- object$normals
      has_normals <- !identical(wsnormals, NA_real_)
      
      if(has_normals){
        wsnormals <- object$rotation %qMq% wsnormals
        wsnormals <- c_rotation %qMq% wsnormals
        
        wsnormals_by_face <- wsnormals[, wsfaces[1, ], drop = FALSE]
        facing_camera <- colSums(wsnormals_by_face * wspts_by_face) < 0
      } else facing_camera <- TRUE
      
      wspts_behind <- wspts[3, ] < 0
      behind <- matrix(wspts_behind[wsfaces[-1, ]], nrow = n_sides)
      behind <- colSums(behind, na.rm = TRUE)
      
      render <- facing_camera & !behind
      n_render <- sum(render)
      
      if(n_render == 0) next
      
      wspts <- t(p_matrix %*% wspts)
      wspts <- wspts[, c(1, 2), drop = FALSE] / wspts[, 4]
      
      wsfaces <- wsfaces[, render, drop = FALSE]
      all_poly[seq_len(n_sides), seq_len(n_render), , o] <- wspts[wsfaces[-1, ], ]
      
      if(has_normals){
        N <- wsnormals_by_face[, render, drop = FALSE]
        V_raw <- -wspts_by_face[, render, drop = FALSE]
        V <- sweep(V_raw, 2, sqrt(colSums(V_raw^2)), `/`, FALSE)
        
        col_index <- if(nrow(object$col) == 1) rep(1, n_render) else wsfaces[1, ]
        col_0 <- object$col[col_index, , drop = FALSE]
        col <- matrix(0, nrow(col_0), 3)
        for(wslight in wslights) col <- col + shade(col_0[, -4], wslight, N, V, V_raw)
        # col <- col / length(wslights)
        col[col > 255] <- 255
        all_col[[o]] <- rgb(col, alpha = col_0[, 4], maxColorValue = 255)
      } else all_col[[o]] <- rep(NA, n_render)
      
      border <- object$border
      border <- if(length(border) == 1) rep(border, n_render) else border[wsfaces[1, ]]
      all_border[[o]] <- border
    }
    
    all_poly <- all_poly[, , , wsorder, drop = FALSE]
    all_x <- as.vector(all_poly[, , 1, ])
    all_y <- as.vector(all_poly[, , 2, ])
    all_col <- unlist(all_col[wsorder])
    all_border <- unlist(all_border[wsorder])
    
    plot.new()
    plot.window(xlim = xylim, ylim = xylim)
    polygon(x = all_x, y = all_y, col = all_col, border = all_border, lwd = lwd)
  }
  
  dev.off()
  out <- list(
    initial_scene = scene,
    final_scene = wsscene,
    key_inputs = key_inputs
  )
  class(out) <- "scenesetr_recording"
  invisible(out)
}