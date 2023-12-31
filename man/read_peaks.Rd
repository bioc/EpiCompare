% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_peaks.R
\name{read_peaks}
\alias{read_peaks}
\title{Read peaks}
\usage{
read_peaks(path, type, verbose = TRUE)
}
\arguments{
\item{path}{Path to peak file.}

\item{type}{File type to search for. Options include:
\itemize{
\item{"<pattern>"}{Finds files matching an arbitrary regex pattern
specified by user.}
\item{"peaks.stringent"}{Finds files ending in "*.stringent.bed$"}
\item{"peaks.consensus"}{Finds files ending in "*.consensus.peaks.bed$"}
\item{"peaks.consensus.filtered"}{
Finds files ending in"*.consensus.peaks.filtered.awk.bed$"}
\item{"picard"}{Finds files ending in
"*.target.markdup.MarkDuplicates.metrics.txt$"}
}}

\item{verbose}{Print messages.}
}
\value{
\link[GenomicRanges]{GRanges}
}
\description{
Read peak files.
}
\keyword{internal}
