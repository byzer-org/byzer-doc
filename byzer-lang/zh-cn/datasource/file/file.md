# 加载文件/文本

Byzer 支持大部分 本地文件/HDFS 数据读取。目前支持的数据格式有
- Parquet
- Json
- Text
- XML
- csv

对数据的 `save` 或者 `load` 操作，都可以后接 `where` 从句配置相关参数。

数据源不同，参数可能有有所区别。
比如本章提到的所有格式都可以设置 `fileNum` 参数，改变文件保存数量；
但是只有 csv 格式可以设置是否保留 `header` (true/false)。

> **注意：**where 条件所有的 value 都必须是字符串，也就是必须用`"` 或者`'''`括起来。value 可以使用 `SET` 得到的变量。

下面是一些示例：


### 1. Parquet
```sql
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

> SET savePath="/tmp/jack";

> LOAD jsonStr.`rawData` AS table1;

> SAVE overwrite table1 AS parquet.`${savePath}`;

> LOAD parquet.`${savePath}` AS table2;

```

### 2. Json

```sql
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

> SET savePath="/tmp/jack";

> LOAD jsonStr.`rawData` AS table1;

> SAVE overwrite table1 AS json.`${savePath}`;

> LOAD json.`${savePath}` AS table2;

```



### 3. csv

```sql
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

> SET savePath="/tmp/jack";

> LOAD jsonStr.`rawData` AS table1;

> SAVE overwrite table1 AS csv.`${savePath}` WHERE header="true";

> LOAD csv.`${savePath}` WHERE header="true" AS table2 ;

```

csv 相关配置项（where 关键字后的部分）如下

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

### 4. Text

```sql
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

> SET savePath="/tmp/jack";

> LOAD jsonStr.`rawData` AS table1;

> SAVE overwrite table1 AS json.`${savePath}`;

> LOAD text.`${savePath}` AS table2;

```



### 5. XML

```sql
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

> SET savePath="/tmp/jack";

> LOAD jsonStr.`rawData` AS table1;

> SAVE overwrite table1 AS xml.`${savePath}`;

> LOAD xml.`${savePath}` AS table2;

```