#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("docopt"))

"Usage: heatmap_plot.R  [options]  PHYLUM  DISTANCE  GROUP  RESULT  LABEL
Options:
   -w --width=width    the width of viewport  [default: 12]
   -h --height=width   the height of viewport [default: 6]

Arguments:
   PHYLUM        phylum classifiction
   DISTANCE      distance matrix
   GROUP         group mapping file
   RESULT        the result names
   LABEL         Weigted or Unweigted" -> doc


opts  <- docopt(doc)

phylum   <- opts$PHYLUM
distance <- opts$DISTANCE
gfile    <- opts$GROUP
output   <- opts$RESULT
type     <- opts$LABEL

library(RColorBrewer)
library(colorspace)
library(dendextend)

cols<-c("black","#f44336","#03a9f4","#e91e63","#9c27b0","#673ab7","#3f51b5","#2196f3","#03a9f4","#00bcd4","#009688","#4caf50","#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800","#ff5722","#795548","#9e9e9e","#607d8b","#455a64","#e57373","#f06292","#ba68c8","#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac","#81c784","#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65","#bcaaa4","#eeeeee","#b0bec5","#ff5252","#e040fb","#7c4dff","#448aff","#18ffff","#69f0ae","#eeff41","#ffd740","#ff6e40")

x  <- read.table(distance, header=T, check.name=F, comment.char = "")
x1 <- as.dist(x)

y  <- read.table(phylum, header=T, check.name=F,comment.char = "")
y1 <- y[,-1]
rownames(y1)<-y[,1]
y2 <- data.matrix(y1)
sam_no<-length(colnames(y1))
taxo_no<-length(rownames(y1))
Hmark<-max(taxo_no,sam_no)
Wmark<-max(taxo_no,sam_no)
pdf_h <-Hmark*10/155+5
pdf_w <-Wmark/10+7

groups<-read.table(gfile, header=F, check.name=F, comment.char = "")
groups<-groups[,c(1,2)]
colnames(groups)<-c("sample","group")
if(length(levels(factor(groups$group)))==length(groups$sample)){
   groups$group<-as.factor(c(rep("no_group",length(groups$sample))))
}

groups$group <- as.factor(groups$group)
group <- levels( groups$group )

rownames(groups) <- groups$sample

hc1    <- hclust(x1,"ave")
dendro <- as.dendrogram(hc1)

size = length(levels(as.factor(groups$group)));

labels_colors(dendro) <-cols[1 : size][sort_levels_values(as.numeric(groups$group)[order.dendrogram(dendro)])]

n  <- hc1$order
m  <- colnames(x)[c(hc1$order)]
g  <-matrix(ncol=ncol(y2), nrow=nrow(y2))

for(i in 1:ncol(y2))
  g[,i]<-y2[,n[i]]

colnames(g) <- m
rownames(g) <- rownames(y1)

pdf(output, width=pdf_w, height=pdf_h )

layout(matrix(c(1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3), nrow = 1))

par(mar=c(3, 1, 2, 3), cex = 0.7,font=2,lwd=1.2)
plot(dendro, horiz=T,axes=T, main=paste(type , "tree", sep=" "),nodePar = list(cex = 0.7))

par(mar=c(3, 1,2, 1), cex = 0.7)
barplot(g,col=cols[2:(nrow(y2)+1)],horiz=T,axisnames=F,axes=T, main="Taxonomy:Phylum",border = NA )

par(mar=c(3, 0, 2, 1), cex = 1)
plot(1:3, rnorm(3), pch = 1, lty = 1, ylim=c(-2, 2), type = "n", axes = FALSE, ann = FALSE)

legend(1, 2, legend=rownames(y2), bty="n", fill=cols[2:(nrow(y2)+1)])

dev.off()
