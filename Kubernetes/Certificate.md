[toc]

# 证书

在 Kubernetes（K8s）中，证书扮演着保障集群通信安全的重要角色。以下是一些与证书相关的主要概念和用途：

1. **TLS 证书**：在 Kubernetes 中，TLS（传输层安全）证书用于加密和认证集群中各个组件之间的通信。这包括 API 服务器、kubelet、kube-proxy 等组件之间的通信，以及集群外部与 API 服务器的通信。
2. **证书颁发机构（CA）**：在 Kubernetes 中，通常会使用一个证书颁发机构来签发和管理 TLS 证书。集群中的各个组件使用由 CA 签发的证书进行通信，确保通信的安全性和可信任性。
3. **API 服务器证书**：API 服务器的证书用于对集群外部的请求进行加密，并验证请求的合法性。通常，API 服务器的证书由 CA 签发。
4. **kubelet 证书**：kubelet 是运行在每个节点上的 Kubernetes 组件，它负责管理容器的生命周期。kubelet 使用 TLS 进行与 API 服务器的安全通信，其证书也通常由 CA 签发。
5. **Service 负载均衡证书**：当 Service 暴露为公开服务时，通常需要使用 TLS 证书来加密和验证与 Service 的通信。
6. **证书到期和更新**：证书有一定的有效期限，因此在 Kubernetes 中需要关注证书的到期时间，并在到期前进行更新。Kubernetes 提供了自动证书管理功能，可以帮助进行证书的续期和更新。
7. **Secret 对象**：在 Kubernetes 中，通常会将证书和私钥存储在 Secret 对象中，以便在 Pod 中使用。这样可以确保敏感信息的安全存储和传递。

总之，证书在 Kubernetes 中扮演着保障集群安全的重要角色，用于加密和认证各个组件之间的通信，以及与集群外部的安全通信。尽管证书管理可能会增加一些复杂性，但它是确保集群通信安全的必要手段。

## 证书的分类

### CA证书

简单来说就是证书的颁发机构，本身也是一个证书，并不会直接提供服务。当然他也是有有效期的。

### 普通证书

就是由CA证书颁发的普通证书，直接应用于业务的，他也有有效期的，比如10年，当然他的有效期还受CA的影响，如果颁发CA证书过期了，即便他自己没过期，证书也是会失效。

### KUBEADM证书介绍

```
[root@master01 ~]# kubeadm certs check-expiration
[check-expiration] Reading configuration from the cluster...
[check-expiration] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'

CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Feb 06, 2025 07:46 UTC   349d            ca                      no      
apiserver                  Feb 06, 2025 07:46 UTC   349d            ca                      no      
apiserver-etcd-client      Feb 06, 2025 07:46 UTC   349d            etcd-ca                 no      
apiserver-kubelet-client   Feb 06, 2025 07:46 UTC   349d            ca                      no      
controller-manager.conf    Feb 06, 2025 07:46 UTC   349d            ca                      no      
etcd-healthcheck-client    Feb 06, 2025 07:46 UTC   349d            etcd-ca                 no      
etcd-peer                  Feb 06, 2025 07:46 UTC   349d            etcd-ca                 no      
etcd-server                Feb 06, 2025 07:46 UTC   349d            etcd-ca                 no      
front-proxy-client         Feb 06, 2025 07:46 UTC   349d            front-proxy-ca          no      
scheduler.conf             Feb 06, 2025 07:46 UTC   349d            ca                      no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Feb 04, 2034 07:46 UTC   9y              no      
etcd-ca                 Feb 04, 2034 07:46 UTC   9y              no      
front-proxy-ca          Feb 04, 2034 07:46 UTC   9y              no   
```

```
#从上面来看，整个证书有3个ca，然后这3个ca分别颁发了部分证书
#ca证书默认有效期是10年
#普通证书默认是1年
#当然实际上,在k8s中的证书不仅仅包含以上部分，只是以上的证书是由kubeadm直接颁发和管理而已。
#比如kubelet访问apiserver的证书，这里就没有，这个算是思考题？

#查看证书有效期，查看文件方式
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates
```

## 实践

### 证书续期

由于证书默认只有1年时间，所以就涉及到续期的问题，如果来得及规划，可以通过修改kubeadm源码重新编译，这样可以让他生成的证书增加年限，比如直接告100年，这样可以避免后续在折腾这个证书。

```
kubeadm certs renew  

Available Commands:
  admin.conf               Renew the certificate embedded in the kubeconfig file for the admin to use and for kubeadm itself
  all                      Renew all available certificates
  apiserver                Renew the certificate for serving the Kubernetes API
  apiserver-etcd-client    Renew the certificate the apiserver uses to access etcd
  apiserver-kubelet-client Renew the certificate for the API server to connect to kubelet
  controller-manager.conf  Renew the certificate embedded in the kubeconfig file for the controller manager to use
  etcd-healthcheck-client  Renew the certificate for liveness probes to healthcheck etcd
  etcd-peer                Renew the certificate for etcd nodes to communicate with each other
  etcd-server              Renew the certificate for serving etcd
  front-proxy-client       Renew the certificate for the front proxy client
  scheduler.conf           Renew the certificate embedded in the kubeconfig file for the scheduler manager to use

#可以根据需要签发部分或者全部证书，特别注意，这里证书签发以后需要重启对应的服务才会生效。
#重启服务方式是删除/移动静态pod的yaml文件，直接删除pod虽然会提示成功，并且运行时间也会随着更新。但是容器本身是不会重启的。
```

```
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Feb 22, 2025 01:24 UTC   364d            ca                      no      
apiserver                  Feb 22, 2025 01:24 UTC   364d            ca                      no      
apiserver-etcd-client      Feb 22, 2025 01:24 UTC   364d            etcd-ca                 no      
apiserver-kubelet-client   Feb 22, 2025 01:24 UTC   364d            ca                      no      
controller-manager.conf    Feb 22, 2025 01:24 UTC   364d            ca                      no      
etcd-healthcheck-client    Feb 22, 2025 01:24 UTC   364d            etcd-ca                 no      
etcd-peer                  Feb 22, 2025 01:24 UTC   364d            etcd-ca                 no      
etcd-server                Feb 22, 2025 01:24 UTC   364d            etcd-ca                 no      
front-proxy-client         Feb 22, 2025 01:24 UTC   364d            front-proxy-ca          no      
scheduler.conf             Feb 22, 2025 01:24 UTC   364d            ca                      no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Feb 04, 2034 07:46 UTC   9y              no      
etcd-ca                 Feb 04, 2034 07:46 UTC   9y              no      
front-proxy-ca          Feb 04, 2034 07:46 UTC   9y              no      

#可以看到，ca证书并没有进行续签，但是业务用的证书都续签了。
```

### k8s证书

#### 根证书

| 路径                                   | 解释                          | 年限     |
| -------------------------------------- | ----------------------------- | -------- |
| /etc/kubernetes/pki/etcd/ca.crt        | etcd根证书                    | 默认10年 |
| /etc/kubernetes/pki/ca.crt             | k8s集群根证书                 | 默认10年 |
| /etc/kubernetes/pki/front-proxy-ca.crt | 代理访问k8s根证书（较少使用） | 默认10年 |





#### etcd证书

ca.crt作为根证书，签发etcd对外的服务器证书和签发etcd节点之间的证书和kubelet向etcd发起健康检查的证书

| 配置                   | 文件                                            | 解释                                             | 签发关系       |
| ---------------------- | ----------------------------------------------- | ------------------------------------------------ | -------------- |
| --cert-file            | /etc/kubernetes/pki/etcd/server.crt             | 对外提供服务的服务器证书                         | 被ca.crt签发   |
| --key-file             | /etc/kubernetes/pki/etcd/server.key             | 对外服务器证书私钥                               |                |
| --trusted-ca-file      | /etc/kubernetes/pki/etcd/ca.crt                 | 用于验证访问 etcd 服务器的客户端证书的 CA 根证书 | 签发server.crt |
| --peer-cert-file       | /etc/kubernetes/pki/etcd/peer.crt               | 节点之间相互通信的证书                           | 被ca.crt签发   |
| --peer-key-file        | /etc/kubernetes/pki/etcd/peer.key               | 节点之间私钥                                     |                |
| --peer-trusted-ca-file | /etc/kubernetes/pki/etcd/ca.crt                 | 用于验证 peer 证书的 CA 根证书                   | 签发peer.crt   |
|                        | /etc/kubernetes/pki/etcd/healthcheck-client.crt | 用于kubelet向etcd发起健康检查的证书              | 被ca.crt签发   |
|                        | /etc/kubernetes/pki/etcd/healthcheck-client.key | 用于kubelet向etcd发起健康检查的私钥              |                |





#### kube-apiserver证书（作为etcd客户端）

| 配置            | 文件                                          | 解释                                           | 签发关系                      |
| --------------- | --------------------------------------------- | ---------------------------------------------- | ----------------------------- |
| --etcd-cafile   | /etc/kubernetes/pki/etcd/ca.crt               | 用于验证kube-apiserver向etcd请求证书的CA根证书 | 签发apiserver-etcd-client.crt |
| --etcd-certfile | /etc/kubernetes/pki/apiserver-etcd-client.crt | 用于kube-apiserver向etcd请求的客户端证书       | 被etcd的ca.crt签发            |
| --etcd-keyfile  | /etc/kubernetes/pki/apiserver-etcd-client.key | 用于kube-apiserver向etcd请求的客户端私钥       |                               |



#### kube-apiserver证书

| 配置                           | 文件                                             | 解释                                                         | 签发关系                   |
| ------------------------------ | ------------------------------------------------ | ------------------------------------------------------------ | -------------------------- |
| --client-ca-file               | /etc/kubernetes/pki/ca.crt                       | 集群CA根证书                                                 | 签发apiserver.crt          |
| --tls-cert-file                | /etc/kubernetes/pki/apiserver.crt                | 对外提供服务的的服务器证书                                   | 被ca.crt签发               |
| --tls-private-key-file         | /etc/kubernetes/pki/apiserver.key                | 对外服务器证书私钥                                           |                            |
| --kubelet-client-certificate   | /etc/kubernetes/pki/apiserver-kubelet-client.crt | 用于kube-apiserver访问kubelet的证书                          | 被ca.crt签发               |
| --kubelet-client-key           | /etc/kubernetes/pki/apiserver-kubelet-client.key | 用于kube-apiserver访问kubelet的私钥                          |                            |
| --proxy-client-cert-file       | /etc/kubernetes/pki/front-proxy-client.crt       | kube-proxy启用代理以后，我们通过请求代理端口，代理请求kube-apiserver所需要的证书 | 被front-proxy-ca.crt签发   |
| --proxy-client-key-file        | /etc/kubernetes/pki/front-proxy-client.key       | kube-proxy启用代理以后，我们通过请求代理端口，代理请求kube-apiserver所需要的私钥 |                            |
| --requestheader-client-ca-file | /etc/kubernetes/pki/front-proxy-ca.crt           | 签发代理证书                                                 | 签发front-proxy-client.crt |
| --service-account-key-file     | /etc/kubernetes/pki/sa.pub                       | kube-apiserver 使用的公钥，用户验证kube-controller-manager过来的签名验证（等同于ssh免密登录放置在被登录服务器的公钥）kube-proxy ,flannel,coreDNS等用此方式和apiserver进行通信 |                            |
| --token-auth-file              | /etc/kubernetes/known_tokens.csv                 |                                                              |                            |



#### kube-scheduler证书

| 配置                       | 文件                           | 解释                                               | 签发关系                         |
| -------------------------- | ------------------------------ | -------------------------------------------------- | -------------------------------- |
| certificate-authority-data | /etc/kubernetes/scheduler.conf | 集群CA根证书，通过base64加密以后存储到配置文件里面 | 签发client-certificate-data      |
| client-certificate-data    | /etc/kubernetes/scheduler.conf | 作为客户端请求kube-apiserver的证书                 | 被certificate-authority-data签发 |
| client-key-data            | /etc/kubernetes/scheduler.conf | 作为客户端请求kube-apiserver的私钥                 |                                  |

#### kube-controller-manager证书

| 配置                       | 文件                               | 解释                                               | 签发关系                         |
| -------------------------- | ---------------------------------- | -------------------------------------------------- | -------------------------------- |
| certificate-authority-data | /etc/kubernetes/controller-manager | 集群CA根证书，通过base64加密以后存储到配置文件里面 | 签发client-certificate-data      |
| client-certificate-data    | /etc/kubernetes/controller-manager | 作为客户端请求kube-apiserver的证书                 | 被certificate-authority-data签发 |
| client-key-data            | /etc/kubernetes/controller-manager | 作为客户端请求kube-apiserver的私钥                 |                                  |

#### kubelet证书

| 配置                       | 文件                               | 解释                                               | 签发关系                         |
| -------------------------- | ---------------------------------- | -------------------------------------------------- | -------------------------------- |
| certificate-authority-data | /etc/kubernetes/controller-manager | 集群CA根证书，通过base64加密以后存储到配置文件里面 | 签发client-certificate-data      |
| client-certificate-data    | /etc/kubernetes/controller-manager | 作为客户端请求kube-apiserver的证书                 | 被certificate-authority-data签发 |
| client-key-data            | /etc/kubernetes/controller-manager | 作为客户端请求kube-apiserver的私钥                 |                                  |