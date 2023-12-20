# Openstack命令

在Openstack的操作当中，有2种命令操作，一种就是`openstack xxx xxx` ，另外一种就是`glance xxxx` ，任何掌握其中一种，只要满足自己的要求则可，初学者建议掌握 `openstack xxx xxx `,因为他相对比较简单，而且规则的通用性更强一点。`glance xxxx`命令则功能会更强大yi'dian

Openstack 是一个命令的集合，包括大概80个左右的下级，就是由这些下级资源组装成整个集群。

查看方式`openstakc -h `,这里挑选了部分常用的介绍。

```
在OpenStack中，常见的2级资源包括：

项目（Project）：项目是资源的隔离单元，用于组织和管理云资源。每个项目都有自己的资源配额和权限。
用户（User）：用户是OpenStack中的身份标识，用于访问和管理云资源。用户可以属于一个或多个项目，并拥有一定的角色和权限。
角色（Role）：角色定义了在OpenStack中可以执行的操作和访问权限。角色可以分配给用户或项目，以控制其对资源的访问和操作权限。
配额（Quota）：配额用于限制项目内各种资源的使用量。例如，可以设置虚拟机数量、CPU核心数、内存大小、存储卷数量等配额限制。
安全组（Security Group）：安全组是用于定义网络访问控制规则的一种机制。它可以控制虚拟机与外部网络之间的数据流入流出。
路由器（Router）：路由器用于在不同的网络之间进行数据包转发和路由。它可以连接不同的子网，并实现网络之间的通信。
网络（Network）：网络用于连接虚拟机和其他云资源。OpenStack支持多种类型的网络，如VLAN、Flat Network、Overlay Network等。
存储卷（Volume）：存储卷是用于虚拟机的持久化存储，可以附加到虚拟机并用作块存储设备。
镜像（Image）：镜像是虚拟机的操作系统和软件的模板。它可以用于创建和启动新的虚拟机实例。
引导卷（Boot Volume）：引导卷是用于启动虚拟机的存储卷。它包含了虚拟机的操作系统和启动配置信息。
快照（Snapshot）：快照是存储卷或虚拟机的数据的副本，用于备份和恢复数据。
外部网络（External Network）：外部网络是连接OpenStack云和外部网络的接口，用于实现云资源与外部网络的通信。
这些是OpenStack中常见的2级资源。每个资源都有自己的属性和操作，可以通过OpenStack的API或管理界面进行管理和配置。根据实际需求和部署情况，还可以扩展和定制其他类型的2级资源。
```

每一个子命令，就可以对一种资源进行操作，比如我们以镜像（Image为例）。

```
openstack image add project  Associate project with image
openstack image create   Create/upload an image
openstack image delete   Delete image(s)
openstack image list     List available images
openstack image member list  List projects associated with image
openstack image remove project  Disassociate project with image
openstack image save     Save an image locally
openstack image set      Set image properties
openstack image show     Display image details
openstack image unset    Unset image tags and properties
```

这里有些选项是专用，但是有些选项则是其他资源类型也是通用的。

```
create     创建资源
delete     删除资源
list       列出资源
show       展示详细信息
```



通过以上2个命令的的方法，我们就能掌握整个`openstack`命令的逻辑，只要我们在日常使用中根据这个规律去操作熟悉，就可以对 `openstack`更加的熟悉。