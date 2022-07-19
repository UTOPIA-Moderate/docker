#!/bin/bash

CWD=$(dirname $(readlink -f  $0))
TODAY=$(date +%F)
BACKUPNAME=vps-bitwarden-$TODAY.tar.gz
TARGET=/home/bitwarden
ENCBACKUP=${BACKUPNAME}.aes256cbc

cd $CWD
tar czvf $BACKUPNAME $TARGET

openssl enc  -e -aes-256-cbc -in $BACKUPNAME -out ${ENCBACKUP} -k qmdsb

rclone copy  ${ENCBACKUP} devil:/bitwarden
 
find $CWD -name "vps-bitwarden-*" -mtime +7 | xargs rm -f
