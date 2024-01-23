[toc]

# Ceph命令

***作者有话说：任何命令都需要自己在实际中多操作，有些命令/参数就算记不住也没关系，需要用的时候在查下就可以了，但是前提你要知道这个命令。***

## 命令介绍

Ceph 提供了一组命令行工具，用于管理和监控 Ceph 存储集群。以下是一些常用的 Ceph 命令：

1. ceph-deploy：用于部署 Ceph 存储集群的命令行工具。它可以配置和安装 Ceph 集群的各个组件，如 MON、OSD 和 MDS。
2. ceph：用于管理和监控 Ceph 存储集群的主要命令行工具。它可以执行多种操作，如创建和删除存储池、添加和删除 OSD、查看集群状态和性能指标等。
3. rados：用于管理 Ceph 存储集群中的 RADOS（Reliable Autonomic Distributed Object Store）对象存储的命令行工具。它可以执行各种操作，如上传和下载对象、创建和删除存储桶、查看对象和存储桶的信息等。
4. rbd：用于管理 Ceph 存储集群中的 RBD（RADOS Block Device）块设备的命令行工具。它可以创建和删除块设备、映射和卸载块设备、执行快照和克隆等操作。
5. cephfs：用于管理 Ceph 存储集群中的 Ceph 文件系统的命令行工具。它可以创建和删除文件系统、挂载和卸载文件系统、执行权限管理和配额控制等操作。
6. ceph-rest-api：用于启动 Ceph RESTful API 服务的命令。它允许通过 HTTP 或 HTTPS 协议访问和管理 Ceph 存储集群。

这些命令行工具可以在 Ceph 存储集群的管理节点上使用。通过结合使用这些工具，您可以对 Ceph 存储集群进行配置、管理和监控，以满足您的存储需求。您可以通过运行各个命令的帮助选项（例如，ceph --help）来查看命令的具体用法和参数。

以下是一些常用的 Ceph 命令的详细解释：

1. ceph：
   - `ceph health`：查看 Ceph 集群的健康状态。
   - `ceph status`：显示 Ceph 集群的状态和拓扑信息。
   - `ceph osd status`：显示 OSD 的状态和详细信息。
   - `ceph osd tree`：显示 OSD 的拓扑树。
   - `ceph df`：显示 Ceph 存储池的使用情况。
   - `ceph osd pool stats`：显示每个存储池的统计信息。
   - `ceph osd pool ls`：列出所有的存储池。
   - `ceph pg stat`：显示每个 PG（Placement Group）的状态和统计信息。
   - `ceph pg dump`：显示 PG 的详细信息。
2. rados：
   - `rados df`：显示 RADOS 对象存储的使用情况。
   - `rados ls`：列出 RADOS 存储集群中的所有对象。
   - `rados get <pool-name> <object-name> <file-path>`：从 RADOS 存储集群中获取对象并保存到本地文件。
   - `rados put <pool-name> <object-name> <file-path>`：将本地文件上传到 RADOS 存储集群中。
   - `rados rm <pool-name> <object-name>`：删除 RADOS 存储集群中的对象。
3. rbd：
   - `rbd ls`：列出 RBD（RADOS Block Device）块设备。
   - `rbd create <pool-name>/<image-name> [--size <image-size>]`：创建一个新的 RBD 块设备。
   - `rbd info <pool-name>/<image-name>`：显示 RBD 块设备的详细信息。
   - `rbd snap create <pool-name>/<image-name>@<snapshot-name>`：创建 RBD 块设备的快照。
   - `rbd snap ls <pool-name>/<image-name>`：列出 RBD 块设备的快照。
   - `rbd snap rollback <pool-name>/<image-name>@<snapshot-name>`：将 RBD 块设备回滚到指定的快照。
   - `rbd rm <pool-name>/<image-name>`：删除 RBD 块设备。
4. cephfs：
   - `ceph fs ls`：列出 Ceph 文件系统。
   - `ceph fs status`：显示 Ceph 文件系统的状态和详细信息。
   - `mount -t ceph <MON-IP>:6789:/ <mount-point>`：挂载 Ceph 文件系统到本地。
   - `umount <mount-point>`：卸载 Ceph 文件系统。

这些命令提供了管理和监控 Ceph 存储集群的各种操作和信息。您可以根据具体的需求使用相应的命令来进行配置、管理和监控。您可以通过运行命令的帮助选项（例如，ceph --help）来查看更多的命令用法和参数。

`cephadm` 是一个用于管理 Ceph 集群的命令行工具。它是 Ceph 官方提供的一种用于部署和管理 Ceph 集群的方法。以下是一些常用的 `cephadm` 命令及其功能的介绍：

1. `cephadm install`：安装 Ceph 管理器（Ceph Manager）和监视器（Monitor）节点。在安装 Ceph 集群之前，需要首先执行此命令。
2. `cephadm bootstrap`：使用指定的 SSH 密钥在远程主机上启动 Ceph 管理器，并创建一个初始的 Ceph 集群。
3. `cephadm add`：在 Ceph 集群中添加一个新的节点。您可以使用此命令来扩展集群，添加新的存储和计算节点。
4. `cephadm shell`：在 Ceph 管理器节点上打开一个 shell 连接，以执行进一步的管理操作。
5. `cephadm deploy`：使用指定的 YAML 文件部署 Ceph 如 OSD（对象存储设备）和 MDS（元数据服务器）等服务。
6. `cephadm adopt`：将一个已经存在的 Ceph 节点纳入 Cephadm 管理并进行管理。
7. `cephadm rm`：从 Ceph 集群中删除指定的节点。
8. `cephadm shell`：打开 Ceph 管理器节点的 shell 连接，以执行进一步的管理操作。

这只是一些常用的 `cephadm` 命令示例，还有其他一些命令可以用于不同的管理和维护任务。您可以使用 `cephadm --help` 或 `cephadm <command> --help` 来获取更详细的命令帮助信息。

希望这能帮助您了解 `cephadm` 命令。如果您有其他问题，请随时提问。

## 真实有用命令

### 1.纠错码的命令

如果要创建常用的4+2需要按照下面的流程来操作，默认的纠错码如果不定义是2+2。

1. 定义一个配置文件

```
ceph osd erasure-code-profile set myecprofile k=4 m=2
```

2. 创建pool，使用该配置文件

```
 ceph osd pool create myecpool 128 128 erasure myecprofile
```

3. 查看当前pool属于那个配置文件

```
ceph osd pool get <pool_name> erasure_code_profile
```

4. 查看某个配置文件的详细信息

```
ceph osd erasure-code-profile get <profile_name>  
```

