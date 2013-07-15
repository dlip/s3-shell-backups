#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=`date +%Y-%m-%d`
LASTDATE=$(date +%Y-%m-%d --date='1 week ago')

# set backup directory variables
SRCDIR='/tmp/s3backups'
DESTDIR='path/to/s3folder'
BUCKET='s3bucket'

# database access details
HOST='127.0.0.1'
PORT='3306'
USER='user'
PASS='pass'

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist
mkdir -p $SRCDIR

# repair, optimize, and dump each database to its own sql file
for DB in $(mysql -h$HOST -P$PORT -u$USER -p$PASS -BNe 'show databases' | grep -Ev 'mysql|information_schema|performance_schema')
do
mysqldump -h$HOST -P$PORT -u$USER -p$PASS --quote-names --create-options --force $DB > $SRCDIR/$DB.sql
mysqlcheck -h$HOST -P$PORT -u$USER -p$PASS --auto-repair --optimize $DB
done

# tar all the databases into $NOWDATE-backups.tar.gz
cd $SRCDIR
tar -czPf $NOWDATE-backup.tar.gz *.sql

# upload backup to s3
/usr/bin/s3cmd put $SRCDIR/$NOWDATE-backup.tar.gz s3://$BUCKET/$DESTDIR/

# delete old backups from s3
/usr/bin/s3cmd del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-backup.tar.gz

# remove all files in our source directory
cd
rm -f $SRCDIR/*
