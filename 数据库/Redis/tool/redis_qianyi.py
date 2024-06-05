import redis

def migrate_redis_data(source_host, source_port, source_password, target_host, target_port, target_password):
    # 连接源 Redis 实例
    source_redis = redis.Redis(host=source_host, port=source_port, password=source_password, decode_responses=True)

    # 连接目标 Redis 实例
    target_redis = redis.Redis(host=target_host, port=target_port, password=target_password)

    # 获取源 Redis 实例中的所有键
    keys = source_redis.keys()

    # 逐个迁移键和对应的值
    for key in keys:
        # 获取源 Redis 中的值
        value = source_redis.dump(key)

        # 导入值到目标 Redis
        target_redis.restore(key, 0, value)

    print("数据迁移完成！")

if __name__ == "__main__":
    # 源 Redis 实例的连接信息
    source_host = "source_redis_host"
    source_port = 6379
    source_password = "source_redis_password"

    # 目标 Redis 实例的连接信息
    target_host = "target_redis_host"
    target_port = 6379
    target_password = "target_redis_password"

    # 执行数据迁移
    migrate_redis_data(source_host, source_port, source_password, target_host, target_port, target_password)
