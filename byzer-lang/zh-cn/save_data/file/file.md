# 存储为文件/文本

> 如何加载文本类数据源请参考 [加载文件/文本](/byzer-lang/zh-cn/datasource/file/file.md) 一节

Byzer 引擎本身是基于一个存储系统上的，根据不同的部署方式的区别，存储为本地磁盘存储，HDFS 或 对象存储。Byzer 支持将数据表存储为下述的文件格式：
- 内置文本数据源
    - Parquet
    - Json
    - Csv
    - Text
- 通过插件的支持的自定义数据源
    - Excel


用户可以通过 `SAVE` 语句来进行对数据的加载操作，如何使用 `SAVE` 语句可以参考语法手册 [数据加载/Load](/byzer-lang/zh-cn/grammar/save.md) 章节，我们可以在 `SAVE` 语句中的 `where` 从句配置数据源的相关参数。

> **注意：**
> 1. 在通过 `SAVE` 语句保存表为文件时，Byzer 内置的文本数据源如（parquet，csv）等，原理和 Spark 写文件路径是一致的，实际在是将数据写入至一个目录，数据文件会被切分成不同大小的数据分片，而不会生成单一的 CSV 或 Parquet 文件，比如我们通过 Byzer 将数据表存储为 CSV 文件时，生成的文件目录下会生成如下的数据文件。即使在路径上加入了文件后缀名，那这个文件后缀名实际上也会被处理为目录的名字
> 2. 因为 Byzer 的存储系统默认会以存储路径上，加上脚本执行的 {user_name} 来拼接每个用户的工作目录，所以本章节中所提到的数据源，在 LOAD 和 SAVE 的语句中的 Path， 都是默认带 `/${user_name}` 的前缀的，从而达到用户之间数据逻辑隔离的目的，下文中提到的 Path，在实际的存储系统中，路径都带了用户了前缀。如果在 Byzer Notebook 中配置了 `notebook.user.home` 参数定义了工作根目录 `${root_path}`，那么通过 byzer 实际读写的路径是以 `/${root_path}/{$user_name}/` 为根目录的。 
> 3. 不能在一次 Byzer SQL 的执行中，对同一个文件路径进行读和写

```
$ ls ./tmp/data
_SUCCESS
part-00000-8e4e25b7-986b-409e-9bcf-5ce02304c915-c000.csv
part-00001-8e4e25b7-986b-409e-9bcf-5ce02304c915-c000.csv
part-00002-8e4e25b7-986b-409e-9bcf-5ce02304c915-c000.csv
part-00003-8e4e25b7-986b-409e-9bcf-5ce02304c915-c000.csv
part-00004-8e4e25b7-986b-409e-9bcf-5ce02304c915-c000.csv
```

## Parquet

我们可以通过 `parquet` 数据源关键字将 Byzer 定义的一张临时表存储到存储系统上的一个路径中，示例如下

```sql
SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

SET savePath="/tmp/jack";

LOAD jsonStr.`rawData` AS table1;

SAVE overwrite table1 AS parquet.`${savePath}`;

LOAD parquet.`${savePath}` AS table2;
```

在该示例中，我们 mock 了一个 json 文本并将其加载成表 `table1`，然后通过 `SAVE` 语句以 `overwrite` 的方式，将 `table1` 写入 `/tmp/jack` 路径下

### Parquet 数据源相关参数

在存储 Parquet 数据源是可以在 where 语句中填写相关的参数，常见的参数说明如下

|参数|默认值|说明|
|--|--|--|
|compress|snappy|存储 parquet 文件时支持的压缩编码方式，可选：`none`,`uncompressed`,`snappy`,`gzip`,`lzo`,`brotil`,`lz4`,`zstd`，该参数在声明时会覆写在 Byzer 的配置文件中进行配置的 `spark.sql.parquet.compression.codec` 参数|

## Json

我们可以通过 `json` 数据源关键字将 Byzer 定义的一张临时表存储到存储系统上的一个路径中，示例如下

```sql
> SET rawData='''
id,name,age
100,'John',30
200,'Mary',
300,'Mike',80
400,'Dan',50
''';

> LOAD csvStr.`rawData` where header="true" AS table1;

> SET savePath="/tmp/jack";
> SAVE overwrite table1 AS json.`${savePath}`;
> Load json.`${savePath}` as table2;
```

在该实例中，我们将 mock 并加载后的表 `table1`，以 `overwrite` 覆写的方式和 json 的格式，将其写入到 `/tmp/jack` 目录下

### Json 数据源相关参数

在使用 Json 数据源储存表为 Json 文件，可以查看 [Json 数据源](https://spark.apache.org/docs/latest/sql-data-sources-json.html) 文档中 **Data Source Option** 一节, 文档中描述的 Scope 为 `write` 或 `read/write` 的 Property 参数都可以用在 where 语句中作为条件 


## CSV

我们可以通过 `csv` 数据源关键字将 Byzer 定义的一张临时表存储到存储系统上的一个路径中，示例如下

```sql
> SET rawData='''
id,name,age
100,'John',30
200,'Mary',
300,'Mike',80
400,'Dan',50
''';

> LOAD csvStr.`rawData` where header="true" AS table1;

> SET savePath="/tmp/jack";

> SAVE overwrite table1 AS csv.`${savePath}` WHERE header="true";

> LOAD csv.`${savePath}` WHERE header="true" AS table2;
```

在该示例中，我们将 mock 并已加载好的表 `table1`， 以 `overwrite` 覆写的方式和 csv 格式将表存储至 `/tmp/jack` 中，在写入的时候，where 语句中加入了 `header="true"` 参数，这样在该路径下生成的每个数据文件分片都会包含 header 


### CSV 数据源的相关参数

在存储 CSV 数据源是可以在 where 语句中填写相关的参数，常见的参数说明如下

| 参数                        | 默认值                         | 说明                                                         |
| :-------------------------- | :----------------------------- | ------------------------------------------------------------ |
| `sep`                       | `,`                            | 指定单个字符分割字段和值                                     |
| `mode`                      |                                | 允许一种在解析过程中处理损坏记录的模式。它支持以下不区分大小写的模式。请注意，`Spark`尝试在列修剪下仅解析`CSV`中必需的列。因此，损坏的记录可以根据所需的字段集而有所不同。 |
| `encoding`                  | `uft-8`                        | 通过给定的编码类型进行解码                                   |
| `quote`                     | `“`                            | 其中分隔符可以是值的一部分，设置用于转义带引号的值的单个字符。如果您想关闭引号，则需要设置一个空字符串，而不是`null`。 |
| `escape`                    | `\`                           | 设置单个字符用于在引号里面转义引号                           |
| `charToEscapeQuoteEscaping` | escape or `\0`                 | 当转义字符和引号(`quote`)字符不同的时候，默认是转义字符(escape)，否则为`\` |
| `header`                    | `false`                        | 将第一行作为列名                                             |


更多的参数，可以参考 [CSV 数据源](https://spark.apache.org/docs/latest/sql-data-sources-csv.html) 文档中 **Data Source Option** 一节, 文档中描述的 Scope 为 `read` 或 `read/write` 的 Property 参数都可以用在 where 语句中作为条件 

##  Excel 

加载或者保存 Excel 会是一个较为常见的需求，Byzer 引擎在[byzer-extension](https://github.com/byzer-org/byzer-extension/tree/master/mlsql-excel)实现了 Excel 的加载和保存

> 注： Excel 数据源是以插件的方式进行开发和发布的，在 Byzer All in One 以及 K8S 镜像我们内置了该插件，如果您的引擎端不支持 Excel，请参考 [Byzer Server 二进制版本安装和部署](/byzer-lang/zh-cn/installation/server/binary-installation.md) 章节中的 **安装 Byzer Extension** 一节

当确保了引擎端正确的加载了所需插件和启动后，我们就可以在 Byzer 中将表存储为一个 Excel 文件，下面是一个示例

```sql
> SET rawData='''
id,name,age
100,'John',30
200,'Mary',
300,'Mike',80
400,'Dan',50
''';

> LOAD csvStr.`rawData` where header="true" AS table1;

> SAVE overwrite table1 as excel.`/tmp/test.xlsx` where header="true";
```

在该示例中我们将表 `table1` 以 excel 的格式覆写至路径 `/tmp/test.xlsx`

> **注意**: excel 数据源插件在 SAVE 的时候，并不像其他的文本类数据源是以数据分片的方式存储在路径中的，而是生成一个单一文件


### Excel 数据源的相关参数

在存储 Excel 数据源是可以在 where 语句中填写相关的参数，常见的参数说明如下

| 参数                      | 默认值                            | 说明                                                         |
| ------------------------- | --------------------------------- | ------------------------------------------------------------ |
| `header`                  | `true`                            | 必填，是否将第一行作为列名                                   |
| `treatEmptyValuesAsNulls` | `true`                            | 是否将空值视为 `Null`                                        |
| `usePlainNumberFormat`    | `false`                           | 是否使用四舍五入和科学计数法格式化单元格                     |
| `addColorColumns`         | `false`                           | 是否需要获取列的背景颜色                                  |
| `dataAddress`             | `A1`                              | 读取数据的范围                                               |
| `timestampFormat`         | `yyyy-mm-dd hh:mm:ss[.fffffffff]` | 时间戳格式                                                   |
| `workbookPassword`        | `None`                            | excel 的密码                                               |