# Redis的常用命令

## 数据库连接

```
#默认无密码连接
redis-cli

#指定ip，端口，密码连接
redis-cli -h host -p port -a password

#在redis有密码的情况下，无密码也能连接进去，但是不能操作，需要通过命令输入密码以后才能操作
auth 密码
```

## 数据库运维类

```
#以下所有命令均基于已经连接到redis服务器以后的操作，redis的操作命令均不区分大小写。

#查看服务器详细信息
info

#查看数据库有多少key
DBSIZE

#搜索key
#所有所有key，在数量很大的情况下慎用
#通配搜索a 相关的key
#搜索以user开头的key
keys *  key a   key user:*

#清空key，清空当前库，清空所有库
FLUSHDB  
FLUSHALL

#关闭服务器
shutdown

#查看修改配置,必须要加对应的参数 
config get xx
config set xx

#切换数据库，默认在0库，redis默认16个库0-15
SELECT 5

#查看实时读写命令
monitor

#持久化数据（阻塞和非阻塞）
save bgsave

#持久化配置，当通过config set 修改配置文件以后，可以直接更新到配置文件里面。
CONFIG REWRITE

#设置或者修改密码
CONFIG SET requirepass password
```



## 数据操作类

1. **字符串操作**：
   - `SET key value`: 设置指定键的值。
   - `GET key`: 获取指定键的值。
   - `DEL key`: 删除指定的键。
   - `INCR key`: 将指定键的值增加1。
   - `DECR key`: 将指定键的值减少1。
   - `EXPIRE key seconds`: 设置键的过期时间。
2. **列表操作**：
   - `LPUSH key value [value ...]`: 将一个或多个值插入到列表的头部。
   - `RPUSH key value [value ...]`: 将一个或多个值插入到列表的尾部。
   - `LPOP key`: 移除并返回列表的头元素。
   - `RPOP key`: 移除并返回列表的尾元素。
   - `LLEN key`: 获取列表的长度。
3. **哈希表操作**：
   - `HSET key field value`: 设置哈希表中指定字段的值。
   - `HGET key field`: 获取哈希表中指定字段的值。
   - `HDEL key field [field ...]`: 删除哈希表中一个或多个字段。
   - `HGETALL key`: 获取哈希表中所有字段和值。
   - `HKEYS key`: 获取哈希表中所有字段。
   - `HVALS key`: 获取哈希表中所有值。
4. **集合操作**：
   - `SADD key member [member ...]`: 向集合添加一个或多个成员。
   - `SMEMBERS key`: 获取集合中的所有成员。
   - `SREM key member [member ...]`: 从集合中移除一个或多个成员。
   - `SCARD key`: 获取集合的基数（元素数量）。
   - `SISMEMBER key member`: 判断成员是否存在于集合中。
5. **有序集合操作**：
   - `ZADD key score member [score member ...]`: 向有序集合添加一个或多个成员，同时指定分数。
   - `ZRANGE key start stop [WITHSCORES]`: 按照分数从低到高获取有序集合的成员。
   - `ZREVRANGE key start stop [WITHSCORES]`: 按照分数从高到低获取有序集合的成员。
   - `ZREM key member [member ...]`: 从有序集合中移除一个或多个成员。
   - `ZCARD key`: 获取有序集合的基数（元素数量）。

