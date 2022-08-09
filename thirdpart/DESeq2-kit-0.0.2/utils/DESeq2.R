#!/usr/bin/env Rscript

"Usage: Deseq2.R  [options]  MATRIX CASE CONTROL RESULT
Options:
  -t --test=test            (Wald, LRT) [default: Wald]
  -f --fitType=fitType      (parametric, local, mean),  [default: parametric]
  -p --parallel=<parallel>  (T, F) [default: F]
Arguments:
   MATRIX        the count matrix
   CASE          the case condition
   CONTROL       the control condition
   RESULT        the result filename" -> doc

library("docopt")
opts    <- docopt(doc)

input   <- opts$MATRIX
case    <- as.character(opts$CASE)
control <- as.character(opts$CONTROL)
result  <- opts$RESULT

library("DESeq2")

conditions       <- as.data.frame (read.table(input, header=F, sep = "\t", row.names = 1, check.name = F, comment.char ="", nrow = 1, colClasses = "character"))
sample.condition <- as.vector(apply(conditions[, c(which(conditions == case), which(conditions == control))], 1, as.vector))

counts_table <- read.table(input, header=T, sep = "\t", row.names = 1, quote="", check.name = F, comment.char ="", skip = 1, fill=TRUE)
countData    <- counts_table[, c(which(conditions == case), which(conditions == control))]
countData    <- data.matrix(countData)

countData    <- countData[apply(countData, 1, sum) != 0,]
colData      <- data.frame ( row.names   = colnames(countData),
                             condition   = factor(sample.condition)
                           )

dds <- DESeqDataSetFromMatrix( countData  = countData,
                               colData    = colData,
                               design     = ~condition
                              )

dds          <- DESeq(dds, test = opts$t, fitType = opts$f, parallel = as.logical(opts$p), quiet = T)
degs_val     <- as.data.frame(results(dds, contrast = c("condition", case, control)))

degs         <- paste(result, ".txt", sep="")
write.table(cbind(ID = rownames(degs_val), degs_val[, c("baseMean", "log2FoldChange", "pvalue", "padj")]), 
            degs, sep="\t", quote=F, row.names=F)
