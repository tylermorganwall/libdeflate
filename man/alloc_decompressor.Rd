% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{alloc_decompressor}
\alias{alloc_decompressor}
\title{Allocate a libdeflate decompressor}
\usage{
alloc_decompressor()
}
\value{
An external pointer (`externalptr`) to a libdeflate decompressor.
}
\description{
Create a new libdeflate decompressor for raw DEFLATE streams.
}
\examples{
dcmp = alloc_decompressor()
stopifnot(inherits(dcmp, "externalptr"))
}
