#!/usr/bin/env Rscript

library("docopt")

"Usage: Kruskal-Wallis.R   INPUT METADATA RESULT \

Arguments:
   INPUT         the input matrix
   METADATA      the group catalog file.
   RESULT        the result filename" -> doc

opts  <- docopt(doc)

input <- opts$INPUT
metadata <- opts$METADATA
output<- opts$RESULT

matrix <- read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char="")

catalog <- read.table(metadata, header = F, sep="\t",comment.char="", check.names=F, stringsAsFactors=F, skip=1, colClasses = "character")
colnames(catalog)<-c("sample","group")

res <- data.frame(t(sapply(rownames(matrix), function(t){
     stack<-stack(matrix[rownames(matrix) == t,])
     stack$group  <- rep(catalog$group,  each = length(rownames(matrix[rownames(matrix) == t,])))
     stack$group  <- as.factor(rep(catalog$group,  each = length(rownames(matrix[rownames(matrix) == t,]))))
     res <- kruskal.test(values~group,data=stack)
      return(c(res$data.name,res$p.value))
     })))

res$padj <- p.adjust(res[[2]], method = "BH")

colnames(res) <- c("NA", "pvalue", "padj")

write.table( cbind(id=rownames(matrix), matrix, pvalue=res$pvalue, padj=res$padj) , output, sep="\t", quote=F, row.names=F)