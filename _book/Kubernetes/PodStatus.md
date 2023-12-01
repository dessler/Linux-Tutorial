# Pod的各种状态

无论什么控制器，最终落点都会落在pod，所以了解各个pod的状态，对于分析处理问题非常有帮助。



在 Kubernetes 中，Pod 的生命周期涵盖了多个状态，其中包括一些长期状态和短暂状态。下面是这些状态的综合描述：

长期状态:

1. **Pending（挂起）**:
   - Pod 已经被 Kubernetes 系统接受，但一个或多个容器尚未被创建或调度。
2. **Running（运行中）**:
   - Pod 已经被调度到一个节点上，所有容器都被创建，至少有一个容器正在运行、启动或重启。
3. **Succeeded（成功完成）**:
   - Pod 中的所有容器都正常运行完成，并且退出码为 0。
4. **Failed（失败）**:
   - Pod 中至少有一个容器终止执行，并且该容器非正常退出（退出码非 0）。
5. **Unknown（未知）**:
   - Pod 的状态无法被 Kubernetes 确定，通常是由于与 Pod 所在节点的通信故障。
6. **Evicted（被驱逐）**:
   - Pod 被系统驱逐，通常是因为资源紧张，如内存或磁盘空间不足。

短暂状态:

1. **ContainerCreating**:
   - Pod 已经被调度到一个节点但容器尚未完全创建。
   - Kubernetes 可能在拉取镜像、设置网络和准备储存卷。
2. **Init:Waiting**:
   - Pod 有初始化容器，这些容器在主容器启动前运行，如果正在等待它们完成，则会显示此状态。
3. **PodScheduled**:
   - Pod 已被调度到节点但还没完全启动。
4. **Terminating**:
   - Pod 正在被删除，处于清理和资源回收过程中。
5. **CrashLoopBackOff**:
   - Pod 中的一个或多个容器尝试启动后失败，Kubernetes 正在尝试重新启动容器。
6. **ImagePullBackOff/ErrImagePull**:
   - Kubernetes 无法拉取指定的容器镜像。
7. **ContainerStatuses: Waiting**:
   - 容器尚未运行，并等待启动。

要查看 Pod 的详细状态和事件，可以使用以下命令：

```bash
kubectl get pod <pod-name>
kubectl describe pod <pod-name>
```

在 `kubectl describe pod` 的输出中，Events 部分会显示 Pod 的生命周期中的各种短暂状态和相关事件，提供有关 Pod 创建、启动或删除过程中发生的详细信息，有助于诊断和解决问题。



但是这些状态并不绝对，短期状态也可能持续存在，比如下载镜像失败，就会持续存在。

**特别注意Terminating状态如果长期不消失则只能强制删除，但是一般不要轻易这样操作。**

要强制删除一个 Pod，你可以使用 `kubectl` 命令并传递 `--force` 和 `--grace-period=0` 参数。这将立即删除 Pod 而不等待优雅终止的过程。请记住，强制删除可能会导致 Pod 中运行的服务不正常终止，可能会引起数据不一致或其他问题。只有当 Pod 无法正常删除时，才建议使用强制删除。

下面是强制删除 Pod 的命令：

```bash
kubectl delete pod <pod-name> --force --grace-period=0
```

这里的 `<pod-name>` 是你想要删除的 Pod 的名字。

请注意，即使使用了 `--force` 参数，如果 Pod 所在的节点出现问题或与集群的通信中断，Pod 仍可能会显示在资源列表中。在这种情况下，Pod 会在节点重新连接到集群并报告 Pod 已经停止后消失。

另一个注意事项是，如果 Pod 被设置了 finalizers（终结器），那么即使使用了 `--force` 参数，它仍可能不会被立即删除。这是因为 finalizers 是用于在删除资源之前执行特定的清理工作。在这种情况下，你可能需要编辑 Pod 资源以移除 finalizers：

```bash
kubectl edit pod <pod-name>
```

然后删除或清空 `metadata.finalizers` 字段，保存并退出编辑器，Pod 将被删除。