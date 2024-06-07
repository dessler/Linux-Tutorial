### 常见 Redis 配置参数

1. **bind**：指定 Redis 仅监听来自特定IP地址的连接请求，增加安全性。如果不设置，默认监听所有接口。
2. **protected-mode**：当未设置密码且bind为默认设置时，开启保护模式以阻止非本地机器的访问。
3. **port**：设置 Redis 服务器监听的端口，默认是6379。
4. **timeout**：设置客户端闲置多久后关闭连接，0表示禁用。
5. **loglevel**：设置日志级别（debug, verbose, notice, warning）。
6. **logfile**：指定日志文件的路径，""表示输出到标准输出。
7. **databases**：设置数据库的数量，默认值是16。
8. **save**：指定不同的时间间隔和更改的键数来触发自动保存到磁盘的操作。
9. **rdbcompression**：在进行RDB持久化时，是否压缩数据，以减少磁盘使用。
10. **dbfilename**：RDB文件的文件名。
11. **dir**：指定所有持久化文件的存储目录。
12. **appendonly**：是否开启AOF持久化模式。
13. **appendfilename**：AOF文件的名称。
14. **maxmemory**：最大内存使用量，超过此值后，将根据`maxmemory-policy`策略来处理新的写入命令。
15. **maxmemory-policy**：达到内存上限后的数据清理策略。
16. **slaveof**：设置该 Redis 服务器为其他某个 Redis 实例的从属服务器。
17. **masterauth**：如果主服务器设置了密码，从服务器连接主服务器时的密码。



如果要查看所有参数：https://github.com/redis/redis/ 

