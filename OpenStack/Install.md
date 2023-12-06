[toc]

# OpenStack

## 1.机器准备

| IP                | 配置                   | 系统      | 角色 |
| ----------------- | ---------------------- | --------- | ---- |
| 192.168.0.78 /251 | 8C16G,100G+100G,双网卡 | centos7.6 | 控制 |
| 192.168.0.28/111  | 8C16G,100G+100G,双网卡 | centos7.6 | 计算 |
| 192.168.0.29/88   | 8C16G,100G+100G,双网卡 | centos7.6 | 计算 |

## 2.环境初始化

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

![image-20231205210034600](.Install/image-20231205210034600.png)

## 2.4 重启节点

```
#重启所有节点
reboot
```



## 3.安装依赖软件

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

![image-20231205213351638](.Install/image-20231205213351638.png)

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

#### ![image-20231205214409760](.Install/image-20231205214409760.png)

### 3.4 安装memcached

#### 3.4.1 安装软件

```
yum -y install memcached python-memcached
```

#### 3.4.2 配置memcached

````
vi /etc/my.cnf.d/openstack.cnf
#修改成这样，然后保存退出
PORT="11211"
USER="memcached"
MAXCONN="1024"
CACHESIZE="64"
OPTIONS="-l 127.0.0.1,::1,control"
````



#### 3.4.3 启动memcached

``` 
systemctl enable memcached.service
systemctl start memcached.service
```

### 3.5 安装etcd

#### 3.5.1 安装软件

```
yum -y install etcd
```

#### 3.5.2 配置etcd



#### 3.5.3 启动服务

```
systemctl enable etcd
systemctl start etcd
```

## 4 OpenStack安装

### 4.1 Keystone  安装

#### 4.1.1 创建keystone数据库

```
#登录mysql
mysql -uroot -p
#登录以后执行的命令，非shell命令
CREATE DATABASE keystone;
#设置mysql用户的密码
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '自己的密码';

```

#### 4.1.2 安装keystone软件包

**作者有话说：这个地方的包太坑了，默认centos7，是python2，如果这里安装错了，后面后面有一堆坑。**

```
yum install openstack-keystone httpd mod_wsgi
```

#### 4.1.3 配置keystone

```
vim /etc/keystone/keystone.conf
#配置数据库部分
connection = mysql+pymysql://keystone:你的密码@control/keystone
#配置token部分，添加一行
provider = fernet

```

#### 4.1.4 填充数据库

```
su -s /bin/sh -c "keystone-manage db_sync" keystone
```

#### 4.1.5 初始化库

```
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
```

#### 4.1.6 配置keystone

```
 keystone-manage bootstrap --bootstrap-password （自己的密码） \
  --bootstrap-admin-url http://control:5000/v3/ \
  --bootstrap-internal-url http://control:5000/v3/ \
  --bootstrap-public-url http://control:5000/v3/ \
  --bootstrap-region-id RegionOne
```



#### 4.1.7 配置httpd

```
vim /etc/httpd/conf/httpd.conf
#配置成这样
ServerAdmin root@localhost
serverName control
#然后做软链
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
```

#### 4.1.8 启动apache

```
systemctl enable httpd.service
systemctl start httpd.service
```

#### 4.1.9测试keystone

```
#设置临时变量

#创建域
openstack domain create --description "An Example Domain" openstack
openstack project create --domain default  --description "Demo Project" myopenstack
```

