#!/bin/bash

BACKUP_SRC="/etc"
S3_BUCKET="s3://my-config-backups"
DATE=$(date +%F-%H%M)
ARCHIVE="/tmp/config-backup-$DATE.tar.gz"

tar -czf $ARCHIVE $BACKUP_SRC

aws s3 cp $ARCHIVE $S3_BUCKET/

#potential cron schedule 0 2 * * * /usr/local/bin/etc-backup.sh
