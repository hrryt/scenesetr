shade <- function(original_col, wslight, N, V, V_raw){
  
  shade <- original_col %*% diag(wslight$col)
  
  place <- wslight$place
  rotation <- wslight$rotation
  
  no_place <- anyNA(place)
  no_rotation <- anyNA(rotation)
  
  if(no_place & no_rotation) return(shade)
  
  direction <- rotation %qpq% c(0,0,-1)
  
  if(no_place) L <- direction else {
    L <- V_raw + place
    L <- sweep(L, 2, sqrt(colSums(L^2)), `/`, FALSE)
  }
  
  N_dot_L <- colSums(N * L)
  
  NNL <- t(t(N) * N_dot_L)
  R <- 2 * NNL - L
  R_dot_V <- colSums(R * V)
  
  N_dot_L[N_dot_L < 0] <- 0
  R_dot_V[R_dot_V < 0] <- 0
  
  both_dots <- (N_dot_L + R_dot_V) / 2
  shade <- shade * both_dots
  
  if(!no_place & !no_rotation){
    S_dot_L <- colSums(direction * L)
    shade[S_dot_L < 0.8, ] <- 0
  }
  
  shade
}
