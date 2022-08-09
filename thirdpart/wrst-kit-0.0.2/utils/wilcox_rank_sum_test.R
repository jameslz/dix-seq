#!/usr/bin/env Rscript

"Usage: wilcox_test.R [options] MATRIX CASE CONTROL STATS
Options:
Arguments:
  MATRIX    the name of input file
  CASE      the case  sample
  CONTROL   the control sample
  STATS     the name of output file "->doc

library("docopt")

opts     <- docopt(doc)
matrix   <- opts$MATRIX
case     <- as.character(opts$CASE)
control  <- as.character(opts$CONTROL)
stats    <- opts$STATS

group  <- unlist(read.table(matrix, sep="\t", header=F, nrow=1, row.names=1, colClasses = c("character"), comment.char = "", check.name=F))
data   <- read.table(matrix, sep="\t", header=T, row.names=1, skip=0, comment.char = "", check.name=F)

g1     <- data[, group ==  case]
g2     <- data[, group ==  control]

stderr <- function(x) sqrt(var(x,na.rm=TRUE)/length(na.omit(x)))

res <- data.frame(t(sapply(rownames(data), function(t){
         x <- unlist(g1[rownames(g1) == t, ])
         y <- unlist(g2[rownames(g2) == t, ])
         res <- wilcox.test(x, y, alternative = "two.sided")
         return(c(mean(x), var(x), stderr(x),
                  mean(y),  var(y), stderr(y), res$p.value))
})))

res$qvalue <- p.adjust(res[[7]],  method = "BH")



colnames(res) <- c(paste0( "mean(", case , ")" ),  paste0( "variance(", case , ")" ), paste0( "standard_error(", case , ")" ),
                   paste0( "mean(", control , ")" ),  paste0( "variance(", control , ")" ), paste0( "standard_error(", control , ")" ),
                   "pvalue", "qvalue")

write.table(cbind(id=rownames(data), res), stats, sep="\t", quote=F, row.names=F)
