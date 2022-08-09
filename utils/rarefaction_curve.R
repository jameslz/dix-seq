#!/usr/bin/env Rscript

library("docopt")

"Usage: rarefaction_curve.R  [options]  INPUT METADATA RESULT LABEL
Options:
   -s --step=1000   the label step size  [default: 1000]
   -t --text=F    label point.     [default: F]
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
step_val <- as.numeric(opts$s)

library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(viridis)
library(ggrepel)
library(plyr)

data.table <- as.data.frame(t(read.table(input, head = F, row.names=1, sep="\t", check.names=1, quote = "", comment.char="", fill=TRUE)))
data.table <- data.table %>% select(-"repeat")
data.table <- rbind( rep(0, each=ncol(data.table) + 1) , data.table)

catalog <- read.table(metadata, header = F, sep="\t", comment.char="", check.names=F, stringsAsFactors=F)
colnames(catalog)<-c("sample","group")

repel <- function(data.table){
     
     data<- data.frame( t(sapply( 2 : ncol(data.table), function(t){
                                                                len <- length( na.omit(data.table[, t]) )
                                                                c(data.table[len, 1], data.table[len, t])
                                                               })))

     colnames(data) <- c("ind", "values")
     data$values    <- as.numeric(as.vector(data$values))
     data$sample    <- catalog$sample
     data$group    <- catalog$group
     data

}

repel_label <- repel(data.table)

data.table$depth <- factor(as.numeric(as.vector(data.table$depth)))

stack <- stack(data.table)
colnames(stack) <- c("values", "sample")
stack$ind   <- as.integer(as.vector(rep(data.table$depth, nrow(catalog))))
stack$group <- rep(catalog$group, each=nrow(data.table))

stats <- ddply(stack, c("ind","sample", "group"), 
                      summarise,
                      values = median(values, na.rm = TRUE))

step_1k  <-  as.integer(max(stack$ind) / step_val)
step     <-  as.integer(step_1k/ 6)
step_size<-  step * step_val


cols<- rep( c("#f44336","#2196f3","#e91e63","#9c27b0","#673ab7","#3f51b5","#03a9f4","#00bcd4","#009688","#4caf50",
              "#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800","#ff5722","#795548","#9e9e9e","#607d8b","#455a64",
              "#e57373","#f06292","#ba68c8","#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac","#81c784",
              "#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65","#bcaaa4","#eeeeee","#b0bec5","#ff5252",
              "#e040fb","#7c4dff","#448aff","#18ffff","#69f0ae","#eeff41","#ffd740","#ff6e40"), times=100)

nrow <- ceiling( length(unique(catalog$group))/8)

p <- ggplot(stats, aes(x=ind, y=values, group=sample, colour=group)) + 
         geom_line( size= 0.4 ) +
         theme_ipsum() +
         theme(   text         = element_text(family="Times", face="plain", size  = 10, colour = "black" ),
                   axis.text    = element_text(family="Times", face="plain", size = 12, colour = "black" ),
                   axis.text.x  = element_text(family="Times", face="plain", size = 12, colour = "black" ), 
                   axis.text.y  = element_text(family="Times", face="plain", size = 12, colour = "black" ), 
                   axis.title   = element_text(family="Times", face="plain", size = 12),
                   axis.title.x = element_text(family="Times", face="plain", size = 12),
           		     axis.title.y = element_text(family="Times", face="plain", size = 12),
                   legend.text  = element_text(family="Times", face="plain", size = 9,  colour = "black" ),
                   plot.title   = element_text(family="Times", face="plain", size = 12),
                   legend.position="bottom") +
         scale_x_continuous(breaks=seq(min(stack$ind), max(stack$ind), step_size), limits = c(min(stack$ind), max(stack$ind))) +  
         guides(size=F, col = guide_legend(nrow = nrow , override.aes = list( size = 5))) +
         labs(x="rarefaction depth", title=label)

if(as.logical(opts$t)){
    p <-p + geom_text_repel(data = repel_label, aes(x = ind, y = values, label=sample), colour="black", size = 2)
}

ggsave(output, device = "pdf", width = 10, height = 7, limitsize = FALSE )
