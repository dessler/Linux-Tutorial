# Pod的介绍

## 基本介绍

在 Kubernetes 中，Pod（容器组）是最小的可调度和可部署的单元。它是一个逻辑概念，用于包装一个或多个相关的容器，并共享网络和存储资源。

Pod 中的容器紧密相关，并且它们一起协同工作来提供某种服务或应用程序。这些容器可以共享同一个网络命名空间和存储卷，它们可以通过 localhost 直接通信。

Pod 具有以下特点：

1. 调度单元：Pod 是 Kubernetes 中最小的调度单元，调度器将一个 Pod 分配给一个可用的节点来运行。
2. 共享网络和存储：Pod 中的容器共享同一个网络命名空间和存储卷。它们可以通过 localhost 直接通信，并共享数据。
3. 生命周期：Pod 具有自己的生命周期，可以创建、启动、停止和删除。当 Pod 被删除时，它内部的所有容器也会被终止。

Pod 有以下几种常见的使用方式：

1. 单容器 Pod：一个 Pod 中只包含一个容器，用于运行一个独立的应用程序服务。
2. 多容器 Pod：一个 Pod 中包含多个紧密相关的容器，可以协同工作。例如，一个应用程序容器和一个辅助容器（如 Sidecar 容器）共同组成一个 Pod。
3. 无状态 Pod：Pod 中的容器不需要保持任何状态，所有数据都来自外部存储（如数据库）或者共享数据卷。
4. 有状态 Pod：Pod 中的容器需要保持一些状态，例如使用本地存储或者共享存储卷存储数据。

总而言之，Pod 是 Kubernetes 中最小的可调度和可部署的单元。它包含一个或多个紧密相关的容器，并共享网络和存储资源。Pod 具有自己的生命周期，可以独立创建、启动、停止和删除。Pod 可以以单容器或多容器的方式使用，并可以是无状态或有状态的。

## 范例一: 单容器

```
apiVersion: v1            # API 版本
kind: Pod                 # 资源类型
metadata:
  name: example-pod       # Pod 名称
  labels:
    app: example          # 标签，用于标识和选择相关的资源
spec:
  containers:             # 容器列表
  - name: example-container  # 容器名称
    image: nginx:latest      # 容器镜像
    ports:
    - containerPort: 80      # 容器内的端口号
```

这个 Pod 清单定义了一个名为 `example-pod` 的 Pod，其中包含一个名为 `example-container` 的容器，该容器基于 `nginx:latest` 镜像。容器将打开端口 80 以便其他 Pod 或服务可以访问它。

要在 Kubernetes 集群中创建这个 Pod，你可以保存这个 YAML 文件，并使用 `kubectl` 命令行工具应用它：

```bash
kubectl apply -f my-pod.yaml
```

在这里，`my-pod.yaml` 是包含上述内容的文件。执行这个命令后，Kubernetes 会根据定义创建 Pod，并确保它按预期运行。

## 范例二：多容器

下面是一个包含两个容器的 Pod 清单文件的示例。这个 Pod 会运行两个容器，其中一个使用 `nginx` 镜像，另一个使用 `busybox` 镜像。每个容器运行不同的应用或服务。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: two-containers-pod
  labels:
    purpose: demonstrate-multi-container
spec:
  containers:
  - name: nginx-container     # 第一个容器
    image: nginx:latest
    ports:
    - containerPort: 80

  - name: busybox-container   # 第二个容器
    image: busybox
    args:                     # 为 busybox 提供参数，让它执行死循环命令
    - /bin/sh
    - -c
    - "while true; do sleep 3600; done"
```

在这个 YAML 文件中：

- `apiVersion`: 指定 Kubernetes API 版本，`v1` 是核心 API 版本。

- `kind`: 指定 Kubernetes 资源类型，这里是 Pod。

- `metadata`: 提供 Pod 的元数据，包括名称和标签。

- `spec`: 描述 Pod 的规范，包括其中运行的容器。

- ```
  containers
  ```

  : 这是一个容器列表，包含 Pod 内的所有容器。

  - `name`: 容器的名称。
  - `image`: 容器使用的镜像。
  - `ports`: 指定容器需要暴露的端口（对于 nginx 容器）。
  - `args`: 提供给容器的启动参数（对于 busybox 容器），这里让 busybox 容器执行一个死循环命令，让它保持运行状态。

保存这个文件，例如命名为 `two-containers-pod.yaml`，然后可以使用 `kubectl` 工具来创建 Pod:

```bash
kubectl apply -f two-containers-pod.yaml
```

这个命令会在你的 Kubernetes 集群中创建一个名为 `two-containers-pod` 的 Pod，该 Pod 内运行两个容器。

![image-20231128151604707](.Pod/image-20231128151604707-1701156316235-1.png)

**从图上可以看到单容器会显示1/1，2个容器会显示2/2，前面的数据代表准备好了的容器，后面的数字代表总容器数量。**

以上都是居于Kubernetes层面来看的，如果从容器层面来看，第一个单容器的Pod，会真实生成2个容器，第二个实例会生成3个容器

![image-20231128151855108](.Pod/image-20231128151855108-1701156316236-2.png)

甚至连Kubernetes自身的pod，包括kube-apiserver/kube-controller-manager/kube-scheduler等也会默认有2个容器

![image-20231128152003918](.Pod/image-20231128152003918-1701156316236-3.png)

可以看到，每个Pod都有一个容器，使用了pause的镜像，启动命令也只有 一个/pause，他是做什么用的，为什么会有这样一个容器的存在。

在 Kubernetes Pod 的上下文中，"pause" 容器起着特殊且重要的角色。在一个 Pod 内，可以有一个或多个业务容器，它们是实际运行应用程序的容器。除此之外，每个 Pod 还会启动一个特殊的容器，称为 "pause" 容器。这个容器不会执行任何实际的应用程序逻辑，它的目的是充当整个 Pod 所有容器的 "父容器"。Pause 容器的作用包括：

1. **资源共享和管理：** Pause 容器是 Pod 内所有容器的资源命名空间的持有者。这意味着网络和 IPC（进程间通信）命名空间都是由 pause 容器创建和持有的。其他业务容器在启动时会加入到这个已经存在的命名空间，从而能够共享相同的网络视图（比如 IP 地址和端口空间）和能够进程间通信。
2. **保持 Pod 的存活状态：** Pause 容器的另一个作用是保证 Pod 保持运行状态，即使业务容器被停止或者崩溃，只要 pause 容器还在运行，Pod 就不会被 Kubernetes 认为是完全死亡的。这可以让 Kubernetes 的调度器和控制器以一种可预测的方式管理 Pod 的生命周期。
3. **提供一个恒定的环境：** Pause 容器在 Pod 的整个生命周期内都是运行的，这为其他容器提供了一个稳定的环境。例如，如果一个业务容器需要重启，它可以重新连接到相同的网络和 IPC 命名空间。

为了实现这些功能，pause 容器通常是一个非常轻量级的容器，使用的镜像占用空间非常小，它不会执行任何实质性的程序，只是简单地在无限循环中休眠状态，等待被 Kubernetes 使用。

Pause 容器的使用是 Kubernetes 管理 Pod 内部容器的一个技术细节，并且对于大多数用户来说是透明的。然而，了解它的存在和作用可以帮助更好地理解 Kubernetes Pod 的内部工作原理。



**作者有话说：在早期的Kubernetes介绍pod会直接引用pod的英文翻译豆荚来介绍什么是Pod，还是很贴切的，整个豆荚包括豆荚壳+豆子，其中豆荚壳可以理解为pause容器，每个豆荚都必须有一个，至于豆荚里面有几个豆子，其实就等效于里面有几个容器，他们共享了豆荚壳的空间等信息。**

## 静态Pod

静态Pod是Kubernetes中的一种特殊类型的Pod，由kubelet直接管理而不是由apiserver管理。这意味着静态Pods不受Kubernetes控制平面（如Scheduler、Controller Manager）的直接控制。静态Pods通常用于运行控制平面组件本身，如Kubernetes Master节点上的apiserver、controller-manager和scheduler。

静态Pods的特点如下：

- **由Kubelet管理**：静态Pods由在节点上运行的kubelet程序直接管理。kubelet会周期性扫描指定的目录，任何在这个目录中的Pod定义文件（通常是YAML或JSON格式）都会被自动创建。
- **不通过apiserver**：静态Pods不依赖于Kubernetes apiserver。即使apiserver不可用，kubelet也可以启动静态Pods。
- **节点范围**：静态Pods只能在它们启动的特定节点上运行，无法跨节点迁移。
- **控制平面组件**：静态Pods通常用于启动控制平面组件，因为它们可以在没有Kubernetes API的情况下启动。

创建静态Pod的步骤如下：

1. **准备Pod的定义文件**：创建一个包含Pod定义的YAML或JSON文件。这个定义与普通的Pod定义类似，但是不需要包含`apiVersion`或`kind`字段，因为kubelet并不会通过Kubernetes API来解析这些定义。
2. **配置kubelet**：在kubelet的配置中（通常是`/etc/kubernetes/kubelet.conf`），指定一个或多个用于存放静态Pod定义文件的目录。例如，你可以在kubelet的启动参数中加上`--pod-manifest-path=/etc/kubernetes/manifests`。
3. **将Pod定义文件放入指定目录**：将上一步准备的Pod定义YAML或JSON文件放入kubelet配置中指定的目录。
4. **kubelet创建Pod**：kubelet会自动检测目录中的新文件，并基于这些文件启动静态Pod。
5. **验证静态Pod状态**：可以通过在节点上运行`kubectl get pods`命令查看静态Pod的状态。尽管kubelet直接管理这些Pod，但它们的状态信息依然会被报告给apiserver并显示在kubectl命令的输出中。

静态Pod是Kubernetes集群初始化时的关键组件，因为它们可以在没有Kubernetes API的情况下启动必要的控制平面服务。然而，由于它们的管理和调度不受集群的统一管理，所以静态Pods主要用于特殊的用途，而不是通常的应用部署。



**作者优化说：虽然可以通过kubectl 查看静态pod，但是无法删除该pod，虽然提示你删除成功，但是实际容器是不会真实删除的。这类pod重启，通常是通过移除/还原该pod的配置文件来实现的，这个操作反应有的时候很快，有的时候会稍慢，操作的时候需要注意。正常情况下修改里面的配置文件都会触发pod重建**