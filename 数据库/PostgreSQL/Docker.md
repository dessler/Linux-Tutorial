[toc]

# Dokcer

## 背景

​	由于PG不支持数据库级别的隔离，所以通过Docker来实现资源限制和隔离，限制每个Docker的资源来限制每个库的资源占用，避免单个库异常从而拖垮整个PG实例的情况。

​	用Docker跑PG本身还是比较简单的，但是现在有一个需求就是使用2台机器分别运行Docker，然后在其中1台机器启动PG容器作为master，另外1台机器启动PG容器作为slave，当master出现故障的时候，可以快速把slave作为master启动起来，然后源master可以作为从节点加入集群。

## 环境准备

```
#1.环境初始化：包括关闭防火墙，selinux，ntp同步等等
#2.安装并自动Docker
#3.提前下载好pg镜像，本次操作以pg14为准
docker pull postgres:14
```

## 架构

| IP地址        | 角色     | 备注             |
| ------------- | -------- | ---------------- |
| 192.168.0.130 | 源master | 故障后变成slave  |
| 192.168.0.160 | 源slave  | 故障后变成master |

## 配置

### 源master

```
#创建对应的目录,实际目录以现场需求为准。
mkdir -p /root/pg/data 



#运行pg-master,POSTGRES_PASSWORD就是pg超级管理员的密码。

docker run --name pg_master -d \
  -v /root/pg/data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=mysecretpassword \
  --network host \
  postgres:14
  
#在master创建主从同步账号(需要进入容器，登录上psql以后执行)

##进入pg容器
docker exec -it pg_master bash

##切换账号进入psql
su postgres
psql

###创建主从账号密码
CREATE ROLE replica  login replication encrypted password 'replica';

#修改本地配置文件
vi /root/pg/config/pg_hba.conf 
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust
host    replication     all             192.168.0.0/24          md5      //本行是添加的，ip范围可根据时间情况调整

#重启pg服务/重启容器
docker restart pg_master
```



### 源slave

```
#创建对应的目录,实际目录以现场需求为准。
mkdir -p /root/pg/data


#启动从节点
docker run --name pg_replica -d \
  -v /root/pg/data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=mysecretpassword \
  --network=host \
  postgres:14

#配置主从，以下操作均在容器外执行

##删除本地生成的数据
cd /root/pg/data  && rm -rf *

##同步主信息到从节点
pg_basebackup -D /root/pg/data -h 192.168.0.130 -p 5432 -U replica -X stream -P

##修配置文件
vi /root/pg/data/postgresql.conf
primary_conninfo = 'host=192.168.0.130 port=5432 user=replica password=replica'
recovery_target_timeline = 'latest'

##新增配置文件
vi /root/pg/data/standby.signal
standby_mode = on

##重启docker，删除本地数据目录会导致容器自动退出
docker restart pg_replica
```

### 检查主从集群状态

```
#主节点执行
select application_name, state, sync_priority, sync_state from pg_stat_replication;
select pid,state,client_addr,sync_priority,sync_state from pg_stat_replication;
#从节点执行
SELECT * FROM pg_stat_wal_receiver;
```

### 持续运行中

这个时候主从已经正常建立，主从过程的建立完全和不用容器一样，实际上由于容器的特性部分地方还更复杂了。当然这里的主从只考虑主从功能的实现，并没有考虑更多的，比如容器自启动/资源限制/多个主从如何实现（主机模式只能1个容器）等，留给大家去自行探索。

### 故障发生

### 故障切换
