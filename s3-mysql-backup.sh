#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=`date +%Y-%m-%d`
LASTDATE=$(date +%Y-%m-%d --date='1 week ago')

# set local server tmp backup directory
SRCDIR='tmp/s3backups'

# set s3 backup bucket and folder
DESTDIR='bucket-folder'
BUCKET='bucket'

# set mysql access details
HOST='localhost'
USER='backupuser'
PASS='backuppass'

#### END CONFIGURATION ####

# check, repair, optimize, and dump each database to its own sql file
for DB in $(echo 'show databases' | mysql -h$HOST -u$USER -p$PASS --batch -N)
do
mysqlcheck -h$HOST -u$USER -p$PASS --auto-repair --check --optimize $DB
mysqldump -h$HOST -u$USER -p$PASS --quote-names --create-options --force $DB > /$SRCDIR/$DB.sql
done

# tar all the databases into $NOWDATE-backups.tar.gz
cd /$SRCDIR/
tar -czf $NOWDATE-backup.tar.gz .
cd

# upload all databases
/usr/bin/s3cmd put /$SRCDIR/$NOWDATE-backup.tar.gz s3://$BUCKET/$DESTDIR/

# rotate out old backups
/usr/bin/s3cmd del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-backup.tar.gz

# remove all local dumps
rm /$SRCDIR/$NOWDATE-backup.tar.gz

for FILE in $(echo $(ls /$SRCDIR/))
do
rm /$SRCDIR/$FILE
done