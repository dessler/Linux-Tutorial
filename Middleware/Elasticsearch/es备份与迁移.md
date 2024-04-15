    本地以单机版配置为标准，如果是多级集群会涉及到共目录的问题,并考虑阿里云使用
[toc]
# 一.ES备份
## 1.修改es配置文件elasticsearch.yml
如果是云es则可以不需要该步骤
```
echo "path.repo: /root/java" >>elasticsearch.yml
```
## 2.重启es
## 3.创建仓库
其中xk_backup是仓库的名字
### 3.1本地仓库
```
curl -XPUT 'http://192.168.2.22:9200/_snapshot/xk_backup' -H 'Content-Type: application/json' -d
'{
"type": "fs",
"settings": {
    "location": "/root/java",
    "compress": "true"
    }
}'
```
### 3.2 云es仓库使用阿里oss
其中xk_backup是仓库的名字，
-u user:passwd 为账号密码
settings里面参数:oss的可用区，id，秘钥，桶
```
curl -XPUT 'http://**.elasticsearch.aliyuncs.com:9200/_snapshot/xk_backup' -H 'Content-Type: application/json' -u user:passwd -d '{
    "type": "oss",
    "settings": {
        "endpoint": "http://oss-cn-hangzhou-internal.aliyuncs.com", 
        "access_key_id": "*********",
        "secret_access_key": "*********",
        "bucket": "**********", 
        "compress": true
    }
}'
```
## 4.查看仓库
```
curl -XGET 'http://192.168.2.22:9200/_snapshot/xk_backup?pretty' 
{
  "xk_backup" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/root/java"
    }
  }
}
```
## 5.备份
xk_backup为刚刚创建的仓库名字，xk_zb为创建的快照名字，wait_for_completion=true参数会阻塞备份，备份完成才返回结果，如果不加这个参数则马上返回结果，备份操作在后台执行
```
 curl -XPUT 'http://192.168.2.22:9200/_snapshot/xk_backup/xk_zb?wait_for_completion=true'
```
## 6.查看备份结果
也可以查看所有快照
将快照名字xk_zb 替换为 _all 即可
```
curl -XGET 'http://192.168.2.22:9200/_snapshot/xk_backup/xk_zb'
```
# 二.备份还原（本操作时候还原到异地其他ES）
## 1.准备同版本的es服务器
## 2.参考备份1, 2，3，4步骤创建同名备份仓库
## 3.将备份服务器备份仓库目录下所有内容复制到本地仓库目录
## 4.还原
```
curl -XPOST 192.168.2.23:9200/_snapshot/xk_backup/xk_zb/_restore?wait_for_completion=true
```
## 5.验证还原结果
```
curl -XGET 'http://192.168.2.23:9200/_snapshot/xk_backup/xk_zb'
```