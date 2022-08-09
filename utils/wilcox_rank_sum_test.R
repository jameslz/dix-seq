#!/usr/bin/env Rscript

"Usage: wilcox_test.R [options] MATRIX CASE CONTROL STATS
Options:
  -f --factor=1  the factor 1 || 100 [default: 1]
Arguments:
  MATRIX    the name of input file
  CASE      the case  sample
  CONTROL   the control sample
  STATS     the name of output file "->doc

library("docopt")
library("qvalue")

opts     <- docopt(doc)
matrix   <- opts$MATRIX
case     <- as.character(opts$CASE)
control  <- as.character(opts$CONTROL)
stats    <- opts$STATS
factor_size  <- as.numeric(opts$factor)

group  <- unlist(read.table(matrix, sep="\t", header=F, nrow=1, row.names=1, colClasses = c("character"), comment.char = "", check.name=F))
data   <- read.table(matrix, sep="\t", header=T, row.names=1, skip=0, comment.char = "", check.name=F )

g1     <- data[, group ==  case]
g2     <- data[, group ==  control]

stderr <- function(x) sqrt(var(x,na.rm=TRUE)/length(na.omit(x)))

res <- data.frame(t(sapply(rownames(data), function(t){
         x <- unlist(g1[rownames(g1) == t, ])/factor_size
         y <- unlist(g2[rownames(g2) == t, ])/factor_size
         res <- wilcox.test(x, y, alternative = "two.sided")
         return(c(mean(x), var(x), stderr(x),
                  mean(y),  var(y), stderr(y), res$p.value))
})))

res$qvalue <- p.adjust(res[[7]],  method = "BH")

colnames(res) <- c("mean(A)",  "variance(A)", "standard_error(A)", "mean(B)", "variance(B)", "standard_error(B)", "pvalue", "qvalue")

write.table(res, stats, sep="\t", quote=F, col.names=NA)
