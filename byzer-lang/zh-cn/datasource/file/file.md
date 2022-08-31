# 加载文件/文本

> 如何将数据存储为文本类数据源请参考 [存储为文件/文本](/byzer-lang/zh-cn/save_data/file/file.md) 一节

Byzer 引擎本身是基于一个存储系统上的，根据不同的部署方式的区别，存储为本地磁盘存储，HDFS 或 对象存储。Byzer 支持加载这些存储上的文本文件作为表，目前支持的数据格式有
- 内置文本数据源
    - Parquet
    - Json
    - Csv
    - Text
- 通过插件的支持的自定义数据源
    - Excel

用户可以通过 `LOAD` 语句来进行对数据的加载操作，如何使用 `LOAD` 语句可以参考语法手册 [数据加载/Load](/byzer-lang/zh-cn/grammar/load.md) 章节，我们可以在 `LOAD` 语句中的 `where` 从句配置数据源的相关参数。

对于不同的数据源，参数可能有有所区别。比如本章节中介绍的内置文本数据源，都具备 `fileNum` 参数，是在保存数据为文件设置的数据文件分片的数量；但是只有 csv 格式可以设置是否保留 `header=true|false`，其他的文本类数据源不具备该参数。

> **注意：**
> 1. where 条件所有的 value 都必须是字符串，也就是必须用`"` 或者`'''`括起来。value 可以使用 `SET` 语法设置的变量。
> 2. 因为 Byzer 的存储系统默认会以存储路径上，加上脚本执行的 {user_name} 来拼接每个用户的工作目录，所以本章节中所提到的数据源，在 LOAD 和 SAVE 的语句中的 Path， 都是默认带 `/${user_name}` 的前缀的，从而达到用户之间数据逻辑隔离的目的，下文中提到的 Path，在实际的存储系统中，路径都带了用户了前缀。如果在 Byzer Notebook 中配置了 `notebook.user.home` 参数定义了工作根目录 `${root_path}`，那么通过 byzer 实际读写的路径是以 `/${root_path}/{$user_name}/` 为根目录的。 

下面我们来展示各类文本数据源如何加载，后续用户可以直接通过 Byzer SQL 来进行后续的操作

## Parquet

我们可以通过 `parquet` 数据源关键字来加载一个 parquet 文件所在的路径

```sql
> SET dataPath="/tmp/jack";
> LOAD parquet.`${dataPath}` as parquet_data;
```

在该示例中，dataPath 为存储的一个路径，该 parquet 文件所在的实际路径为 `/${user_name}/tmp/jack`，通过 `LOAD` 语句将该路径下的 Parquet 文件加载为 `parquet_data` 表


## Json

#### 通过 jsonStr 加载 Json 字符串

我们可以通过 `jsonStr` 数据源关键字来加载一个或多个 mock 在内存中的 Json 字符串变量

```sql
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

> LOAD jsonStr.`rawData` AS table1;
```

在 Byzer 中可以通过 `SET` 语句来 mock 一组 Json 数据，方便后续用于数据调试，该数据是存在在引擎的内存中的。

在该示例中， 我们 mock 一个包含两个 json 的字符串变量 `rawData`，在 `LOAD` 语句中我们通过 `jsonStr` 数据源来指定这个变量


> **注意**，
> 1. `jsonStr` 数据源加载的变量引用时不包含 `$` 符号 
> 2. 通过 `jsonStr` 数据源加载 Json 字符串文本时，会根据 Json 的字段 key 来加载为表的字段名
> 3. `jsonStr` 数据源当加载存在 Json 嵌套的文本字符串时，被嵌套的字符串会作为该字段 key 对应的 value 来处理，如果需要处理嵌套 Json 字符串，就将 value 中的 JsonString 取出继续通过 `jsonStr` 来进行加载处理


### 加载 Json 文件

我们可以通过 `json` 数据源关键字来加载指定目录上的 json 文件

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
在该示例中，我们先 mock 了一张 csv 数据文本，将其加载为表，然后通过 `SAVE` 语句和 `json` 数据源将其保存至 `/tmp/jack` 路径中，保存为 json 文件，然后在通过 `LOAD` 语法，将在该路径下的 json 文件加载成 `table2`

> **注意**，
> 1. 通过 `json` 数据源加载 Json 文本文件时，会根据 Json 的字段 key 来加载为表的字段名
> 2. `json` 数据源当加载存在 Json 嵌套的文本字符串时，被嵌套的字符串会作为该字段 key 对应的 value 来处理

### Json 数据源相关参数

在使用 Json 数据源加载数据，可以查看 [Json 数据源](https://spark.apache.org/docs/latest/sql-data-sources-json.html) 文档中 **Data Source Option** 一节, 文档中描述的 Scope 为 `read` 或 `read/write` 的 Property 参数都可以用在 where 语句中作为条件 

## CSV

### 通过 csvStr 加载 csv 字符串

我们可以通过 `csvStr` 数据源关键字来加载一个 mock 在内存中的 CSV 表

```sql
> SET rawData='''
id,name,age
100,'John',30
200,'Mary',
300,'Mike',80
400,'Dan',50
''';

> LOAD csvStr.`rawData` 
where header="true"
AS table1;
```
在 Byzer 中可以通过 `SET` 语句来 mock 一组 CSV 数据表，方便后续用于数据调试，该数据是存在在引擎的内存中的。

在该示例中， 我们 mock 一个包含两个 5行数据的字符串变量 `rawData`，其中第一行是 Header，在 `LOAD` 语句中我们通过 `csv` 数据源来指定这个变量

> **注意**
> 1. 该变量引用时不包含 `$` 符号 
> 2. LOAD 语句中可以通过 where 条件来控制一些参数，比如是否带 header，或指定分隔符等操作
> 3. 默认的分隔符为逗号 `,`
> 4. 需要注意 mock 的 CSV 字符串中，注意遵从 CSV 文件的一些规范，比如分隔符前后的空格处理

### 加载指定路径的 CSV 文件

我们可以通过 `csv` 关键字来加载指定目录上的 csv 文件

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
在该示例中，我们先 mock 了一张 csv 数据文本，将其加载为表，然后通过 `SAVE` 语句和 `csv` 数据源将其保存至 `/tmp/jack` 路径中，保存为文件，然后在通过 `LOAD` 语法，将在该路径下的 CSV 文件加载成 `table2`



### CSV 数据源的相关参数
在加载 CSV 数据源是可以在 where 语句中填写相关的参数，常见的参数说明如下

| 参数                        | 默认值                         | 说明                                                         |
| :-------------------------- | :----------------------------- | ------------------------------------------------------------ |
| `sep`                       | `,`                            | 指定单个字符分割字段和值                                     |
| `mode`                      |                                | 允许一种在解析过程中处理损坏记录的模式。它支持以下不区分大小写的模式。请注意，`Spark`尝试在列修剪下仅解析`CSV`中必需的列。因此，损坏的记录可以根据所需的字段集而有所不同。 |
| `encoding`                  | `uft-8`                        | 通过给定的编码类型进行解码                                   |
| `quote`                     | `“`                            | 其中分隔符可以是值的一部分，设置用于转义带引号的值的单个字符。如果您想关闭引号，则需要设置一个空字符串，而不是`null`。 |
| `escape`                    | `\`                           | 设置单个字符用于在引号里面转义引号                           |
| `charToEscapeQuoteEscaping` | escape or `\0`                 | 当转义字符和引号(`quote`)字符不同的时候，默认是转义字符(escape)，否则为`\` |
| `comment`                   | 空                             | 设置用于跳过行的单个字符，以该字符开头。默认情况下，它是禁用的 |
| `header`                    | `false`                        | 将第一行作为列名                                             |
| `inferSchema`               | `false`                        | 从数据自动推断输入模式。 *需要对数据进行一次额外的传递       |
| `samplingRatio`             | `1.0`                          | 定义用于模式推断的行的分数                                   |
| `ignoreLeadingWhiteSpace`   | `false`                        | 一个标志，指示是否应跳过正在读取的值中的前导空格             |
| `ignoreTrailingWhiteSpace`  | `false`                        | 指示是否应跳过正在读取的值的结尾空格                         |


更多的参数，可以参考 [CSV 数据源](https://spark.apache.org/docs/latest/sql-data-sources-csv.html) 文档中 **Data Source Option** 一节, 文档中描述的 Scope 为 `read` 或 `read/write` 的 Property 参数都可以用在 where 语句中作为条件 

## Text

我们可以通过 `text` 数据源关键字来支持加载文件系统中的 Parquet，CSV，Json，xml 等数据文件

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

>Load text.`${savePath}` as table2;
```

该示例 mock 了一组 csv 字符串并通过 `csvStr` 将其加载成表，并通过 `json` 数据源将其写入至 `/tmp/jack` 路径下，然后再通过 `text` 数据源关键字加载成表。得到的结果如下

| file | value |
| ----------- | ----------- |
|`file:///${root_path}/{$user_name}/tmp/jack/part-00003-2e02851c-fc95-44cf-853d-61b870a8106a-c000.json` | `{"id":"300","name":"'Mike'","age":"80"}`|
|`file:///${root_path}/{$user_name}/tmp/jack/part-00003-2e02851c-fc95-44cf-853d-61b870a8106a-c000.json` | `{"id":"100","name":"'John'","age":"30"}`|
|`file:///${root_path}/{$user_name}/tmp/jack/part-00003-2e02851c-fc95-44cf-853d-61b870a8106a-c000.json` | `{"id":"400","name":"'Dan'","age":"50"}`|
|`file:///${root_path}/{$user_name}/tmp/jack/part-00003-2e02851c-fc95-44cf-853d-61b870a8106a-c000.json` | `{"id":"200","name":"'Mary'"}`|


`text` 数据源返回的结果为一张两列的表，分别为 `file | 数据所在的文件全路径` 以及 `value | 数据文件的中的一行`

> **注意**：text 数据源不支持 SAVE 语句


## Excel

加载或者保存 Excel 会是一个较为常见的需求，Byzer 引擎在[byzer-extension](https://github.com/byzer-org/byzer-extension/tree/master/mlsql-excel)实现了 Excel 的加载和保存

> 注： Excel 数据源是以插件的方式进行开发和发布的，在 Byzer All in One 以及 K8S 镜像我们内置了该插件，如果您的引擎端不支持 Excel，请参考 [Byzer Server 二进制版本安装和部署](/byzer-lang/zh-cn/installation/server/binary-installation.md) 章节中的 **安装 Byzer Extension** 一节

当确保了引擎端正确的加载了所需插件和启动后，我们就可以在 Byzer 中加载一个 Excel 文件，下面是一个示例

```sql
> LOAD excel.`/tmp/upload/titanic.xlsx` 
where header="true" 
and maxRowsInMemory="100" 
and dataAddress="A1:C8"
as data;
```


Excel 数据源中可使用的参数项如下：

| 参数                      | 默认值                            | 说明                                                         |
| ------------------------- | --------------------------------- | ------------------------------------------------------------ |
| `header`                  | `true`                            | 必填，是否将第一行作为列名                                   |
| `treatEmptyValuesAsNulls` | `true`                            | 是否将空值视为 `Null`                                        |
| `usePlainNumberFormat`    | `false`                           | 是否使用四舍五入和科学计数法格式化单元格                     |
| `inferSchema`             | `false`                           | 是否开启推断模式                                             |
| `addColorColumns`         | `false`                           | 是否需要获取列的背景颜色                                  |
| `dataAddress`             | `A1`                              | 读取数据的范围                                               |
| `timestampFormat`         | `yyyy-mm-dd hh:mm:ss[.fffffffff]` | 时间戳格式                                                   |
| `maxRowsInMemory`         | `None`                            | 内存中缓存的最大数据条数                                     |
| `excerptSize`             | `10`                              | 如果同时设置 `inferSchema` 和 `excerptSize`，则会推断的数据条数 |
| `workbookPassword`        | `None`                            | excel 的密码                                               |


### FAQ

#### Q1. 如何扩展 Byzer 可接入的文本类数据源？
Byzer 实现 Excel 数据源的加载是通过插件来进行开发的，可以参考 [自定义数据源插件开发](byzer-lang/zh-cn/extension/dev/ds_dev.md) 来进行数据源插件的扩展