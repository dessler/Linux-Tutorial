[toc]

# OpenStack网络

## neutron网络基本介绍

### 1.neutron组件介绍

### 2.neutron网络类型

### 3.neutron网络范例-flat

#### 3.1 创建一个网络

```
openstack network create --share --external --provider-physical-network provider --provider-network-type flat public
```

您提供的命令用于在 OpenStack 中创建一个外部 Flat 网络，可以用于浮动 IP 地址，以及提供虚拟机访问外部网络，例如互联网。

这是命令的详细解释：

- `openstack network create`：这是在 OpenStack 中创建一个新网络的命令。
- `--share`：这个标志指定网络是共享的，这意味着所有租户都可以访问它。
- `--external`：这个标志标识这个网络是外部网络，外部网络通常用于提供虚拟机对外部物理网络的访问。
- `--provider-physical-network provider`：这指定了物理网络的名称，它是在 Neutron 的配置中定义的。在这个示例中，`provider` 是被用作物理网络的标识符。
- `--provider-network-type flat`：这表明创建的网络是一个 Flat 网络，这意味着没有使用 VLAN 或 VXLAN 进行网络隔离。
- `public`：这是您要创建的网络的名称，在这里命名为 "public"。

运行这个命令之后，一个名为 "public" 的外部共享 Flat 网络将被创建。记住，根据您的 OpenStack 设定和环境配置，您可能需要在 Neutron 配置文件中事先定义 `provider` 物理网络(flat_networks就是这个参数定义的)。此外，外部网络的创建通常需要管理员权限。

一旦创建了网络，您还需要创建相应的子网，分配 IP 地址范围，并设置适当的路由和 DNS 服务器，才能让网络完全可用。

#### 3.2 创建一个子网

```
openstack subnet create --network public --subnet-range 192.168.0.0/24 --gateway 192.168.0.1 --dns-nameserver 114.114.114.114 public_1
```

您的命令用于在 OpenStack 中创建一个子网（subnet），通常会在已经创建的外部网络（比如之前创建的名为 `public` 的外部共享网络）上执行这个操作。该子网配置会影响加入网络的所有虚拟机实例。

以下是命令的详细解释：

- `openstack subnet create`：这是 OpenStack 命令行工具用于创建一个新子网的命令。
- `--network public`：这一参数指定了子网将要关联的网络名称，这里是之前创建的名为 `public` 的网络。
- `--subnet-range 192.168.0.0/24`：这一参数定义了子网的 IP 地址范围，这里指定了 192.168.0.0/24，意味着 IP 地址从 192.168.0.1 到 192.168.0.254 的设备都可以在这个子网内分配地址。
- `--gateway 192.168.0.1`：设置子网的默认网关，虚拟机将通过这个网关访问网络之外的资源。
- `--dns-nameserver 114.114.114.114`：指定子网使用的 DNS 名称服务器地址，这里使用了 114.114.114.114，这是一个公共DNS服务地址。
- `public_1`：这是您给新创建的子网命名的名字。

需要注意的是，在实际环境中，您可能要使用与您的网络环境匹配的参数，比如正确的子网范围、网关和 DNS 服务器地址。

**作者有话说：**

**由于这套环境是采用的类似公有云的，配置创建子网以后，控制直接直接离线，删除了子网和网络都无法恢复，重启才恢复，所以是未经过验证是否可行的。**

### 4.neutron网络范例-vxlan

#### 4.1 重新修正配置文件

```
#控制节点
vi /etc/neutron/plugins/ml2/ml2_conf.ini

[ml2]
type_drivers = flat,vlan,vxlan	
tenant_network_types = vxlan
mechanism_drivers = linuxbridge,l2population
extension_drivers = port_security

[ml2_type_vxlan]
vni_ranges = 1:1000
vxlan_group = 192.168.0.1-192.169.0.250

[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
#然后重启服务
systemctl restart neutron-server
```

```
#计算节点
vi /etc/neutron/plugins/ml2/linuxbridge_agent.ini

[DEFAULT]

[linux_bridge]
physical_interface_mappings = provider:eth1

[vxlan]
enable_vxlan = True
local_ip = 192.168.0.111
l2_population = True

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
enable_ipset =True
#然后重启服务
systemctl restart  neutron-linuxbridge-agent.service openstack-nova-compute.service
```



#### 4.2 创建网络

```
openstack network create myvxlan --provider-network-type vxlan
```

#### 4.3 创建子网

```
openstack subnet create --network myvxlan --subnet-range 172.17.0.0/24 myvxlansubnet
```

