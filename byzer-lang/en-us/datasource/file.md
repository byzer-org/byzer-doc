# Local file/HDFS
Byzer supports most HDFS/local file data reading. Currently supported data formats are:
- Parquet
- Json
- Text
- Xml
- Csv

The `save` or `load` operations on data can be followed by `where` clauses to configure relevant parameters.

Parameters may vary with data sources. For example, all the formats mentioned in this chapter can set the `fileNum` parameter to change the number of saved files; but only csv format can set whether to keep `header` (true/false).

> **Note: **all values ​​of where conditions must be character strings. It means that they must be enclosed in`"` or`'''`. Value can use variables obtained by `SET`.

Examples:

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

## Csv

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


## Text

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

## Xml

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
