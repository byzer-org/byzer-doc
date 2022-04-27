# Byzer CLI

### 使用命令行交互执行 Byzer 脚本

在 `$BYZER_HOME/bin` 目录中，提供了一个可执行文件 `$BYZER_HOME/bin/byzer` 以及一个测试文件 `hello.byzer`, 该测试文件包含了一条 Byzer 语句如下

```sql
select 1 AS id;
```
您可以通过在命令行中执行如下语句

```shell
$ ./bin/byzer run bin/hello.byzer
```
等待执行完毕后，你会在命令行中看到如下输出，即通过 Byzer 引擎运行上述 SQL 语句的结果

```shell
$ ./bin/byzer run bin/hello.byzer
...
...
...
+----------+
|1    |
+----------+
|1|
+----------+

```
> 1. Byzer CLI 的交互是一次性的，当执行完脚本后，进程就自动退出了。
> 2. 您可以自己创建 `xxx.byzer` 结尾的文件，在其中编写 Byzer 语句，然后通过 `{BYZER_HOME}/bin/byzer run xxx.byzer` 来进行执行