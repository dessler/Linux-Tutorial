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

#### 2.5.2 以普通用户配置免密

##### 2.5.2.1 生成密钥

```
#此操作在第一台集群上执行即可
#切换用户
su ceph_user
#生成密钥，持续回车
ssh-keygen
```

##### 2.5.2.2 分发密钥



```
ssh-copy-id ceph_user@ceph1
ssh-copy-id ceph_user@ceph2
ssh-copy-id ceph_user@ceph3
```



### 2.6 设置ntp同步

**作者有话说：ceph对时间很敏感，如果时间节点之前时间不一致，则会出现集群异常，所以必须确保ceph内部时间准确，具体以现场为环境为准。**

### 2.7 关闭防火墙

## 3.部署

### 3.1 安装基本软件

**作者有话说：选择版本的时候也尽量选择比较新的版本，尽量减少环境依赖带来的部署问题**

```
yum clean all && yum makecache
#centos7.6 由于底层系统软件版本太低，所以这里升级到了7.9
yum update -y
#安装

```

