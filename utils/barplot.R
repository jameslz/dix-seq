#!/usr/bin/env Rscript

library("docopt")

"Usage: barplot.R  [options]  INPUT  RESULT LABEL
Options:
  -f --font=12  the font size [default: 7]
Arguments:
   INPUT         the input matrix
   RESULT        the result filename
   LABEL         label" -> doc

   
opts  <- docopt(doc)

input <- opts$INPUT
output<- opts$RESULT
label <- opts$LABEL
font  <- as.integer(opts$f)

library(grid)
library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(viridis)

cols<-c("#ff0000","#0000ff","#f27304","#008000","#91278d","#ffff00","#7cecf4","#f49ac2","#5da09e","#6b440b")

matrix <- read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char="")
stack<-stack(matrix)

stack$taxon  <- rep(rownames(matrix), ncol(matrix))
stack$ind    <- factor(stack$ind, level = unique(stack$ind), ordered=TRUE)

pdf_w <-length(colnames(matrix))*45/155+8;
pdf_h <-length(rownames(matrix))/20+5;


p <- ggplot(stack, aes(x=ind, y=values, fill=taxon)) + 
     geom_bar(stat="identity", position="fill", width=0.7) + 
     theme_ipsum() +
     theme(text            = element_text(family="Times", face="plain", size = 12, colour="black" ),
         axis.text         = element_text(family="Times", face="plain"),
         axis.text.x       = element_text(family="Times", face="plain", angle =45, vjust =1, hjust=1),
         axis.text.y       = element_text(family="Times", face="plain", size = 12 ) , 
         axis.title        = element_text(family="Times", face="plain", size = 12),
         axis.title.x      = element_text(family="Times", face="plain", size = 12),
         axis.title.y      = element_text(family="Times", face="plain", size = 12),
         plot.title        = element_text(family="Times", face="plain"),
         legend.text       = element_text(family="Times", face="plain"),
         legend.title      = element_text(family="Times", face="plain"),
         legend.position   = "bottom") +
    labs(x="Specimens", y="Relative Abundance") +
    scale_y_continuous(expand = c(0, 0)) + 
	guides(guide_legend(reverse = T))+
	scale_fill_manual(values=cols, name = label)

ggsave(output, device = "pdf", width = ceiling(pdf_w), height = ceiling(pdf_h))
