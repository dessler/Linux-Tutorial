[toc]

# Cinder



Cinder 在一个最小的OpenStack的集群里面默认是不需要的，当你需要使用到其他共享存储的时候才需要该组件，所以这里部署是单独出来的

## 1.Cinder基本介绍



## 2.Cinder组件介绍

## 3.Cinder部署使用

### 3.1 ceph配置

#### 3.1.1 创建pool

```
ceph osd pool create vms 128 128
rbd pool init vms
```

#### 3.1.3 创建key

```
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=vms' -o /etc/ceph/ceph.client.cinder.keyring
```



#### 3.1.4 推送密钥

```
#cinder服务器需要提前创建目录对应的目录才行，如果用rsync命令传输则不用提前创建。
#由于这里控制节点只有1台，和glance在一起，所以就不用复制cepy.conf文件。
scp /etc/ceph/ceph.client.cinder.keyring cinder:/etc/ceph/
```



### 3.2 Cinder配置

#### 3.2.1 Cinder数据库初始化

```
#登录mysql,control机器执行
mysql -uroot -p
#登录以后执行的命令，非shell命令，创建数据库，库名：cinder
CREATE DATABASE cinder;
#设置cinder库的的用户及访问控制权限
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '自己的密码';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '自己的密码';
#刷新权限
flush privileges;
```

#### 3.2.2 创建Cinder用户

```
openstack user create --domain default --password-prompt cinder
```

![image-20231214104120143](.Cinder/image-20231214104120143.png)

#### 3.2.3 添加Cinder权限

```
openstack role add --project service --user cinder admin
```



#### 3.2.4 创建Cinder服务

```
openstack service create --name cinder --description "OpenStack Cinder" cinder
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

```

![image-20231214104256826](.Cinder/image-20231214104256826.png)

![image-20231214105816741](.Cinder/image-20231214105816741.png)

#### 3.2.5 创建api

```
 openstack endpoint create --region RegionOne volumev2 public http://control:8776/v2/%\(project_id\)s
 openstack endpoint create --region RegionOne volumev2 internal http://control:8776/v2/%\(project_id\)s
 openstack endpoint create --region RegionOne volumev2 admin http://control:8776/v2/%\(project_id\)s
 openstack endpoint create --region RegionOne volumev3 public http://control:8776/v3/%\(project_id\)s
 openstack endpoint create --region RegionOne volumev3 internal http://control:8776/v3/%\(project_id\)s
 openstack endpoint create --region RegionOne volumev3 admin http://control:8776/v3/%\(project_id\)s
#添加完成以后查询
```

![image-20231214110523333](.Cinder/image-20231214110523333.png)

#### 3.2.6 Cinder 基本软件的安装

```
 yum install -y openstack-cinder
```
#### 3.2.7 同步数据库

```
 su -s /bin/sh -c "cinder-manage db sync" cinder
```

#### 3.2.8 修改配置文件

注：因为调试glance对接后端ceph失败（原因暂时未知），以下步骤是基于packstack安装的文件进行的调试，理论上是没有区别的，至于上面的手工安装步骤也是通用的。

```
###这个是packstack安装生成的的配置文件
vi /etc/cinder/cinder.conf
[DEFAULT]
backup_swift_url=http://192.168.0.11:8080/v1/AUTH_
backup_swift_container=volumebackups
backup_driver=cinder.backup.drivers.swift.SwiftBackupDriver
enable_v3_api=True
auth_strategy=keystone
storage_availability_zone=nova
default_availability_zone=nova
default_volume_type=iscsi
enabled_backends=lvm
osapi_volume_listen=0.0.0.0
osapi_volume_workers=4
debug=False
log_dir=/var/log/cinder
transport_url=rabbit://guest:guest@192.168.0.11:5672/
control_exchange=openstack
api_paste_config=/etc/cinder/api-paste.ini
glance_host=192.168.0.11
[backend]
[backend_defaults]
[barbican]
[brcd_fabric_example]
[cisco_fabric_example]
[coordination]
[cors]
[database]
connection=mysql+pymysql://cinder:01c684e8d90e4634@192.168.0.11/cinder
[fc-zone-manager]
[healthcheck]
[key_manager]
[keystone_authtoken]
www_authenticate_uri=http://192.168.0.11:5000/
auth_type=password
auth_url=http://192.168.0.11:5000
username=cinder
password=8642130903694561
user_domain_name=Default
project_name=services
project_domain_name=Default
[nova]
[oslo_concurrency]
lock_path=/var/lib/cinder/tmp
[oslo_messaging_amqp]
[oslo_messaging_kafka]
[oslo_messaging_notifications]
driver=messagingv2
[oslo_messaging_rabbit]
ssl=False
[oslo_middleware]
[oslo_policy]
policy_file=/etc/cinder/policy.json
[oslo_reports]
[oslo_versionedobjects]
[privsep]
[profiler]
[sample_castellan_source]
[sample_remote_file_source]
[service_user]
[ssl]
[vault]
[lvm]
volume_backend_name=lvm
volume_driver=cinder.volume.drivers.lvm.LVMVolumeDriver
target_ip_address=192.168.0.11
target_helper=lioadm
volume_group=cinder-volumes
volumes_dir=/var/lib/cinder/volumes
```

```
###修改过后的部分
[DEFAULT]
backup_swift_url=http://192.168.0.11:8080/v1/AUTH_
backup_swift_container=volumebackups
backup_driver=cinder.backup.drivers.swift.SwiftBackupDriver
enable_v3_api=True
auth_strategy=keystone
storage_availability_zone=nova
default_availability_zone=nova
#如果要使用ceph，下面这行需要注释，改成ceph还不行，具体原因未知
default_volume_type=iscsi
#下面这行修改
enabled_backends=ceph
osapi_volume_listen=0.0.0.0
osapi_volume_workers=4
debug=False
log_dir=/var/log/cinder
transport_url=rabbit://guest:guest@192.168.0.11:5672/
control_exchange=openstack
api_paste_config=/etc/cinder/api-paste.ini
glance_host=192.168.0.11
[backend]
[backend_defaults]
[barbican]
[brcd_fabric_example]
[cisco_fabric_example]
[coordination]
[cors]
[database]
connection=mysql+pymysql://cinder:01c684e8d90e4634@192.168.0.11/cinder
[fc-zone-manager]
[healthcheck]
[key_manager]
[keystone_authtoken]
www_authenticate_uri=http://192.168.0.11:5000/
auth_type=password
auth_url=http://192.168.0.11:5000
username=cinder
password=8642130903694561
user_domain_name=Default
project_name=services
project_domain_name=Default
[nova]
[oslo_concurrency]
lock_path=/var/lib/cinder/tmp
[oslo_messaging_amqp]
[oslo_messaging_kafka]
[oslo_messaging_notifications]
driver=messagingv2
[oslo_messaging_rabbit]
ssl=False
[oslo_middleware]
[oslo_policy]
policy_file=/etc/cinder/policy.json
[oslo_reports]
[oslo_versionedobjects]
[privsep]
[profiler]
[sample_castellan_source]
[sample_remote_file_source]
[service_user]
[ssl]
[vault]
[lvm]
volume_backend_name=lvm
volume_driver=cinder.volume.drivers.lvm.LVMVolumeDriver
target_ip_address=192.168.0.11
target_helper=lioadm
volume_group=cinder-volumes
volumes_dir=/var/lib/cinder/volumes
#下面内容为新增
[ceph]
volume_driver=cinder.volume.drivers.rbd.RBDDriver
rbd_pool=vms
rbd_user=cinder
rbd_secret_id=ce35bff3-c303-4754-83a0-7e95556f73c0
rbd_ceph_conf=/etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot=false
rbd_cluster_name=ceph
rbd_max_clone_depth=5

#注意这里有一个rbd_secret_id ，这个id放后面单独说明如何获取

##重启Cinder
systemctl restart openstack-cinder-scheduler
systemctl restart openstack-cinder-volume
systemctl restart openstack-cinder-api
systemctl restart openstack-cinder-backup
```

#### 3.2.9 创建测试volume

##### 3.2.9.1 默认情况下创建volume

在未对接ceph存储的时候创建创建出来的volume是通过本地lvm方式创建出来的文件

```
#创建
openstack volume create --size 100 --availability-zone nova myvolume
#查看
cinder list
```

![image-20231215145805314](.Cinder/image-20231215145805314.png)

![image-20231219142934783](.Cinder/image-20231219142934783.png)

##### 3.2.9.2 使用rbd情况创建volume

###### 3.2.9.2.1 获取rbd_secret_id

简单点说就是cinder是可以直接访问到ceph集群的，但是nova是不行，需要通过这个方式来让nova可以访问到ceph的块存储。

1.生成key

```
#ceph集群执行
ceph auth get-key client.cinder | ssh  任选一台计算节点 tee  /etc/ceph/client.cinder.key
```

2.生成uuid

```
#刚才选择计算节点执行，执行完成获得一个uuid
uuidgen
```

3.编辑配置文件

```
# 把这里的uuid替换为刚才生成的uuid
vim secret.xml
<secret ephemeral='no' private='no'>
<uuid>674fea11-e69e-4c95-b378-2baa19cd6b4e</uuid>
<usage type='ceph'>
<name>client.cinder secret</name>
</usage>
</secret>
```

4.生成密钥文件

```
virsh secret-define --file secret.xml 
```

5.生成保密字符串文件

```
#这里的uuid替换上一步获取的
virsh secret-set-value --secret 674fea11-e69e-4c95-b378-2baa19cd6b4e --base64 $(cat ./client.cinder.key)
```

6.查看secret的uuid

```
virsh secret-list
```



###### 3.2.9.2.2 检查后的rbd是否正常

```
openstack volume service  list
#这里lvm宕机是是因为配置了ceph，自然lvm就是不可用的。
```

![image-20231219171654076](.Cinder/image-20231219171654076.png)

###### 3.2.9.2.3 创建volume

这个时候创建的volume就会到ceph对应的pool去创建对应的文件。





### 3.3 Nova配置



### 3.3.1 配置计算节点nova

控制节点的nova不需要配置

#### 3.3.2 安装ceph-common

```
yum -y install ceph-common
```

#### 3.3.3 复制配置文件

```
#从glance复制ceph.conf 可不用二次修改
#从ceph复制ceph.client.cinder.keyring 过来
scp /etc/ceph/ceph.client.cinder.keyring cinder:/etc/ceph/
scp /etc/ceph/ceph.conf cinder:/etc/ceph/
```

#### 3.3.4 配置secret-list

```
#如果这里有多台，则使用第一台的uuid，不用重复生成，生成步骤参考3.2.9.2 
#如果只有一台，这里的步骤已经完成，不需要操作。
```

#### 3.4.5 配置nova

```
#vi /etc/nova/nova.conf
#只修改了libvirt下面的部分内容，删除原来的，添加新的。

[DEFAULT]
instance_usage_audit_period=hour
rootwrap_config=/etc/nova/rootwrap.conf
compute_driver=libvirt.LibvirtDriver
allow_resize_to_same_host=False
vif_plugging_is_fatal=True
vif_plugging_timeout=300
force_raw_images=True
reserved_host_memory_mb=512
cpu_allocation_ratio=16.0
ram_allocation_ratio=1.5
instance_usage_audit=True
heal_instance_info_cache_interval=60
host=ecs-chenhong-openstack-0003.novalocal
metadata_host=192.168.0.207
ssl_only=False
state_path=/var/lib/nova
report_interval=10
service_down_time=60
debug=False
log_dir=/var/log/nova
transport_url=rabbit://guest:guest@192.168.0.207:5672/
volume_api_class=nova.volume.cinder.API
[api]
auth_strategy=keystone
[api_database]
connection=mysql+pymysql://nova_api:249e3def5610411b@192.168.0.207/nova_api
[barbican]
[cache]
[cinder]
[compute]
[conductor]
[console]
[consoleauth]
[cors]
[database]
connection=mysql+pymysql://nova:249e3def5610411b@192.168.0.207/nova
[devices]
[ephemeral_storage_encryption]
[filter_scheduler]
[glance]
api_servers=http://192.168.0.207:9292
[guestfs]
[healthcheck]
[hyperv]
[ironic]
[key_manager]
backend=nova.keymgr.conf_key_mgr.ConfKeyManager
[keystone]
[keystone_authtoken]
#以下内容为修改过后的内容
[libvirt]
virt_type = qemu 
images_type = rbd
images_rbd_pool = vms
images_rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_user = cinder
rbd_secret_uuid = ce35bff3-c303-4754-83a0-7e95556f73c0
disk_cachemodes="network=writeback"
inject_password = false
inject_key = false
inject_partition = -2
live_migration_flag="VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST,VIR_MIGRATE_TUNNELLED"
hw_disk_discard = unmap
#以上内容为修改过后的内容
[metrics]
[mks]
[neutron]
ovs_bridge=br-int
default_floating_pool=public
extension_sync_interval=600
timeout=30
auth_type=v3password
auth_url=http://192.168.0.207:5000/v3
project_name=services
project_domain_name=Default
username=neutron
user_domain_name=Default
password=2a095fdf95914973
region_name=RegionOne
[notifications]
notify_on_state_change=vm_and_task_state
[osapi_v21]
[oslo_concurrency]
lock_path=/var/lib/nova/tmp
[oslo_messaging_amqp]
[oslo_messaging_kafka]
[oslo_messaging_notifications]
driver=messagingv2
[oslo_messaging_rabbit]
ssl=False
[oslo_middleware]
[oslo_policy]
[pci]
[placement]
auth_type=password
auth_url=http://192.168.0.207:5000/v3
project_name=services
project_domain_name=Default
username=placement
user_domain_name=Default
password=f2c99ef018d24eea
region_name=RegionOne
[powervm]
[privsep]
[profiler]
[quota]
[rdp]
[remote_debug]
[scheduler]
[serial_console]
[service_user]
[spice]
enabled=False
[upgrade_levels]
[vault]
[vendordata_dynamic_auth]
project_domain_name=Default
user_domain_name=Default
[vmware]
[vnc]
enabled=True
server_listen=0.0.0.0
server_proxyclient_address=ecs-chenhong-openstack-0003.novalocal
novncproxy_base_url=http://192.168.0.207:6080/vnc_auto.html
[workarounds]
enable_numa_live_migration=False
[wsgi]
[xenserver]
[xvp]
[zvm]
```

#### 3.5.6 测试创建虚拟机

```
#参考CreateCVM.md部分，这里的网络模式需要使用geneve
#这个qemu虚拟机已经可以看到使用的是ceph存储了
#这里有一个遗留问题就是openstack volume list 看不到这个虚拟机所使用的磁盘，但是这个rbd镜像是真是存在于ceph的pool里面的。
```

![image-20231220102717453](.Cinder/image-20231220102717453.png)

#### 3.5.7 给虚拟机里面添加云盘

```
openstack server add volume  虚拟机id  云盘id  --device /dev/vd？  这里的设备名字要未使用的。
openstack server add volume 0e8a0ca5-fe9d-42f4-927c-4f7f8ffa5346  52b61e0f-e3a4-4f03-927a-25b08695ed11 --device /dev/vdb
```

![image-20231220103330661](.Cinder/image-20231220103330661.png)

未添加之前这里的状态是``available``,虚拟机里面也能看到新硬盘。

![image-20231220103423808](.Cinder/image-20231220103423808.png)
