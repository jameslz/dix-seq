#!/usr/bin/env Rscript

library("docopt")

"Usage: Violin INPUT METADATA RESULT LABEL

Arguments:
   INPUT         the input matrix
   METADATA      the group catalog file.
   RESULT        the result filename
   LABEL         label" -> doc
 
opts     <- docopt(doc)

input    <- opts$INPUT
metadata <- opts$METADATA
output   <- opts$RESULT
label    <- opts$LABEL

library(ggstatsplot)
library(palmerpenguins)
library(tidyverse)

matrix <- read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char="")
stack  <- stack(matrix)

catalog <- read.table(metadata, header = F, sep="\t",comment.char="", check.names=F, stringsAsFactors=F, skip = 1, colClasses = "character")
colnames(catalog) <- c("sample","group")

stack$taxon  <- rep(rownames(matrix), length( rownames(catalog) ))
stack$group  <- rep(catalog$group,  each = length( rownames(matrix) ))
stack$group  <- as.factor(rep(catalog$group,  each = length( rownames(matrix) )))

p <- ggbetweenstats(
         data = stack,
         x = group,
         y = values,
         type = "nonparametric",
         title = label,
         plot.type = 'violin'
) 

ggsave(output, device = "pdf")