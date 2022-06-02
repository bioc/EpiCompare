% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/translate_genome.R
\name{translate_genome}
\alias{translate_genome}
\title{Translate genome}
\usage{
translate_genome(
  genome,
  style = c("UCSC", "Ensembl", "NCBI"),
  omit_subversion = TRUE
)
}
\arguments{
\item{genome}{A character vector of genomes equivalent to UCSC version
    or Ensembl Assemblies}

\item{style}{A single value equivalent to "UCSC" or "Ensembl"
    specifying the output genome}

\item{omit_subversion}{Omit any subversion suffixes after the ".".}
}
\value{
Standardized genome build name as a character string.
}
\description{
Translate the name of a genome build from one format to another.
}
\examples{
genome <- translate_genome(genome="hg38", style="Ensembl")
}