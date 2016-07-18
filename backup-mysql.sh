#/bin/sh

db_user=dev
db_passwd=Wc~0453224133
db_name=dev
dir_backup=/home/backup/data/database
error_log=$dir_backup/error.log
failure_log=$dir_backup/failure.log
success_log=$dir_backup/success.log

folder=$(date +%A)
if [[ $folder == 'Thursday' ]]; then
folder=${folder}-$(date +%Y-%m)
fi



mysqldump -u$db_user -p$db_passwd --single-transaction --quick --lock-tables=false $db_name > $dir_backup/$folder.sql 2>&1

if [ "$?" = 0 ]; then
	rm -f $dir_backup/$folder.sql.gz
        gzip $dir_backup/$folder.sql 2>>$error_log
        if [ "$?" = 0 ]; then
		echo "[$(date)] : success $folder" >>$success_log
	else
                echo "[$(date)] : gzip" >>$failure_log
		rm -f $dir_backup/$folder.sql
        fi
else
        echo "[$(date)] : mysqldump" >>$failure_log
	cat $dir_backup/$folder.sql >>$error_log
	rm -f $dir_backup/$folder.sql
fi
