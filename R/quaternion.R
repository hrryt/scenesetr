quaternion_pi <- function(axis, angle){
  c(cospi(angle), axis * sinpi(angle))
}

quaternion <- function(axis, angle){
  c(cos(angle), axis * sin(angle))
}

normalise <- function(x){
  x / sqrt(sum(x^2))
}

roll <- function(q){
  q %q% conjugate(dir2q(q %qpq% c(0,0,1)))
}

`%to%` <- function(v1, v2){
  normalise(c(
    1 + sum(v1 * v2),
    v1[2]*v2[3] - v1[3]*v2[2],
    v1[3]*v2[1] - v1[1]*v2[3],
    v1[1]*v2[2] - v1[2]*v2[1]
  ))
}

dir2q <- function(dir){
  if(anyNA(dir)) return(NA_real_)
  if(sum(dir) == 0) return(c(1,0,0,0))
  dir <- normalise(dir)
  yaw <- quaternion(c(0,1,0), atan2(dir[1], dir[3]) / 2)
  yawed <- yaw %qpq% c(0,0,1)
  pitch <- atan2(dir[2], sqrt(sum(dir[-2]^2))) / 2
  pitch <- quaternion(c(-yawed[3],0,yawed[1]), pitch)
  pitch %q% yaw
}

`%q%` <- function(q1, q2){
  c(q1[1]*q2[1] - q1[2]*q2[2] - q1[3]*q2[3] - q1[4]*q2[4],
    q1[1]*q2[2] + q1[2]*q2[1] + q1[3]*q2[4] - q1[4]*q2[3],
    q1[1]*q2[3] - q1[2]*q2[4] + q1[3]*q2[1] + q1[4]*q2[2],
    q1[1]*q2[4] + q1[2]*q2[3] - q1[3]*q2[2] + q1[4]*q2[1])
}

`%qpq%` <- function(q, p){
  (q %q% c(0, p) %q% conjugate(q))[-1]
}

conjugate <- function(q){
  q[-1] <- -q[-1]
  q
}

`%qcrossM%` <- function(q, M){
  matrix(byrow = TRUE, nrow = 3, c(
    q[3]*M[3, ] - q[4]*M[2, ],
    q[4]*M[1, ] - q[2]*M[3, ],
    q[2]*M[2, ] - q[3]*M[1, ]
  ))
}

`%qMq%` <- function(q, M){
  t <- 2 * q %qcrossM% M
  M[-4, ] <- M[-4, ] + q[1] * t + q %qcrossM% t
  M
}
