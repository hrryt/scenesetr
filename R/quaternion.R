quaternion_pi <- function(axis, angle) {
  c(cospi(angle), axis * sinpi(angle))
}

quaternion <- function(axis, angle) {
  c(cos(angle), axis * sin(angle))
}

normalise <- function(x) {
  x / sqrt(sum(x^2))
}

roll <- function(q) {
  q %q% conjugate(dir2q(q2dir(q)))
}

`%to%` <- function(v1, v2) {
  normalise(c(
    1 + sum(v1 * v2),
    v1[2]*v2[3] - v1[3]*v2[2],
    v1[3]*v2[1] - v1[1]*v2[3],
    v1[1]*v2[2] - v1[2]*v2[1]
  ))
}

dir2q <- function(dir) {
  if(anyNA(dir)) return(NA_real_)
  if(sum(dir) == 0) return(c(1,0,0,0))
  dir <- normalise(dir)
  yaw <- quaternion(c(0,1,0), atan2(dir[1], dir[3]) / 2)
  yawed <- q2dir(yaw)
  pitch <- atan2(dir[2], sqrt(sum(dir[-2]^2))) / 2
  pitch <- quaternion(c(-yawed[3],0,yawed[1]), pitch)
  pitch %q% yaw
}

`%q%` <- function(q1, q2) {
  c(q1[1]*q2[1] - q1[2]*q2[2] - q1[3]*q2[3] - q1[4]*q2[4],
    q1[1]*q2[2] + q1[2]*q2[1] + q1[3]*q2[4] - q1[4]*q2[3],
    q1[1]*q2[3] - q1[2]*q2[4] + q1[3]*q2[1] + q1[4]*q2[2],
    q1[1]*q2[4] + q1[2]*q2[3] - q1[3]*q2[2] + q1[4]*q2[1])
}

conjugate <- function(q) {
  q[-1] <- -q[-1]
  q
}

`%qcross%` <- function(q, p) {
  c(q[3]*p[3] - q[4]*p[2],
    q[4]*p[1] - q[2]*p[3],
    q[2]*p[2] - q[3]*p[1])
}

`%rot%` <- function(q, p) {
  t <- 2 * q %qcross% p
  p + q[1] * t + q %qcross% t
}

q2dir <- function(q) {
  q %rot% c(0,0,1)
}
