#!/usr/bin/env bash

SOURCE_MACHINE="postgres0@pg167"

BACKUPS_DIR="backups"

echo "Database recover process start"

echo "Determining backup to restore"
if [ $# -eq 0 ];
then
    echo "No arguments supplied, backing up newest snapshot"
    if [ "$(ls $BACKUPS_DIR | wc -l)" -eq 0 ];
    then
        echo "Nothing to backup, skipping"
        exit
    fi
    BACKUP_NAME=$(ls $BACKUPS_DIR | tail -1)
else
    BACKUP_NAME=$1
fi
echo "Backing up $BACKUP_NAME"

echo "Stopping database if exists"
ssh $SOURCE_MACHINE "set -a && source .env && pg_ctl stop"
echo "Database stopped"

echo "Copying backup"
rsync -avz $BACKUPS_DIR/"$BACKUP_NAME"/* $SOURCE_MACHINE:~/
echo "Backup copied"

echo "Database recover process finish"
