#!/usr/bin/env bash

SOURCE_MACHINE="postgres0@pg167"

BACKUPS_DIR="backups"

PGPATH="quo58"
TMP1_DIR="hqa17"
TMP2_DIR="hfh15"

NEW_TMP1_DIR="hqa17.new"
NEW_TMP2_DIR="hfh15.new"

echo "Database restore from failed disk process start"

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

echo "Copying server dir $PGPATH"
rsync -avz $BACKUPS_DIR/"$BACKUP_NAME"/"$PGPATH" $SOURCE_MACHINE:~/"$SOURCE_PATH"
echo "Server dir copied"

echo "Copying tablespace $TMP1_DIR into $NEW_TMP1_DIR"
rsync -avz $BACKUPS_DIR/"$BACKUP_NAME"/"$TMP1_DIR" $SOURCE_MACHINE:~/"$NEW_TMP1_DIR"
echo "Tablespace $TMP1_DIR copied"

echo "Copying tablespace $TMP2_DIR into $NEW_TMP2_DIR"
rsync -avz $BACKUPS_DIR/"$BACKUP_NAME"/"$TMP2_DIR" $SOURCE_MACHINE:~/"$NEW_TMP2_DIR"
echo "Tablespace $TMP2_DIR copied"

echo "Restoring tablespaces and start database"
ssh $SOURCE_MACHINE "
  ln -sF \$HOME/$NEW_TMP1_DIR/ $PGPATH/pg_tblspc/16385
  ln -sF \$HOME/$NEW_TMP2_DIR/ $PGPATH/pg_tblspc/16386
  set -a && source .env && pg_ctl start -l /dev/null
"
echo "Database started"

echo "Database restore from failed disk process finish"
