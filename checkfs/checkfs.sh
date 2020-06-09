#!/bin/bash

for i in `df -P | awk '{print $6}' | tail -n +2`
do
	FSNAME=$i
	PRCT=$(df -P $i | awk '{print $5}' | tail -n +2 | cut -d "%" -f1)
	if [ $PRCT -ge 80 ]
	then
		echo "Warning! Mountpoint $FSNAME is $PRCT full!"
	else
		echo "Mountpoint $FSNAME is ok"
	fi
done

exit 0
