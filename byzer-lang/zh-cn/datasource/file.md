# 本地文件/HDFS
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

## Parquet
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



## Json

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



## csv

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


## text

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



## XML

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
