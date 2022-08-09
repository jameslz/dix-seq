#!/usr/bin/env Rscript

"Usage: anosim.R [options] INPUT OUTPUT LABEL TEXT
Options:
Arguments:
  INPUT    the name of input file
  OUTPUT   the name of output file
  LABEL    label for signif
  TEXT     text description for signif values"->doc

library("docopt")
opts    <- docopt(doc)
input   <- opts$INPUT
output  <- opts$OUTPUT
label   <- opts$LABEL
text    <- opts$TEXT


library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(kableExtra)
library("vegan")
library(viridis)

matrix    <- read.table(input, header=T, row.names=1, check.names = FALSE, sep="\t", comment.char = "")

levels    <- gsub(pattern="^.+?__", replacement="", colnames(matrix), perl=TRUE)
group     <- ordered(levels, level=unique(levels))
anosim    <- anosim(matrix, group)

dist      <- data.frame(values = anosim$dis.rank, group = anosim$class.vec)

pval <- NULL
if (anosim$permutations) {
     pval <- format.pval(anosim$signif)
} else {
     pval <- "not assessed"
}

stats <- paste( label, ": R = ", round(anosim$statistic, 3), "," , " P = ", pval, sep="")

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

p <- ggplot(dist, aes(x=group, y=values, fill=group)) + 
     stat_summary(fun.data = median.quartile, geom = "errorbar", width=0.25, size=0.8, linetype=2) +
     geom_boxplot(width=0.5, notch = F, outlier.size = 3, size = 0.8,) + 
     scale_fill_viridis(discrete = TRUE, alpha = 1) +
     geom_jitter(color="black", size=0.4, alpha=0.9) +
     theme_ipsum() +
     theme(text         = element_text(family="Times", face="plain", size = 12),
           axis.title.x = element_text(family="Times", face="plain", size = 14),
           axis.title.y = element_blank(),
           axis.title   = element_text(family="Times", face="plain", size = 12),
           axis.text    = element_text(family="Times", face="plain", size = 12),
           plot.title   = element_text(family="Times", face="plain", size = 14),
           legend.position='none')+
    labs( title=stats)

unit <- ncol(matrix);
pdf_w <-unit*30/155 + 5;
pdf_h <-unit/20 + 5;

ggsave(paste(output, '.pdf', sep=''), device = "pdf", width=pdf_w, height=pdf_h)

signif <- paste(text, label , format.pval(anosim$signif), round(anosim$statistic, 3), sep='\t');
write(signif, paste(output, '.signif', sep=''))
