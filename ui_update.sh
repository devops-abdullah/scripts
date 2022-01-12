#!/bin/bash

#######################################
#     Author: Abdullah Manzoor
#######################################

### UI Directory
dir=/root/cx9/ui
build_path=$dir/build
UI=/var/www/html
DATE=`date +%d-%m-%Y`

function backup() {
if [ -d $UI/cx9 ]; then
	echo Please wait for the backup....!
	cp -a $UI/cx9 $UI/cx9-$DATE
	echo !!!!!!!!!!!!!!!!!!!!!!!!
	echo !!!!!!!!!!!!!!!!!
	echo !!!!!!!!!!!
	echo Backup Done....!
else
	echo Files or directories are not exist...!
	exit 1
fi
}

function pull_changes() {
echo Going to pull new changes
cd $dir && git checkout .
cd $dir && git pull

echo Copping New UI Build Files to UI Directory....!
	yes | cp -a $build_path/* $UI/cx9 
	yes | cp -a $build_path/* $UI/cx9 
	yes | cp -a $build_path/* $UI/cx9 
echo Files copied successfully...!

echo "UI code has been updated successfully...!!!"
}

backup
pull_changes
