[toc]

# Mysql 常用命令

在Mysql的命令操作中，本身是不区分大小写的。例如，SELECT 和 select 是等效的。

## 数据库本身操作

### 1.库操作

#### 1.1 创建数据库

```
#创建一个新的数据库
CREATE DATABASE database_name;
```

#### 1.2 删除数据库

```
#删除一个已有的数据库,该操作需要慎重。
DROP DATABASE database_name; 
```

#### 1.3 进入数据库

```
#进入数据库
USE database_name; 
```

#### 1.4 查看所有库

```
#查看所有库
SHOW DATABASE;
```

### 2.账号及权限操作

#### 2.1 创建用户

```
#创建一个用户，并设置登录密码
CREATE USER 'username'@'hostname' IDENTIFIED BY 'password';
```

#### 2.2 添加权限

```
#添加权限
GRANT privilege_type ON database_name.table_name TO 'username'@'hostname';
```

#### 2.3 创建用户同时添加权限

```
#这个看个人习惯，个人习惯创建用户用户同时添加权限
GRANT privilege_type ON database_name.table_name TO 'username'@'hostname' IDENTIFIED BY 'password';
```

#### 2.4 撤销权限

```
#撤销指定用户在指定库表的权限
REVOKE privilege_type ON database_name.table_name FROM 'username'@'hostname';
#撤销指定用户的所有权限
REVOKE ALL PRIVILEGES ON database_name.* FROM 'username'@'hostname';
```

#### 2.5 修改密码

```
ALTER USER 'username'@'hostname' IDENTIFIED BY 'new_password';
```

#### 2.6  删除用户

```
DROP USER 'username'@'hostname'; 
```

#### 2.7 查看用户权限

```
SHOW GRANTS FOR 'username'@'hostname';
```

#### 2.8 查看所有用户的的支持的连接地址

```
select * from user,host mysql.user;
```

特别注意 

1.添加权限的时候时候可以用`*.*`代表所有库表
2.hostname 

- '%'：表示任意主机。

- 'localhost'：表示本地主机。

- '192.168.0.1'：表示只允许该地址连接

- '192.168.0.%':  表示只要是192.168.0.0/24都可以连接

3.权限

- ALL PRIVILEGES：授予用户在指定数据库上的所有权限。

- SELECT：允许用户查询（读取）表中的数据。

- INSERT：允许用户向表中插入新的数据。

- UPDATE：允许用户更新表中的数据。

- DELETE：允许用户从表中删除数据。

- CREATE：允许用户创建新的数据库或表。

- DROP：允许用户删除数据库或表。

- ALTER：允许用户修改表的结构。

- INDEX：允许用户创建或删除索引。

- GRANT OPTION：允许用户将自己拥有的权限授予其他用户。
- 当然还有些特殊权限，比如配置主从的时候用到的`REPLICATION SLAVE`权限。

### 3.备份及还原

在中小规模情况下用mysqldump逻辑备份并没有啥问题，但是在大型系统里面就很少用到逻辑备份。大型数据至少都是主从架构，所以一般备份是逻辑备份+binglog备份。

#### 3.1 备份

```
#1.备份指定库表，如果不写表，则是备份所有表。
mysqldump -u username -p database_name table1 table2 > backup.sql
2.备份全部库表
#mysqldump -u username -p --all-databases > backup.sql
```

#### 3.2 还原

注意：这里还原会覆盖原有数据。

```
#指定库还原，备份只包含该库
mysql -u username -p target_database < database_backup.sql
#所有库还原，备份好汉所有库
mysql -u username -p < backup.sql
#指定库还原，备份包含所有库
mysql -u username -p --database=target_database < database_backup.sql
```

### 4.表操作

#### 4.1 查询操作

````
#查询库表，如果使用了use 库，则可以只输入表名字即可。
slect * from database_name.table_name;
#带条件的查询，其中带条件还涉及到多个条件的and 和or 操作。
slect * from database_name.table_name where xxx=xxx;
#模糊查询
SELECT * FROM table_name WHERE column_name LIKE '%keyword%';
#只统计行数查询
select count(*) from table_name;
#格式输出,任何查询后面都可以
slect * from database_name.table_name\G;
#只显示结果的多少行，该参数也用户update操作，避免因为条件错误更新大量的数据。
#作为开发来说，可能还需要更多的排序结果，需要用到ORDER BY。
#对于运维来说，可能不是很关注这个。
slect * from database_name.table_name limit 1；

# 查看表结构
desc 表名；

#当然实际上还有更多的查询，就看实际业务需求，这里只写了本人比较用得多的语句。
````

#### 4.2 增加数据

```
INSERT INTO 表名 (列1, 列2, 列3, ...) VALUES (值1, 值2, 值3, ...);
#范例
INSERT INTO customers (id, name, email)VALUES (1, 'John Doe', 'john@example.com');
```

#### 4.3 更新操作

 ```
 UPDATE 表名称 SET 列名称1 = 新值1, 列名称2 = 新值2, ...WHERE 条件;
 #范例，这里其实可以也可以添加limit参数，避免条件错误更新了大量数据。
 UPDATE students SET age = 20 WHERE name = 'John';
 ```

#### 4.4 删除操作

```
#删除表里面所有数据，一条一条的执行，数据大的时候很慢。
DELETE FROM 表名;
#清空表，速度快。
TRUNCATE TABLE 表名;

#删除表，数据被删除，表结构还在；清空表，表结构和数据都没了。
```

### 5.DDL操作

对于刚才的增删改查（CURD）一般而言对数据库而言是属于非DDL操作，还有一部分操作被定义为DDL（Data Definition Language）语句用于定义或更改数据库结构，例如添加索引、修改表等。

```
#创建索引
CREATE INDEX index_name ON table_name (column1, column2, ...);
#添加列
ALTER TABLE table_name ADD column_name datatype;
#删除列
ALTER TABLE table_name DROP COLUMN column_name;
#修改数据类型
ALTER TABLE table_name ALTER COLUMN column_name TYPE new_datatype;
#重命名表
RENAME TABLE old_table_name TO new_table_name;
#重命名列
ALTER TABLE table_name RENAME COLUMN old_column_name TO new_column_name;
```

### 6.主从配置

```
#创建主从账号，master操作
grant  replication slave  on  *.* to 'replica'@'192.168.0.%'   identified  by  'passwd';
flush privileges;

#记录当前binglog值，master操作
show master status;

#从链接到主，slave操作
change master to master_host='192.168.0.76',master_user='replica',master_password='passwd',master_log_file='mysql-bin.000001',master_log_pos=677;

#启动从节点，slave操作
start slave;

#停止从节点，slave操作
stop slave;

#检查主从状态，slave操作

show slave status\G;

```

