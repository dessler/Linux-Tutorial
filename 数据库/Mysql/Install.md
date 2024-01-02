# Mysql安装

## Centos8

```
#安装maridb
dnf -y install mariadb

#启动
systemctl enable mariadb
systemctl start mariadb

#初始化
mysql_secure_installation
```



## Centos7

#### 安装mariadb

```
#安装mariadb
yum install -y mariadb-server

#启动
systemctl enable mariadb
systemctl start mariadb

#初始化
mysql_secure_installation

```

#### 安装Mysql

``` 
#安装yum源
yum -y install http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm

#安装mysql
yum install -y mysql-community-server
#如果出现类似GPG Keys are configured as: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
#可以跳过
yum install -y mysql-community-server --nogpgcheck

#启动
systemctl enable mysqld
systemctl start mysqld

#找到初始root密码
cat /var/log/mysqld.log  |grep passwd


#初始化
mysql_secure_installation
```

