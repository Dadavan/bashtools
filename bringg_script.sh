#!/bin/bash

# $1 is the email / user you want to notify

script=$(basename -- $0)
email=$1
dir_array=()

function send_email {
	echo "$script has failed" | mail -s 'Oh no!' $email && echo "Email sent to $email"
}

function check_running {
	if pidof -x $script -o $$ > /dev/null  ; then
		echo "Instance of script already running, exiting"
		return 1
	fi
}

function create_folders {
	for i in {1..100} ; do 
		dir=$RANDOM$RANDOM
		mkdir $dir && dir_array+=($dir)
	done
}

function create_files {
	for dir in ${dir_array[@]} ; do
		for file in {1..100} ; do
			prefix_array=(a b c)
			size_array=(`seq 50 200 | sort -R`)
			random_prefix=${prefix_array[$RANDOM % ${#prefix_array[@]}]}
			random_size=${size_array[$RANDOM % ${#size_array[@]}]}
			file_name=`echo -e "$random_prefix$RANDOM"`
			
			cat /dev/urandom | tr -dc 'a-zA-Z0-9 ' | head -c "$random_size"k > $dir/$file_name
		done
	done
}

function remove_spaces {
	for dir in ${dir_array[@]} ; do
		find $dir -type f | xargs sed -i s/" "/""/g 
	done
}

function create_md5 {
	for dir in ${dir_array[@]} ; do
		for file in `ls $dir` ; do
			md5sum $dir/$file > $dir/$file.md5
		done
	done
}

check_running 		\
&& create_folders 	\
&& create_files 	\
&& remove_spaces 	\
&& create_md5 		\
|| send_email



		

