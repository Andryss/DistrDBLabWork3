#!/usr/bin/env bash

SOURCE_MACHINE="postgres0@pg167"
SOURCE_PATH="~/quo58"
TMP1_PATH="~/hqa17"
TMP2_PATH="~/hfh15"

BACKUPS_DIR="backups"
BACKUP_NAME=$(date "+%Y%m%d_%H%M%S")

MAX_BACKUPS_COUNT=14

echo "Database backup process start"

echo "Stopping database"
ssh $SOURCE_MACHINE "set -a && source .env && pg_ctl stop"
echo "Database stopped"

echo "Copying data"
rsync -avz $SOURCE_MACHINE:$SOURCE_PATH :$TMP1_PATH :$TMP2_PATH $BACKUPS_DIR/"$BACKUP_NAME"
echo "Data copied"

echo "Starting database"
ssh $SOURCE_MACHINE "set -a && source .env && pg_ctl start -l /dev/null"
echo "Database started"

BACKUPS_COUNT=$(ls $BACKUPS_DIR | wc -l)

if (( $BACKUPS_COUNT > $MAX_BACKUPS_COUNT ));
then

  OLDEST_BACKUP=$(ls $BACKUPS_DIR | head -1)
  echo "Backups count exceeded $MAX_BACKUPS_COUNT, removing $OLDEST_BACKUP"
  rm -rf $BACKUPS_DIR/"$OLDEST_BACKUP"
  echo "Oldest backup removed"

fi

echo "Database backup process finish"
