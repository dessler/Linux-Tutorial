[toc]

# MAVEN

## Maven介绍

Maven（“MAVEN”）是一个流行的项目管理工具，用于构建和管理 Java 项目。它可以自动化构建过程，管理项目依赖关系，并提供了一种标准化的项目结构。下面是 Maven 的一些重要特点和功能：

1. **项目对象模型（Project Object Model，POM）：** Maven 使用 POM 文件来描述项目的配置信息。POM 是一个 XML 文件，其中包含项目的元数据，如项目的坐标（groupId、artifactId、version）、依赖关系、插件、构建配置等。
2. **约定优于配置：** Maven 鼓励开发者遵循一套约定，而不是强制进行大量的配置。通过遵循一致的项目结构和命名约定，Maven 能够自动识别项目的组织结构和文件布局。
3. **依赖管理：** Maven 管理项目依赖关系，可以自动下载、安装和配置项目所需的依赖库。通过 POM 文件中的 `<dependency>` 元素，开发者可以指定项目依赖的外部库，包括库的坐标和版本。
4. **生命周期和插件：** Maven 定义了一系列标准的构建生命周期，如编译、测试、打包、部署等，并提供了一系列插件来执行各个阶段的任务。开发者可以通过配置插件来扩展 Maven 的功能，满足项目特定的构建需求。
5. **中央仓库：** Maven 使用中央仓库作为默认的依赖库存储位置。中央仓库包含了大量常用的开源 Java 库和框架，开发者可以直接在项目中引用这些库，无需手动下载和管理。
6. **多模块项目支持：** Maven 支持多模块项目，允许开发者将一个大型项目拆分成多个模块，并通过父子模块的关系进行管理和构建。

使用 Maven 可以提高项目的可维护性、可重用性和可扩展性，同时简化项目的构建和依赖管理过程。它是 Java 生态系统中广泛使用的标准构建工具之一，受到了开发者和开源社区的欢迎。

## Pom.xml 介绍

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <!-- 项目坐标 -->
    <groupId>com.example</groupId>
    <artifactId>my-project</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <!-- 项目描述 -->
    <name>My Project</name>
    <description>This is a Maven project.</description>

    <!-- 项目依赖 -->
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
            <version>5.3.4</version>
        </dependency>
        <!-- 其他依赖 -->
    </dependencies>

    <!-- 构建配置 -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
            <!-- 其他插件 -->
        </plugins>
    </build>
</project>
```

在这个示例中，`pom.xml` 文件包含了以下主要部分：

1. **项目坐标（Project Coordinates）：** 包括 `groupId`、`artifactId` 和 `version`，用于唯一标识项目。`groupId` 表示项目组织或公司的唯一标识符，`artifactId` 是项目的唯一标识符，`version` 表示项目的版本号。
2. **项目描述（Project Description）：** 包括项目的名称和描述，用于说明项目的功能和用途。
3. **项目依赖（Project Dependencies）：** 包括项目所依赖的外部库和框架。每个依赖都由 `<dependency>` 元素表示，包括 `groupId`、`artifactId` 和 `version` 等信息。
4. **构建配置（Build Configuration）：** 包括项目的构建配置信息，如编译器版本、打包方式等。`<build>` 元素包含了一系列 `<plugins>` 元素，每个 `<plugin>` 元素表示一个 Maven 插件，用于执行特定的构建任务。

`pom.xml` 文件还可以包含其他配置信息，如资源过滤、打包配置、仓库配置等。通过编辑 `pom.xml` 文件，开发者可以定制项目的构建过程，管理项目的依赖关系，以及配置项目的其他相关信息。

***作者有话说：对于运维人员拉说，我们需要关注的其实就是他是如何指定本地仓库地址的，如果要修改，一般也仅仅局限于此；比如你从其他地方拿到JAVA源码就肯定要重新匹配本地的mvn仓库。***

## 仓库介绍

Maven 仓库是 Maven 项目依赖管理的核心组件之一，它用于存储和管理项目所需的依赖库和插件。Maven 仓库通常分为以下几种类型：

1. **本地仓库（Local Repository）：** 每个开发者在本地计算机上都有一个本地仓库，用于存储项目的依赖库和插件。当开发者执行 Maven 构建命令时，Maven 会自动从本地仓库中查找和下载所需的依赖库，如果本地仓库中不存在相应的依赖，则会从远程仓库下载并缓存到本地。
2. **中央仓库（Central Repository）：** 中央仓库是 Maven 的默认远程仓库，包含了大量常用的开源 Java 库和框架。开发者可以在项目的 `pom.xml` 文件中指定依赖关系，Maven 会自动从中央仓库下载所需的依赖库。中央仓库由 Maven 社区维护，是 Maven 生态系统中最重要的仓库之一。
3. **远程仓库（Remote Repository）：** 除了中央仓库外，开发者还可以配置其他自定义的远程仓库，用于存储私有或第三方的依赖库和插件。远程仓库可以是 HTTP、HTTPS 或其他协议的 URL 地址，开发者需要在项目的 `pom.xml` 文件中添加相应的仓库配置。
4. **企业仓库（Enterprise Repository）：** 企业仓库是一种私有的 Maven 仓库，用于存储企业内部的依赖库和插件。企业可以搭建自己的仓库服务器，用于集中管理和分发内部的 Java 组件和库。常见的企业仓库管理软件包括 Nexus、Artifactory 等。

Maven 仓库的作用是集中管理和分发项目依赖，开发者可以通过 Maven 构建工具方便地引用和管理第三方库和插件，避免手动下载和管理依赖的麻烦。同时，Maven 仓库还促进了依赖库的共享和重用，有助于提高项目的开发效率和质量。

***作者有话说：其实这里的本地仓库，一般而言对于linux来说就是`/root/.m2`目录；企业仓库,一般而言就是用Nexus搭建的私有仓库***

## MVN命令介绍

Maven 是一个强大的项目管理工具，通过命令行界面可以执行各种操作。以下是一些常用的 Maven 命令及其功能介绍：

1. **mvn clean：** 清理项目，删除 target 目录及其中生成的文件。
2. **mvn compile：** 编译项目源代码。
3. **mvn test：** 运行项目的单元测试。
4. **mvn package：** 打包项目，生成可部署的 artifact，如 JAR、WAR 等。
5. **mvn install：** 安装项目到本地仓库，以供其他项目引用。
6. **mvn deploy：** 将项目部署到远程仓库，用于共享和分发。
7. **mvn clean install：** 清理项目并将项目安装到本地仓库。
8. **mvn clean package：** 清理项目并打包项目。
9. **mvn clean test：** 清理项目并运行单元测试。
10. **mvn clean deploy：** 清理项目并将项目部署到远程仓库。
11. **mvn dependency:resolve：** 解析项目的依赖关系，并下载到本地仓库。
12. **mvn dependency:tree：** 生成项目的依赖树，显示项目依赖的层次关系。
13. **mvn help：** 显示 Maven 帮助信息。
14. **mvn archetype:generate：** 生成 Maven 项目的骨架。
15. **mvn site：** 生成项目的站点文档。

这些只是 Maven 命令的一部分，Maven 还提供了许多其他命令和插件，用于项目构建、依赖管理、站点生成等各种任务。通过使用这些命令，开发者可以高效地管理和构建他们的项目。



***作者有话说：如果是基础依赖项目，使用`mvn install`  他会把包推送了本地仓库，供别人使用，也就是`.m2`目录；如果是mvn去本地私有仓库读取，则需要使用`mvn deploy` 命令，把这个包推送到仓库里面。推送成功以后，在`nexus`  的控制台可以看到。***

## maven配置文件

如果是`yum`安装，他的默认路径是`/etc/maven/settings.xml`,对于运维而言，这个文件就是就只有几个地方是需要进行修改的。

1. **本地仓库路径 (`<localRepository>`)**：指定本地 Maven 仓库的路径，该路径通常位于用户主目录下的 `.m2` 目录中。例如：

   ```
   xml复制代码<localRepository>${user.home}/.m2/repository</localRepository>
   ```

2. **远程仓库镜像 (`<mirrors>`)**：用于配置 Maven 的镜像设置，指定 Maven 从哪个远程仓库下载依赖。示例：

   ```
   xml复制代码<mirrors>
       <mirror>
           <id>nexus</id>
           <mirrorOf>*</mirrorOf>
           <url>http://nexus.example.com/repository/maven-public/</url>
           <blocked>false</blocked>
       </mirror>
   </mirrors>
   ```

3. **代理服务器 (`<proxies>`)**：如果你的网络环境需要使用代理服务器来访问外部资源，你可以在这里配置代理服务器。示例：

   ```
   xml复制代码<proxies>
       <proxy>
           <id>example-proxy</id>
           <active>true</active>
           <protocol>http</protocol>
           <host>proxy.example.com</host>
           <port>8080</port>
           <username>proxyuser</username>
           <password>proxypassword</password>
           <nonProxyHosts>www.example.com|*.example.com</nonProxyHosts>
       </proxy>
   </proxies>
   ```

4. **服务器认证信息 (`<servers>`)**：用于配置 Maven 连接到远程仓库时的认证信息，例如用户名和密码。示例：

   ```
   xml复制代码<servers>
       <server>
           <id>nexus</id>
           <username>admin</username>
           <password>admin123</password>
       </server>
   </servers>
   ```

5. **配置文件包含 (`<profiles>`)**：用于定义不同环境下的不同配置。你可以在这里定义不同的配置文件，并在需要时进行引用。示例：

   ```
   xml复制代码<profiles>
       <profile>
           <id>development</id>
           <!-- Development specific configurations -->
       </profile>
       <profile>
           <id>production</id>
           <!-- Production specific configurations -->
       </profile>
   </profiles>
   ```

6. **其他配置项**：除了上述主要配置项外，`settings.xml` 文件还可以包含其他配置项，例如插件管理、全局属性等。

通过修改 `settings.xml` 文件，你可以定制 Maven 的行为以适应你的项目和环境需求。

## 总结

如果去到一个新项目或者拿到一个项目的java源码运维关注的角度就是

1. 准备基础环境，包括jdk，maven安装，nexus仓库的安装
2. 配置各个环境，以便他们可以正常使用
3. 修改业务的pom.xml，让他可以使用本地环境
4. 编译每一个项目，让各个依赖的项目都能拿到自己依赖的包（可能不知道顺序，有的项目需要多次编译）
5. 然后构建编译的包运行方式（可选）
6. 构建自动化流水线发布（可选）