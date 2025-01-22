#!/bin/bash

# Configuration variables
DB_CREDENTIALS=(
    "-u jokedbuser"
    "-p123456"
    "-h db-jokesapp.cuzcrct8tvj7.us-east-1.rds.amazonaws.com"
)
DB_NAME="jokedb"
BACKUP_DIR="/mnt/backup"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DUMP_FILE="/tmp/mysql_backup_${DB_NAME}_${DATE}.sql"
ARCHIVE_FILE="/tmp/mysql_backup_${DB_NAME}_${DATE}.tar.gz"

# Ensure backup directory exists
[ -d "$BACKUP_DIR" ] || { 
    echo "Backup directory $BACKUP_DIR does not exist. Please create or mount it."; 
    exit 1; 
}

# Create a MySQL dump
echo "Creating MySQL dump..."
if ! mysqldump "${DB_CREDENTIALS[@]}" "$DB_NAME" > "$DUMP_FILE"; then
    echo "Failed to create MySQL dump."
    exit 1
fi
echo "MySQL dump created: $DUMP_FILE"

# Compress the dump file
echo "Compressing dump..."
if ! tar -czf "$ARCHIVE_FILE" -C /tmp "$(basename "$DUMP_FILE")"; then
    echo "Failed to compress dump."
    exit 1
fi
echo "Dump compressed: $ARCHIVE_FILE"

# Move the archive to the backup directory
echo "Moving archive to $BACKUP_DIR..."
if ! sudo mv "$ARCHIVE_FILE" "$BACKUP_DIR/"; then
    echo "Failed to move archive."
    exit 1
fi

# Cleanup the temporary dump file
rm -f "$DUMP_FILE"

echo "Backup completed successfully. Archive saved to $BACKUP_DIR/$(basename "$ARCHIVE_FILE")"
