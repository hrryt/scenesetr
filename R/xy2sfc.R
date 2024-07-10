xy2sfc <- function(x) {
  d = stars::st_dimensions(x)
  olddim = dim(x)
  r = attr(d, "raster")
  dxy = r$dimensions
  if (is.null(r) && all(dxy %in% names(d))) 
    stop("x and/or y not among dimensions")
  if (!any(is.na(dxy)))
    x = aperm(x, c(dxy, setdiff(names(d), dxy)))
  xy_pos = match(dxy, names(d))
  stopifnot(all(xy_pos == 1:2))
  keep = as.vector(!is.na(x$relief))
  sfc = sf::st_as_sfc(x, as_points = FALSE, which = which(keep))
  d[[dxy[1]]] = structure(list(
    from = 1, to = length(sfc), offset = NA, delta = NA,
    refsys = sf::st_crs(sfc), point = TRUE, values = sfc
  ), class = "dimension")
  names(d)[names(d) == dxy[1]] = "geometry"
  d[[dxy[2]]] = NULL
  attr(d, "raster") = structure(list(
    affine = rep(0, 2), dimensions = rep(NA_character_, 2),
    curvilinear = FALSE, blocksizes = NULL
  ), class = "stars_raster")
  x = unclass(x)
  for (i in seq_along(x)) dim(x[[i]]) = c(geometry = length(keep), 
                                          olddim[-xy_pos])
  args = rep(list(rlang::missing_arg()), length(dim(x[[1]])))
  args[[1]] = which(keep)
  args[["drop"]] = FALSE
  for (i in seq_along(x)) x[[i]] = structure(eval(rlang::expr(x[[i]][!!!args])), 
                                             levels = attr(x[[i]], "levels"))
  structure(x, dimensions = d, class = "stars")
}