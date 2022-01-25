# HBase data source

HBase is a widely used storage system. Byzer also supports loading one of these indexes as a table.

Note: the HBase package is not included in Byzer's default distribution package, so you need to add the relevant dependencies via `--jars` to use it. There are two ways for users to install
HBase Jar package:

1. ~~Use [hbase Datasource plugin](https://github.com/allwefantasy/mlsql-pluins/tree/master/ds-hbase-2x)~~;
   (Not currently supported)
2. Access [spark-hbase](https://github.com/allwefantasy/spark-hbase) and compile it manually;

## Installation and use

### ~~Plugin installation~~(Not currently supported)

Install `ds-hbase-2x` with the following command:

```sql
> !plugin ds add tech.mlsql.plugins.ds.MLSQLHBase2x ds-hbase-2x;
```

There are a lot of HBase dependencies and they are about 80M so the download speed will be slow.

### Execute in Byzer

**Example:**

```sql
> SET rawText='''
{"id":9,"content":"Spark","label":0.0}
{"id":10,"content":"Byzer","label":0.0}
{"id":12,"content":"Byzer lang","label":0.0}
''';

> LOAD jsonStr.`rawText` AS orginal_text_corpus;

> SELECT cast(id as String) AS rowkey,content,label FROM orginal_text_corpus AS orginal_text_corpus1;

-- connect is followed by the data format, here is hbase2x, and then followed by some configuration. Finally name this connection hbase1.
> CONNECT hbase2x WHERE `zk`="127.0.0.1:2181"
and `family`="cf" AS hbase1;

> SAVE overwrite orginal_text_corpus1
AS hbase2x.`hbase1:kolo_example`;

> LOAD hbase2x.`hbase1:kolo_example` WHERE field.type.label="DoubleType"
AS kolo_example;

> SELECT * FROM kolo_example AS show_data;

```

**DataFrame code:**

```scala
val data = (0 to 255).map { i =>
      HBaseRecord(i, "extra")
    }
val tableName = "t1"
val familyName = "c1"


import spark.implicits._
sc.parallelize(data).toDF.write
  .options(Map(
    "outputTableName" -> cat,
    "family" -> family
  ) ++ options)
  .format("org.apache.spark.sql.execution.datasources.hbase2x")
  .save()

val df = spark.read.format("org.apache.spark.sql.execution.datasources.hbase2x").options(
  Map(
    "inputTableName" -> tableName,
    "family" -> familyName,
    "field.type.col1" -> "BooleanType",
    "field.type.col2" -> "DoubleType",
    "field.type.col3" -> "FloatType",
    "field.type.col4" -> "IntegerType",
    "field.type.col5" -> "LongType",
    "field.type.col6" -> "ShortType",
    "field.type.col7" -> "StringType",
    "field.type.col8" -> "ByteType"
  )
).load()
```

## Configuration parameters

The configuration parameters of ds-hbase-2x are as follows:

| Parameter Name | Parameter meaning |
|---|---|
| `tsSuffix` | Override the timestamp of the Hbase value |
| `namespace` | Hbase namespace |
| `family` | Hbase family, `family=""` means to load all existing families |
| `field.type.ck` | Specify type for `ck(field name)`; now supports: LongType, FloatType, DoubleType, IntegerType, BooleanType, BinaryType, TimestampType, DateType; default: StringType |