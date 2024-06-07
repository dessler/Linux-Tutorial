# 安装

`Redis`一般有3种安装方式，使用系统的自带的包管理工具，但是这个版本比较低；使用`Docker`安装，但是这个需要有基础条件；第三种就是编译安装。由于`Redis`并没有提供二进制包，我们如果要使用就基本上以上三种其中一种。

## 下载

```
#根据需要选择对应的版本,本次以redsi-7.2.4，操作系统为centos 7.9
https://download.redis.io/releases/
```

## 编译安装

```
#redis是C语言编写的，所以需要安装gcc编译器
yum -y install gcc
```



```
tar xvf redis-7.2.4.tar.gz 
cd redis-7.2.4
make MALLOC=libc   //make会报错，所以加了个参数
make install
```

```
#安装完成会生成3个文件及3个软连接，由于不加任何参数编译，生成的文件直接在 /usr/local/bin目录，所以可以直接使用。
-rwxr-xr-x 1 root root 1069016 6月   7 09:41 redis-benchmark
lrwxrwxrwx 1 root root      12 6月   7 09:41 redis-check-aof -> redis-server
lrwxrwxrwx 1 root root      12 6月   7 09:41 redis-check-rdb -> redis-server
-rwxr-xr-x 1 root root 1790600 6月   7 09:41 redis-cli
lrwxrwxrwx 1 root root      12 6月   7 09:41 redis-sentinel -> redis-server
-rwxr-xr-x 1 root root 9420728 6月   7 09:41 redis-servercd 
```

## 启动

```
#默认不加任何参数是前台启动，并且持久化配置也在当前目录。
redis-server
```

```
#从配置文件启动，具体实现就是以配置文件方式来确定
redis-server redis.conf
```

当然这些启动都仅仅是把redis拉起来而已，只能作为测试环境使用 ，真正的生产环境，你需要考虑的稳定性，可靠性，服务自动拉起等功能。比如使用服务来启动或者通过第三方管控来实现启动。