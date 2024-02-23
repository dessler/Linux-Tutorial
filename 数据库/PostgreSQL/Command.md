# PG 常用命令

```
\l       显示所有数据库
\c xxx   进入某个数据
\dt      显示所有表
\d xxx   显示表结构   
```

```
CREATE USER <new_username> WITH PASSWORD '<password>';  创建用户并设置密码
GRANT ALL PRIVILEGES  ON DATABASE <database> TO <new_username>; 将用户绑定到特定库，并具有curd 权限（这里并不能插入数据）
SELECT table_name FROM <database>.tables WHERE table_schema = 'public'; 
GRANT SELECT, INSERT, UPDATE, DELETE ON my_table TO user01;                3条预计执行完毕以后，才有对表里面操作。

如果表还有自增字段，则还需要GRANT ALL PRIVILEGES ON SEQUENCE my_table_id_seq TO user01;否则会出现
```

```
pg_basebackup -D /var/lib/pgsql/14/data -h 192.168.0.186 -p 5432 -U replica -X stream -P   备份（用于数据同步或者建立主从）
SELECT pg_is_in_recovery(); 查询是输入从 还是主
SELECT pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(); 检查从库状态，确认从库是否有最新的数据
```

```
#备份
#备份远程的库，有多少库，就需要输入多少次密码。
pg_dumpall -U postgres -h localhost -p 5432 -f back.sql

#备份本机不需要输入密码
pg_dumpall -U postgres  -f back.sql

#备份单个库,不需要输入密码，默认文本格式，只能用psql还原
pg_dump -U postgres -d dbname  -f dbname.sql

#备份单个库,不需要输入密码，使用二进制备份
pg_dump -U postgres -d dbname -F c -f dbname.sql


```



``` 
#还原单个库，库必须要提前创建
#默认不加参数的pg_dump的备份只能用psql还原
psql -h 192.168.1.1 -p 5432 -U postgres -d public  -f  public.sql 

#二进制备份还原
pg_restore -h 192.168.0.182 -U postgres -d public1  back2.sql 
```



```
#创建超级管理员,需要超级管理员才可以创建。
CREATE ROLE super_admin WITH SUPERUSER LOGIN PASSWORD 'your_password';
```



```
#查看每个库的大小
SELECT pg_database.datname AS "Database Name", pg_size_pretty(pg_database_size(pg_database.datname)) AS "Size" FROM pg_database;

#查看所有用户
SELECT usename AS "Username", usecreatedb AS "Can Create DB?", usesuper AS "Is Superuser?" FROM pg_user;

#创建表（这里需要注意，在pg里面每个表还有自己的owner，如果权限不对也是无法curd的）
#比如如果某个库绑定了某个账号，如果用psql用户进入库创建了表，则这个绑定的用户对这个表也无curd权限。
CREATE TABLE users1 (id serial PRIMARY KEY, name varchar(100) NOT NULL, email varchar(100) UNIQUE);

#修改表的owner
ALTER TABLE table_name OWNER TO new_owner;

#插入数据
INSERT INTO users1 (name, email) VALUES ('User', 'user@example.com');

```

