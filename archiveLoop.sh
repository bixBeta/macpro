#!/bin/sh


readarray projects < $1


for i in "${projects[@]}"
	do
		  iSUB=`echo $i | cut -d "-" -f1`
		  cd $i

		  mkdir /home/RSCshare/RSC/Projects/ARCHIVE/$iSUB
		  rsync -av fastq/ /home/RSCshare/RSC/Projects/ARCHIVE/$iSUB

		  cd ..

	done
