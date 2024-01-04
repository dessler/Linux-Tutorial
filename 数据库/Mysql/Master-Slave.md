# 主从配置

无论是Mysql 还是 Mariadb 在配置主从上都是一样的，所以这里我们以Mariadb为作为实际操作范例

## 准备工作

需要准备2台安装完成的数据库机器

## 配置

### Master

```
#编辑配置文件，在mysqld下面新增下面的内容
vi /etc/my.cnf.d/mariadb-server.cnf

[mysqld]
server-id=1                                                #定义数据库的id，全局唯一,只要加入主从都需要配置
log_bin=mysql-bin                                          #启用binglog日志

#重启数据库
systemctl restart mariadb 
```

```
#配置主从账号

grant  replication slave  on  *.* to 'replica'@'192.168.0.0/24'   identified  by  'passwd';
flush privileges;
```

```
#查询master节点信息，从启动需要
show master status
```

![image-20240102103414805](.Master-Slave/image-20240102103414805.png)

### Slave

```
#编辑配置文件，在mysqld下面新增下面的内容
vi /etc/my.cnf.d/mariadb-server.cnf

[mysqld]
server-id=2                                                #定义数据库的id，全局唯一,只要加入主从都需要配置
log_bin=mysql-bin                                          #启用binglog日志

#重启数据库
systemctl restart mariadb 
```

```
#链接到master，这里会用到master的ip，刚才配置的主从账号密码，及主节点的binglog信息
change master to master_host='192.168.0.161',master_user='replica',master_password='passwd',master_log_file='master-bin.000001',master_log_pos=783;
```

```
#启动主从
start slave;
```

 ```
 #检查主从状态
 show slave status\G;
 
 #以下2个进程都需要是：Yes 才是正常的。
 Slave_IO_Running: Yes        #代表正常从master节点读取binlog日志
 Slave_SQL_Running: Yes       #代表正常解析master的binlog日志
 ```

 ## 坑

1.telnet 坑

```
telnet xxxx 3306 
提示xxx ip 不允许链接，这个是因为mysql是一个支持telnet链接的服务（不仅仅是探测网络是否畅通）所以telnet实际上等于mysql -h xxxx -uxx（当前系统用户）
一般情况下在root下操作就等于用root链接，如果本地ip并未被授权在root下登录，就会出现该问题。
```

2.主从坑

```
配置主从的时候需要配置允许的ip地址
192.168.0.0/24     不能使用(cidr)
192.168.0.*        不能使用(通配)
192.168.0.11       可以使用(具体ip)
%                  可以使用(所有ip)
```



