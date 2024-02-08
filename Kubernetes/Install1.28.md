[toc]

# Install

本文档是基于kubernetes+containerd搭建。

## 1.环境准备

| 机器IP        | 角色   | 配置  | 系统                |
| ------------- | ------ | ----- | ------------------- |
| 192.168.0.58  | master | 8C16G | centos7，未升级内核 |
| 192.168.0.127 | node   | 8C16G | centos7，未升级内核 |



## 2.初始化

​	这里的大部分操作都是属于通用的，不仅仅用于部署kubernetes，部署其他系统也是通用。当然其实这里大部分操作，如果是使用云主机，其实大部分都是自带了的。配置这些应该是养成运维习惯的一部分。

### 2.1 关闭防火墙

```
systemctl stop firewalld && systemctl disable firewalld
```

### 2.2 关闭selinux

```
setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```

### 2.3 关闭swap

```
swapoff -a && sed -ri 's/.*swap.*/#&/' /etc/fstab
```

### 2.4 同步时间

```
yum -y install ntpd
systemctl start ntpd && systemctl enable ntpd
#默认安装都是指向centos的官方ntp，根据实际情况修改里面的ntp地址。
```

### 2.5 修改主机名&hosts

```
#修改主机名
hostnamectl set-hostname master01 
hostnamectl set-hostname node01

#添加hosts
echo '192.168.0.58 master01' >>/etc/hosts
echo '192.168.0.127 node01'  >>/etc/hosts
```



## 3.部署

### 3.1 修改内核参数

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

### 3.2 安装containerd

#### 3.2.1 添加yum源

​	虽然不安装docker，但是 由于containerd是docker开源并捐赠给CNCF的，所以containerd和docker实际用的是一个源。

```
vi /etc/yum.repos.d/containerd.repo

[containerd]
name=containerd
baseurl=https://download.docker.com/linux/centos/7/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
```

#### 3.2.2 安装containerd

```
yum install -y containerd.io
```

#### 3.3.2 配置containerd

```
#生成全量的配置文件，默认里面几乎没什么配置
containerd config default > /etc/containerd/config.toml

#修改cgroup
sed -i 's/systemd_cgroup = false/systemd_cgroup = true/g' /etc/containerd/config.toml


#修改镜像地址
#默认是registry.k8s.io/pause:3.6，可能后面的版本环境不一样可能有区别。
sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
```



#### 3.3.4启动containerd

```
systemctl start containerd && systemctl enable containerd
```



### 3.3 安装kubernetes

#### 3.3.1 添加yum源

```
vi /etc/yum.repos.d/kubernetes.repo

[kubernetes]
name=kubernetes
enabled=1
gpgcheck=0
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
```

#### 3.3.2 安装kubeadm

```
#安装最新版
yum -y install kubelet kubeadm kubectl

#安装指定版本，虽然在编写该文档时候最新的版本是1.28.6，但是yum源并没更新只更新到了1.28.2(可以在源对应的目录去查看搜索)
yum -y install kubelet-1.28.2 kubeadm-1.28.2 kubectl-1.28.2
```

#### 3.3.3 启动kubelet

```
systemctl start kubelet && systemctl enable kubelet
```

## 3.4 创建集群

​	之前的操作都是所有所有节点都需要做的，下面的操作才是分master和node分开执行。

#### 3.4.1 初始化master

```
kubeadm init \
  --apiserver-advertise-address=192.168.0.58 \
  --image-repository registry.aliyuncs.com/google_containers \
  --service-cidr=10.10.0.0/16 \
  --pod-network-cidr=172.16.0.0/16 \
  --kubernetes-version v1.28.2 \
  --v=5

```

```
[root@master01 ~]# kubeadm init   --apiserver-advertise-address=192.168.0.58   --image-repository registry.aliyuncs.com/google_containers   --service-cidr=10.10.0.0/16   --pod-network-cidr=172.16.0.0/16  --kubernetes-version v1.28.2 --v=5
I0207 15:45:54.480079    8217 initconfiguration.go:117] detected and using CRI socket: unix:///var/run/containerd/containerd.sock
I0207 15:45:54.480135    8217 kubelet.go:196] the value of KubeletConfiguration.cgroupDriver is empty; setting it to "systemd"
[init] Using Kubernetes version: v1.28.2
[preflight] Running pre-flight checks
I0207 15:45:54.482350    8217 checks.go:563] validating Kubernetes and kubeadm version
I0207 15:45:54.482363    8217 checks.go:168] validating if the firewall is enabled and active
I0207 15:45:54.486852    8217 checks.go:203] validating availability of port 6443
I0207 15:45:54.486960    8217 checks.go:203] validating availability of port 10259
I0207 15:45:54.486973    8217 checks.go:203] validating availability of port 10257
I0207 15:45:54.486985    8217 checks.go:280] validating the existence of file /etc/kubernetes/manifests/kube-apiserver.yaml
I0207 15:45:54.486992    8217 checks.go:280] validating the existence of file /etc/kubernetes/manifests/kube-controller-manager.yaml
I0207 15:45:54.486998    8217 checks.go:280] validating the existence of file /etc/kubernetes/manifests/kube-scheduler.yaml
I0207 15:45:54.487003    8217 checks.go:280] validating the existence of file /etc/kubernetes/manifests/etcd.yaml
I0207 15:45:54.487010    8217 checks.go:430] validating if the connectivity type is via proxy or direct
I0207 15:45:54.487034    8217 checks.go:469] validating http connectivity to first IP address in the CIDR
I0207 15:45:54.487046    8217 checks.go:469] validating http connectivity to first IP address in the CIDR
I0207 15:45:54.487053    8217 checks.go:104] validating the container runtime
I0207 15:45:54.510569    8217 checks.go:639] validating whether swap is enabled or not
I0207 15:45:54.510606    8217 checks.go:370] validating the presence of executable crictl
I0207 15:45:54.510623    8217 checks.go:370] validating the presence of executable conntrack
I0207 15:45:54.510640    8217 checks.go:370] validating the presence of executable ip
I0207 15:45:54.510649    8217 checks.go:370] validating the presence of executable iptables
I0207 15:45:54.510659    8217 checks.go:370] validating the presence of executable mount
I0207 15:45:54.510667    8217 checks.go:370] validating the presence of executable nsenter
I0207 15:45:54.510682    8217 checks.go:370] validating the presence of executable ebtables
I0207 15:45:54.510690    8217 checks.go:370] validating the presence of executable ethtool
I0207 15:45:54.510698    8217 checks.go:370] validating the presence of executable socat
I0207 15:45:54.510706    8217 checks.go:370] validating the presence of executable tc
I0207 15:45:54.510713    8217 checks.go:370] validating the presence of executable touch
I0207 15:45:54.510725    8217 checks.go:516] running all checks
I0207 15:45:54.515491    8217 checks.go:401] checking whether the given node name is valid and reachable using net.LookupHost
I0207 15:45:54.515618    8217 checks.go:605] validating kubelet version
I0207 15:45:54.553340    8217 checks.go:130] validating if the "kubelet" service is enabled and active
I0207 15:45:54.557995    8217 checks.go:203] validating availability of port 10250
I0207 15:45:54.558032    8217 checks.go:329] validating the contents of file /proc/sys/net/bridge/bridge-nf-call-iptables
I0207 15:45:54.558078    8217 checks.go:329] validating the contents of file /proc/sys/net/ipv4/ip_forward
I0207 15:45:54.558095    8217 checks.go:203] validating availability of port 2379
I0207 15:45:54.558109    8217 checks.go:203] validating availability of port 2380
I0207 15:45:54.558121    8217 checks.go:243] validating the existence and emptiness of directory /var/lib/etcd
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
I0207 15:45:54.558176    8217 checks.go:828] using image pull policy: IfNotPresent
I0207 15:45:54.576842    8217 checks.go:854] pulling: registry.aliyuncs.com/google_containers/kube-apiserver:v1.28.2
I0207 15:46:01.153665    8217 checks.go:854] pulling: registry.aliyuncs.com/google_containers/kube-controller-manager:v1.28.2
I0207 15:46:05.714600    8217 checks.go:854] pulling: registry.aliyuncs.com/google_containers/kube-scheduler:v1.28.2
I0207 15:46:08.746929    8217 checks.go:854] pulling: registry.aliyuncs.com/google_containers/kube-proxy:v1.28.2
I0207 15:46:11.774341    8217 checks.go:854] pulling: registry.aliyuncs.com/google_containers/pause:3.9
I0207 15:46:13.235333    8217 checks.go:854] pulling: registry.aliyuncs.com/google_containers/etcd:3.5.9-0
I0207 15:46:22.290000    8217 checks.go:854] pulling: registry.aliyuncs.com/google_containers/coredns:v1.10.1
[certs] Using certificateDir folder "/etc/kubernetes/pki"
I0207 15:46:25.095452    8217 certs.go:112] creating a new certificate authority for ca
[certs] Generating "ca" certificate and key
I0207 15:46:25.301323    8217 certs.go:519] validating certificate period for ca certificate
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local master01] and IPs [10.10.0.1 192.168.0.58]
[certs] Generating "apiserver-kubelet-client" certificate and key
I0207 15:46:25.464177    8217 certs.go:112] creating a new certificate authority for front-proxy-ca
[certs] Generating "front-proxy-ca" certificate and key
I0207 15:46:25.579642    8217 certs.go:519] validating certificate period for front-proxy-ca certificate
[certs] Generating "front-proxy-client" certificate and key
I0207 15:46:25.782808    8217 certs.go:112] creating a new certificate authority for etcd-ca
[certs] Generating "etcd/ca" certificate and key
I0207 15:46:25.828289    8217 certs.go:519] validating certificate period for etcd/ca certificate
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [localhost master01] and IPs [192.168.0.58 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [localhost master01] and IPs [192.168.0.58 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
I0207 15:46:26.368020    8217 certs.go:78] creating new public/private key files for signing service account users
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
I0207 15:46:26.478203    8217 kubeconfig.go:103] creating kubeconfig file for admin.conf
[kubeconfig] Writing "admin.conf" kubeconfig file
I0207 15:46:26.888151    8217 kubeconfig.go:103] creating kubeconfig file for kubelet.conf
[kubeconfig] Writing "kubelet.conf" kubeconfig file
I0207 15:46:27.080651    8217 kubeconfig.go:103] creating kubeconfig file for controller-manager.conf
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
I0207 15:46:27.168802    8217 kubeconfig.go:103] creating kubeconfig file for scheduler.conf
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
I0207 15:46:27.368663    8217 local.go:65] [etcd] wrote Static Pod manifest for a local etcd member to "/etc/kubernetes/manifests/etcd.yaml"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
I0207 15:46:27.368687    8217 manifests.go:102] [control-plane] getting StaticPodSpecs
I0207 15:46:27.368813    8217 certs.go:519] validating certificate period for CA certificate
I0207 15:46:27.368854    8217 manifests.go:128] [control-plane] adding volume "ca-certs" for component "kube-apiserver"
I0207 15:46:27.368859    8217 manifests.go:128] [control-plane] adding volume "etc-pki" for component "kube-apiserver"
I0207 15:46:27.368863    8217 manifests.go:128] [control-plane] adding volume "k8s-certs" for component "kube-apiserver"
I0207 15:46:27.369401    8217 manifests.go:157] [control-plane] wrote static Pod manifest for component "kube-apiserver" to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
I0207 15:46:27.369413    8217 manifests.go:102] [control-plane] getting StaticPodSpecs
I0207 15:46:27.369534    8217 manifests.go:128] [control-plane] adding volume "ca-certs" for component "kube-controller-manager"
I0207 15:46:27.369540    8217 manifests.go:128] [control-plane] adding volume "etc-pki" for component "kube-controller-manager"
I0207 15:46:27.369544    8217 manifests.go:128] [control-plane] adding volume "flexvolume-dir" for component "kube-controller-manager"
I0207 15:46:27.369548    8217 manifests.go:128] [control-plane] adding volume "k8s-certs" for component "kube-controller-manager"
I0207 15:46:27.369553    8217 manifests.go:128] [control-plane] adding volume "kubeconfig" for component "kube-controller-manager"
I0207 15:46:27.370018    8217 manifests.go:157] [control-plane] wrote static Pod manifest for component "kube-controller-manager" to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[control-plane] Creating static Pod manifest for "kube-scheduler"
I0207 15:46:27.370028    8217 manifests.go:102] [control-plane] getting StaticPodSpecs
I0207 15:46:27.370137    8217 manifests.go:128] [control-plane] adding volume "kubeconfig" for component "kube-scheduler"
I0207 15:46:27.370485    8217 manifests.go:157] [control-plane] wrote static Pod manifest for component "kube-scheduler" to "/etc/kubernetes/manifests/kube-scheduler.yaml"
I0207 15:46:27.370498    8217 kubelet.go:67] Stopping the kubelet
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
I0207 15:46:27.428040    8217 waitcontrolplane.go:83] [wait-control-plane] Waiting for the API server to be healthy
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 4.001674 seconds
I0207 15:46:31.430957    8217 uploadconfig.go:112] [upload-config] Uploading the kubeadm ClusterConfiguration to a ConfigMap
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
I0207 15:46:31.579708    8217 uploadconfig.go:126] [upload-config] Uploading the kubelet component config to a ConfigMap
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
I0207 15:46:31.587058    8217 uploadconfig.go:131] [upload-config] Preserving the CRISocket information for the control-plane node
I0207 15:46:31.587077    8217 patchnode.go:31] [patchnode] Uploading the CRI Socket information "unix:///var/run/containerd/containerd.sock" to the Node API object "master01" as an annotation
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node master01 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: bjw2m9.cmzpb40r0a8cfks9
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
I0207 15:46:32.615201    8217 clusterinfo.go:47] [bootstrap-token] loading admin kubeconfig
I0207 15:46:32.615545    8217 clusterinfo.go:58] [bootstrap-token] copying the cluster from admin.conf to the bootstrap kubeconfig
I0207 15:46:32.615716    8217 clusterinfo.go:70] [bootstrap-token] creating/updating ConfigMap in kube-public namespace
I0207 15:46:32.618608    8217 clusterinfo.go:84] creating the RBAC rules for exposing the cluster-info ConfigMap in the kube-public namespace
I0207 15:46:32.622239    8217 kubeletfinalize.go:90] [kubelet-finalize] Assuming that kubelet client certificate rotation is enabled: found "/var/lib/kubelet/pki/kubelet-client-current.pem"
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
I0207 15:46:32.622782    8217 kubeletfinalize.go:134] [kubelet-finalize] Restarting the kubelet to enable client certificate rotation
[addons] Applied essential addon: CoreDNS
I0207 15:46:32.795359    8217 request.go:629] Waited for 83.214332ms due to client-side throttling, not priority and fairness, request: POST:https://192.168.0.58:6443/api/v1/namespaces/kube-system/serviceaccounts?timeout=10s
I0207 15:46:33.004989    8217 request.go:629] Waited for 197.247023ms due to client-side throttling, not priority and fairness, request: POST:https://192.168.0.58:6443/apis/rbac.authorization.k8s.io/v1/namespaces/kube-system/rolebindings?timeout=10s
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.58:6443 --token bjw2m9.cmzpb40r0a8cfks9 \
	--discovery-token-ca-cert-hash sha256:4898ec334fb11c86aedda7948d0005776c8f37682a75570d0c4430b4d9128818 

```

#### 3.4.2 配置master

​	 按照上面的配置操作以后，就可以使用kubectl get 获取节点信息。

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
```

#### 3.4.3 添加node节点

​	按照上面的信息加入集群

```
kubeadm join 192.168.0.58:6443 --token bjw2m9.cmzpb40r0a8cfks9 \
	--discovery-token-ca-cert-hash sha256:4898ec334fb11c86aedda7948d0005776c8f37682a75570d0c4430b4d9128818 
```

```
[root@node01 ~]# kubeadm join 192.168.0.58:6443 --token bjw2m9.cmzpb40r0a8cfks9 --discovery-token-ca-cert-hash sha256:4898ec334fb11c86aedda7948d0005776c8f37682a75570d0c4430b4d9128818
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

#### 3.4.4 部署网络插件

​	注意事项：下载下来的文件定义的service的cidr是10.244.0.0/16，如果在初始化集群的时候用的和这个不一致，需要先修改，然后再再apply到集群里面，否则容器会无法拉起。

```
https://github.com/flannel-io/flannel/releases/download/v0.22.3/kube-flannel.yml

[root@master01 ~]# kubectl  apply -f kube-flannel.yml 
namespace/kube-flannel created
serviceaccount/flannel created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created
```

#### 3.4.5 检查集群状态

```
[root@master01 ~]# kubectl  get node
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   49m   v1.28.2
node01     Ready    <none>          12m   v1.28.2
[root@master01 ~]# 
[root@master01 ~]# kubectl  get pod -A
NAMESPACE      NAME                               READY   STATUS    RESTARTS   AGE
kube-flannel   kube-flannel-ds-hg9s4              1/1     Running   0          28s
kube-flannel   kube-flannel-ds-zr2md              1/1     Running   0          28s
kube-system    coredns-66f779496c-dx46n           1/1     Running   0          49m
kube-system    coredns-66f779496c-gjr9f           1/1     Running   0          49m
kube-system    etcd-master01                      1/1     Running   0          49m
kube-system    kube-apiserver-master01            1/1     Running   0          49m
kube-system    kube-controller-manager-master01   1/1     Running   0          49m
kube-system    kube-proxy-5pjdz                   1/1     Running   0          49m
kube-system    kube-proxy-cm2jk                   1/1     Running   0          12m
kube-system    kube-scheduler-master01            1/1     Running   0          49m

```

