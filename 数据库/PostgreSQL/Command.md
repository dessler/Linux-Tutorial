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


#备份单个库,不需要输入密码
pg_dump -U postgres -d dbname  -f dbname.sql

```



``` 
#还原单个库，库必须要提前创建
#默认不加参数的pg_dump的备份只能用psql还原
psql -h 192.168.1.1 -p 5432 -U postgres -d public  -f  public.sql 
```

