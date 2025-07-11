#!/bin/bash

# === CONFIGURATION ===
MYSQL_USER="root"
MYSQL_PASS="your_password"
MYSQL_HOST="localhost"
MYSQL_DB="your_database"
MYSQL_TABLE="your_table"
DATE_COLUMN="created_at"
BATCH_SIZE=500

# === DELETE OLD RECORDS IN BATCHES ===
echo "Starting deletion process..."

while :; do
    ROWS_DELETED=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" "$MYSQL_DB" -N -e "
        DELETE FROM $MYSQL_TABLE
        WHERE $DATE_COLUMN < NOW() - INTERVAL 30 DAY
        LIMIT $BATCH_SIZE;
        SELECT ROW_COUNT();
    ")

    echo "Deleted $ROWS_DELETED rows..."

    # Break if less than batch size (last batch)
    if [ "$ROWS_DELETED" -lt "$BATCH_SIZE" ]; then
        break
    fi
done

# === OPTIMIZE TABLE ===
echo "Optimizing table..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" "$MYSQL_DB" -e "OPTIMIZE TABLE $MYSQL_TABLE;"

echo "Done."
