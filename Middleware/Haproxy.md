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

