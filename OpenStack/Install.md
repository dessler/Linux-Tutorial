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
echo "192.168.0.28 computer1" >> /etc/hosts
echo "192.168.0.29 computer2" >> /etc/hosts
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

![image-20231205214409760](.Install/image-20231205214409760.png)

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

## 4 OpenStack控制端安装

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

### 4.2 glance安装
#### 4.2.1 创建glance数据库

```
#登录mysql,control机器执行
mysql -uroot -p
#登录以后执行的命令，非shell命令，创建数据库，库名：glance
CREATE DATABASE glance;
#设置glance库的的用户及访问控制权限
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '自己的密码';
```

#### 4.2.2 创建glance用户

创建用户的同时，需要在交付场景下设置改用户的密码。

```
openstack user create --domain default --password-prompt glance
```

![image-20231208150458126](.Install/image-20231208150458126.png)

#### 4.2.3 添加glance用户权限

将名为"glance"的用户添加到"service"项目，并将其分配为"admin"角色。这将赋予"glance"用户超级管理员权限

```
openstack role add --project service --user glance admin
```

#### 4.2.4 创建镜像服务

创建一个名为"glance"的服务，并设置其描述为"OpenStack Image"。服务类型为"image"

```
openstack service create --name glance --description "OpenStack Image" image
```

![image-20231208151207061](.Install/image-20231208151207061.png)

#### 4.2.5 创建api站点

第一个命令创建了一个名为"public"的终端节点，用于公共访问。它位于"RegionOne"区域

第二个命令创建了一个名为"internal"的终端节点，用于内部访问。它也位于"RegionOne"区域

第三个命令创建了一个名为"admin"的终端节点，用于管理员访问。同样，它也位于"RegionOne"区域

```
openstack endpoint create --region RegionOne image public http://control:9292
openstack endpoint create --region RegionOne image internal http://control:9292
openstack endpoint create --region RegionOne image admin http://control:9292
```

#### 4.2.6 安装glance软件包

```
yum install openstack-glance
```

#### 4.2.7 修改glance配置文件

```
vim /etc/glance/glance-api.conf
#修改数据库的链接信息
[database]
connection = mysql+pymysql://glance:自己的密码@control/glance

#添加认证信息
[keystone_authtoken]
www_authenticate_uri  = http://control:5000
auth_url = http://control:5000
memcached_servers = control:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = GLANCE_PASS
```

#### 4.2.8 同步数据库

通俗来说就是初始化数据库表。

```
su -s /bin/sh -c "glance-manage db_sync" glance
```

#### 4.2.9 启动服务

```
systemctl enable openstack-glance-api.service
systemctl start openstack-glance-api.service
```



#### 4.2.10 准备原始镜像

去其他地方找一个原始镜像,比如这里就很多，下载img格式的文件即可。

```
https://github.com/cirros-dev/cirros/releases
```

#### 4.2.9上传镜像

本意是打算上传一个公共镜像，但是无法上传，只有取消参数 `--visibility=public`才能上传成功，这样这个惊喜上传实际就是私有镜像了。根据前面的提示，理论上glance也是一个超级管理员的，不知道为什么还是不行？

```
glance image-create --name "cirros"   --file cirros-0.4.0-x86_64-disk.img   --disk-format qcow2 --container-format bare
```

![image-20231208142930233](.Install/image-20231208142930233.png)

#### 4.2.10 检查镜像

```
glance image-list
```

![image-20231208143019928](.Install/image-20231208143019928.png)

### 4.3 安装placement

#### 4.3.1 创建placement数据库

```
#登录mysql
mysql -uroot -p
#登录以后执行的命令，非shell命令
CREATE DATABASE placement;
#设置mysql用户的密码
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '自己的密码';
```

#### 4.3.2 创建placement用户

```
openstack user create --domain default --password-prompt placement
```

![image-20231208153954545](.Install/image-20231208153954545.png)

#### 4.3.3 添加placemet权限

```
openstack role add --project service --user placement admin
```

#### 4.3.4 创建服务

```
openstack service create --name placement --description "Placement API" placement
```

![image-20231208154159691](.Install/image-20231208154159691.png)

#### 4.3.5 创建api站点

```
openstack endpoint create --region RegionOne placement public http://control:8778
openstack endpoint create --region RegionOne placement internal http://control:8778
openstack endpoint create --region RegionOne placement admin http://control:8778
```

#### 4.3.6 安装软件

```
yum install openstack-placement-api
```

#### 4.3.7 修改配置文件

```
vim /etc/placement/placement.conf

[placement_database]
connection = mysql+pymysql://placement:自己密码@control/placement

[api]
auth_strategy = keystone

[keystone_authtoken]

auth_url = http://control:5000/v3
memcached_servers = control:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
```

#### 4.3.8 同步数据库

```
su -s /bin/sh -c "placement-manage db sync" placement
```

#### 4.3.9 重启apache

```
systemctl restart httpd
```

#### 4.3.10 验证服务

```
placement-status upgrade check
```

![image-20231208155002776](.Install/image-20231208155002776.png)

### 4.4 nova 的安装

#### 4.4.1 初始化数据库

```
#登录mysql
mysql -uroot -p
#登录以后执行的命令，非shell命令
CREATE DATABASE nova_api;
CREATE DATABASE nova;
CREATE DATABASE nova_cell0;
#设置mysql用户的密码
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '自己的密码';
#刷新权限
flush privileges;
```

#### 4.4.2 创建nova用户e

```
openstack user create --domain default --password-prompt nova
```

![image-20231208161458496](.Install/image-20231208161458496.png)

#### 4.4.3 添加nova权限

```
openstack role add --project service --user nova admin
```

#### 4.4.4   创建nova服务

```
openstack service create --name nova --description "OpenStack Compute" compute
```

![image-20231208161531013](.Install/image-20231208161531013.png)

#### 4.4.5 创建api

```
openstack endpoint create --region RegionOne compute public http://control:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://control:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://control:8774/v2.1
```

#### 4.4.6安装软件包

```
yum install openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler
```

#### 4.4.7 修改配置文件

```
[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:RABBIT_PASS@control:5672/
my_ip = 192.168.14.2
use_neutron = true
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api_database]
connection = mysql+pymysql://nova:NOVA_DBPASS@control/nova_api

[database]
connection = mysql+pymysql://nova:NOVA_DBPASS@control/nova

[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://control:5000/
auth_url = http://control:5000/
memcached_servers = control:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = NOVA_PASS

[vnc]
enabled = true
server_listen = $my_ip 
server_proxyclient_address = $my_ip

[glance]
api_servers = http://control:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://control:5000/v3
username = placement
password = PLACEMENT_PASS

[neutron]
url = http://control:9696
auth_url = http://control:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = NEUTRON_PASS
service_metadata_proxy = true
metadata_proxy_shared_secret = NEUTRON_PASS
```

#### 4.4.8 同步数据库

```
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
#最后遇到一个坑，提示找不到数据库nova_api_cell0,实际上前面所有的配置都没有用到这个，不知道为什么会提示需要这个库，实在没办法规避，临时创建了这个库，并和其他库一样赋予权限
#最后完成的时候，数据确是写到了nova_api_cell0库里面，并没有到nova_cell0库里面
#不知道问题在哪里？？？？？？？
```

#### 4.4.9 检查数据库是否正常

```
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova
```

如下图才是正常的

![image-20231208171931640](.Install/image-20231208171931640.png)

#### 4.4.10 启动服务 

```
systemctl enable \
    openstack-nova-api.service \
    openstack-nova-scheduler.service \
    openstack-nova-conductor.service \
    openstack-nova-novncproxy.service
systemctl start \
    openstack-nova-api.service \
    openstack-nova-scheduler.service \
    openstack-nova-conductor.service \
    openstack-nova-novncproxy.service
```

#### 4.4.11 检查结果

```
openstack compute service list
```



![image-20231208224418084](.Install/image-20231208224418084.png)

如果不创建虚拟机实际上，这个组件已经部署完成了。如果要部署计算宿主机则需要在另外的节点执行

 

### 4.5 neutron安装

#### 4.5.1 初始化数据库

```
#登录mysql
mysql -uroot -p
#登录以后执行的命令，非shell命令
CREATE DATABASE placement;
#设置mysql用户的密码
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost'  IDENTIFIED BY 'adljf3werW2S';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'adljf3werW2S';
flush privileges;
```

#### 4.5.2 创建neutron用户

```
openstack user create --domain default --password-prompt neutron
```

![image-20231208221954757](.Install/image-20231208221954757.png)

#### 4.5.3增加权限

```

openstack role add --project service --user neutron admin
```

#### 4.5.4 创建neutron服务

```
openstack service create --name neutron \
  --description "OpenStack Networking" network
```

#### 4.5.5 创建api接口

```
openstack endpoint create --region RegionOne \
  network public http://control:9696
  
  openstack endpoint create --region RegionOne \
  network internal http://control:9696
  
  openstack endpoint create --region RegionOne \
  network admin http://control:9696
```

#### 4.5.6 修改主配置文件

```
vim /etc/neutron/neutron.conf
 
[database]
connection = mysql+pymysql://neutron:infocore@control/neutron
 
[DEFAULT]
core_plugin = ml2
service_plugins =
transport_url = rabbit://openstack:passwd@control
auth_strategy = keystone
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true
 
[keystone_authtoken]
www_authenticate_uri = http://control:5000
auth_url = http://control:5000
memcached_servers = control:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = infocore
 
[nova]
auth_url = http://control:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = nova
password = infocore
 
[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

#### 4.5.7 修改二层配置文件

```
vim /etc/neutron/plugins/ml2/ml2_conf.ini

[ml2]
type_drivers = flat,vlan	
tenant_network_types =
mechanism_drivers = linuxbridge
extension_drivers = port_security
[ml2_type_flat]
flat_networks = provider
[securitygroup]
enable_ipset = true

vim /etc/neutron/plugins/ml2/linuxbridge_agent.ini

[linux_bridge]
physical_interface_mappings = provider:eth1
[vxlan]
enable_vxlan = false
[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

vim /etc/neutron/dhcp_agent.ini
 
[DEFAULT]
interface_driver = linuxbridge
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true

vim /etc/neutron/metadata_agent.ini
[DEFAULT]
nova_metadata_host = control
metadata_proxy_shared_secret = infocore

#这里其实还有和nova还有一次联动的修改，但是我们在配置nova的的时候已经已经提前配置了，所以就不用再继续修改了,也不需要再重启nova服务，如果在配置nova的时候没有设置在配置了还需要重启一次
```



#### 4.5.8 执行初始化操作

```
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
```

#### 4.5.9 重启服务

```
systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service 
systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
```



#### 4.5.10 检查服务状态

```
openstack network agent list
```

正常这里不应该有computer节点，但是这个图是部署了computer在截取的，所以这里把计算节点也显示出来了。

![image-20231210054412024](.Install/image-20231210054412024.png)

## 5.OpenStack计算节点安装

### 5.1 nova配置安装

#### 5.1.1 安装软件包

```
yum install openstack-nova-compute
```

#### 5.1.2 设置配置文件

```
vim /etc/nova/nova.conf

[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:infocore@control
#注意配置为计算节点的ip地址
my_ip =192.168.111.127
 

[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://control:5000/
auth_url = http://control:5000/
memcached_servers = control:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = infocore
 

[vnc]
enabled = true
server_listen = 0.0.0.0
server_proxyclient_address = $my_ip
novncproxy_base_url = http://control:6080/vnc_auto.html
 

[glance]
api_servers = http://control:9292
 

[oslo_concurrency]
lock_path = /var/lib/nova/tmp
 

[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://control:5000/v3
username = placement
password = infocore
 
```

#### 5.1.3 硬件加速配置

```
egrep -c '(vmx|svm)' /proc/cpuinfo
如果返回值为0，就需要配置/etc/nova/nova.conf
[libvirt]
virt_type = qemu
```

#### 5.1.4 启动服务

```
systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service
```

#### 5.1.5 检查节点是否添加成功

```
openstack compute service list
```

![image-20231210055304349](.Install/image-20231210055304349.png)

### 5.2 neutron配置安装

#### 5.2.1  安装软件包

```
yum install openstack-neutron-linuxbridge ebtables ipset
```

#### 5.2.2 设置配置文件

```
vim /etc/neutron/neutron.conf

 
[DEFAULT]
transport_url = rabbit://openstack:infocore@control
auth_strategy = keystone
 
[keystone_authtoken]
www_authenticate_uri = http://control:5000
auth_url = http://control:5000
memcached_servers = control:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = infocore
 
[oslo_concurrency]
lock_path = /var/lib/neutron/tmp

vim /etc/neutron/plugins/ml2/linuxbridge_agent.ini
 
[linux_bridge]
physical_interface_mappings = provider:ens192
[vxlan]
enable_vxlan = false
[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
 
 
 
vim /etc/sysctl.conf 
 
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
执行下面命令
modprobe br_netfilter
sysctl -p
```

#### 5.2.3 启动服务

```
systemctl restart openstack-nova-compute.service
systemctl enable neutron-linuxbridge-agent.service
systemctl start neutron-linuxbridge-agent.service
```



#### 5.2.4 检查网络服务状态

```
openstack network agent list
```

## 6 Horizon安装

### 6.1 安装软件包

```
#控制节点执行
yum install -y openstack-dashboard
```

### 6.2 设置配置文件

```
vim /etc/openstack-dashboard/local_settings
OPENSTACK_HOST = "control"
ALLOWED_HOSTS = ['*']
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': 'control:11211',
    },
}
OPENSTACK_KEYSTONE_URL = "http://control:5000/v3" 
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}
OPENSTACK_NEUTRON_NETWORK = {
    'enable_router': False,
    'enable_quotas': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'enable_fip_topology_check': False,
}
TIME_ZONE = "Asia/Shanghai"
WEBROOT = "/dashboard"

```

### 6.3 坑

```
1. /usr/share/openstack-dashboard/openstack_dashboard/local/.secret_key_store
.secret_key_store 文件权限，要确保apache能读到他，这个文件权限还不能修改
2. /etc/openstack-dashboard/local_settings  文件权限
```



