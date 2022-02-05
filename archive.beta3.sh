#!/bin/bash

for i in *
do
  PIN=`echo $i | cut -d "-" -f1`

  cd $i/fastqs
  fastqs=`pwd`
  echo $fastqs

  mkdir /home/RSCshare/RSC/Projects/ARCHIVE/$PIN
  rsync -av $fastqs /home/RSCshare/RSC/Projects/ARCHIVE/$PIN

  cd ../..

done
