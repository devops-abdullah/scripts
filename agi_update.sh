#!/bin/bash

#######################################
#     Author: Abdullah Manzoor
#######################################

### AGI Directory
dir=/etc/agispeedy
config_file=$dir/etc/agispeedy.conf

### Backup Directory
backup_dir=/tmp/admin_bkp

function backup() {
if [[ ! -d $backup_dir ]]; then 
	mkdir $backup_dir
fi

if [ -f $config_file ]; then
	echo Please wait for the backup....!
	yes | cp $config_file $backup_dir
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

echo Copping the config files from backup....!
	yes | cp $backup_dir/agispeedy.conf $dir/etc/ 
echo Config files copied successfully...!

echo Setting up the Permission on the Application folder....!!!
chmod 755 -R $dir

echo "AGI code has been updated successfully...!!!"

echo reloading the service
service agispeedy restart
}

backup
pull_changes
