# Linux安全

Linux 安全主要涉及以下几个关键领域：

1. 用户和组管理：Linux 系统中，所有的文件和进程都有一个所有者。为确保系统的安全，应该对每个用户及其权限进行严格的管理，避免非授权的用户访问和修改重要文件。
2. 文件权限：在 Linux 中，你可以设置谁可以读取、写入或执行某个文件。这个“谁”可以是文件的所有者、用户组或其他任何人。你应该始终确认你的文件权限设置正确。
3. 防火墙：防火墙可以帮助你控制哪些服务可以从网络上访问你的系统。你应该设置防火墙规则，以只允许必要的网络连接，并阻止所有不需要的连接。
4. 安全软件：你应该安装和配置安全软件，如 SELinux 和 AppArmor，以增强你的系统安全。此外，你应该定期更新你的系统和软件，以获取最新的安全补丁。
5. 安全的 Shell 使用：对于需要 shell 访问的用户，应该使用适当的 shell 设置和工具，如 sudo，来控制他们可以执行的命令。
6. 网络服务安全：如果你的系统运行了网络服务，如 HTTP 服务器或 FTP 服务器，你应该配置这些服务以最小化安全风险。例如，你可以通过使用 chroot 环境，限制服务的文件系统访问。
7. 审计和日志：你应该配置并使用日志和审计系统，如 syslog 和 auditd，以跟踪系统事件和可能的安全问题。
8. 加密：对于敏感数据，你应该使用加密技术，如 GPG 或 SSL，来保护它。
9. 访问控制和认证：对于重要服务和数据，你应该使用强大的访问控制和认证机制，如 PAM 或 Kerberos。
10. 安全的编程实践：如果你开发自己的软件，你应该遵循安全编程实践，如使用安全的函数，避免缓冲区溢出等。

## 1.防火墙的介绍

iptables 和 firewalld 都是在 Linux 系统中用来设置网络防火墙规则的工具。

1. iptables：

   iptables 是一个强大的防火墙工具，它在内核空间中作为 netfilter 模块的一部分运行。iptables 用于配置单个 Linux 机器上的网络流量过滤规则，它可以匹配、修改和处理所有网络数据包。iptables 规则包括匹配条件和动作，当数据包满足匹配条件时，就执行相应的动作，动作可以是接受、丢弃或者重定向数据包。

2. firewalld：

   firewalld 是 Red Hat 和 CentOS 7 以上版本的默认防火墙工具，它是 iptables 的前端工具，用于更简单地管理和配置 iptables 规则。firewalld 使用 zones 和 services 的概念，使得配置防火墙规则变得更直观和更易于管理。firewalld 支持动态更新防火墙规则，无需重启防火墙或清除当前的规则。

总结来说，iptables 和 firewalld 都是 Linux 防火墙规则的管理工具，它们都可以用于过滤和处理网络数据包。iptables 是一个底层的工具，它提供了强大且灵活的功能，但是配置可能会比较复杂。firewalld 则提供了一个更简单易用的接口，使得管理防火墙规则变得更加容易。

### 1.1 Iptabeles

iptables 是 Linux 操作系统中的一个命令行工具，被用于配置内核防火墙的规则。它使系统管理员能够定义过滤规则，从而控制进入和离开系统的网络流量。

iptables 的主要功能包括：

1. 数据包过滤：iptables 可以根据源 IP 地址，目标 IP 地址，源端口，目标端口，协议类型等因素来决定是否允许数据包通过。
2. NAT(网络地址转换)：iptables 能够修改数据包的源和/或目标 IP 地址，这在路由器和防火墙中是很常见的。
3. 数据包修改：除了过滤和 NAT 功能外，iptables 还可以修改流经网络的数据包。

iptables 的工作原理涉及到以下几个概念：

1. 链：iptables 的规则是按照链的形式组织的，每条链都对应一组规则。主要有三条预定义的链：INPUT（处理进入系统的数据包），OUTPUT（处理从系统发出的数据包），和 FORWARD（处理通过系统路由的数据包）。
2. 表：iptables 有四个表，每个表包含一组用于特定目的的链。这些表包括：filter（用于数据包过滤），nat（用于网络地址转换），mangle（用于特殊的数据包修改），和 raw（用于配置 exemptions）。
3. 规则：规则是 iptables 的核心部分，每条规则都定义了一个匹配条件和一个目标。如果一个数据包满足匹配条件，那么就会执行对应的目标动作。

iptables 是一个强大且灵活的工具，但也相对复杂。对于大多数用户来说，可能更倾向于使用更高级别的防火墙管理工具，如 UFW 或者 FirewallD，它们提供了更友好的用户接口，但底层依然是通过 iptables 来实现防火墙功能。

iptables 的规则有无数种，以下是一些常见的例子：

1. 允许来自特定 IP 的访问：

```
iptables -A INPUT -s 192.168.0.10 -j ACCEPT
```

这条规则将允许源 IP 为 192.168.0.10 的所有流量进入系统。

1. 拒绝所有的 ICMP 流量：

```
iptables -A INPUT -p icmp -j DROP
```

这条规则将拒绝所有的 ICMP（互联网控制消息协议）流量，这包括 ping 请求。

1. 允许 SSH 连接：

```
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

这条规则允许所有的入站 SSH（端口 22）连接。

1. 设置默认策略为拒绝所有流量：

```
iptables -P INPUT DROP
```

这条规则将所有未被特别允许的流量拒之门外。为了保证连接的正常，我们通常会在设置这个默认策略之前，先允许某些特定的流量。

1. 阻止特定IP访问：

```
iptables -A INPUT -s 192.168.0.10 -j DROP
```

这条规则将阻止所有的来自 IP 为 192.168.0.10 的流量。

需要注意的是，iptables 的规则是按顺序执行的，所以规则的顺序非常重要。

iptables 命令有很多参数，我来介绍一下一些最常用的参数：

1. `-A`：将规则添加到链的末尾。比如 `iptables -A INPUT` 就是在 INPUT 链的末尾加入新的防火墙规则。
2. `-D`：删除一条规则。你需要指定链和规则的编号或者完整的规则内容。例如 `iptables -D INPUT 1` 就是删除 INPUT 链中的第一条规则。
3. `-I`：在链中的某个位置插入规则，后面可以跟一个数字 n，表示在链中的第 n 个位置插入。例如 `iptables -I INPUT 1` 就是在 INPUT 链的最前面（第一条）插入新的防火墙规则。
4. `-F`：清空所有规则。
5. `-L`：列出所有的规则。
6. `-P`：设置默认策略，通常为 ACCEPT 或 DROP。例如 `iptables -P INPUT DROP` 将默认策略设置为拒绝所有流量。
7. `-s`：指定源 IP 或者子网，例如 `-s 192.168.0.1`。
8. `-d`：指定目标 IP 或者子网，例如 `-d 192.168.0.1`。
9. `-p`：指定协议，比如 tcp、udp、icmp 等。
10. `--dport`：指定目标端口，通常与 `-p` 选项一起使用。例如 `-p tcp --dport 22`。
11. `-j`：指定满足规则的数据包应该执行的动作，常见的动作有 ACCEPT（接受）、DROP（丢弃）、REJECT（拒绝）、LOG（记录日志）等。

以上就是 iptables 的一些常用参数，实际使用中可以根据需要组合使用这些参数来定义防火墙规则。

**特别注意：在配置这个的时候，尤其需要不要把自己关在外面，比如配置了正常规则以后，然后把进入规则默认设置成为拒绝，这个时候如果清空规则，则会把自己关在外面，因为清空的规则并不包含默认规则，清空的规则只是具体的规则。**

### 1.2 firewalld

Firewalld 是 CentOS 7 及更高版本默认的防火墙管理工具，它提供了对防火墙的动态管理，并且支持网络/防火墙区域定义，以达到简化防火墙设置的目的。

Firewalld 把所有网络流量分为工作区（zone），每个区有自己的规则。你可以设置网络接口或者子网与特定的工作区匹配，从而动态地对网络流量应用不同的规则。

Firewalld 的基本操作：

1. 启动 firewalld： `systemctl start firewalld`
2. 禁止 firewalld： `systemctl stop firewalld`
3. 查看 firewalld 状态： `systemctl status firewalld`
4. 启动开机启动： `systemctl enable firewalld`
5. 禁止开机启动： `systemctl disable firewalld`

查看和修改工作区设置：

1. 查看活动工作区： `firewall-cmd --get-active-zones`
2. 查看默认工作区： `firewall-cmd --get-default-zone`
3. 设置默认工作区： `firewall-cmd --set-default-zone=zone`
4. 查看工作区规则： `firewall-cmd --zone=zone --list-all`

添加和删除规则：

1. 添加规则： `firewall-cmd --zone=zone --add-service=service --permanent`
2. 删除规则： `firewall-cmd --zone=zone --remove-service=service --permanent`
3. 重新加载规则： `firewall-cmd --reload`

这里的 `zone` 是你要操作的工作区，`service` 是你要添加或删除的服务。比如，你可以添加一个允许 SSH 连接的规则： `firewall-cmd --zone=public --add-service=ssh --permanent`。

以上就是 firewalld 的基本操作，通过这些操作你可以方便地管理你的防火墙规则。

Firewalld 的规则基于区域和服务，下面是一些具体的规则例子：

1. 在公共区域（public zone）允许 SSH 服务：

```bash
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --reload
```

1. 在内部区域（internal zone）允许 HTTP 和 HTTPS 服务：

```bash
firewall-cmd --zone=internal --add-service=http --permanent
firewall-cmd --zone=internal --add-service=https --permanent
firewall-cmd --reload
```

1. 在家庭区域（home zone）允许网络文件系统（NFS）服务：

```bash
firewall-cmd --zone=home --add-service=nfs --permanent
firewall-cmd --reload
```

1. 在公共区域（public zone）禁止 FTP 服务：

```bash
firewall-cmd --zone=public --remove-service=ftp --permanent
firewall-cmd --reload
```

1. 在工作区域（work zone）打开端口 8000：

```bash
firewall-cmd --zone=work --add-port=8000/tcp --permanent
firewall-cmd --reload
```

以上规则在添加或删除后需要使用 `firewall-cmd --reload` 命令重新加载以应用更改。使用 `--permanent` 参数是为了让规则永久生效，如果省略这个参数，那么规则只在当前会话中有效，重启后将失效。





在实际应用中，尤其在当前大部分都上云的情况下，防火墙规则都是关闭的状态的，采用的都是云防火墙。尤其是现在大量的内部通信，都是要求关闭防火墙，要求默认全部放通。所以在实际的运维过程中，安全相关的规则使用还是比较少的。

firewall需要关闭服务，iptables则不配置则不算启用。