# Kubectl命令

`kubectl` 是 Kubernetes 的命令行工具，它允许用户与 Kubernetes 集群进行交互。以下是 `kubectl` 命令的一些常用操作及其说明：
## 系统命令
### 获取资源信息

- `kubectl get <resource>`: 列出某种类型的所有资源。例如，`kubectl get pods` 会列出所有的 Pods。
- `kubectl describe <resource> <name>`: 显示某个具体资源的详细信息。例如，`kubectl describe pod my-pod`。

### 创建和更新资源

- `kubectl apply -f <file>`: 根据指定的 YAML 或 JSON 文件创建或更新资源。例如，`kubectl apply -f deployment.yaml`。
- `kubectl create -f <file>`: 根据指定的 YAML 或 JSON 文件创建资源。与 `apply` 不同，`create` 仅用于创建操作。
- `kubectl edit <resource> <name>`: 编辑集群中的资源。这将打开一个文本编辑器供您修改当前资源的配置。

### 删除资源

- `kubectl delete <resource> <name>`: 删除某个具体资源。例如，`kubectl delete pod my-pod`。
- `kubectl delete -f <file>`: 根据指定的 YAML 或 JSON 文件删除资源。

### 与 Pod 和容器交互

- `kubectl exec <pod> -- <command>`: 在指定的 Pod 中执行命令。例如，`kubectl exec my-pod -- ls /` 会在 `my-pod` 中执行 `ls /`。
- `kubectl logs <pod>`: 获取 Pod 中容器的日志。如果 Pod 有多个容器，则需使用 `-c <container>` 指定容器。
- `kubectl attach <pod>`: 附加到正在运行的容器以查看输出流或交云控制台。
- `kubectl port-forward <pod> <local-port>:<pod-port>`: 将本地端口转发到 Pod 中的端口。

### 管理集群

- `kubectl config view`: 查看 `kubectl` 的配置信息，包括集群、用户和上下文。
- `kubectl cluster-info`: 获取集群的端点信息。
- `kubectl top <node|pod>`: 显示节点或 Pod 的 CPU 和内存使用情况。

### 高级命令

- `kubectl rollout status <resource>/<name>`: 查看资源的部署状态。例如，`kubectl rollout status deployment/my-deployment`。
- `kubectl rollout undo <resource>/<name>`: 回滚资源到之前的状态。例如，`kubectl rollout undo deployment/my-deployment`。
- `kubectl scale <resource>/<name> --replicas=<num>`: 缩放资源的副本数。例如，`kubectl scale deployment/my-deployment --replicas=3`。

### 帮助和自省

- `kubectl help`: 获取命令行帮助。
- `kubectl explain <resource>`: 获取资源定义的详细信息。

以上只是 `kubectl` 命令的一小部分。根据不同的需要，`kubectl` 提供了丰富的子命令和选项来处理各种 Kubernetes 资源管理任务。你可以使用 `kubectl <command> --help` 获取特定命令的详细使用说明。
## 常用命令

```
# 1.查看pod所在节点及ip地址
kubectl get pod -n xxx -o wide
# 2.查看某个资源的详细信息
kubectl get xxx -n xxx -o yaml
# 3.查看退出状态容器日志（均指容器的标准输出），不加-p则查看当前运行中的日志，加了-p则看最后一个退出的容器
kubectl log -f -n xxx xxxx -p
# 4.多容器查看日志（均指容器的标准输出）container-name则是在yaml文件里面定义的名字
kubectl logs -f <pod-name> -c <container-name>
# 5.多容器进入
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh
# 6.强制删除容器（慎用）
kubectl delete pod <pod-name> --force --grace-period=0
# 7.编辑资源，k8s中的命令太多，有的时候不太记得，但是又想某个资源则可以用
kubectl edit deployment <deployment-name>
```

