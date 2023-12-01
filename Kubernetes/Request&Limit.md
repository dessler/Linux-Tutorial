# Request&Limit

## 请求与限制基本介绍

在 Kubernetes 配置文件中，`requests` 和 `limits` 是与资源管理相关的两个重要概念，它们都在 `spec` 部分的 `containers` 字段下定义。这两个设置用于控制 Pod 中容器可以使用的资源量，通常指的是 CPU 和内存资源。

以下是 `requests` 和 `limits` 在容器配置中的示例用法：

```yaml
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"  # 请求内存
        cpu: "250m"     # 请求 CPU
      limits:
        memory: "128Mi" # 内存限制
        cpu: "500m"     # CPU 限制
```

### 解释：

- `requests`：定义了容器启动时最小的资源需求量。
  - `memory: "64Mi"`：此容器在创建时，至少需要 64MiB 的内存才能运行。
  - `cpu: "250m"`：此容器在创建时，至少需要 0.25 CPU 核心的处理能力。在 Kubernetes 中，1 CPU 等于云供应商的 1 vCPU/Core 或者物理 CPU 的 1 核心。
- `limits`：定义了容器运行过程中可以使用的资源上限。
  - `memory: "128Mi"`：此容器可以使用的内存上限是 128MiB。如果容器尝试使用超过此限制的内存，它可能会被 OOMKilled（内存不足杀掉）。
  - `cpu: "500m"`：此容器可以使用的 CPU 处理能力上限是 0.5 核心。如果容器尝试使用更多的 CPU，它的 CPU 使用将会被限制，在必要时会被节流（降低 CPU 使用率）。

设置合适的 `requests` 和 `limits` 对于 Kubernetes 集群的稳定性和性能至关重要。`requests` 用于调度决策，Kubernetes 调度器将保证每个 Pod 都能至少获得其 `requests` 指定的资源。而 `limits` 用于防止 Pod 过度消耗资源，保证系统资源不会被单个 Pod 占用过多。这有助于避免资源争抢，确保集群中的其他 Pod 也能获得必要的资源。

## 