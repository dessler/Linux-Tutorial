# Ceph安装

[toc]

## 1.环境准备

本环境才用公有云安装，所以暂时不考虑入口的高可用问题，计划了4台机器，其中1台机器作为网关，3台机器作为存储后端。

存储3块盘，其中一个磁盘当成日志盘，另外2块当成数据盘。

部署顺序是先部署Ceph集群，以192.168.0.55为部署机

| IP地址        | 配置               | 角色     |
| ------------- | ------------------ | -------- |
| 192.168.0.235 | 4C8G+100G+单网卡   | rgw      |
| 192.168.0.55  | 4C8G+100G*3+单网卡 | osd，mon |
| 192.168.0.165 | 4C8G+100G*3+单网卡 | osd，mon |
| 192.168.0.154 | 4C8G+100G*3+单网卡 | osd，mon |

## 2.初始化

### 2.1 更新yum源

```
vi  /etc/yum.repos.d/ceph.repo 

[Ceph]
name=Ceph packages for $basearch
baseurl=http://download.ceph.com/rpm-mimic/el7/$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1
[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-mimic/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1
[ceph-source]
name=Ceph source packages
baseurl=http://download.ceph.com/rpm-mimic/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1
```

### 2.2 设置主机名

```
#设置3台主机的主机名
hostnamectl set-hostname ceph1
hostnamectl set-hostname ceph2
hostnamectl set-hostname ceph3
#设置3台主机的hosts
echo "192.168.0.55 ceph1" >> /etc/hosts
echo "192.168.0.165 ceph2" >> /etc/hosts
echo "192.168.0.154 ceph3" >> /etc/hosts
```



### 2.3 关闭selinux

```
setenforce 0
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

### 2.4 关闭防火墙

```
systemctl stop firewalld.service
systemctl disable firewalld.service
```

### 2.5 配置免密

#### 2.5.1 创建一个普通用户

 ```
 useradd -d /home/ceph_user -m ceph_user 
 passwd ceph_user
 ```

#### 2.5.2 配置sudo

```
echo "ceph_user ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/ceph_user 
chmod 0440 /etc/sudoers.d/ceph_user
```

#### 2.5.3 以普通用户配置免密

##### 2.5.3.1 生成密钥

```
#此操作在第一台集群上执行即可
#切换用户
su ceph_user
#生成密钥，持续回车
ssh-keygen
```

##### 2.5.3.2 分发密钥

```
ssh-copy-id ceph_user@ceph1
ssh-copy-id ceph_user@ceph2
ssh-copy-id ceph_user@ceph3
```



### 2.6 设置ntp同步

**作者有话说：ceph对时间很敏感，如果时间节点之前时间不一致，则会出现集群异常，所以必须确保ceph内部时间准确，具体以现场为环境为准。**

```
yum -y install ntp
systemctl start ntpd
systemctl enable ntpd
#在centos通公网的情况下，直接启动就是可以的
```

#### 2.7 重启服务器

```
reboot
```

## 3.部署ceph

### 3.1 安装基本软件

**作者有话说：选择版本的时候也尽量选择比较新的版本，尽量减少环境依赖带来的部署问题**

```
yum clean all && yum makecache
#centos7.6 由于底层系统软件版本太低，所以这里升级到了7.9
yum update -y
yum install epel-release -y
#安装基本软件
yum -y install ceph ceph-deploy
```

### 3.2 创建集群

```
su ceph_user
mkdir ceph-cluster 
cd ceph-cluster
ceph-deploy new ceph1 ceph2 ceph3
```

![image-20231211204501289](.Install\image-20231211204501289.png)

```
#如果安装出现错误，可以通过该命令清理重来
ceph-deploy purge ceph1 ceph2 ceph3
ceph-deploy purgedata ceph1 ceph2 ceph3
ceph-deploy forgetkeys
```

### 3.3 编辑配置文件

```
vi ceph.conf 添加下面的内容

# 公网网络 
public network = 192.168.0.0/24 
# 容忍更多的时钟误差
mon clock drift allowed = 2 
mon clock drift warn backoff = 30 
# 允许删除pool 
mon_allow_pool_delete = true
[mgr]
# 开启WEB仪表盘 mgr modules = dashboard
```

### 3.4 安装集群

```
ceph-deploy install ceph1 ceph2 ceph3
```

![image-20231211205146651](.Install\image-20231211205146651.png)

![image-20231211205931753](.Install\image-20231211205931753.png)

### 3.5 初始monitor信息

```
ceph-deploy --overwrite-conf mon create-initial
```

![image-20231211210129833](.Install\image-20231211210129833.png)

### 3.6 同步管理信息

```
ceph-deploy admin ceph1 ceph2 ceph3
```

![image-20231211210408416](.Install\image-20231211210408416.png)

### 3.7   安装mgr

```
ceph-deploy mgr create ceph1 ceph2 ceph3
```

![image-20231211210538465](.Install\image-20231211210538465.png)

### 3.8 安装osd

```
#按照规划，每个节点2个osd，不过这里好像没用到日志盘
ceph-deploy osd create --data /dev/vdc ceph1
ceph-deploy osd create --data /dev/vdd ceph1
ceph-deploy osd create --data /dev/vdc ceph2
ceph-deploy osd create --data /dev/vdd ceph2
ceph-deploy osd create --data /dev/vdc ceph3
ceph-deploy osd create --data /dev/vdd ceph3
```

### 3.9 生成证书文件

```
切换到root账号下操作
#每生成一次，需要删除当前目录下的*.keyring文件
ceph-deploy gatherkeys ceph1
ceph-deploy gatherkeys ceph2
ceph-deploy gatherkeys ceph3
```

### 3.10 ceph集群检查

```
ceph -s
ceph osd tree
```

![image-20231211212618504](.Install\image-20231211212618504.png)

到这里，整个集群就算安装完成，但是目前这个时候还无法提供服务，而且ceph可提供的服务包括块存储，对象存储，文件存储，也没有配置。

## 4.部署dashboard

### 4.1 开启dashboard模块

```
ceph mgr module enable dashboard
```

### 4.2 生成签名

```bash
ceph dashboard create-self-signed-cert
```

### 4.3 创建目录

```
mkdir mgr-dashboard
cd mgr-dashboard
```

### 4.4 生成密钥对

```
openssl req -new -nodes -x509 -subj "/O=IT/CN=ceph-mgr-dashboard" -days 3650 -keyout dashboard.key -out dashboard.crt -extensions v3_ca
```

![image-20231211213207678](.Install\image-20231211213207678.png)

### 4.5 启动dashboard

```
ceph mgr module enable dashboard
```

```
ceph config set mgr mgr/dashboard/server_addr 192.168.0.55
ceph config set mgr mgr/dashboard/server_port 18843
```

### 4.6 设置管理员

```
ceph dashboard set-login-credentials admin admin
```

### 4.7 访问

![image-20231211213652465](.Install\image-20231211213652465.png)

## 5 配置rgw网关

### 5.1 rgw网关介绍

Ceph RGW（Rados Gateway）网关是一个用于提供对象存储服务的组件，它允许通过 S3 和 Swift 接口访问 Ceph 存储集群中的对象数据。RGW 网关为应用程序和用户提供了一个简单且可扩展的方式来存储和访问对象数据，类似于云存储服务（如 Amazon S3 和 OpenStack Swift）。

以下是 RGW 网关的一些主要特点：

1. **对象存储接口支持**：RGW 网关同时支持 S3 和 Swift 接口，这使得各种类型的应用程序和工具可以无缝地与 RGW 网关进行交互。你可以使用 AWS SDK、S3cmd、Rclone 等工具来管理和操作 RGW 网关上的对象。
2. **多租户和身份认证**：RGW 网关支持多租户环境，可以为不同的用户和应用程序提供独立的访问权限和数据隔离。它支持基于密钥、基于 AWS IAM 和基于 Keystone 的身份认证方式，你可以根据需要选择适合的身份认证方式。
3. **数据持久性和可靠性**：RGW 网关使用 Ceph RADOS（可靠自动分布式对象存储）作为后端存储，它通过将对象数据分布在多个 OSD（对象存储设备）上实现数据的持久性和冗余。这确保了数据的可靠性和高可用性。
4. **弹性扩展性**：RGW 网关可以与 Ceph 存储集群一起水平扩展，以满足不断增长的存储需求。你可以在需要时添加更多的 RGW 守护进程和存储节点，以提高系统的吞吐量和容量。
5. **访问控制和存储策略**：RGW 网关支持灵活的访问控制策略，你可以定义存储桶级别和对象级别的访问权限。它还支持存储桶策略和生命周期管理，让你能够自动化管理对象的生命周期和存储成本。
6. **日志记录和监控**：RGW 网关提供了详细的日志记录和监控功能，你可以通过日志文件和性能统计信息来了解网关的使用情况和性能状况。此外，你还可以使用 Ceph 的监控工具（如 ceph-dash）来实时监控 RGW 网关的状态。

总体而言，Ceph RGW 网关是一个强大且可靠的对象存储解决方案，它为应用程序和用户提供了方便的方式来存储、访问和管理对象数据。无论是构建私有云存储还是公有云存储，RGW 网关都是一个理想的选择。

### 5.2 部署rgw网关

