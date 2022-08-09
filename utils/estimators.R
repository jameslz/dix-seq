#!/usr/bin/env Rscript

"Usage: estimators.R [options] INPUT RESULT LABEL
Options:
  -w --width=7  the width of output pdf fiel    [default: 7]
  -h --height=7 the height of output pdf file   [default: 7]
Arguments: 
   INPUT    the input file name
   RESULT   the output figure file name
   LABEL    the yaxis label name "->doc

library(docopt)
opts    <- docopt(doc)
input   <- opts$INPUT
output  <- opts$RESULT
label   <- opts$LABEL

height  <- as.integer(opts$h)
width   <- as.integer(opts$w)

library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(viridis)

dt  <- read.table(input, header=F, sep="\t", colClasses = 'character', stringsAsFactors=F, comment.char = "", row.names=1)
dt  <- as.data.frame.matrix(t(dt))

rownames(dt) <-NULL
colnames(dt) <- c("group", "xval", "yval")
dt$group     <- factor(dt$group, level=unique(dt$group))

dt$xval <-as.character(dt$xval)
dt$yval <-as.character(dt$yval)
dt$yval <-as.numeric(dt$yval)

median.quartile <- function(x){
    
    a <- quantile(x, probs = 0.75)
    b <- quantile(x, probs = 0.25)
    c <- a + 1.5*IQR(x)
    d <- b - 1.5*IQR(x)
    y <- x[x >= d & x<=c ]
    out <- range(a, b, y) 
    names(out) <- c("ymin","ymax")
    return(out) 

}

q <- ggplot(data=dt, aes(x = group, y = yval, fill = group)) + 
   stat_summary(fun.data = median.quartile, geom = "errorbar", width=0.25, size=0.8, linetype=2) +
   geom_boxplot(width=0.5, notch = F, outlier.size = 3, size = 0.8) + 
   scale_fill_viridis(discrete = TRUE, alpha=0.6) +
   geom_jitter(color="black", size=0.4, alpha=0.9) +
   theme_ipsum() +
   theme(text              = element_text(family="Times", face="plain", size = 18, colour="black" ),
         axis.text.x       = element_text(family="Times", face="plain", angle =45, vjust =1, hjust=1),
         axis.text.y       = element_text(family="Times", face="plain", size = 18 ) , 
         axis.title.x      = element_text(family="Times", face="plain", size = 12),
         axis.title.y      = element_text(family="Times", face="plain", size = 12),
         legend.position   = "none") +
  xlab("") +
  ylab(paste(label, " estimators", sep=""))

ggsave(output, device = "pdf", width=width, height=height)
