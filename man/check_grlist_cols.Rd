% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_grlist_cols.R
\name{check_grlist_cols}
\alias{check_grlist_cols}
\title{Check \link[GenomicRanges]{GRanges} list columns}
\usage{
check_grlist_cols(grlist, target_cols)
}
\arguments{
\item{grlist}{Named list of \link[GenomicRanges]{GRanges} objects.}

\item{target_cols}{A character vector of column names to search for.}
}
\value{
Named list of \link[GenomicRanges]{GRanges} objects.
}
\description{
Check that at least one of the required columns is in 
a list of \link[GenomicRanges]{GRanges} objects.
Elements that do not meet this criterion will be dropped from the list.
}
\keyword{internal}
