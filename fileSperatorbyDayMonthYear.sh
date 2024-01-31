#!/bin/bash

# Set the source directory
source_dir="/home/contegris/recordingbackup/OldBackups/days"

# Iterate through each file in the source directory
for file in "$source_dir"/*/*; do
    # Check if it's a regular file
    if [ -f "$file" ]; then
        # Extract the year, month, and day from the file's timestamp
        year=$(date -r "$file" +%Y)
        month=$(date -r "$file" +%m)
        day=$(date -r "$file" +%d)

        # Create the destination directory if it doesn't exist
        dest_dir="$source_dir/$year/$month/$day"
        mkdir -p "$dest_dir"

        # Move the file to the destination directory
        mv "$file" "$dest_dir/"
        echo "Moved $file to $dest_dir/"
    fi
done
