#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dump directory variables
SRCDIR='/tmp/s3backups'
DESTDIR='bucket-folder'
BUCKET='bucket'
FILENAME='dev-dump'

# database access details
HOST=''
USER='root'
PASS=''

#### END CONFIGURATION ####

# dump each database, excluding roles and system databases, to sql files
mkdir -p $SRCDIR

DBLIST=`psql -l -U $USER \
  | awk '{print $1}' | grep -v "+" | grep -v "Name" | \
  grep -v "List" | grep -v "(" | grep -v "template" | \
  grep -v "postgres" | grep -v "root" | grep -v "|" | grep -v "|"`

for DB in ${DBLIST}
do
pg_dump -Oxc -U $USER $DB > $SRCDIR/$DB.sql 
done

# tar all the databases into $FILENAME.tar.gz
cd $SRCDIR
tar -czPf $FILENAME.tar.gz *.sql
cd

# upload all databases
/usr/bin/s3cmd put $SRCDIR/$FILENAME.tar.gz s3://$BUCKET/$DESTDIR/

# remove all local dumps
rm -f $SRCDIR/$FILENAME.tar.gz

for FILE in $(echo $(ls $SRCDIR/))
do
rm -f $SRCDIR/$FILE
done