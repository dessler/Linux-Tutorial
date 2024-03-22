```
#!/bin/bash

#需要填写下面的变量即可完成，备份还原的时候需要确保操作ip具有链接pg的权限
#为了避免库错误，所以这里只定义了一个变量

# 定义变量
BACKUP_SERVER_IP=""
BACKUP_SERVER_USER=""
BACKUP_SERVER_PASSWORD=""
RESTORE_SERVER_IP=""
RESTORE_SERVER_USER=""
RESTORE_SERVER_PASSWORD=""
DB_NAME=""

# 本地备份路径
LOCAL_BACKUP_PATH="/root/pg/${DB_NAME}_backup_$(date +'%Y%m%d_%H%M%S').sql"
LOG_FILE="/root/pg/backup_restore.log"

# 备份操作
echo "$(date +'%Y-%m-%d %H:%M:%S') - Starting backup $DB_NAME..." >> $LOG_FILE
PGPASSWORD=$BACKUP_SERVER_PASSWORD pg_dump -h $BACKUP_SERVER_IP -U $BACKUP_SERVER_USER -d $DB_NAME -f $LOCAL_BACKUP_PATH

if [ $? -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Backup successful $DB_NAME" >> $LOG_FILE
else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Backup failed $DB_NAME, exiting" >> $LOG_FILE
    exit 1
fi

# 清理数据
echo "$(date +'%Y-%m-%d %H:%M:%S') - Starting clear $DB_NAME..." >> $LOG_FILE
PGPASSWORD=$RESTORE_SERVER_PASSWORD psql -h $RESTORE_SERVER_IP -U $RESTORE_SERVER_USER -d $DB_NAME -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;"

# 还原操作
echo "$(date +'%Y-%m-%d %H:%M:%S') - Starting restore $DB_NAME..." >> $LOG_FILE
PGPASSWORD=$RESTORE_SERVER_PASSWORD psql -h $RESTORE_SERVER_IP -U $RESTORE_SERVER_USER -d $DB_NAME -f $LOCAL_BACKUP_PATH

if [ $? -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Restore successful $DB_NAME" >> $LOG_FILE
else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Restore failed $DB_NAME" >> $LOG_FILE
    exit 1
fi

echo "$DB_NAME Backup and restore process completed successfully"
```

