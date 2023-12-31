# Linux的环境变量

`env` 是一个unix和linux系统中的一个shell命令，它用于打印出当前环境的环境变量。你可以通过 `env` 命令来查看所有可用的环境变量，或者用它来运行某个命令于特定的环境设置中。

下面是 `env` 命令的一些基本用法：

1. **查看环境变量**：你只需在终端中输入 `env`，然后回车，它就会列出所有的环境变量。
2. **设置环境变量并运行命令**：你可以使用 `env` 在特定环境下运行命令，这对于调试非常有用。例如，如果你想在一个没有任何环境变量的环境中运行 `bash`，你可以使用 `env -i bash`，这将启动一个新的 `bash` 会话，其中不包含任何环境变量。
3. **暂时改变环境变量**：`env` 命令也可以用来临时改变环境变量的值。例如，如果你想改变 `PATH` 环境变量并运行命令，你可以使用 `env PATH=/new/path command`。

总的来说，`env` 是一个非常有用的命令，可以用来查看和修改环境变量，以及在特定环境下运行命令。

## Linux的环境变量从哪里来

Linux的环境变量通常来自以下几个地方：

1. **系统级环境变量**：这些变量在系统启动时由init系统设置，通常定义在/etc/environment，/etc/profile，/etc/bash.bashrc或者/etc/profile.d/*中。
2. **用户级环境变量**：用户级的环境变量通常在用户登录时设置，定义在用户的家目录下的一些文件中，如~/.bashrc，~~/.bash_profile，~~/.profile等。这些变量只对当前用户有效。
3. **临时环境变量**：这些变量只在当前shell会话中有效，当会话结束时，这些变量就会消失。你可以在命令行中使用export命令创建临时环境变量。
4. **命令级环境变量**：这些变量只在特定命令执行时有效，当命令执行完毕后，这些变量就会消失。你可以在命令前使用VAR=value的形式设置命令级环境变量。

总的来说，环境变量可以在系统级，用户级，会话级和命令级设置，不同级别的环境变量对应的作用范围也不同。

如果我们要修改环境变量，则需要根据需要对以上文件进行修改来实现环境变量的更改。

## Linux的环境变量如何配置

以实际环境中运用得比较多的JDK的环境变量的配置为例，在Linux系统中配置JDK的环境变量通常涉及到以下几个步骤：

1. **下载并安装JDK**：首先，你需要从Oracle官网或其他可信赖的源下载JDK，并按照说明进行安装。
2. **设置JAVA_HOME环境变量**：JAVA_HOME环境变量应该指向你的JDK的安装目录。你可以通过在terminal中输入以下命令来设置：

```bash
export JAVA_HOME=/path/to/your/jdk
```

这将在当前的shell会话中设置JAVA_HOME环境变量。请记住，你需要将`/path/to/your/jdk`替换为你的JDK的实际安装路径。

1. **设置PATH环境变量**：接下来，你需要将JDK的bin目录添加到PATH环境变量中，这样你就可以直接运行`java`、`javac`等命令了。你可以通过以下命令来设置：

```bash
export PATH=$JAVA_HOME/bin:$PATH
```

1. **使环境变量永久生效**：前面的步骤只在当前的shell会话中设置了环境变量。如果你想让这些设置在每次登录时都自动生效，你需要将它们添加到你的bash配置文件中（如~/.bashrc或~/.bash_profile）。你可以使用文本编辑器打开这些文件，并将上述的export命令添加到文件的末尾。
2. **检查设置是否正确**：最后，你可以通过以下命令来检查你的设置是否正确：

```bash
echo $JAVA_HOME
java -version
```

如果以上命令分别打印出了你的JDK安装路径和正确的java版本信息，那么你的环境变量设置就是正确的。

