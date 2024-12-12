#!/bin/bash

### This is an example script that to remove email folder from the file-store

# Define the root directory to search
ROOT_DIR=`docker volume inspect {volumeName} --format {{.Mountpoint}}`

# Define Folder name
FOLDER_NAME="email"

# Define the output file to store folder paths and creation dates
OUTPUT_FILE="${FOLDER_NAME}_folders_list.txt"

# Clear previous output files if they exist
> "$OUTPUT_FILE"

# Define the output file to store Deleted folder paths and dates
OUTPUT_FILE_DELETED="${FOLDER_NAME}_deleted_folders_list.txt"

# Find all 'email' folders and write their full path and creation date to the list
echo "Scanning directories for $FOLDER_NAME folders..."
find "$ROOT_DIR" -type d -name "$FOLDER_NAME" -print0 | while IFS= read -r -d '' folder; do
    creation_date=$(stat -c '%Y' "$folder") # Get folder creation date (in seconds since epoch)
    creation_date_readable=$(date -d @"$creation_date" +"%Y-%m-%d %H:%M:%S") # Convert to readable format
    echo "$folder,$creation_date_readable" >> "$OUTPUT_FILE"
done

echo "List of $FOLDER_NAME folders with creation dates saved to $OUTPUT_FILE."

# Process the list to delete folders older than 3 months
echo "Deleting folders older than 2 months..."
current_time=$(date +%s)
months_in_seconds=$((2 * 30 * 24 * 3600))

while IFS=',' read -r folder_path creation_date; do
    folder_creation_time=$(date -d "$creation_date" +%s)
    age=$((current_time - folder_creation_time))
    if [ "$age" -gt "$months_in_seconds" ]; then
        echo "Deleting folder: $folder_path (Created on: $creation_date)"
        rm -rf "$folder_path"
        echo "Deleted AT: $(date) => $folder_path (Created on: $creation_date)" >> "$OUTPUT_FILE_DELETED"
    fi
done < "$OUTPUT_FILE"

echo "Cleanup completed."
