#/bin/sh

db_user=dev
db_passwd=***********
db_name=dev
dir_root_backup=/home/backup/data/database

folder=$(date +%A)
if [[ $folder == 'Thursday' ]]; then
folder=${folder}-$(date +%Y-%m)
fi

#mysqldump -u$db_user -p$db_passwd $db_name | gzip > $dir_root_backup/$folder.gz 2>/dev/null


mysqldump -u$db_user -p$db_passwd $db_name > $dir_root_backup/$folder.sql 2>/dev/null

if [ "$?" = 0 ]; then
        gzip $dir_root_backup/$folder.sql
        if [ "$?" != 0 ]; then
                echo "[$(date)] : failed on gzip" >> $dir_root_backup/error.log
        fi
else
        echo "[$(date)] : failed on mysqldump" >> $dir_root_backup/error.log
fi
