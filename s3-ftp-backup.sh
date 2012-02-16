#!/bin/sh

# Backup from directory on server

/usr/local/bin/s3cmd sync -v --recursive /home/backups/* s3://s3-bucket-name