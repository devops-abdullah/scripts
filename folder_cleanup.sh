#!/bin/bash

# Define the root directory to search
ROOT_DIR=`docker volume inspect {{volumeName}} --format {{.Mountpoint}}`

# Define the output file to store folder paths and creation dates
OUTPUT_FILE="folders_list.txt"

# Find all 'email' folders and write their full path and creation date to the list
echo "Scanning directories for 'email' folders..."
find "$ROOT_DIR" -type d -name "email" -print0 | while IFS= read -r -d '' folder; do
    creation_date=$(stat -c '%Y' "$folder") # Get folder creation date (in seconds since epoch)
    creation_date_readable=$(date -d @"$creation_date" +"%Y-%m-%d %H:%M:%S") # Convert to readable format
    echo "$folder,$creation_date_readable" >> "$OUTPUT_FILE"
done

echo "List of 'email' folders with creation dates saved to $OUTPUT_FILE."

# Process the list to delete folders older than 3 months
echo "Deleting folders older than 3 months..."
current_time=$(date +%s)
three_months_in_seconds=$((3 * 30 * 24 * 3600))

while IFS=',' read -r folder_path creation_date; do
    folder_creation_time=$(date -d "$creation_date" +%s)
    age=$((current_time - folder_creation_time))
    if [ "$age" -gt "$three_months_in_seconds" ]; then
        echo "Deleting folder: $folder_path (Created on: $creation_date)"
        rm -rf "$folder_path"
    fi
done < "$OUTPUT_FILE"

echo "Cleanup completed."
