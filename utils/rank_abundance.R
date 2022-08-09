#!/usr/bin/env Rscript

library("docopt")

"Usage: rank_abundance.R  [options]  INPUT RESULT
Options:
Arguments:
   INPUT         The input matrix
   RESULT        The result filename"-> doc

opts  <- docopt(doc)

input <- opts$INPUT
output<- opts$RESULT

library(Cairo)
library(tidyverse)
library(hrbrthemes)

matrix   <- read.table(input, header=T, row.names=1, check.names = FALSE, sep="\t", comment.char = "")
matrix   <- as.data.frame(apply(matrix, 2, sort, decreasing=T))
stack    <- stack(log10( matrix + 1))

colnames(stack) <- c('values', 'samples')
stack$position  <- as.numeric( rep(rownames(matrix), ncol(matrix) ))

cols<- rep( c("#f44336","#2196f3","#e91e63","#9c27b0","#673ab7","#3f51b5","#03a9f4","#00bcd4","#009688","#4caf50",
              "#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800","#ff5722","#795548","#9e9e9e","#607d8b","#455a64",
              "#e57373","#f06292","#ba68c8","#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac","#81c784",
              "#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65","#bcaaa4","#eeeeee","#b0bec5","#ff5252",
              "#e040fb","#7c4dff","#448aff","#18ffff","#69f0ae","#eeff41","#ffd740","#ff6e40"), times=100)
step_cols = rep_len(cols, length(colnames(matrix)))

ncol = ceiling(length(colnames(matrix))/9)

p <- ggplot(stack, aes(x=position, y = values)) +
     geom_step(aes(colour=samples, group = samples )) +
     theme_ipsum() +
     theme(text         = element_text(family="Times", face="plain", size = 12),
           axis.title.x = element_text(family="Times", face="plain", size = 12),
           axis.title.y = element_text(family="Times", face="plain", size = 12),
           axis.title   = element_text(size = 12),
           axis.text    = element_text(family="Times", face="plain", size = 12),
           plot.title   = element_text(family="Times", face="plain", size = 12),
           legend.text  = element_text(family="Times", face="plain", size = 9),
           legend.position="bottom" )+
    xlim(0, 900) +
    scale_colour_manual(values=cols, guide = guide_legend(nrow = ncol, title.position="top"))+
    labs( title="Rank Abundance", x="rank", y='log10(reads)')

ggsave(output, device = "pdf", limitsize = FALSE)
