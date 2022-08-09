#!/usr/bin/env Rscript

library("docopt")

"Usage: heatmap.R  [options]  INPUT RESULT LABEL
Options:
  -f --font=12  the font size [default: 7]
  -e --errorbar=<logic>  (T, F) [default: F]

Arguments:
   INPUT         the input matrix
   RESULT        the result filename
   LABEL         label" -> doc

opts  <- docopt(doc)

input    <- opts$INPUT
metadata <- opts$METADATA
output   <- opts$RESULT
label    <- opts$LABEL
font     <- as.integer(opts$f)

library(RColorBrewer)
library(pheatmap)

matrix   <- read.table(input,  header=T, check.names = FALSE, sep="\t", row.names = 1 ,comment.char = "")

pdf_w <-length(colnames(matrix))*25/155+5;
pdf_h <-length(rownames(matrix))/20+5;

p <- pheatmap(log10(100 * matrix + 0.0001), 
         color = colorRampPalette( brewer.pal(n = 9, name ="YlGnBu"))(100), 
         main=paste0("Level ", label, ": log10(Relative abundance)" , sep=""), 
         border_col="black",
         width    = pdf_w,
         height   = pdf_h,
         filename = output)


