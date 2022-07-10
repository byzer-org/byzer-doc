# Byzer CLI

Byzer 社区为 Byzer 引擎提供了一个命令行交互的插件，可以方便用户快速体验 Byzer 引擎，用于执行 Byzer 脚本，源码 [byzer-org/byzer-cli](https://github.com/byzer-org/byzer-cli)


### 下载 Byzer CLI

您可以前往 Byzer 社区的官方下载站点来下载 [Byzer CLI](https://download.byzer.org/byzer/misc/byzer-cli/)

Byzer CLI 支持 MacOS（Intel） 以及 Linux，对 Windows 提供部分支持：
- [byzer-cli-darwin-amd64](https://download.byzer.org/byzer/misc/byzer-cli/byzer-cli-darwin-amd64)
- [byzer-cli-linux-amd64](https://download.byzer.org/byzer/misc/byzer-cli/byzer-cli-linux-amd64)
- [byzer-cli-win-amd64](https://download.byzer.org/byzer/misc/byzer-cli/byzer-cli-win-amd64.exe)


### 安装 Byzer CLI

安装 Byzer CLI 之前，您需要先前往官方下载站点，下载对应操作系统的 Byzer Engine 并进行安装，详情可参考 [社区下载方式说明](/byzer-lang/zh-cn/installation/download/site.md) 章节， Byzer CLI 支持在以下两个产品安装包

- Byzer Server 安装包
- Byzer All-In-One 安装包

其中 Byzer All-In-One 安装包中已内置了 Byzer CLI 可执行文件，您可以在 `$BYZER_HOME/bin`目录中找到他；如果您安装的是 Byzer Server 安装包，则需要自行下载 Byzer CLI 可执行文件，将其放入 `$BYZER_HOME/bin` 目录下，并将其重命名为 `byzer`。

> 注意：您可能需要执行 `chmod +x byzer` 命令来赋予可执行权限


### 使用 Byzer CLI

Byzer CLI 的使用方式如下

```shell
$ $BYZER_HOME/bin/byzer run /path/to/{byzer-script}
```

byzer-script 文件后缀名支持 `.byzer` 和 `.mlsql`

### 执行 Byzer 脚本示例

我们在 `$BYZER_HOME/bin` 目录中，创建一个 Byzer Script 脚本文件 `hello.byzer`, 并写入如下的一条 Byzer 语句

```sql
load Everything.`` as table;
```
这条语句代表的是 Byzer 语言的设计理念，Everything is a table，您可以通过在命令行中执行如下语句

```shell
$ cd $BYZER_HOME
$ ./bin/byzer run bin/hello.byzer
```
等待执行完毕后，你会在命令行中看到如下输出，即通过 Byzer 引擎运行上述 SQL 语句的结果

```shell
$ ./bin/byzer run bin/hello.byzer
...
...
...
+----------+
|Hello     |
+----------+
|Byzer-lang|
+----------+

```

 Byzer CLI 的交互是一次性的，当执行完脚本后，进程就自动退出了。
