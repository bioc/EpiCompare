% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/report_command.R
\name{report_command}
\alias{report_command}
\title{Report command}
\usage{
report_command(params, peaklist_tidy, reference_tidy)
}
\arguments{
\item{params}{Parameters supplied to the Rmarkdown template.}

\item{peaklist_tidy}{Post-processed target peaks.}

\item{reference_tidy}{Post-processed reference peaks.}
}
\value{
String reconstructing R function call.
}
\description{
Reconstruct the \link[EpiCompare]{EpiCompare} command 
used to generate the current Rmarkdown report.
}
\examples{
# report_command()
}
