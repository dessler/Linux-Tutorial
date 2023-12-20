# Glance

## 1.Glance基本介绍

Glance是用于管理和提供虚拟机镜像的开源项目。它是OpenStack项目的一部分，作为OpenStack的镜像服务，用于存储、注册和传输虚拟机镜像。

Glance提供了一种集中式的方式来管理虚拟机镜像，并使其可以被多个计算节点使用。它允许用户通过API或命令行界面上传、注册和下载虚拟机镜像，从而方便地部署和管理虚拟机。

Glance支持多种镜像格式，包括RAW、VHD、VMDK、ISO等，可以适应不同类型的虚拟化平台和需求。

Glance的主要功能包括：

1. 镜像注册和管理：用户可以通过Glance API或命令行工具注册、删除和查询镜像，以及管理镜像的元数据。
2. 镜像上传和下载：用户可以通过Glance上传和下载虚拟机镜像，方便地共享和迁移镜像。
3. 镜像格式转换：Glance支持将不同格式的镜像进行转换，以满足不同虚拟化平台的要求。
4. 镜像元数据管理：Glance允许用户为镜像添加自定义的元数据，以便更好地描述和组织镜像。
5. 镜像访问控制：Glance提供了访问控制机制，用户可以根据需要设置镜像的访问权限，保护镜像的安全性。

总的来说，Glance是一个功能强大的虚拟机镜像管理工具，为用户提供了方便的方式来管理和使用虚拟机镜像，提高了虚拟化环境的部署效率和管理便捷性。

## 2.Glance进程介绍

Glance组件通常会运行以下几个进程：

1. Glance API进程：这个进程负责接收和处理用户通过API发起的请求，如镜像的注册、查询和下载等。
2. Glance Registry进程：这个进程负责管理镜像的元数据信息，包括镜像的名称、大小、格式等。它还负责验证和授权用户对镜像的访问权限。
3. Glance Scrubber进程：这个进程定期检查存储后端，删除已经被标记为无效的镜像，以释放存储空间。
4. Glance Store进程：这个进程负责与存储后端进行交互，将镜像上传到存储后端，以及从存储后端下载镜像。

每个进程都有特定的功能和职责，在Glance的架构中协同工作，以提供完整的虚拟机镜像管理服务。

***作者有话说：这个其实已经很老的版本，才有4个进程了，目前的版本都只有2个进程，一个api，一个registry。***

```
如果请求与镜像元数据（metadata）相关，例如获取镜像信息、创建、更新或删除镜像的元数据等操作，API会将请求转发给Glance Registry服务进行处理。
如果请求涉及到镜像文件的存取，例如上传、下载或删除镜像文件等操作，API会根据镜像的存储后端（store backend）信息，将请求转发给相应的存储后端进行处理。
```





## 3.Glance配置Ceph

Glance作为镜像仓库，默认存储是放在本机，这个是不符合高可用的，所以接入其他分布式存储是必然，Ceph作为一个分布式存储也非常契合。

默认通过yum配置的OpenStack怎么都没配置通，所以换了一个方式重新部署，立即就调通了。

OpenStack： centos7.9+packstack部署

Ceph：centos7.9 + cephadmin部署

### 3.1 配置文件修改

其实就是把默认的文件存储方式，修改为使用rbd方式。

```
#packstack配置文件修改方法，参考中间的注释。

[DEFAULT]
bind_host=0.0.0.0
bind_port=9292
workers=4
image_cache_dir=/var/lib/glance/image-cache
registry_host=0.0.0.0
debug=False
log_file=/var/log/glance/api.log
log_dir=/var/log/glance
transport_url=rabbit://guest:guest@192.168.0.11:5672/
enable_v1_api=False
[cinder]
[cors]
[database]
connection=mysql+pymysql://glance:33bc67c240a949a3@192.168.0.11/glance
[file]
[glance.store.http.store]
[glance.store.rbd.store]
[glance.store.sheepdog.store]
[glance.store.swift.store]
[glance.store.vmware_datastore.store]
[glance_store]
#下面内容是原始内容，正式使用要求删除下面的内容
stores=file,http,swift
default_store=file
filesystem_store_datadir=/var/lib/glance/images/
os_region_name=RegionOne
#上面内容是原始内容，正式使用要求删除上面的内容
#下面内容是修改过后的内容
stores=rbd
default_store=rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8
os_region_name=RegionOne
#上面的内容是修改过的内容
[image_format]
[keystone_authtoken]
www_authenticate_uri=http://192.168.0.11:5000/v3
auth_type=password
auth_url=http://192.168.0.11:5000
username=glance
password=c8ccfdc416df45ae
user_domain_name=Default
project_name=services
project_domain_name=Default
[oslo_concurrency]
[oslo_messaging_amqp]
[oslo_messaging_kafka]
[oslo_messaging_notifications]
driver=messagingv2
topics=notifications
[oslo_messaging_rabbit]
ssl=False
default_notification_exchange=glance
[oslo_middleware]
[oslo_policy]
policy_file=/etc/glance/policy.json
[paste_deploy]
flavor=keystone
[profiler]
[store_type_location_strategy]
[task]
[taskflow_executor]
```

### 3.2 Ceph的配置

以下操作在ceph集群操作

#### 3.2.1 创建pool

```
ceph osd pool create images 128 128
rbd pool init images
```

#### 3.2.2 创建key

```
#大概意思就是创建一个客户端，权限mod给读，osd给读写执行
#这里按照常规理解只要给读写权限就行的，但实际是不行。
ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images' -o /etc/ceph/ceph.client.glance.keyring
```

#### 3.2.3 复制配置文件到Glance

```
#glance服务器需要提前创建目录对应的目录才行，如果用rsync命令传输则不用提前创建。
scp /etc/ceph/ceph.client.glance.keyring glance:/etc/ceph/
scp /etc/ceph/ceph.conf glance:/etc/ceph/
```
### 3.3 Glance做的配置

#### 3.3.1 安装ceph-common

```
#安装ceph客户端命令
yum -y install ceph-common
```

### 3.3.2 修改配置文件

```
vi /etc/ceph/ceph.conf

# minimal ceph.conf for bf839c1e-998c-11ee-8d81-fa163e8fe68a
[global]
	fsid = bf839c1e-998c-11ee-8d81-fa163e8fe68a
	mon_host = [192.168.0.163]
	
#上面是修改后的配置,下面这个原始配置，区别应该只是ceph命令的区别。如果用逗号分隔，写多个mon，发现是不行的，不知道问题在哪里。
#cephadm安装的ceph版本是ceph version 15.2.17 (8a82819d84cf884bd39c17e3236e0632ac146dc4) octopus (stable)
#默认安装的是ceph version 10.2.5 (c461ee19ecbc0c5c330aca20f7392c9a00730367)

# minimal ceph.conf for bf839c1e-998c-11ee-8d81-fa163e8fe68a
[global]
	fsid = bf839c1e-998c-11ee-8d81-fa163e8fe68a
	mon_host = [v2:192.168.0.163:3300/0,v1:192.168.0.163:6789/0]
	
#重启Glance
#通过packstack部署的OpenStack会自带一个镜像(但是我没找到这个文件)，默认存储在本地文件，把他删除，避免冲突
glance image-delete xxx

systemctl restart openstack-glance-api
```

### 3.4 测试上传镜像

```
#需要提前准备镜像文件
#参考下载地址：https://cloud.centos.org/centos/7/images/
#上传
glance image-create --name "centos7.9"   --file CentOS-7-x86_64-GenericCloud-1907.qcow2   --disk-format qcow2 --container-format bare  --visibility public
#查看images的pool是否有数据增加
ceph df 
```

在实际使用当中，每上传一个镜像，都会生成一个rbd镜像文件（同名镜像id），并不能直接把所有镜像挂载到一个目录形式看到所有文件。





