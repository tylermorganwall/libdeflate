#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
fn <- args[[1]]
txt <- readLines(fn)
writeLines(txt, fn)
