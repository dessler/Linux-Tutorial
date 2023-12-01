# Nginx

nginx 配置4层代理

```
stream {
  server {
    listen 80;
    proxy_pass backend1.example.com:8080;
  }
  server {
    listen 81;
    proxy_pass backend2.example.com:8081;
  }
}
```

```
stream {
  upstream backend_servers {
    server backend1.example.com:8080;
    server backend2.example.com:8081;
  }
  server {
    listen 80;
    proxy_pass backend_servers;
  }
}
```

