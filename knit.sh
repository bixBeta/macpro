#!/bin/sh

if [ "$1" = "help" ] || [  -z $1  ]; then
    echo ""
    echo "--------------------------------------------------------------------------------------"
    echo "  To run this script, use the following syntax:"
    echo "     bash" $0 "<title> <genome> <annot>"
    echo "--------------------------------------------------------------------------------------"
    echo ""
    exit 1

else

scp /Users/faraz/bin/macpro/rmd_temp.Rmd .

Rscript /Users/faraz/bin/macpro/knit.R $1 $2 $3

rm rmd_temp.Rmd

fi
