#!/bin/bash

# Assign variables 
BACKUP_DIRS="/root /home /usr /mnt /app /media /var/log /var/lib /var/local /var/backups /var/opt /pol"
BACKUP_LOCATION="/backup"
BACKUP_LOG="/var/log/backup.log"
TIMESTAMP=$(date +%m-%d-%Y)
# Create backup directory
mkdir -p "$BACKUP_LOCATION"
# Clear existing logs
> "$BACKUP_LOG"
# Loop through each directory
for DIRECTORY in $BACKUP_DIRS; do
DIRECTORY_NAME=$(basename "$DIRECTORY")
BACKUP_FILE="$BACKUP_LOCATION/$DIRECTORY_NAME-$TIMESTAMP.tar.gz"
# Remove old backups
echo "Removing old backups, time: $TIMESTAMP." | tee -a "$BACKUP_LOG"
find "$BACKUP_LOCATION" -type f -name "$DIRECTORY_NAME-*.tar.gz" -delete
echo "$TIMESTAMP removing backup of $DIRECTORY." | tee -a "$BACKUP_LOG"
# Log backups
echo "Backing up $DIRECTORY to $BACKUP_FILE" | tee -a "$BACKUP_LOG"
# Perform backups
tar --exclude '*/docker*' -czf "$BACKUP_FILE" "$DIRECTORY" 2>&1 | tee -a "$BACKUP_LOG"
    # Check for successful backup
    if [ $? = 0 ]; then
        echo " $TIMESTAMP Backup of $DIRECTORY successful." | tee -a "$BACKUP_LOG"
    else
        echo "$TIMESTAMP Backup of $DIRECTORY unsuccessful." | tee -a "$BACKUP_LOG"
    fi
done

echo "$TIMESTAMP Backups complete, check $BACKUP_LOG." | tee -a "$BACKUP_LOG"

