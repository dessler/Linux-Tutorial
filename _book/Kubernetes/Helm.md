# Helm

## Helm介绍

Helm 是一个 Kubernetes 应用程序的包管理工具。它简化了Kubernetes应用的安装和管理。Helm 由客户端工具 `helm` 和服务端组件 `tiller`（仅在 Helm v2 中）组成。Helm v3 在后来的版本中移除了 Tiller 组件，以增强安全性和简化操作。

以下是 Helm 的一些关键特性：

**应用程序包格式**：

- Helm 定义了一种应用程序包格式称为“图表”（charts）。一个图表是一组描述Kubernetes资源的文件集合。
- 图表可以简化复杂应用的安装流程，因为它们包含了应用所有必要的Kubernetes资源和配置信息。

**应用程序仓库**：

- Helm 允许用户从仓库中添加、更新和下载图表。
- Helm Hub 是 Helm 官方的集中仓库，用户可以找到各种社区维护的图表。
- 用户也可以创建和维护私有仓库。

**版本控制和升级**：

- Helm 管理图表的版本，使得部署的应用可以轻松升级和回滚。
- 通过Helm，你可以升级应用到新版本，或者回滚到旧版本，而无需直接操作底层Kubernetes资源。

**模板化和配置**：

- 图表使用模板语言来动态配置Kubernetes资源，这为部署相同应用的不同实例（例如不同的环境或配置）提供了灵活性。
- Helm 的模板语法允许用户重用代码，通过简单的配置改变来定制资源。

**依赖管理**：

- Helm 允许图表定义依赖于其他图表，这使得复杂应用的部署成为可能，因为你可以组合不同的图表来构建整个应用。

**社区和生态系统**：

- 由于 Helm 的流行，已经建立了一个庞大的社区和生态系统。这意味着许多常见的应用和服务都有现成的图表可以使用。
- Helm 社区积极维护和更新图表，确保与Kubernetes的兼容性。

从 Helm v2 到 Helm v3 的主要变化：

- 移除了 Tiller，图表的安装和管理现在完全在客户端进行，提高了操作及安全性。
- 引入了新的图表API版本及相关改进，例如改进的版本控制和发布追踪机制。
- 改进了对Kubernetes资源的处理，包括对CRDs（自定义资源定义）的支持。

Helm 是 Kubernetes 生态系统中的核心工具之一，它大幅简化了Kubernetes应用的部署和管理流程。

## Helm安装

要在Kubernetes集群上安装Helm，你需要按照以下步骤来安装Helm客户端并初始化它：

1. **下载Helm**: 前往[官方Helm发布页面](https://github.com/helm/helm/releases)来下载适合你的操作系统的Helm版本。你可以使用以下命令在Linux上下载并解压Helm（以特定版本为例，确保更换为最新版本）:

   ```shell
   curl -s https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz | tar xz
   ```

2. **安装Helm**: 从解压后的目录中找到`helm`二进制文件，并移动它到某个在你的PATH中的位置，如`/usr/local/bin/`。

   ```shell
   sudo mv linux-amd64/helm /usr/local/bin/helm
   ```

3. **验证Helm安装**: 确认Helm已正确安装：

   ```shell
   helm version
   ```

   你应该看到Helm的版本信息。

4. **添加仓库（可选）**: Helm V3不再自带默认仓库。你可以根据需要添加官方仓库或者其他仓库，比如添加Nginx Ingress仓库：

   ```shell
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   ```

5. **使用Helm安装应用**: 一旦Helm客户端安装并配置好，你就可以开始使用它来安装应用了。例如，你可以用Helm来安装Nginx Ingress控制器：

   ```shell
   helm install my-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
   ```

   这条命令将会在`ingress-nginx`命名空间中安装一个名为`my-nginx`的Nginx Ingress控制器实例。

记住，上述命令是针对Linux系统的。如果你使用的是MacOS或Windows，相关的下载命令和文件路径会有所不同，但安装的基本步骤是相同的。 若要安装Helm的其他平台版本，请参照[Helm的官方文档](https://helm.sh/docs/intro/install/)。

Helm V3不再需要在集群上安装Tiller，这是Helm V2使用的服务器端组件。Helm V3是客户端只的工具，因此不需要对Kubernetes集群进行任何特殊的初始化。







**作者的理解：通俗来说，如果你发布了一个应用，里面可能包含多个资源，如果按照常规的方式，需要去挨个创建对应的资源，但是如果使用helm则一个用一个命令，把这些资源都拉起来。并且这个还有仓库，可以分发自己或者使用别人已经配置好了的包。**

