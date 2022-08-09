#!/usr/bin/env Rscript

"Usage: Volcano [options] INPUT CASE  CONTROL OUTPUT QVAL FDC
Options:
   -t --text=F          label point.      [default: F]
   -w --width=width     the width of viewport [default:  9] 
   -h --height=width    the height of viewport [default: 7]
Arguments:
   INPUT   the input file name
   CASE    case condition
   CONTROL control condition
   OUTPUT  the output file name
   QVAL    label the qvalue.
   FDC     label the |log2foldchange|.
   "->doc

library(docopt)

opts    <- docopt(doc)
case    <- as.character(opts$CASE)
control <- as.character(opts$CONTROL)
output  <- opts$OUTPUT
qval    <- as.numeric(opts$QVAL)
fold    <- as.numeric(opts$FDC)

library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(vegan)
library(viridis)
library(ggplot2)
library(ggrepel)

dt  <- read.table(opts$INPUT, header=TRUE, sep="\t", check.name=F, quote="", comment.char="", stringsAsFactors=F,  fill=TRUE)

dt <-dt %>%
     mutate(ID=replace(ID, regulation=='Not DA', NA)) %>%
     as.data.frame()

p <-  ggplot(dt, aes(x  =log2FoldChange, y = -log10(padj), colour=regulation)) +
      geom_point(size = 3.5, alpha=0.5) +
      geom_hline(yintercept=-log10(qval),
                 linetype=4, 
                 color = 'black', 
                 size = 0.25) +
      geom_vline(xintercept=c(-fold, fold),
                 linetype=4, 
                 color = 'black', 
                 size = 0.25) +
      theme_classic() +
      theme( text                 = element_text(family="Times", face="plain", size = 12, colour="black" ),
             axis.text            = element_text(family="Times", face="plain"),
             axis.text.x          = element_text(family="Times", face="plain"),
             axis.text.y          = element_text(family="Times", face="plain", size = 12 ) , 
             axis.title           = element_text(family="Times", face="plain", size = 12),
             axis.title.x         = element_text(family="Times", face="bold",  size = 18),
             axis.title.y         = element_text(family="Times", face="bold",  size = 18),
             plot.title           = element_text(family="Times", face="plain"),
             legend.text          = element_text(family="Times", face="plain"),
             legend.title         = element_text(family="Times", face="plain"),
             legend.position      = c(1, 1),
             legend.justification = c(1, 1)) +
      scale_x_continuous(limits = c(-30,30), breaks = seq(-30, 30, 2), labels = seq(-30, 30, 2)) +
      scale_color_manual(name=bquote(paste(FDR <= .(qval) , " and " ,  '|log2ratio| >=', .(fold) ) ),
                breaks= c("Up", "Down", "Not DA"),
                values = c("Up" = "red", "Down" = "green", "Not DE" = "grey"), 
                labels = c("Up-DA", "Down-DA", "Not DA")) +
      labs(x= "log2FoldChange", y= "-log10(padj)") +
      ggtitle(paste( case, control, sep = " vs. "))

if(as.logical(opts$t)){
    p <-p + geom_text_repel(data=dt, 
                              aes(x=log2FoldChange, y=-log10(padj), label=ID), 
                              hjust=0.5, 
                              vjust=0.5, 
                              size=2,
                              show.legend = F)
}

ggsave(output, device = "pdf", width=as.numeric(opts$w), height=as.numeric(opts$h))