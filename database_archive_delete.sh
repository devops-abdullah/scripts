#!/bin/bash

# MySQL credentials
DB_HOST="localhost"
DB_USER="username"
DB_PASS="password"
DB_NAME="db_name"

LOG_FILE="archive_run_$(date +%F).log"
echo "=== Archive Process Started at $(date) ===" | tee -a $LOG_FILE

# Offset and Limit
OFFSET=0
LIMIT=1000

archive() {
while true; do
    # Insert batch of records
    ROWS_INSERTED=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "
        INSERT INTO $DEST_TABLE
        SELECT *
        FROM $SRC_TABLE
        WHERE created_at >= '$START_DATE' AND created_at < '$END_DATE'
        LIMIT $LIMIT OFFSET $OFFSET;
        SELECT ROW_COUNT();
    ")

    # Check if no more rows were inserted
    if [ "$ROWS_INSERTED" -eq 0 ]; then
        echo "All records inserted. Exiting..." | tee -a $LOG_FILE
        break
    fi

    echo "Inserted $ROWS_INSERTED records from offset $OFFSET" | tee -a $LOG_FILE

    # Increment offset for next batch
    OFFSET=$((OFFSET + LIMIT))
done

# Optional: show total count
TOTAL_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "
    SELECT COUNT(0)
    FROM $DEST_TABLE
    WHERE created_at >= '$START_DATE' AND created_at < '$END_DATE';
")

echo "Total records in $DEST_TABLE for 2021: $TOTAL_COUNT" | tee -a $LOG_FILE
}

delete() {

while true; do
    # Insert batch of records
    ROWS_DELTED=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "
        DELETE FROM $SRC_TABLE
        WHERE created_at >= '$START_DATE' AND created_at < '$END_DATE'
        LIMIT $LIMIT;
    ")

    # Check if no more rows were inserted
    if [ "$ROWS_DELTED" -eq 0 ]; then
        echo "All records inserted. Exiting..." | tee -a $LOG_FILE
        break
    fi

    # Increment offset for next batch
    OFFSET=$((OFFSET + LIMIT))
	
    echo "Deleted $ROWS_DELTED records from offset $OFFSET" | tee -a $LOG_FILE
	
done
echo "Total records in $DEST_TABLE for 2021: $TOTAL_COUNT" | tee -a $LOG_FILE

}

usage() {
    echo "==============================================================" | tee -a $LOG_FILE
    echo  | tee -a $LOG_FILE
    echo ">>>>>>>>>>>>>> Usage: $0 {archive|delete} {YEAR}" | tee -a $LOG_FILE
    echo ">>>>>>>>>>>>>> Example: $0 archive 2023" | tee -a $LOG_FILE
    echo | tee -a $LOG_FILE
    echo "==============================================================" | tee -a $LOG_FILE
    exit 1
}

# Check both arguments
[ -z "$1" ] && usage
[ -z "$2" ] && usage

func="$1"
YEAR="$2"

# Date range
START_DATE="${YEAR}-01-01 00:00:00"

# END Date Next Year
NEXT_YEAR=$((YEAR + 1))
END_DATE="${NEXT_YEAR}-01-01 00:00:00"

# Table names
SRC_TABLE="TableName"
DEST_TABLE="archrival_table_name_${YEAR}"

# Validate YEAR (4-digit number)
if ! [[ "$YEAR" =~ ^[0-9]{4}$ ]]; then
    echo "Error: YEAR must be a 4-digit number." | tee -a $LOG_FILE
    usage
fi

# Confirm YEAR
echo "Selected YEAR: $YEAR" | tee -a $LOG_FILE

# Ask for confirmation
echo -n "Press ENTER to start the script..." | tee -a $LOG_FILE
read _

# Check if function exists
if declare -f "$func" > /dev/null; then
    echo "Function Caled >>>>>>>>>>>>>>>>>>>>> $func" | tee -a $LOG_FILE
    $func   # Execute function
else
    echo "Error: function $func not found" | tee -a $LOG_FILE
    usage
fi
