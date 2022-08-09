#!/usr/bin/env Rscript

library("docopt")

"Usage: stat.R  [options]  INPUT METADATA RESULT LABEL
Options:
  -f --font=12  the font size [default: 7]
  -e --errorbar=<logic>  (T, F) [default: F]

Arguments:
   INPUT         the input matrix
   METADATA      the group catalog file.
   RESULT        the result filename
   LABEL         label" -> doc

opts  <- docopt(doc)

input    <- opts$INPUT
metadata <- opts$METADATA
output   <- opts$RESULT
label    <- opts$LABEL
font     <- as.integer(opts$f)

library(grid)
library(ggplot2)
library(Rmisc) 
library(plyr)

cols<-c("#ff0000","#0000ff","#f27304","#008000","#91278d","#ffff00","#7cecf4","#f49ac2","#5da09e","#6b440b")

matrix   <- read.table(input, header=T, row.names=1, check.names = FALSE, sep="\t", comment.char = "")
stack<-stack(matrix)

catalog <- read.table(metadata, header = F, sep="	",comment.char="", check.names=F, stringsAsFactors=F)
colnames(catalog)<-c("sample","group")

stack$taxon  <- rep(rownames(matrix), length( rownames(catalog) ))
stack$group  <- rep(catalog$group,  each = length( rownames(matrix) ))
stack$group  <- as.factor(rep(catalog$group,  each = length( rownames(matrix) )))

stats <- summarySE(stack, measurevar="values",groupvars=c("taxon", "group"), na.rm = TRUE)
revcumsum <- function(x) rev(cumsum(rev(x)))
stats <- within(stats, cumsum <- ave(values, group, FUN=revcumsum))

unit <- length(unique(catalog$group))

pdf_w <-length(colnames(matrix))*45/155+8;
pdf_h <-length(rownames(matrix))/20+5;

p<- ggplot(stats, aes(x=group, y=values, fill= factor(taxon, level = unique(taxon)) )) +
    geom_bar(stat="identity", width=0.7) +
    theme_bw() + 
    theme( text         = element_text(family="Times", face="plain", size = 12, colour = "black" ),
           axis.text    = element_text(colour = "black" ),
           axis.text.y  = element_text(size = 12), 
           legend.text  = element_text(size = 12),
           legend.position="bottom",
           legend.title = element_text(size = 12),
           axis.title   = element_text(size = 12 ),
           axis.text.x  = element_text(size = font, angle=75, vjust=1, hjust=1 )) +
    labs(x="Specimens", y="Relative Abundance") +
    scale_y_continuous(expand = c(0, 0)) + 
	guides(guide_legend(reverse = T))+
	scale_fill_manual(values=cols, name = label)

if(as.logical(opts$e)){
    
    p <- p + geom_errorbar( aes(ymin=cumsum-se, ymax=cumsum + se), size=0.2,   
                       width=.12)
}

ggsave(output, device = "pdf", width = ceiling(pdf_w), height = ceiling(pdf_h))
