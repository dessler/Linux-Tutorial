[toc]

# 安装PostgreSQL


## Centos7
### 准备yum源

```
#不同的系统，不同的pg版本对应的源都是不一样的，可以查看：https://www.postgresql.org/download/
#下面这个是centos7，pg14的地址
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

### 安装

```
yum install -y postgresql14-server
```

### 初始化

```
/usr/pgsql-14/bin/postgresql-14-setup initdb
```

1. 创建数据库的系统表空间：通过该命令，将创建一个名为"pg_global"的系统表空间，用于存储全局数据。
2. 创建数据库的数据目录：该命令将创建一个指定位置的数据目录，用于存储数据库的数据文件。
3. 创建数据库的配置文件：命令会创建一个名为"postgresql.conf"的配置文件，其中包含数据库的各种配置选项。
4. 初始化数据库的权限：该命令会为数据库设置适当的权限，以确保只有授权的用户可以访问和操作数据库。
5. 创建初始数据库：命令会创建一个名为"postgres"的初始数据库，该数据库可以用于管理和创建其他数据库。

执行该命令后，您可以通过启动PostgreSQL服务来访问和使用初始化的数据库实例。请注意，您可能需要使用适当的权限和身份验证来访问数据库。

### 启动

```
systemctl enable postgresql-14
systemctl start postgresql-14

#另外一个方式是到 postgres 用户下使用
/usr/pgsql-14/bin/pg_ctl -D /var/lib/pgsql/14/data/ -l logfile start #启动，当然也支持重启，停止操作。
```
## Centos8

### 准备yum源

```
#虽然centos8采用dnf来替代yum，但是他们还是采用rpm包，并且连配置文件都是通用的/etc/yum.conf和/etc/yum.repos.d/目录中的.repo文件
#安装pg的源和以来
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf install -y lz4
```



### 安装

```
#由于centos8的源里面默认有pg，所以需要先停用旧版本，启用新版本。
dnf module disable -y postgresql
dnf module enable -y postgresql:14

#安装
dnf install -y postgresql14-server postgresql14-contrib
```



### 初始化

```
#初始化
/usr/pgsql-14/bin/postgresql-14-setup initdb
```



### 启动

```
systemctl enable postgresql-14
systemctl start postgresql-14
```

