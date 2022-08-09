#!/usr/bin/env bash

if [ $# -eq 1 ]; then
    path=$1
else
    echo pdf2png path;exit
fi

for i  in `ls $path/*.pdf`; do basename=$(basename $i  .pdf); echo convert  -antialias  -quality 100  -compress lzw  -density 200  $i  $path/$basename.png ; done | parallel -j 20
