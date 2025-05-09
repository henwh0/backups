#!/bin/bash

# Exit on error, undefined var, or pipefail
set -euo pipefail

# Assign variables 
BACKUP_DIRS="/root /home /usr /mnt /app /media /var/log /var/lib /var/local /var/backups /var/opt /pol"
BACKUP_LOCATION="/backup"
BACKUP_LOG="/var/log/backup.log"
TIMESTAMP=$(date +%m-%d-%Y)

# Ensure backup directory exists
mkdir -p "$BACKUP_LOCATION"

# Clear and initialize log
> "$BACKUP_LOG"
echo "======================================" | tee -a "$BACKUP_LOG"
echo "$TIMESTAMP Starting backup process" | tee -a "$BACKUP_LOG"
echo "======================================" | tee -a "$BACKUP_LOG"

# Remove all old backups once before starting
echo "$TIMESTAMP Removing all old backups in $BACKUP_LOCATION" | tee -a "$BACKUP_LOG"
find "$BACKUP_LOCATION" -maxdepth 1 -type f -name "*.tar.gz" -delete

# Loop through each directory
for DIRECTORY in $BACKUP_DIRS; do
    DIRECTORY_NAME=$(basename "$DIRECTORY")
    BACKUP_FILE="$BACKUP_LOCATION/$DIRECTORY_NAME-$TIMESTAMP.tar.gz"

    echo "--------------------------------------" | tee -a "$BACKUP_LOG"
    echo "$TIMESTAMP Backing up $DIRECTORY" | tee -a "$BACKUP_LOG"

    # Check if directory exists
    if [ -d "$DIRECTORY" ]; then
        # Perform backup
        tar --exclude='*/docker/*' -cf - "$DIRECTORY" | pv -s $(du -sb "$DIRECTORY" | awk '{print $1}') | gzip > "$BACKUP_FILE" | tee -a "$BACKUP_LOG"

        # Check for success
        if [ $? -eq 0 ]; then
            echo "$TIMESTAMP Backup of $DIRECTORY successful." | tee -a "$BACKUP_LOG"
        else
            echo "$TIMESTAMP Backup of $DIRECTORY failed." | tee -a "$BACKUP_LOG"
        fi
    else
        echo "$TIMESTAMP Warning: $DIRECTORY does not exist or is not a directory." | tee -a "$BACKUP_LOG"
    fi
done

echo "======================================" | tee -a "$BACKUP_LOG"
echo "$TIMESTAMP All backups complete. Check log at $BACKUP_LOG" | tee -a "$BACKUP_LOG"
echo "======================================" | tee -a "$BACKUP_LOG"
