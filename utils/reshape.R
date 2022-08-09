#!/usr/bin/env Rscript

"Usage:hrbr-boxplot.R [options] DATA  RESULT LABEL
Options:
Arguments:
   DATA      data table
   RESULT    result plot(pdf format)
   LABEL     label for axis.title.y. " -> doc

library("docopt")
opts     <- docopt(doc)

res      <- opts$RESULT
label    <- opts$LABEL

library(reshape2)
library(tidyverse)
library(hrbrthemes)
library(viridis)
library(Cairo)

data=t(read.table(opts$DATA, row.names=1, head=F, check.names=F, na.strings = "NA", fill=TRUE))
melt <- melt(data)[, c(2,3)]
colnames(melt) <- c("group", "value")

p <- melt  %>%  
  ggplot( aes(group, value, fill =group)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(
        axis.title     = element_text(family="Times", face="plain", size = 20),
        axis.text      = element_text(family="Times", face="plain", size = 16, color = "black"),
        axis.title.x   = element_text(family="Times", face="plain", size = 12),
        plot.title     = element_text(family="Times", face="plain", size = 12),
        axis.title.y   = element_text(family="Times", face="plain", size = 12),
        legend.position = "none")+
  labs(x="", y="abundance", title=label)


ggsave(res, device = "pdf")
