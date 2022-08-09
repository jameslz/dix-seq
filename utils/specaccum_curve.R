#!/usr/bin/env Rscript

"Usage: specaccum_curve.R [options] INPUT RESULT
Options:
Arguments: 
   INPUT    the input file name
   RESULT   the output figure file name
   LABEL    the yaxis label name "->doc

library(docopt)
opts    <- docopt(doc)
input   <- opts$INPUT
output  <- opts$RESULT

library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(vegan)
library(viridis)

matrix   <- t(read.table(input, header=T, row.names=1, check.names = FALSE, sep="\t", comment.char = ""))
specaccum <- specaccum(matrix, "random")

perm <- as.data.frame( t(specaccum$perm) )
colnames(perm) <- rownames(matrix)
rownames(perm) <- 1:nrow(perm)

stack <- stack(perm)
colnames(stack) <- c('values', 'samples')

median <-vector()
for(i in 1:ncol(perm)){
    median[i] <- apply(perm, 2, median)[[i]][1]
}
line <- data.frame(x=1:ncol(perm), y=median)

median.quartile <- function(x){
    a <- quantile(x, probs = 0.75)
    b <- quantile(x, probs = 0.25)
    c <- a + 1.5*IQR(x)
    d <- b - 1.5*IQR(x)
    y <- x[x >= d & x<=c ]
    out <- range(a,b,y) 
    names(out) <- c("ymin","ymax")
    return(out) 
}

p <- ggplot(stack, aes(x=samples, y=values, colour=samples)) + 
     stat_summary(fun.data = median.quartile, geom = "errorbar", width=0.25, size=0.8, linetype=2) +
     geom_boxplot(width=0.5, notch = F, outlier.size = 3, size = 0.8,) + 
     scale_colour_viridis(discrete = TRUE, alpha=0.6) +
     geom_jitter(color="black", size=0.4, alpha=0.9) +
     geom_line(data = line, aes(x = x, y = y), colour  = "black") + 
     theme_ipsum() +
     theme(text         = element_text(family="Times", face="plain", size = 12),
           axis.title   = element_text(family="Times", face="plain", size = 12),
           axis.title.x = element_text(family="Times", face="plain", size = 9),
           axis.title.y = element_text(family="Times", face="plain", size = 9),
           axis.text    = element_text(family="Times", face="plain", size = 12),
           axis.text.x  = element_text(family="Times", face="plain", size = 12),
           axis.text.y  = element_text(family="Times", face="plain", size = 12),
           plot.title   = element_text(family="Times", face="plain", size = 12),
           legend.position="none" )+
    labs( title="Specaccum Curve", x="Samples", y='Number of OTUs')


unit <- ncol(perm);
pdf_w <-unit*50/155 + 7;
pdf_h <-unit/20 + 7;

ggsave(output, device = "pdf", width=pdf_w, height=pdf_h, limitsize = FALSE)
