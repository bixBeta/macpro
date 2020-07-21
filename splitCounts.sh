#!/bin/sh

if [ "$1" = "help" ] || [ -z "$1" ]
    then
    echo ""
    echo "   bash" $0 "<countMatrix>"
    echo ""

else

  NCOL=`awk 'NR==2 {print NF}' $1`
  echo "number of cols detected= "$NCOL

  # store feature names
  cut -f1 $1 | awk 'NR>1 {print $0}' > .records

  for ((i=2;i<=${NCOL};i++))

  do
      NAME="`cut -f${i} $1 | head -1`"
      awk 'NR>1 {print $'$i'}' $1 > .temp
      paste .records .temp > $NAME.rawCounts
  done

rm .records .temp


fi
