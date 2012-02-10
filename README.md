Amazon S3 Backup Scripts
========================

This is a collection of Amazon S3 backup scripts for unix-based systems. The scripts make use of [s3cmd](https://github.com/s3tools/s3cmd) ([website](http://s3tools.org/s3cmd)) to backup files and databases to S3.

The s3-mysql-backup.sh script performs the following operations each time you run it:

1. Checks, repairs, and optimizes each MySQL database.
2. Dumps each database into its own .sql file.
3. Tars all of the .sql files into a directory on the server.
4. Uploads the tarred file to S3 and deletes the tarred file from the local server.
5. Deletes backups older than 7 days from the S3 bucket.

Setup
-----

1. Install s3cmd. See [s3tools.org/repositories](http://s3tools.org/repositories) for instructions.
2. Configure s3cmd to work with your AWS account: `s3cmd --configure`. You can access or generate your AWS security credentials [here](https://aws-portal.amazon.com/gp/aws/developer/account/index.html?ie=UTF8&action=access-key).
3. Create an S3 bucket: `s3cmd mb s3://my-database-backups`.
4. Put the *.sh backup script somewhere on your server (ie - `/root/scripts`).
5. Give the *.sh backup script 755 permissions: `chown 755 /root/scripts/backups/s3-mysql-backup.sh`.
6. Edit the variables near the top of backup script to match your bucket, directory, and MySQL authentication.


Example Cron Usage
------------------

1. Edit your crontab: `crontab -e`.
2. Add the following line to your crontab. This will execute the backup script at 2am every day and will email you the results of the run.

		0 2 * * * /path/to/your/script.sh |mail -s "Backup Cron Output" -c email@exmaple.com