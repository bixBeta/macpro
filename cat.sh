#!/bin/bash


readarray fastqs < B1B2

for i in "${fastqs[@]}"
do
  iSUB=`echo $i | cut -d '_' -f5`
  cat $i > NEW_${iSUB}.gz

done
