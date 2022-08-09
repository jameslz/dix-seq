#!/usr/bin/env Rscript

library("docopt")

"Usage: PCoA.R  [options]  INPUT METADATA RESULT
Options:
  -g --group=F   plot ellipse.    [default: F]
  -t --text=F    label point.     [default: F]
  -m --method=.. method for construct distance matrix:euclidean/jaccard/bray... [default: NONE]
  -c --conf=0.6  confidence value for the ellipse.  [default: 0.6]
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

matrix <- NULL
if( distance == 'NONE'){

  matrix <- read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char="")
  if(nrow(matrix) != ncol(matrix)){
      stop("[ERR]: Non symmetric matrix\n")
  }

}else{

  data.table <- t(read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char=""))
  matrix     <- vegdist(data.table,  method = distance)

}

library(Cairo)
library(hrbrthemes)
library(viridis)
library(ggrepel)
library(ellipse)

catalog <- read.table(metadata, header = F, sep="\t", comment.char="", check.names=F, stringsAsFactors=F)
colnames(catalog)<-c("sample","group")

cols<-c("#f44336","#2196f3","#9c27b0","#673ab7","#3f51b5","#00bcd4","#009688",
        "#4caf50","#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800","#ff5722",
        "#795548","#9e9e9e","#607d8b","#455a64","#e57373","#f06292","#ba68c8",
        "#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac","#81c784",
        "#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65","#bcaaa4",
        "#eeeeee","#b0bec5","#ff5252","#e040fb","#7c4dff","#448aff","#18ffff",
        "#69f0ae","#eeff41","#ffd740","#ff6e40")


pcoa <- cmdscale(matrix, k=2, eig=T)

pcoa.data <- data.frame(pc1    = pcoa$points[,1],
                        pc2    = pcoa$points[,2],
                        sample = rownames(pcoa$points),
                        group  = factor(catalog$group, level=unique(catalog$group),ordered = TRUE))

pcoa.eig <- round(pcoa$eig/sum(pcoa$eig)*100, 1)

ellipse <- NA
segment <- NA

if( as.logical(opts$g) ){

    uniques      <- catalog %>% count(group) %>% filter(n > 1)
    centroids    <- aggregate(cbind(pc1,pc2)~group, pcoa.data, mean)  %>% filter(group %in%  uniques$group)
    pcoa.ellipse <- pcoa.data %>% filter(group %in%  uniques$group)

    ellipse      <- do.call(rbind, lapply(unique(pcoa.ellipse$group), function(t)
                       data.frame( group = factor(as.character(t)),
                       ellipse(cov(pcoa.ellipse[pcoa.ellipse$group==t,1:2]),
                       centre=as.matrix(centroids[t,2:3]),
                       level=conf), stringsAsFactors=FALSE)))
    
    ellipse$group <- factor(ellipse$group, level=unique(catalog$group), ordered = TRUE)
    segment       <- right_join(centroids, pcoa.data, by='group')

    colnames(segment) <- c("group", "x","y","xend","yend", "sample")
    segment$group <- factor(segment$group, level=levels(pcoa.data$group))

}

nrow <- ceiling( length(levels(pcoa.data$group))/8)

p <- pcoa.data %>% ggplot()
    
if(as.logical(opts$g)){
    
    p <- p + geom_polygon(data = ellipse, aes(x=pc1, y=pc2, colour=group, fill=group), 
                    colour = "black", linetype=3, size =0.2, alpha=0.1, show.legend=F) + 
             geom_segment(data = segment, 
                    mapping = aes(x = x, y = y, xend = xend, yend = yend, colour = group),
                    linetype = 2, size=0.2, show.legend=F) + 
             scale_fill_manual(values = cols) 

}

p <-p + geom_point(aes(x=pc1, y=pc2, color=group), size = 4)+
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
        
        xlab(paste("PC1(", pcoa.eig[1],"%","variance)", sep="")) +
        ylab(paste("PC2(", pcoa.eig[2],"%","variance)", sep="")) +
        geom_hline(yintercept=0, linetype=3, size =0.5) + 
        geom_vline(xintercept=0, linetype=3, size= 0.5) +
        guides(fill  =guide_legend(title=NULL, nrow=nrow),
               color =guide_legend(title=NULL, nrow=nrow))

if(as.logical(opts$g)){
    p <-p + geom_polygon(data=ellipse, aes(x=pc1, y=pc2, group=group), 
                  colour = "black", linetype=3, size =0.2, alpha=0, show.legend=F)
}

if(as.logical(opts$t)){
    p <-p + geom_text_repel(data=pcoa.data, aes(x=pc1,y=pc2, label=sample), size=2)
}

ggsave(output, device = "pdf")
