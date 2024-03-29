#!/bin/bash

# Define variables
SOURCE_DIR="/source/directory"
DEST_USER="username"
DEST_HOST="1.1.1.1"
DEST_MODULE="Rec"
PASSWORD='123123123123'
THREE_MONTHS_AGO=$(date -d "3 months ago" +%s)  # Get timestamp for three months ago ### This option is also use able.
OLD_DIRECTORIES=$(find "$SOURCE_DIR" -type d -mtime +90)
PID="/var/run/rsync_sh.pid"

if [ -f $PID ]; then
        CMD=`cat $PID`
        echo Process is already running on PID: $CMD
        exit 1
else
        echo $$ > $PID
        clear

                # Create a temporary file for the password
                password_file=$(mktemp)
                echo -n "$PASSWORD" > "$password_file"
                chmod 600 "$password_file"

                # Run rsync with the password file and only sync files older than three months
                #for DIR in $OLD_DIRECTORIES; do
                #        cd $DIR && pwd \
                #        && rsync -avz --bwlimit=1000 --password-file="$password_file" "$DIR" "$DEST_USER@$DEST_HOST::$DEST_MODULE"
                #done
                
                # Below Command is much better than above For Loop
                # Below command will sync the Data in Same Directory Structure
                find "$source_dir" -type d -ctime +90 -exec rsync -avR --bwlimit=1000 --password-file="$password_file" {} "$remote_user@$remote_host::$remote_dir/" \;
                
                # Clean up the temporary password file
                rm -f "$password_file"

        # Removing PID file on success....!
        rm -rf $PID
fi
