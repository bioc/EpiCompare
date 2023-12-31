% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_workers.R
\name{check_workers}
\alias{check_workers}
\title{Check workers}
\usage{
check_workers(workers = NULL)
}
\arguments{
\item{workers}{Number of cores to parallelise across 
(in applicable functions).
If \code{NULL}, will set to the total number of available cores minus 1.}
}
\value{
Integer
}
\description{
Assign parallel worker cores.
}
\examples{
workers <- check_workers()
}
