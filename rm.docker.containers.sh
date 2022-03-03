docker ps -a | cut -d " " -f1 | sed 1,1d | while read line ; do docker rm $line ; done
