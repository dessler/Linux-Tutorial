# Linux软件操作

## 一、使用YUM安装、卸载和升级软件：

1. 安装：打开终端，输入 `sudo yum install packagename` ，其中 `packagename` 是你想要安装的软件包的名称。比如，如果你想安装 wget，那么命令就是 `sudo yum install wget`。
2. 卸载：输入 `sudo yum remove packagename`，其中 `packagename` 是你想要卸载的软件包的名称。比如，如果你想卸载 wget，那么命令就是 `sudo yum remove wget`。
3. 升级：输入 `sudo yum update packagename`，其中 `packagename` 是你想要升级的软件包的名称。如果你想更新所有的软件包，只要输入 `sudo yum update`即可。

## 二、使用RPM安装软件：

RPM是另一种在CentOS中安装软件的方法，特别适合于软件包不在YUM仓库中的情况。

1. 安装：输入 `sudo rpm -i packagefile.rpm`，其中 `packagefile.rpm` 是你的 RPM 包的文件名。
2. 卸载：输入 `sudo rpm -e packagefile.rpm`，其中 `packagefile.rpm` 是你的 RPM 包的文件名。
3. 升级：输入 `sudo rpm -U packagefile.rpm`，其中 `packagefile.rpm` 是你的 RPM 包的文件名。

## 三、编译安装：

编译安装适用于源码包，以下是基本的编译安装步骤：

1. 解压源码包，一般使用 `tar -xvf packagefile.tar.gz` 命令。
2. 进入解压后的目录，一般使用 `cd directoryname` 命令。
3. 配置，一般使用 `./configure` 命令。你可以添加参数来定制你的安装，比如指定安装目录 `--prefix=/usr/local`。
4. 编译，使用 `make` 命令。
5. 安装，使用 `sudo make install` 命令。

以上步骤可能会因软件不同而有所改变，应根据具体的 README 或 INSTALL 文件进行操作。

需要注意的是，所有这些操作可能都需要 root 权限，所以在执行时可能需要使用 `sudo` 并输入你的密码。



在实际运维过程中，一般用yum最多，rpm次之，编译安装目前已经使用很少了。yum安装本质上是先把包从网上下载到本地，然后在安装，这里实际上还衍生出来另外2个问题，我怎么知道我去哪里下载包（本地配置xxx.repo配置），服务器里面有些啥（yum源）

yum update 会升级centos的版本，举个例子:如果我当前的版本是centos 7.5 ，但是最新的centos的版本是centos是7.9，当我执行yum update以后就会把整个系统的版本升级到centos7.9。所以这个命令一般是在安装完成系统的时候进行系统初始化的时候就需要完成的，一般情况下，如果业务已经部署上去了，一般就不建议在执行该命令。