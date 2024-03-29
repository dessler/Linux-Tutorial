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

#查看当前库有多少表，需要进入库
SELECT count(*) AS table_count FROM information_schema.tables WHERE table_schema = 'public' AND table_catalog = 'xxxx';

#查看当前库每个表有多少条记录(需要进入库)，如果表太多，可以添加limit

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

```
#启用扩展
CREATE EXTENSION citext;  //定义了一种新的数据类型，来代替文本实现忽略大小写的问题

#常用扩展
pgcrypto: 提供了各种密码学函数，用于数据加密、解密和哈希等操作。
uuid-ossp: 支持生成和处理 UUID（通用唯一标识符），用于唯一标识数据行或对象。
hstore: 提供了一个键值对的存储模型，可以在单个列中存储非结构化数据。
pg_trgm: 提供了 trigram 相似度匹配功能，用于进行模糊文本搜索和匹配。
ltree: 支持层次树结构数据的存储和查询，用于处理层次结构数据。
pg_stat_statements: 收集并展示 SQL 查询的统计信息，用于性能调优和查询优化。
postgis: 提供了地理信息系统（GIS）功能，支持地理空间数据的存储和查询。
pg_partman: 提供了表分区管理功能，用于自动管理大型表的数据分区。
pglogical: 实现逻辑复制功能，用于在不同 PostgreSQL 数据库之间进行数据同步和复制。
citext: 提供了大小写不敏感的文本比较和匹配功能，简化文本处理过程。

#查询开启了什么扩展
SELECT * FROM pg_extension;
或者
\dx 
#查询有哪些扩展可用
SELECT * FROM pg_available_extensions;

#部分扩展pg，可能不会自带，需要额外导入包才可以
```

```
在pg中，默认会有2个库template0和template1
template0 是一个干净的、只读的空模板数据库，用于创建全新的数据库，不允许用户修改它的内容。
template1 是一个可以修改的模板数据库，用户可以向其中添加自定义数据、设置和表结构，然后将其用作创建新数据库的模板，没加参数默认就是用的这个库
```

```
#查看事务级别，命令行修改仅仅针对当前事务生效，全局修改需要修改配置文件并重启服务。默认级别是read committed，事务只能读取已经提交的数据变更，这可以避免脏读，但仍可能出现不可重复读和幻读的问题。
SHOW transaction_isolation;
SELECT current_setting('transaction_isolation') AS isolation_level;
```

