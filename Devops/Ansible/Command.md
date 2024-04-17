[toc]

# 常用命令

ansible命令常用主要分为两种，一种就是直接使用，另外一种就是使用playbook编写脚本来执行。

## ping 模块

Ansible 的 ping 模块是用于检查目标主机是否可达的基本模块之一。尽管它的名称是 "ping"，但它实际上不是发送 ICMP 回显请求（ping）来检查主机是否可达，而是通过执行一个非常轻量级的操作来测试与主机的连接。

1. **功能**：
   - 检查目标主机是否可达。
   - 验证 Ansible 是否能够与目标主机建立连接。
   - 用于快速测试 Ansible 的基本功能。
2. **用法**：
   - 在 Ansible 命令中，使用 ping 模块，指定目标主机或主机组即可。
   - 语法：`ansible <host-pattern> -m ping`
3. **示例**：
   - 检查单个主机是否可达：`ansible 192.168.0.130 -m ping`
   - 检查主机组是否可达：`ansible mygroup -m ping`

  主机组配置文件是`/etc/ansible/hosts`

## command 模块

Ansible 的 command 模块用于在目标主机上执行任意的命令，并返回执行结果。与在命令行中直接执行命令相比，使用 Ansible 的 command 模块可以实现批量执行、并行执行、以及输出结果的收集和处理等功能。

以下是 command 模块的主要功能和用法：

1. **功能**：

   - 在目标主机上执行任意的命令。
   - 可以执行 Shell 命令、Python 脚本等。
   - 返回命令的标准输出和标准错误输出。

2. **用法**：

   - 在 Ansible 命令中，使用 command 模块，指定要执行的命令即可。
   - 语法：`ansible <host-pattern> -m command -a "<command>"`

3. **示例**：

   - 在目标主机上执行 `ls -l` 命令：`ansible myhost -m command -a "ls -l"`
   - 在目标主机上执行 `uname -a` 命令：`ansible myhost -m command -a "uname -a"`

4. **返回结果**：

   - 如果命令执行成功，将返回命令的标准输出。
   - 如果命令执行失败，将返回标准错误输出或错误信息。

5. **注意事项**：

   - 虽然 command 模块可以执行任意的命令，但建议尽量使用专门的模块来代替，例如使用 yum 模块安装软件包，使用 file 模块管理文件等，这样更符合 Ansible 的最佳实践。

   - 在执行敏感命令时，务必谨慎处理，避免泄露敏感信息或对系统造成损坏。

## shell 模块

Ansible 的 shell 模块与 command 模块类似，用于在目标主机上执行任意的命令，但与 command 模块不同的是，shell 模块会在目标主机上启动一个 Shell 环境来执行命令，因此可以支持更复杂的命令、管道和重定向等操作。

以下是 shell 模块的主要功能和用法：

1. **功能**：
   - 在目标主机上启动一个 Shell 环境，并执行任意的命令。
   - 支持复杂的命令、管道、重定向、通配符等 Shell 特性。
   - 返回命令的标准输出和标准错误输出。
2. **用法**：
   - 在 Ansible 命令中，使用 shell 模块，指定要执行的命令即可。
   - 语法：`ansible <host-pattern> -m shell -a "<command>"`
3. **示例**：
   - 在目标主机上执行 `ls -l | grep test` 命令：`ansible myhost -m shell -a "ls -l | grep test"`
   - 在目标主机上执行 `df -h` 命令：`ansible myhost -m shell -a "df -h"`
4. **返回结果**：
   - 如果命令执行成功，将返回命令的标准输出。
   - 如果命令执行失败，将返回标准错误输出或错误信息。
5. **注意事项**：
   - 由于 shell 模块会启动一个 Shell 环境，因此执行效率可能会比 command 模块稍低，特别是在大规模批量执行时。
   - 尽量避免在 Ansible 中编写复杂的 Shell 命令，应尽量使用专门的模块来代替，以提高可读性和可维护性。

## script 模块

`script` 模块允许在远程主机上执行本地脚本，并将执行结果返回到 Ansible 控制节点。与 `shell` 和 `command` 模块不同，`script` 模块允许你在控制节点上指定一个本地脚本文件，然后将其复制到远程主机上执行。

#### 特点

- **复制和执行脚本**：`script` 模块会将本地脚本文件复制到远程主机上，并在远程主机上执行该脚本。
- **本地脚本**：脚本文件可以是在控制节点上已经存在的本地文件，Ansible 将直接使用该文件；或者可以是在 playbook 中指定的一个相对路径或绝对路径的文件名。
- **返回结果**：与其他模块一样，`script` 模块会返回执行结果，包括标准输出和标准错误输出。
- **权限**：在执行脚本之前，确保脚本文件在控制节点上具有执行权限，Ansible 将在远程主机上保留相同的权限。

#### 用法示例

```
yaml复制代码
- name: 在远程主机上执行本地脚本
  hosts: myhost
  tasks:
    - name: 使用 script 模块执行脚本
      script: /path/to/local/script.sh
```

在这个示例中，`script` 模块会将本地的 `/path/to/local/script.sh` 文件复制到远程主机上，并在远程主机上执行该脚本。

#### 结果输出

与 `shell` 和 `command` 模块不同，`script` 模块默认只返回脚本执行的状态（成功或失败），而不返回输出。如果你需要脚本的输出，可以通过 `register` 将输出保存到一个变量中，然后通过 `debug` 模块将这个变量打印出来。例如：

```
yaml复制代码
- name: 在远程主机上执行本地脚本并获取输出
  hosts: myhost
  tasks:
    - name: 使用 script 模块执行脚本并获取输出
      script: /path/to/local/script.sh
      register: script_output

    - name: 打印脚本输出
      debug:
        msg: "{{ script_output.stdout }}"
```

在这个示例中，脚本的标准输出会保存在 `script_output.stdout` 变量中，并通过 `debug` 模块打印出来。

#### 总结

`script` 模块是 Ansible 中用于在远程主机上执行本地脚本的方便方式，特别适用于需要执行复杂操作或需要在多台主机上执行相同脚本的情况。

## copy &fetch 模块

**功能：** `copy` 将文件或目录从控制节点复制到远程主机。

​            `fetch`从远程主机获取文件或目录到控制节点。

**用法：**

```
ansible mygroup -m copy -a "src=/path/to/local/file.txt dest=/path/on/remote/file.txt"
ansible mygroup -m fetch -a "src=/path/on/remote/file.txt dest=/path/to/local/"
```

- `src`: copy本地文件路径,如果是fetch则相反。
- `dest`: copy远程主机目标路径，如果是fetch则相反。

**注意事项：**

- 确保远程主机文件路径正确并具有适当的权限。
- 目标路径必须是一个目录，否则会将文件下载到具有相同名称的文件中。

## 其他

除了以上比较常用可以单独拿出来说，其实还有很多模块，并且在不同的版本是有不同的模块, 需要有特定的需求的时候根据需要去研究对应的模块使用方法即可。

```
Ansible 提供了丰富的模块，用于执行各种任务，从系统管理到应用部署，涵盖了多个领域。以下是一些常用的 Ansible 模块及其功能的详细介绍：

command: 在目标主机上执行任意的命令。
shell: 在目标主机上执行命令，并支持使用 shell 语法。
raw: 在目标主机上执行原始的 SSH 命令，不经过模块解释。
script: 在目标主机上执行本地脚本。
copy: 将文件从控制节点复制到目标主机。
fetch: 从目标主机复制文件到控制节点。
template: 使用 Jinja2 模板引擎，在控制节点上渲染模板文件，然后将结果复制到目标主机。
lineinfile: 在文件中添加、修改或删除特定行。
replace: 替换文件中的特定字符串。
yum: 在 CentOS/RHEL 等基于 YUM 的系统上安装、卸载或更新软件包。
apt: 在 Ubuntu/Debian 等基于 APT 的系统上安装、卸载或更新软件包。
pip: 使用 pip 在 Python 环境中安装 Python 包。
service: 启动、停止或重新启动系统服务。
user: 管理系统用户，包括创建、删除和修改用户账户。
group: 管理系统用户组，包括创建、删除和修改用户组。
file: 对文件和目录进行管理，包括创建、删除、修改权限等操作。
cron: 管理 crontab 定时任务。
wait_for: 等待条件满足后再继续执行任务。
pause: 在剧本执行过程中暂停一段时间。
debug: 打印调试信息。
uri: 发送 HTTP、HTTPS 请求，并处理响应。
docker_container: 管理 Docker 容器的创建、启动、停止等操作。
k8s: 在 Kubernetes 集群中执行各种操作，如创建、删除、扩展 Pod 等。
ec2: 在 AWS EC2 实例上执行各种操作，如创建、删除、启动、停止实例等。
gce: 在 Google Cloud Platform 上执行各种操作，如创建、删除、启动、停止实例等。
azure_rm: 在 Azure 上执行各种操作，如创建、删除、启动、停止虚拟机等。
ios_command / ios_config: 用于在 Cisco 设备上执行命令和配置。
这些只是 Ansible 模块中的一小部分，还有许多其他模块可用于特定的任务和场景。Ansible 的模块库不断扩展，可以根据需要自定义编写模块，或从社区中获取第三方模块来满足各种需求
```

