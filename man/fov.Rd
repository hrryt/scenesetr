% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fov.R
\name{fov}
\alias{fov}
\alias{fov<-}
\alias{set_fov}
\title{The Field of View of a Camera}
\usage{
fov(x)

fov(x) <- value

set_fov(x, value)
}
\arguments{
\item{x}{camera (object of class "scenesetr_camera")}

\item{value}{numeric replacement value}
}
\value{
For \code{fov(x)}, the field of view as a double.

For \code{fov(x) <- value}, and \code{set_fov(x, value)}, the updated camera.
(Note that the value of
\code{fov(x) <- value} is that of the assignment, \code{value}, not the return
value from the left-hand side.)
}
\description{
Functions to get or set the field of view of a camera.
}
\details{
\code{fov(x)} returns the field of view of a camera in degrees.

\code{fov(x) <- value} assigns a value to the field of view of a camera.

\code{set_fov} is an alias of \verb{fov<-} useful in pipes.

By default, \code{\link[=camera]{camera()}} generates a camera with a sixty degree field of view.

The field of view of a camera in a scene is used by \code{\link[=record]{record()}} in configuring
the perspective of the rendered frames from the viewpoint of the camera.
}
