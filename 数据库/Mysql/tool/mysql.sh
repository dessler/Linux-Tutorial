#!/bin/bash

# 定义循环次数
iterations=1000000

# MySQL 连接参数
MYSQL_USER="your_mysql_username"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_DATABASE="your_mysql_database"

# 循环插入数据
for ((i=1; i<=$iterations; i++)); do
    # 生成随机的用户名和邮箱
    username="user_$i"
    email="user$i@example.com"
    
    # 插入数据到 MySQL 数据库
    mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "INSERT INTO users (username, email) VALUES ('$username', '$email');"
    
    echo "Inserted data for $username"
    
    # 等待一段时间，可以根据需要调整
    sleep 1
done
