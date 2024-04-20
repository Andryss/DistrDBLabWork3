#!/usr/bin/env bash

BACKUPS_DIR="backups"

PGPATH="quo58"

TMP1_DIR="hqa17"
TMP2_DIR="hfh15"

echo "Database restore process start"

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
set -a && source .env
pg_ctl stop
echo "Database stopped"

echo "Clearing last backup if exists"
if [ -d $PGPATH ]; then
    rm -rf $PGPATH
fi
if [ -d $TMP1_DIR ]; then
    rm -rf $TMP1_DIR
fi
if [ -d $TMP2_DIR ]; then
    rm -rf $TMP2_DIR
fi
echo "Last backup cleared"

echo "Extracting backup"
cp -r $BACKUPS_DIR/"$BACKUP_NAME"/* ~
echo "Backup extracted"

echo "Restoring tablespaces"
ln -sF "$HOME"/"$TMP1_DIR" $PGPATH/pg_tblspc/16385
ln -sF "$HOME"/"$TMP2_DIR" $PGPATH/pg_tblspc/16386
chmod 777 $TMP1_DIR $TMP2_DIR
echo "Tablespaces restored"

echo "Starting database"
pg_ctl start -l /dev/null
echo "Database started"

echo "Database restore process finish"
