[toc]

# Yum源

Yum（Yellowdog Updater, Modified）是一种在Fedora和RedHat以及CentOS中的Shell前端软件包管理器。基于RPM包管理，能够自动下载并安装RPM包，可以自动处理依赖性关系，使得整个系统的软件包管理更为方便。

Yum源就是Yum软件包管理器访问的软件仓库，仓库中包含了大量的软件包及其相关的依赖信息。有了Yum源，用户就能够通过Yum命令方便地进行软件的安装、升级、查询和卸载等操作。

Yum源根据存放的位置，可以分为本地源和网络源。本地源即存放在本地硬盘上，而网络源则存放在网络上的服务器中。网络源又可以根据服务器的不同，分为公共源和私有源。公共源对所有用户免费开放，私有源则只对特定用户开放。

在CentOS等系统中，官方的Yum源通常会在安装操作系统时自动配置。你也可以添加其他公共的或私有的Yum源，以便获取更多的软件包。要添加Yum源，一般需要在/etc/yum.repos.d/目录下创建.repo文件，并在其中指定Yum源的URL以及其他相关信息。

## 1.Yum源更换

正常的系统配置在完成以后，都会配置默认的Yum源，但是这个源可能因为特殊原因不可用，或者慢，我们可用手工配置国内的镜像源。

在CentOS等基于RPM的Linux发行版中，你可以通过以下步骤来配置阿里云或腾讯云的Yum源：

1. **备份原有的Yum源文件**：为了防止配置出错，首先建议备份你原有的Yum源配置文件：

   ```bash
   mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
   ```

2. **下载新的Yum源文件**：接下来，你可以从阿里云或腾讯云的镜像站点下载新的Yum源文件。例如，如果你想使用阿里云的Yum源，可以使用以下命令：

   ```bash
   wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
   ```

   或者如果你想使用腾讯云的Yum源，可以使用以下命令：

   ```bash
   wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
   ```

3. **清除Yum缓存**：你需要使用以下命令来清除Yum的缓存：

   ```bash
   yum clean all
   ```

   这将清除所有已经缓存的包和元数据。

4. **生成新的缓存**：最后，你可以使用以下命令来生成新的Yum缓存：

   ```bash
   yum makecache
   ```

现在，你的系统应该已经配置好使用阿里云或腾讯云的Yum源了。你可以使用`yum list`命令来检查是否可以获取到软件包的列表。

## 2.配置其他源

### 2.1 什么是EPEL源

EPEL源是由Fedora项目社区打造的一个提供高质量额外软件包的项目，其中的软件包适用于Red Hat企业版（RHEL）及其衍生版本（如CentOS，Scientific Linux等）。EPEL的全称是 Extra Packages for Enterprise Linux，意为企业版 Linux 的额外软件包。

EPEL源为那些被纳入 Fedora的软件提供预构建的二进制包，这些软件并没有被纳入 RHEL 或 CentOS 的软件源中，但是这些软件对于许多用户来说是必不可少的。EPEL源的软件包都是由 Fedora 社区打包并维护的，所以这些软件包的质量相对较高，而且相对稳定。

例如，一些常见的开源软件，如htop，iftop，mtr等，如果只使用默认的CentOS源是无法安装的，安装这些软件就需要配置EPEL源。

**通俗点说就是部分通用软件虽然用得多，但是并不是在官方源里面，都放在一个EPEL源里面。**

### 2.2 如何配置EPEL源

阿里云和腾讯云的镜像站点都提供了EPEL（Extra Packages for Enterprise Linux）源的镜像，但是在他们的CentOS源配置文件中并没有默认包含EPEL源，需要你手动添加。

以下是如何添加阿里云或腾讯云的EPEL源的方法：

1. **下载EPEL源配置文件**：

   对于阿里云的EPEL源，你可以使用以下命令：

   ```bash
   wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
   ```

   对于腾讯云的EPEL源，首先需要下载EPEL Release包：

   ```bash
   yum install -y https://mirrors.cloud.tencent.com/epel/epel-release-latest-7.noarch.rpm
   ```

   然后修改/etc/yum.repos.d/epel.repo文件，将mirrorlist地址修改为腾讯云的EPEL源地址：

   ```bash
   mirrorlist=https://mirrors.cloud.tencent.com/epel/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
   ```

2. **清理并生成新的Yum缓存**：

   ```bash
   yum clean all
   yum makecache
   ```

现在，你的系统应该已经配置好使用阿里云或腾讯云的EPEL源了。

### 2.3 配置其他私有源

有了官方源和EPEL是不是就万事大吉了呢，当然不是，有些软件这官方源或者EPEL源里面也有，但是版本并不是我们常用的版本，所以这些程序也提供了他们的自己的源，如果你需要安装这些软件的主流版本，就还需要配置这些软件的源。比如我们常见的Mysql和Docker。

### 2.3.1配置Mysql源

默认的centos7源是不包含Mysql，而是MariaDB，虽然他们同出一辙，但是Mysql通用性还是会更高一点。

如果你想在CentOS 7上安装最新版本的MySQL，你可以通过添加MySQL的官方Yum仓库来实现。以下是步骤：

1. 首先，从MySQL的官方网站下载Yum仓库的RPM包：

   ```
   wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
   ```

2. 然后，安装该RPM包，它会自动在你的系统添加MySQL的Yum仓库：

   ```
   sudo yum localinstall mysql80-community-release-el7-3.noarch.rpm
   ```

3. 确认MySQL的Yum仓库已经被正确添加：

   ```
   yum repolist enabled | grep "mysql.*-community.*"
   ```

   你应该可以看到类似于下面的输出：

   ```
   mysql-connectors-community/x86_64 MySQL Connectors Community
   mysql-tools-community/x86_64       MySQL Tools Community
   mysql80-community/x86_64           MySQL 8.0 Community Server
   ```

4. 现在，你可以使用yum命令来安装MySQL服务器：

   ```
   sudo yum install mysql-community-server
   ```

5. 最后，启动MySQL服务器，并设置开机自启：

   ```
   sudo systemctl start mysqld
   sudo systemctl enable mysqld
   ```

以上就是配置MySQL源并安装MySQL服务器的步骤。

### 2.3.2 配置Docker源

如果你想在CentOS 7上安装Docker，你可以通过添加Docker的官方Yum仓库来实现。以下是步骤：

1. 首先，安装必要的软件包。`yum-utils` 提供了 `yum-config-manager` 工具，`devicemapper` 驱动依赖 `device-mapper-persistent-data` 和 `lvm2`。

   ```bash
   sudo yum install -y yum-utils device-mapper-persistent-data lvm2
   ```

2. 设置稳定版的 Docker 仓库：

   ```bash
   sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   ```

3. 这时，你可以选择安装最新版的 Docker CE，或者特定版本的 Docker CE，或者测试版的 Docker CE。

   安装最新版本的 Docker CE：

   ```bash
   sudo yum install docker-ce docker-ce-cli containerd.io
   ```

   如果想安装特定版本的 Docker CE，你需要列出可用版本，然后选择安装：

   ```bash
   yum list docker-ce --showduplicates | sort -r
   ```

   安装这样的版本（这里列出的版本为例）：

   ```bash
   sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
   ```

4. 启动Docker服务：

   ```bash
   sudo systemctl start docker
   ```

5. 通过运行 hello-world 镜像来验证 Docker 是否正确安装：

   ```bash
   sudo docker run hello-world
   ```

6. 最后，如果你希望在系统引导时启动 docker 服务，可以使用以下命令：

   ```bash
   sudo systemctl enable docker
   ```

以上就是配置Docker源并安装Docker的步骤。

## 3.如何搭建本地Yum源

下面是在CentOS等基于RPM的Linux发行版中配置本地Yum源的步骤：

1. **挂载安装介质**：首先，你需要将你的CentOS安装光盘（或ISO文件）挂载到某个目录，比如/mnt/cdrom。你可以使用以下命令来挂载：

   ```bash
   mount /dev/cdrom /mnt/cdrom
   ```

   如果你的安装介质是ISO文件，你需要使用-loop选项来进行挂载。

2. **创建.repo文件**：接下来，你需要在/etc/yum.repos.d/目录下创建一个新的.repo文件，比如myrepo.repo。你可以使用文本编辑器来创建和编辑这个文件。在这个文件中，你需要指定你的本地Yum源的名称、描述、路径等信息。一个例子如下：

   ```bash
   [myrepo]
   name=My Repository
   baseurl=file:///mnt/cdrom
   enabled=1
   gpgcheck=0
   ```

   在这里，baseurl指定了你的本地Yum源的路径（即你的安装介质的挂载点）。enabled=1表示这个Yum源是启用的。gpgcheck=0表示不进行GPG签名检查。

3. **清除Yum缓存**：你需要使用以下命令来清除Yum的缓存：

   ```bash
   yum clean all
   ```

   这将清除所有已经缓存的包和元数据。

4. **测试本地Yum源**：最后，你可以使用以下命令来测试你的本地Yum源是否正常工作：

   ```bash
   yum list
   ```

如果你看到了你的安装介质中的软件包，那么你的本地Yum源就已经配置成功了。

## 4.如何搭建局域网可用源

搭建局域网内可用的Yum源包括以下步骤：

1. **准备一台服务器**：首先，你需要准备一台可以作为Yum服务器的机器，它需要有一定的硬盘空间来存放软件包，同时需要安装HTTP或FTP服务器软件，用于提供网络访问。

2. **挂载并复制软件包**：然后，把CentOS的安装光盘挂载到这台服务器上，并把光盘里的所有文件复制到一个目录下，例如/var/www/html/centos7。

3. **安装createrepo**：接下来，安装createrepo工具，这个工具可以创建Yum源需要的元数据信息：

   ```bash
   yum install -y createrepo
   ```

4. **创建Yum源元数据**：然后在存放软件包的目录下创建Yum源的元数据：

   ```bash
   createrepo /var/www/html/centos7
   ```

   这个命令会在当前目录下生成一个名为"repodata"的子目录，其中包含了Yum源需要的元数据信息。

5. **配置HTTP或FTP服务器**：根据你的实际情况，配置HTTP或FTP服务器，使其可以提供对/var/www/html/centos7目录的访问。

6. **在客户端配置Yum源**：最后，在局域网内的其他机器上，你需要修改/etc/yum.repos.d/目录下的.repo文件，将baseurl设置为你的Yum服务器的地址，例如：

   ```bash
   [myrepo]
   name=My Repository
   baseurl=http://myserver/centos7
   enabled=1
   gpgcheck=0
   ```

   之后，运行`yum clean all`和`yum list`命令，如果能列出软件包，说明Yum源已经配置成功。