# Linux的主机名和Hosts

## 1.主机名

在Linux中，主机名是用来唯一标识网络中的设备的名称。它可以用来在网络中识别各个系统，并且在很多网络协议和程序中，例如电子邮件和SSL证书中，都会用到主机名。

主机名可以是任何由字母，数字和连字符组成的字符串，但不能以连字符开头或结尾，也不能包含任何空格或特殊字符。

在Linux系统中，主机名被分为两种类型：

1. 静态主机名（Static Hostname）: 这是系统在启动时分配的主机名，通常在/etc/hostname文件中设置。这个主机名一般不会改变，除非系统管理员手动更改。
2. 动态主机名（Transient Hostname）: 这个主机名是在系统运行时动态分配的，通常通过DHCP或mDNS服务设置。这个主机名可能会随着网络环境的改变而改变。

在Linux系统中，你可以使用`hostname`命令来查看或更改主机名。例如，运行`hostname`命令将显示当前的主机名，运行`hostname newname`将设置新的主机名为"newname"。但是需要注意的是，这种方法更改的主机名在系统重启后将会被重置。

如果想要永久改变主机名，可以直接编辑/etc/hostname文件，并在其中输入新的主机名。然后，重启系统以使更改生效。

## 2.Hosts

Linux下的"hosts"文件是一个系统文件，通常位于"/etc/"目录下，文件全名为"/etc/hosts"。它是Internet服务器的主机名字和IP地址的映射列表，可以被所有的应用程序在进行域名解析时使用。

当你尝试访问一个URL地址时，系统首先会查找hosts文件，看是否有相应的映射关系。如果有，系统会直接采用hosts文件中的IP地址，而不会再去请求DNS服务器。如果没有，那么系统会继续请求DNS服务器来解析这个URL。

这个文件一般的格式是这样的：

```
192.168.1.1     example.com
192.168.1.2     www.example.com
```

第一列是IP地址，第二列是对应的主机名。你可以在每行添加多个主机名，只需要用空格隔开。

编辑hosts文件可以有很多用途，例如：

- 在无法访问DNS服务器的情况下仍然可以访问某些网站。
- 用于测试，可以将开发中的网站指向开发服务器的IP。
- 用于屏蔽某些网站，将某些网站的域名解析到127.0.0.1即本机，从而无法访问。

在编辑和更改hosts文件后，通常无需重启系统或服务，更改会立即生效。

## 3.主机名和Hosts的实际应用

### 3.1 主机名

默认的Linux部署完成以后的主机名字是Localhost，如果只是单机使用，是不会有什么问题的，但是当这个机器需要和网络上其他机器通信的时候，或者多个机器需要快速识别的时候就需要为每个主机定义不同的主机名，这样可以用于快速识别。

在Linux系统下，可以通过以下两种方法修改主机名：

**方法一：使用hostnamectl命令（推荐）**

这是Systemd系统，比如Ubuntu 16.04及之后的版本，CentOS 7及之后的版本等，修改主机名的推荐方式。

1. 查看当前主机名

   ```
   hostnamectl
   ```

2. 修改主机名为新的主机名（例如：new-hostname）

   ```
   sudo hostnamectl set-hostname new-hostname
   ```

**方法二：手动编辑配置文件**

在没有Systemd的系统中，主机名存放在/etc/hostname文件中，可以直接编辑该文件来修改主机名。

1. 使用文本编辑器打开/etc/hostname文件。例如：

   ```
   sudo nano /etc/hostname
   ```

2. 将文件中的内容修改为新的主机名，然后保存并关闭文件。

然后，你需要编辑/etc/hosts文件，将旧的主机名替换为新的主机名。

1. 使用文本编辑器打开/etc/hosts文件。例如：

   ```
   sudo nano /etc/hosts
   ```

2. 在文件中找到旧的主机名，将其替换为新的主机名。

无论使用哪种方法，更改后需要重启系统才能使新的主机名生效。

注意：不同的Linux发行版可能会有不同的方法来修改主机名，请根据你的实际情况来选择合适的方法。



### 3.2 Hosts

hosts文件是一个操作系统用来将人类可读的主机名映射到IP地址的计算机文件。在互联网协议（IP）规范中，主机文件的内容帮助网络节点在主机名和IP地址之间进行映射查找。

以下是hosts文件的一些实际应用：

1. **网站阻止/屏蔽**：通过将特定网站的域名映射到本地主机（通常是127.0.0.1 IP地址，也就是你自己的电脑），可以阻止访问特定网站。这是一种常用的屏蔽不想要的网站（例如广告或恶意网站）的方法。
2. **开发和测试**：开发者经常使用hosts文件在本地开发和测试网站。例如，可以将新网站的域名映射到正在进行开发的本地服务器的IP地址。这样就可以使用实际的域名进行测试，而无需更改DNS设置。
3. **网络重定向**：如果一个网络服务从一个IP地址迁移到另一个IP地址，可以通过更新hosts文件来重定向网络流量。
4. **DNS调试**：如果怀疑DNS服务器出现问题，可以使用hosts文件将主机名手动映射到已知的IP地址进行测试。
5. **特定软件需要**：目前比较常用的软件Rabbitmq，HDFS需要通过主机名识别，而跨主机的主机名则需要通过Hosts文件来实现。

总的来说，虽然对于大多数人来说，hosts文件的应用可能并不广泛，但它在特定的应用场景中仍然非常有用。
