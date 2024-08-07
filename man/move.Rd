% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/move.R
\name{move}
\alias{move}
\title{Move a Scene Element}
\usage{
move(x, translation)
}
\arguments{
\item{x}{scene element or scene. Camera (object of class "scenesetr_camera")
or light (object of class "scenesetr_light") or scene object (object of class
"scenesetr_obj") or scene (object of class "scenesetr_scene").}

\item{translation}{numeric vector or an R object containing \code{NA}.
3-D (x,y,z) coordinates.}
}
\value{
Scene element or scene with updated position.
}
\description{
Change the position of a scene element relative to its current position.
}
\details{
If \code{anyNA(translation)}, the scene element will be unplaced. Otherwise,
\code{translation} must be a numeric vector of length three specifying the change
in position along each of the basis axes (x,y,z).

If the scene element is already unplaced, \code{move()} will return the
element unmodified.

An unplaced element will not be rendered by \code{\link[=record]{record()}}.

If \code{x} is a scene, \code{move()} will be applied to every element in the scene.
}
\seealso{
\code{\link[=place]{place()}}, \code{\link[=position]{position()}}.
}
