#!/usr/bin/env Rscript

library("docopt")

"Usage: render.R    INPUT  

Arguments:
   INPUT         the input Rmd" -> doc

   
opts  <- docopt(doc)

input <- opts$INPUT

library('rmarkdown')


render(input, 'html_document')