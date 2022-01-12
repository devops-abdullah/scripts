#!/bin/bash

#Put the last digits of the local IP as argument to sync all data folders.
echo "Author        :   Abdullah Manzoor"
echo "Company       :   Contegris Pvt. Ltd"
echo "Department    :   Infrastructure & DevOps"

HOSTIP="1.1.1.1"
PID=/var/run/rsync_sh.pid

HTML=/var/www/html/intellicon
AGI=/etc/agispeedy
NODE=/etc/node
TAIL=/etc/tail
RECORDINGS=/var/spool/asterisk/monitor
RECORDINGS1=/var/spool/asterisk/voicemail

if [ -f $PID ]; then
        CMD=`cat $PID`
        echo Process is already running on PID: $CMD
        exit 1
else
        echo $$ > $PID
        clear

        #Exclude File from Intellicon
        #int_exclude='--exclude /var/www/html/intellicon/application/config/setting.php'

        #Exclude File & Folder from Tail
        #tail_env='--exclude /etc/tail/.env'
        #tail_db="--exclude '/etc/tail/level-mysql'"

        #Exclude Files From CX9 Directory
        #cx9_ecosystem='--exclude /root/cx9/ecosystem.config.js'

        #echo "Running rsync on $HTML Directory...."
        #echo "Syncing Application...."
        #rsync -arv $int_exclude $HTML $HOSTIP:/var/www/html/
        #rsync -arunv $int_exclude $HTML $HOSTIP:/var/www/html/

        #rsync -av $cx9_ecosystem ~/cx9 $HOSTIP:/root/

        #echo "Running rsync on $AGI Directory...."
        #echo "Syncing AGI...."
        #rsync -aunv $AGI $HOSTIP:/etc/

        #echo "Running rsync on $TAIL Directory...."
        #echo "Syncing Logger...."
        #rsync -av $tail_env $tail_db $TAIL $HOSTIP:/etc/

        echo "Running rsync on $RECORDINGS Directory...."
        echo "Syncing Voice Recordings Directory...."
        rsync --bwlimit=1000 -av  $RECORDINGS $HOSTIP:/var/spool/asterisk/
        rsync --bwlimit=1000 -av  $RECORDINGS1 $HOSTIP:/var/spool/asterisk/

        echo "---------------------------------"
        echo "-     All Directories Synced    -"
        echo "---------------------------------"

fi
