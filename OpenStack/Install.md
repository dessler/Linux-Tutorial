# OpenStack

## 1.机器准备

| IP                | 配置                   | 系统      | 角色 |
| ----------------- | ---------------------- | --------- | ---- |
| 192.168.0.78 /251 | 8C16G,100G+100G,双网卡 | centos7.6 | 控制 |
| 192.168.0.28/111  | 8C16G,100G+100G,双网卡 | centos7.6 | 计算 |
| 192.168.0.29/88   | 8C16G,100G+100G,双网卡 | centos7.6 | 计算 |

## 2.准备工作

## 2.1 修改主机名

 ```
 #78机器做
 hostname control
 #28机器做
 hostnamectl set-hostname computer1
 #29机器做
 hostnamectl set-hostname computer2
 ```



## 2.2 修改hosts

```
#3台机器都执行
echo "192.168.0.78 control" >> /etc/hosts
echo "192.168.0.78 computer1" >> /etc/hosts
echo "192.168.0.78 computer2" >> /etc/hosts
```

## 2.3 安装部署ntp客户端

如果默认有则可不配置，也可以选择chrony，根据个人习惯来

### 2.3.1 安装ntp客户端

```
#3台机器都执行
yum -y install ntp
```

### 2.3.2 配置ntpserver

这里配置的是阿里的ntp服务器

```
#3台机器都执行
vi /etc/ntp.conf
#修改ntpserver为阿里服务器，请根据现场实际情况为准。
server ntp.aliyun.com iburst
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
```

### 2.3.3 启动ntp服务

```
#3台机器都执行
systemctl status ntpd
systemctl enable ntpd
```

### 2.3.4 检查ntp服务状态

```
#3台机器都执行
#刚启动要等会才会正常，有*号，
ntpq -pn
```

![image-20231205210034600](.Install\image-20231205210034600.png)

#### 2.3.5 重启节点

```
#重启所有节点
reboot
```



## 3.安装

### 3.1 安装依赖库
```
#3台都执行
yum -y install centos-release-openstack-victoria
 yum   install centos-release-openstack-victoria 
 #上面未执行成功
 yum -y install python-openstackclient

```

### 3.2  安装数据库

#### 3.2.1 安装数据库

 ```
 #控制节点执行
 yum -y install mariadb mariadb-server python-pymysql
 ```
#### 3.2.2 配置数据库

```
#控制节点执行,请替换实际ip地址，如果你对数据库精通也可以根据需要配置
vi /etc/my.cnf.d/openstack.cnf
[mysqld]
bind-address = 192.168.0.78
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
```

#### 3.2.3 启动数据库

```
 systemctl enable mariadb
 systemctl start mariadb
```



#### 3.2.4 配置数据库密码

```
mysql_secure_installation
#根据提示输入密码
```

![image-20231205213351638](.Install\image-20231205213351638.png)

### 3.3 安装rabbitmq

#### 3.3.1 安装rabbitmq

````
yum -y install rabbitmq-server
````

#### 3.3.2 启动rabbitmq服务

```
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
```

#### 3.3.3 添加openstack用户机器权限

```
#添加用户openstack，密码passwd
rabbitmqctl add_user openstack passwd
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```

#### ![image-20231205214409760](.Install\image-20231205214409760.png)

```
```

### 3.4 安装memcached

#### 3.4.1 安装软件

```
yum -y install memcached python-memcached
```

#### 3.4.2 配置memcached

````
vi 
PORT="11211"
USER="memcached"
MAXCONN="1024"
CACHESIZE="64"
OPTIONS="-l 127.0.0.1,::1,control"
````



