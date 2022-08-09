#!/usr/bin/env Rscript

library("docopt")

"Usage: NMDS.R  [options]  INPUT METADATA RESULT
Options:
  -g --group=F     plot ellipse.     [default: F]
  -t --text=F      label point.      [default: F]
  -m --method=..   method for construct distance matrix:euclidean/jaccard/bray... [default: NONE]
  -c --conf=0.6    confidence value for the ellipse.  [default: 0.6]
Arguments:
   INPUT         the input matrix
   METADATA      the group catalog file.
   RESULT        the result filename" -> doc

opts  <- docopt(doc)

input    <- opts$INPUT
metadata <- opts$METADATA
output   <- opts$RESULT
distance <- opts$m
conf     <- as.numeric(opts$c)

library(tidyverse)
library(vegan)
library(Cairo)
library(hrbrthemes)
library(viridis)
library(ggrepel)
library(ellipse)

data.table <- t(read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char=""))

catalog <- read.table(metadata, header = F, sep="\t", comment.char="", check.names=F, stringsAsFactors=F)
colnames(catalog)<-c("sample","group")

cols<-c("#f44336","#2196f3","#9c27b0","#673ab7","#3f51b5","#00bcd4","#009688",
        "#4caf50","#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800","#ff5722",
        "#795548","#9e9e9e","#607d8b","#455a64","#e57373","#f06292","#ba68c8",
        "#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac","#81c784",
        "#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65","#bcaaa4",
        "#eeeeee","#b0bec5","#ff5252","#e040fb","#7c4dff","#448aff","#18ffff",
        "#69f0ae","#eeff41","#ffd740","#ff6e40")

set.seed(2)
nmds  <- NA

if( distance == 'NONE'){
  nmds <- metaMDS(data.table, k=2, try = 20, trymax = 200)
}else{
  nmds <- metaMDS(data.table, distance=distance, k=2, try = 20, trymax = 200)
}

score <- scores(nmds)
nmds.data <- data.frame(nmds1    = score[,1],
                        nmds2    = score[,2],
                        sample   = rownames(score),
                        group    = factor(catalog$group, level=unique(catalog$group),ordered = TRUE))

ellipse <- NA
segment <- NA

if( as.logical(opts$g) ){


    uniques        <- catalog %>% count(group) %>% filter(n > 1)
    centroids      <- aggregate(cbind(nmds1, nmds2)~group, nmds.data, mean) %>% filter(group %in%  uniques$group)
    nmds.ellipse   <- nmds.data %>% filter(group %in%  uniques$group)
    ellipse        <- do.call(rbind, lapply(unique(nmds.ellipse$group), function(t)
                         data.frame( group = factor(as.character(t)),
                             ellipse(cov(nmds.ellipse[nmds.ellipse$group==t,1:2]),
                                     centre=as.matrix(centroids[t,2:3]),
                                     level=conf),
                             stringsAsFactors=FALSE)))
    
    ellipse$group <- factor(ellipse$group, level=unique(catalog$group), ordered = TRUE)
    segment       <- right_join(centroids, nmds.data, by='group')

    colnames(segment) <- c("group", "x","y","xend","yend", "sample")
    segment$group <- factor(segment$group, level=unique(catalog$group), ordered = TRUE)
}

nmds.data$group <- factor(catalog$group, level=unique(catalog$group), ordered = TRUE)

nrow <- ceiling( length(levels(nmds.data$group))/8)

p <- nmds.data %>% ggplot()

if(as.logical(opts$g)){
    
    p <- p + geom_polygon(data = ellipse, aes(x=nmds1, y=nmds2, colour=group, fill=group), 
                    colour = "black", linetype=3, size =0.2, alpha=0.1, show.legend=F) + 
             geom_segment(data = segment, 
                    mapping = aes(x = x, y = y, xend = xend, yend = yend, colour = group),
                    linetype = 2, size=0.2, show.legend=F) + 
             scale_fill_manual(values = cols) 

}

p <-p + geom_point(aes(x=nmds1, y=nmds2, color=group), size = 4)+
        scale_color_manual(values = cols)+
        theme_ipsum() +
        theme(   text         = element_text(family="Times", face="plain", size = 10, colour = "black" ),
                 panel.grid   = element_blank(),
                 axis.text    = element_text(family="Times", face="plain", size = 12, colour = "black" ),
                 axis.text.x  = element_text(family="Times", face="plain", size = 12, colour = "black" ), 
                 axis.text.y  = element_text(family="Times", face="plain", size = 12, colour = "black" ), 
                 axis.title   = element_text(family="Times", face="plain", size = 12),
                 axis.title.x = element_text(family="Times", face="plain", size = 12),
         		     axis.title.y = element_text(family="Times", face="plain", size = 12),
                 legend.text  = element_text(family="Times", face="plain", size = 9,  colour = "black" ),
                 legend.position="bottom") +
        
      xlab(paste( "NMDS1( Stress ", signif(nmds$stress,2), " )", sep="")) +
      ylab("NMDS2") +
      geom_hline(yintercept=0, linetype=3, size =0.5) + 
        geom_vline(xintercept=0, linetype=3, size= 0.5) +
        guides(fill  =guide_legend(title=NULL, nrow=nrow),
               color =guide_legend(title=NULL, nrow=nrow))

if(as.logical(opts$g)){
    p <-p + geom_polygon(data=ellipse, aes(x=nmds1, y=nmds2, group=group),
                  colour = "black", linetype=3, size =0.2, alpha=0, show.legend=F)
}

if(as.logical(opts$t)){
    p <-p + geom_text_repel(data=nmds.data, aes(x=nmds1,y=nmds2, label=nmds.data$sample), size=2)
}

ggsave(output, device = "pdf")
