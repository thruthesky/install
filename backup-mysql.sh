#/bin/sh

db_user=dev
db_passwd=***********
db_name=dev
dir_backup=/home/backup/data/database
error_log=$dir_backup/error.log
failure_log=$dir_backup/failure.log
success_log=$dir_backup/success.log

folder=$(date +%A)
if [[ $folder == 'Thursday' ]]; then
folder=${folder}-$(date +%Y-%m)
fi



mysqldump -u$db_user -p$db_passwd --single-transaction --quick --lock-tables=false $db_name > $dir_root_backup/$folder.sql 2>>$error_log

if [ "$?" = 0 ]; then
        gzip $dir_root_backup/$folder.sql 2>>$error_log
        if [ "$?" = 0 ]; then
		echo "[$(date)] : success" >>$success_log
	else
                echo "[$(date)] : gzip" >>$failure_log
        fi
else
        echo "[$(date)] : mysqldump" >>$failure_log
fi
