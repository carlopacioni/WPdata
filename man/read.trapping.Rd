% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/main.R
\name{read.trapping}
\alias{read.trapping}
\title{Read trapping data}
\usage{
read.trapping(dir.in = NULL, nfile = "Woodland Reserve Fauna Data.xlsx",
  sheet = "DB", last.row = 0)
}
\arguments{
\item{dir.in}{The path to the folder where the data file is located}

\item{nfile}{The name of the (excel) data file}

\item{sheet}{The name of the sheet to be imported}

\item{last.row}{An integer with the number of the last row to be imported. If
zero (default), the last row is determined automatically}
}
\description{
\code{read.trapping} reads data from an excel file and returns a
\code{data.frame} after having conducted basic quality checks
}
\details{
Default file name is "Woodland Reserve Fauna Data.xlsx", but this can be set
to NULL and an interactive window will open to browse to the file. In this
case, \code{dir.in} is taken from the path of the file selected.

If \code{dir.in} is NULL and \code{nfile} is provided, then an interactive
window is opened to select the path to \code{nfile}.

If \code{last.row} is left to default (0), a warning is reported. This is
because currently the excel file uses several formula to validate/obtain data
from the IDs list. If validated fields/formula are present in the last lines
(even if no data is actually inserted) these are read as non-empty rows in R
and filled with NA, potentially causing problem for downstream analyses.
}
