#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=`date +%Y-%m-%d`
LASTDATE=$(date +%Y-%m-%d --date='1 week ago')

# set backup directory variables
SRCDIR='/tmp/s3backups'
DESTDIR='bucket-folder'
BUCKET='bucket'

# database access details
HOST=''
USER='backupuser'
PASS=''

#### END CONFIGURATION ####

# create the tmp database directory if it doesn't exist
mkdir -p $SRCDIR

# dump each database, excluding system databases, to sql files
DBLIST=`psql -l -U $USER \
| awk '{print $1}' | grep -v "+" | grep -v "Name" | \
grep -v "List" | grep -v "(" | grep -v "template" | \
grep -v "postgres" | grep -v "root" | grep -v "|" | grep -v "|"`

for DB in ${DBLIST}
do
pg_dump -U $USER $DB -f $SRCDIR/$DB.sql
done

# tar all the databases into $NOWDATE-backups.tar.gz
cd $SRCDIR
tar -czPf $NOWDATE-backup.tar.gz *.sql
cd

# upload all databases
/usr/bin/s3cmd put $SRCDIR/$NOWDATE-backup.tar.gz s3://$BUCKET/$DESTDIR/

# rotate out old backups
/usr/bin/s3cmd del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-backup.tar.gz

# remove all local dumps
rm -f $SRCDIR/$NOWDATE-backup.tar.gz

for FILE in $(echo $(ls $SRCDIR/))
do
rm -f $SRCDIR/$FILE
done