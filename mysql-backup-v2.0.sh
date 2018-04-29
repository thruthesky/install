#/bin/sh
#
# It does `mysqldump` to saves SQL of the database into a file name. 
# File name is consisted with 'week-hour'. So, you can run this every hour with cronjob.
# Or you can run it twice a day.
#
# Example of crontab.
#
#       * 1,13 * * * ~/mysql-backup-v2.0.sh
#


####################################################
#
# Settings
#
####################################################

## Database backup folder & log files. You can change this folder whereever you want.
dir_backup=./database-backup

## Database user login.
db_user=db_user
## Database user password
db_passwd=db_password
## Database name
db_name=db_name



#############
# Code begins
#############

## Create backup folder if it does not exists.
mkdir $dir_backup 2>> /dev/null

## Log files.
error_log=$dir_backup/error.log
failure_log=$dir_backup/failure.log
success_log=$dir_backup/success.log

## Backup file name. Week-HH. 1-4 is monday 4 am.
backup_file_name=$(date +%u-%H)


mysqldump -u$db_user -p$db_passwd --single-transaction --quick --lock-tables=false $db_name > $dir_backup/$backup_file_name.sql 2>&1

if [ "$?" = 0 ]; then
        ## delete exist file.
        rm -f $dir_backup/$backup_file_name.sql.gz
        ## zip it.
        gzip $dir_backup/$backup_file_name.sql 2>>$error_log
        ## leave log
        if [ "$?" = 0 ]; then
                echo "[$(date)] : success $backup_file_name" >>$success_log
        else
                echo "[$(date)] : gzip" >>$failure_log
                rm -f $dir_backup/$backup_file_name.sql
        fi
else
        echo "[$(date)] : mysqldump" >>$failure_log
        cat $dir_backup/$backup_file_name.sql >>$error_log
        rm -f $dir_backup/$backup_file_name.sql
fi
