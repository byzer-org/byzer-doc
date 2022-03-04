# 内置宏函数/ Built-in Macro Functions


Byzer-lang 内置了非常多的宏函数，可以帮助用户实现更好的交互。

- ### !show

该命令可以展示系统很多信息。

1) 查看当前引擎版本：

```sql
!show version;
```

2. 显示show支持的所有子命令：

```sql
!show commands;
```

3. 列出所有的表：

```sql
!show tables;
```

4. 从指定db罗列所有表

```sql
!show tables from [DB名称];
```

5. 列出所有当前正在运行的任务：


```sql
!show jobs;
```

6. 列出某个任务的相关信息：

```sql
!show "jobs/v2/[jobGroupId]";
!show "jobs/[jobGroupId]";
!show "jobs/get/[jobGroupId]";
```

三者显示的内容不同，用户可以自己尝试下结果。

7. 列出所有可用的数据源：

```sql
!show datasources;
```

8. 列出所有Rest接口：

```sql
!show "api/list";
```

9. 列出所有支持的配置参数（不全,以文档为主）:

```sql
!show "conf/list";
```

10. 查看日志：

```sql
!show "log/[文件偏移位置]";
```

11. 列出数据源的参数：

```sql
!show "datasources/params/[datasource name]";
```

12. 列出当前系统资源：

```sql
!show resource;
```

13. 列出所有的 ET 组件：

```sql
!show et;
```

14. 列出某个 ET 组件的信息：

```sql
!show "et/[ET组件名称]";
```

15. 列出所有函数：

```sql
!show functions;
```

16. 列出某个函数：

```sql
!show "function/[函数名称]";
```

- ### !hdfs

!hdfs 主要用来查看文件系统。支持大部分HDFS查看命令。

查看帮助：

```shell
!hdfs -help;
!hdfs -usage;
```

下面为一些常见操作：

1. 罗列某个目录所有文件：

```shell
!hdfs -ls /tmp;
```

2. 删除文件目录：


```shell
!hdfs -rmr /tmp/test;
```

3. 拷贝文件：


```shell
!hdfs -cp /tmp/abc.txt /tmp/dd;
```

- ### !kill

该命令主要用来结束任务。

```shell
!kill [groupId或者Job Name];
```

- ### !desc

查看表结构。

```shell
!desc [表名];
```


- ###  !cache/!unCache

对表进行缓存。

```shell
!cache [表名] [缓存周期];
```

其中缓存周期有三种选择：

1. script
2. session
3. application

手动释放缓存：

```
!unCache [表名];
```

- ### !println

打印文本：

```
!println '''文本内容''';
```

- ### !runScript

将一段文本当做 Byzer 脚本执行：

```
!runScript ''' select 1 as a as b; ''' named output;
```

- ### !lastCommand

将上一条命令的输出取一个表名，方便后续使用：

```shell
!hdfs -ls /tmp;
!lastCommand named table1;
select * from table1 as output;
```

- ### !lastTableName

记住上一个表的名字，然后可以在下次获取：

```
select 1 as a as table1;
!lastTableName;
select "${__last_table_name__}" as tableName as output;
```

输出结果为 table1;

- ### !tableRepartition

对表进行分区：

```
!tableRepartition _ -i [表名] -num [分区数] -o [输出表名];
```


- ### !saveFile

如果一个表只有一条记录，并且该记录只有一列，并且该列是 binary 格式，那么我们可以将该列的内容保存成一个文件。

```
!saveFile _ -i [表名] -o [保存路径];
```

- ### !emptyTable

比如有的时候我们并不希望有输出，可以在最后一句加这个语句：

```
!emptyTable;
```

- ### !profiler

1. 执行原生 SQL:

```
!profiler sql ''' select 1 as a ''' ;
```

2. 查看所有 spark 内核的配置：

```
!profiler conf;
```

3. 查看一个表的执行计划：

```
!profiler explain [表名或者一条 SQL];
```


- ### !python

可以通过该命令设置一些 Python 运行时环境。


- ### !delta

1. 显示帮助：

```
!delta help;
```

2. 列出所有 delta 表：

```
!delta show tables;
```

3. 版本历史：

```
!delta history [db/table];
```

4. 表信息：

```
!delta info [db/table];
```

5. 文件合并：

```
!delta compact [表路径] [版本号] [文件数] [是否后台运行];
!delta compact db/tablename 100 3 background;
```

上面表示对 db/table 100 之前的版本的文件进行合并，每个目录只保留三个文件。


- ### !plugin

插件安装和卸载

- ### !kafkaTool

Kafka 相关的小工具

- ### !callback

流式 Event 事件回调