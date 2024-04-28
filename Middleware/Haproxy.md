# Haproxy

4层代理配置,不支持udp代理

```
global
    maxconn 2000

defaults
    mode tcp
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend tcp_frontend
    bind *:80
    default_backend tcp_backend

backend tcp_backend
    server backend1 192.168.0.11:8011 check


frontend tcp_frontend1
    bind *:88
    default_backend tcp_backend1

backend tcp_backend1
    server backend1 192.168.0.11:88 check


frontend tcp_frontend2
    bind *:1000
    default_backend tcp_backend2

backend tcp_backend2
    server backend1 192.168.0.11:1000 check


frontend tcp_frontend3
    bind *:30
    default_backend tcp_backend3

backend tcp_backend3
    server backend1 192.168.0.11:30 check

frontend tcp_frontend4
    bind *:22
    default_backend tcp_backend4

backend tcp_backend4
    server backend1 192.168.0.11:22 check
```

检查配置文件是否正确

```
haproxy -c -f <config-file>：这个命令可以用来检查配置文件的语法和语义错误。它会读取指定的配置文件并尝试进行解析，如果配置文件中存在任何错误，它会输出错误信息并指出错误的位置。

haproxy -d -f <config-file>：这个命令会在配置文件中检查语法错误的同时，也会输出一些调试信息。它对于定位错误可能会更有帮助。
```

