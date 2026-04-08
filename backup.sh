#!/bin/bash

CONFIG_FILE="$(dirname "$0")/backup.conf"
if [[ -f $CONFIG_FILE ]]; then
    source $CONFIG_FILE
else
    echo "Error: Configuration file $CONFIG_FILE not found!"
    exit 1
fi

PATHS_FILE="$(dirname "$0")/paths.txt"
BACKUP_FILEPATH="$TMP_BACKUP_PATH_WITH_FILE_PREFIX$(date +"%Y-%m-%d_%H-%M-%S").tar.gz"
CONN_STRING=$REMOTE_USER@$REMOTE_HOST
# MAX_BACKUPS=${1:-1}

if [[ ! -f $PATHS_FILE ]]; then
    echo "Error: $PATHS_FILE not found!"
    exit 1
fi

#TMP_MONGODB_PATH="/tmp/mongodb_dump"
#mongodump -o $TMP_MONGODB_PATH

echo "Creating archive: $BACKUP_FILEPATH"
sudo tar -czf $BACKUP_FILEPATH --exclude node_modules --exclude .next -T $PATHS_FILE

#rm -rf $TMP_MONGODB_PATH

echo "Transferring archive to $CONN_STRING:$REMOTE_PATH"
ssh $CONN_STRING mkdir -p $REMOTE_PATH/
rsync -vrlcz -e ssh $BACKUP_FILEPATH $CONN_STRING:$REMOTE_PATH
#scp -v $BACKUP_FILEPATH $CONN_STRING:$REMOTE_PATH/ # Optional upload method

sudo rm -f $BACKUP_FILEPATH

if [[ $? -eq 0 ]]; then
    echo "Transfer successful."
    if [[ -n "${MAX_BACKUPS:-}" ]]; then
        echo "Removing old backups on remote - only keep latest $MAX_BACKUPS."
        ssh $CONN_STRING "ls -t $REMOTE_PATH/* | tail -n +$((MAX_BACKUPS+1)) | xargs -r rm --"
    else
        echo "Keeping all old backups, MAX_BACKUPS not set."
    fi
else
    echo "Transfer failed."
    exit 1
fi

echo "Backup process completed."
