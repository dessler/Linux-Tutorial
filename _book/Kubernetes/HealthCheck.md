# HealthCheck

在 Kubernetes 中，*健康检查*（Health Checks）主要通过两种机制来实现：Liveness Probes 和 Readiness Probes。这些检查帮助 Kubernetes 理解应用程序内部的状态，并相应地管理 Pod。配置健康检查确保 Kubernetes 能够响应应用的故障，提供自动恢复的能力，并确保流量不会发送到尚未准备好处理请求的 Pod。

### Liveness Probes

Liveness Probes 确定何时需要重启容器。例如，当应用陷入死锁，能够响应 Web 服务器的 ping，但无法进行进一步操作时，最好是重启容器。

这里是一个 Liveness Probe 的示例配置：

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 3
  periodSeconds: 3
```

### Readiness Probes

Readiness Probes 确定容器是否已经准备好接受流量。如果 Pod 不准备好，它会从服务的负载均衡器中移除。Readiness Probes 通常用于在启动时，容器需要加载大量数据或配置文件、与外部服务进行连接等场景。

这里是一个 Readiness Probe 的示例配置：

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### 健康检查类型

- `httpGet`：Kubernetes 尝试对指定的路径和端口执行 HTTP GET 请求。如果返回的状态码是 200-399 之间，那么就认为是成功的。

- `exec`：Kubernetes 会在容器内执行指定的命令。如果命令退出代码为 0，则认为探测成功。

  ```
     livenessProbe:
        exec:
          command:
          - my-command
        initialDelaySeconds: 10
        periodSeconds: 5
  ```

- `tcpSocket`：Kubernetes 尝试打开容器的指定端口。如果能够建立 TCP 连接，则探测被认为是成功的。

  ```
     readinessProbe:
        tcpSocket:
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 10
  ```

  

### 常见参数

- `initialDelaySeconds`：容器启动后延迟多少秒后开始进行第一次探测。
- `periodSeconds`：执行探测的频率。
- `timeoutSeconds`：探测请求超时的秒数。
- `successThreshold`：探测被认为成功之前的最小连续成功次数。
- `failureThreshold`：当探测失败后，Kubernetes 尝试重启之前的最小连续失败次数。

正确配置健康检查有助于确保 Kubernetes 集群能够自动处理容器失败，以及只将流量发送到已准备好的服务实例。



在 Kubernetes 中，当您需要在 Pod 终止之前执行特定的清理操作或优雅关闭应用程序时，可以使用“关闭钩子”(Termination Hooks)。最常见的是使用 `preStop` 钩子，这是一个在发送 SIGTERM 信号给容器以结束进程之前执行的命令或 HTTP 请求。

这个目前使用还是比较少的，可作为了解。

### `preStop` 钩子的 `exec` 示例

以下是 `preStop` 钩子配置的示例，它使用 `exec` 类型执行一个脚本或命令。在这个例子中，`preStop` 钩子执行一个名为 `pre-stop-script.sh` 的脚本。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mycontainer
    image: myimage
    lifecycle:
      preStop:
        exec:
          command: ["/bin/sh", "-c", "/usr/sbin/pre-stop-script.sh"]
```

在此例中，当 Pod 收到终止请求后，它将运行指定的脚本，然后等待该脚本执行完成。在脚本完成后，Kubernetes 将继续正常的终止过程，向容器进程发送 SIGTERM 信号。

### `preStop` 钩子的 `httpGet` 示例

如果你的应用程序提供了一个 HTTP 终端来实施优雅的关闭，你可以使用 `httpGet` 类型的 `preStop` 钩子。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mycontainer
    image: myimage
    lifecycle:
      preStop:
        httpGet:
          path: /pre-stop
          port: 8080
          scheme: HTTP
```

在这个例子中，当 Pod 收到终止请求后，Kubernetes 将对容器内的 `/pre-stop` 端点发起 HTTP GET 请求，容器可以在该端点处理任何必要的清理工作。处理完成后，Kubernetes 会发送 SIGTERM 信号以终止容器。

请记住，`preStop` 钩子的执行时间会计入 Pod 的 `terminationGracePeriodSeconds`（默认 30 秒），如果钩子执行超出了宽限期，Kubernetes 将发送 SIGKILL 信号强制终止容器。如果你的清理操作需要较长时间，确保设置一个足够长的宽限期。