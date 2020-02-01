#!/bin/sh

# bedtools genomecov -bg \
# -trackline \
# -trackopts 'name="D2-rep1"' \
# -scale 0.397
# -ibam ..bam \ #| gzip - > MP1-D2rep1_scaled.bg.gz
# -strand + # or - and -split for animals (with spliced introns)


for i in *.bam
do
  iSUB=`echo $i | cut -d "_" -f1`
  P=`echo "'name="\"$iSUB.plus\"\'`
  M=`echo "'name="\"$iSUB.minus\"\'`

  bedtools genomecov -bg \
  -trackline -trackopts $P \
  -ibam $i \
  -strand + > $iSUB.plusStrand.bg

  bedtools genomecov -bg \
  -trackline -trackopts $M \
  -ibam $i \
  -strand - > $iSUB.minusStrand.bg

done

gunzip *.bg 
