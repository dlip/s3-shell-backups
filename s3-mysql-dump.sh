#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dump directory variables
SRCDIR='/tmp/s3backups'
DESTDIR='bucket-folder'
BUCKET='bucket'

# database access details
HOST='127.0.0.1'
USER='dbusername'
PASS='dbpassword'

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist and cd into it
mkdir -p $SRCDIR
cd $SRCDIR

# dump each database to its own sql file and upload it to s3
for DB in $(mysql -u$USER -p$PASS -BNe 'show databases' | grep -Ev 'mysql|information_schema|performance_schema')
do
mysqldump -h$HOST -u$USER -p$PASS --quote-names --create-options --force $DB > $DB.sql
tar -czPf $DB.tar.gz $DB.sql
/usr/bin/s3cmd put $SRCDIR/$DB.tar.gz s3://$BUCKET/$DESTDIR/
done

# remove all files in our source directory
cd
rm -f $SRCDIR/*