# 内置宏函数/ Built-in Macro Functions


Byzer-lang 内置了非常多的宏函数，可以帮助用户实现更好的交互。

## 信息查看类命令

> 在 Byzer 中可以通过 `!show` 命令来查看相关信息

| 分类 | 语句 | 功能描述 |
|--|--|--|
| 系统版本 | `!show version;` | 查看当前引擎版本 |
| 命令 | `!show commands;` | 列出 show 命令支持的所有子命令 |
| 表 | `!show tables;` | 列出所有的表 |
| 表 | `!show tables from [databaseName];` | 列出指定 databaseName 中的表 |
| 任务 | `!show jobs;` | 列出当前正在运行的任务 |
| 任务 | `!show "jobs/[jobGroupId]";` <br> `!show "jobs/v2/[jobGroupId]";` | 列出指定 jobGroupId 的任务详细信息 |
| 数据源 | `!show datasources;` | 列出当前系统中可用的数据源 |
| 数据源 | `!show "datasources/params/[datasourceName]";` | 列出指定数据源 datasourceName 的参数列表 |
| API | `!show "api/list";` | 列出 REST API 接口的相关信息 |
| 配置 | `!show "conf/list";` | 列出支持的配置参数， **当前的实现可能不全，以用户手册文档为主** |
| 日志 | `!show "log/[offset]";` | 查看指定偏移位置的日志 |
| 硬件资源 | `!show resource;` | 查看当前系统的资源情况 |
| ET | `!show et;` | 列出系统中的 ET 组件 |
| ET | `!show "et/[ET Name]";` | 列出指定的 ET Name 的 ET 组件详情 |
| ET | `!show "et/params/[ET Name]";` | 列出指定的 ET Name 的 ET 组件中的参数列表信息，比如 `!show "et/params/RateSampler;` 是查看 RateSampler 组件包含的所有参数信息 |
| 函数 | `!show functions;` | 查看当前引擎版本 |
| 函数 | `!show "function/[functionName]";` | 查看当前引擎版本 |

## 文件操作

> 在 Byzer 中可以通过 `!hdfs` 和 `!fs` 来对文件进行操作
> `!hdfs` 和 `!fs` 是相同的命令，可以互换使用
> 支持大部分常见的 Hadoop 系统中 HDFS 的查看命令

| 分类 | 语句 | 功能描述 |
|--|--|--|
| 帮助 | `!hdfs -help;` <br> `!hdfs -usage;` | 查看该命令的帮助信息 |
| 查看文件（夹） | `!hdfs -ls [path];` | 列出指定路径 path 下的文件和文件夹信息 |
| 删除文件（夹） | `!hdfs -rmr [path];` | 删除指定路径 path |
| 复制文件（夹） | `!hdfs -cp [source] [destination];` | 复制 source 文件路径至 destination |
| 移动文件（夹） | `!hdfs -mv [source] [destination];` | 移动 source 文件路径至 destination |
| 移动文件（夹） | `!hdfs -mv [source] [destination];` | 移动 source 文件路径至 destination |
| 重命名文件 | `!hdfs utils rename "/tmp/*.csv"   "/tmp/sub"  "(\\.csv)$"  ".txt";` <br> 或  <br>`!fs utils rename _ -source "/tmp/*.csv"  -target "/tmp/sub"  -pattern "(\\.csv)$"  -replace ".txt"; ` | 重命名指定 source 路径下的文件，将符合正则表达式 pattern 匹配的文件，重命名（或replace）指定的字符串，没有匹配到规则的文件，则保持原样移动到新的目录下|
| 合并文件 | `!hdfs utils utils getmerge "/tmp/*.csv" "/tmp/a.csv" 1;` <br> 或 <br> `!fs utils utils getmerge _  -source "/tmp/*.csv"  -target "/tmp/a.csv"  -skipNLines 1;` | 合并指定 source 路径下匹配到的文件，匹配通过通配符 `*`，将合并后的文件合并单一文件，并移动至 target 指定的目录，`skipNLines` 参数指定了除了第一个文件暴露前 N 行，其余的文件则去掉前 N 行，一般应用于当合并的文件有 header 时，最后合并的文件不会有重复 header 出现 |


## 任务操作
| 分类 | 语句 | 功能描述 |
|--|--|--|
| 查看任务 | `!show jobs;` | 列出当前正在运行的任务 |
| 查看任务 | `!show "jobs/[jobGroupId]";` <br> `!show "jobs/v2/[jobGroupId]";` | 列出指定 jobGroupId 的任务详细信息 |
| 结束任务 | `!kill [jobName];` | 结束指定 jobName 的任务 |
| 结束任务 | `!kill [jobGroupId];` | 结束指定 jobGroupId 的任务 |

## 表操作

| 分类 | 语句 | 功能描述 |
|--|--|--|
| 查看表 | `!show tables;` | 列出所有的表 |
| 查看表 | `!show tables from [databaseName];` | 列出指定 databaseName 中的表 |
| 查看 Schema | `!desc [tableName];` | 查看指定 tableName 的 Schema |
| 缓存表 | `!cache [tableName] [lifecycle];` | 缓存指定 tableName 的表至内存中，lifecycle 有两个值，分别是 `script` 和 `session`；<br> - 其中 script 表示该表的缓存只在当前的脚本有效（即通过 API 一次执行后就失效），用户无需手动进行释放缓存；<br> - 其中 session 表示该表的缓存在引擎的session 中和用户绑定，需要用户手动执行释放后才会被释放 <br> 一般情况下，为了加快计算，我们建议使用 script 生命周期来进行缓存|
| 释放表缓存 | `!unCache [tableName];` | 释放指定 tableName 的表的缓存 |
| 定义命令的结果返回为表 | `!lastCommand named [tableName];` | 将脚本中上一条执行的宏命令语句的结果定义为临时表 tableName，在后续调用时，可以使用 select 语句来操作上一条宏命令的结果|
| 获取表名称 | `!lastTableName;` | 使用该命令跟在一条定义了虚拟临时表的语句后面，在后续的引用中可以通过变量 `"${__last_table_name__}"` 来获取该虚拟临时表的名称。 <br> 比如有一条语句 `select 1 as a as table1;`, 在该语句后执行 `!lastTableName;`, 在后续的语句可以这样获取表的名称进行操作 `select "${__last_table_name__} as tableName as output` ，输出为 `table` |
|表分区| `!tableRepartition _ -i [tableName] -num [partitionNum] -o [outputTableName];` | 对指定的表 tableName 进行分区，分区数量由 partitionNum 指定，分区后会产生一张新的表 outputTableName|
|忽略表结果的返回| `!emptyTable;` |有些时候可能结果集过大或不需要将表结果返回给调用方，那我们就可以在脚本的末尾使用 `!emptyTable;`|

## Delta 操作

| 分类 | 语句 | 功能描述 |
|--|--|--|
| 显示帮助 | `!delta help;` | 显示帮助信息 |
| 查看 Delta 表 | `!delta show tables;` | 列出 delta 中的所有表 |
| 查看版本历史 | `!delta history [dbName].[tableName];` | 列出 delta 中指定 dbName.tableName 的表的历史信息，可以使用反引号 将 `[dbName].[tableName]` 进行 quote 操作|
| 查看 Delta 表信息| `!delta info [dbName].[tableName];`| 查看 delta 中指定 dbName.tableName 的表的信息 |
| 文件合并 | `!delta compact [dbName].[tableName] [version] [fileNum] background;` | 合并 delta 中 指定 dbName.tableName 的表的文件，version 是表的版本信息， fileNum 是合并后的文件数量， background 表示后台执行。<br> 以语句 `!delta compact demo.table1 100 3 background;` 为例，表示对 demo.table1 这张表，在 100 之前的版本的数据文件进行合并，合并后每个目录下只保留 3 个文件 |

## 其他命令

| 分类 | 语句 | 功能描述 |
|--|--|--|
| 打印文本 | `!println '''[contentString]''';` | 打印文本 contentString |
| 执行文本 | `!runScript '''[contentString]''' named [tableName];` | 将文本内容 contentString 作为 byzer 脚本来进行执行，结果命名为 `tableName` <br> 比如 `!runScript ''' select 1 as a as b; ''' named output;` |
| 保存文件 | `!saveFile _ -i [tableName] -o [pathToSave];` | 如果 tableName 这张表中只有一列，且只有一条记录（即单一 cell），且该 cell 内的内容是 binary 格式，那么我们可以将该 binary 内容保存为一个文件 |
| 分析器 | `!profiler sql '''select 1 as a''';` | 通过分析器直接执行原生 Spark SQL |
| 分析器 | `!profiler conf;` | 通过分析器获取 spark 内核的配置 |
| 分析器 | `!profiler explain [ SQL | tableName ]` | 通过分析器查看一条 SQL 语句或 一张表的执行计划 |
