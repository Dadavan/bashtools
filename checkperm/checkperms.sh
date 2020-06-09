#!/bin/bash

read -p "Path: " TARGET
read -p "Permissions: " STATE ; echo -e " "
declare -a PERM

#Checks if target path exists, exits if not
if [ -d "$TARGET" ]
then
	continue 2> /dev/null
else
	echo "Invalid path, exiting"
	exit
fi

#Creates array of inputed permissions and checks if they are valid
for (( i=0; i < ${#STATE}; i++ ))
do
	PERM+=("${STATE:i:1}")
done

for i in ${PERM[*]}
do
	if [ "$i" -ge 0 ] 2> /dev/null && [ $i -le 7 ] 2> /dev/null
	then
		continue
        else
                echo "Invalid permissions, exiting"
		exit
        fi
done

#Checks permissions of all files in target and prints them
cd $TARGET

for i in `ls -l | tail -n +2 | awk '{print $9}'`
do
	FILE=$i
	USER=`ls -l $i | awk '{print substr($1,2,3)}' | awk '{gsub("x","1"); gsub("w","2"); gsub("r","4"); print}'`
	UARRAY=`echo $USER | tr -d "-" | fold -w1`
	GROUP=`ls -l $i | cut -c5-7 | awk '{gsub("x","1"); gsub("w","2"); gsub("r","4"); print}'`
	GARRAY=`echo $GROUP | tr -d "-" | fold -w1`
	OTHER=`ls -l $i | awk '{print substr($1,8,3)}' | awk '{gsub("x","1"); gsub("w","2"); gsub("r","4"); print}'`
	OARRAY=`echo $OTHER | tr -d "-" | fold -w1`
	
	USUM=0; GSUM=0; OSUM=0

#Adds file permissions up to be represented with digit
	for i in $UARRAY; do USUM=$(($USUM+$i)); done
	for i in $GARRAY; do GSUM=$(($GSUM+$i)); done
	for i in $OARRAY; do OSUM=$(($OSUM+$i)); done

#Checks if inputed permissions match current state, fixes permissions if needed
	if [ ${PERM[0]} -eq $USUM ] && [ ${PERM[1]} -eq $GSUM ] && [ ${PERM[2]} -eq $OSUM ]
	then
		echo -e "\e[32m$FILE: OK\e[0m"
	else
		echo -e "\e[31m$FILE permissions are ($USUM$GSUM$OSUM)\e[0m"
		read -p "Fix?: " FIX
		PERMNOSPACE=`echo ${PERM[*]} | tr -d " "`

#Fixes permissions
		if [[ $FIX == "y" || $FIX == "Y" || $FIX == "yes" || $FIX == "Yes" ]]
		then
			chmod $PERMNOSPACE $FILE && echo -e "\e[32m$FILE permissions are now $PERMNOSPACE\e[0m\n"
		fi
	fi
done


