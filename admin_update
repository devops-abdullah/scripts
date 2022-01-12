#!/bin/bash

#######################################
#     Author: Abdullah Manzoor
#######################################

### Application Directory
dir=/var/www/html/intellicon
app=application/config
config_file="$dir/$app/config.php"
config_ajam="$dir/$app/yovo_ajam.php"
config_db="$dir/$app/database.php"
config_setting="$dir/$app/setting.php"

### Backup Directory
backup_dir="/tmp/admin_bkp"


function backup() {
if [[ ! -d $backup_dir ]]; then 
	mkdir $backup_dir
fi

if [ -f $config_file ] && [ -f $config_ajam ] && [ -f $config_db ]; then
	echo Please wait for the backup....!
	yes | cp $config_file $backup_dir
	yes | cp $config_ajam $backup_dir
	yes | cp $config_db $backup_dir
	yes | cp $config_setting $backup_dir
	echo !!!!!!!!!!!!!!!!!!!!!!!!
	echo !!!!!!!!!!!!!!!!!
	echo !!!!!!!!!!!
	echo Backup Done....!
else
	echo Files are directories not exist...!
	exit 1
fi
}

function pull_changes() {
# remove INSTALL file from /var/www/html/intellicon/
file=/var/www/html/intellicon/INSTALL
monitor=/var/spool/asterisk/monitor
voicemail=/var/spool/asterisk/voicemail

echo Going to pull new changes
cd $dir && git checkout .
cd $dir && git pull

if [ -f $file ]; then rm -rf $file; fi
echo Copping the config files from backup....!
	yes | cp $backup_dir/config.php $dir/$app/ 
	yes | cp $backup_dir/yovo_ajam.php $dir/$app/
	yes | cp $backup_dir/database.php $dir/$app/
	yes | cp $backup_dir/setting.php $dir/$app/
echo Config files copied successfully...!

echo Setting up the Permission on the Application folder....!!!
chmod 755 -R $dir
chmod 777 -R $dir/sounds
chmod 777 -R $dir/export
chown -R apache: $dir

echo Checking the Call Recording Link
if [[ ! -L $dir/sounds/monitor ]] && [[ ! -L $dir/sounds/voicemail ]]; then
	ln -s $monitor $dir/sounds/
	ln -s $voicemail $dir/sounds/
fi

echo "Intellicon Application Admin Panel code has been updated successfully...!!!"
echo "Please Refresh the page & update the settings under Setting > Core"
}

backup
pull_changes
