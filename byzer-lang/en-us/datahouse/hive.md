# Byzer-lang reads/writes Hive data

Hive is extremely easy to use in Byzer-lang. Loading a Hive table only requires one statement:

```sql
load hive.`db1.table1` as table1;
```

The statement of save is:

```sql
save overwrite table1 as hive.`db.table1`;
```

If partitioning is required, use

```
save overwrite table1 as hive.`db.table1` partitionBy col1;
```

We can also use JDBC to access hive as follows:

```sql
load jdbc.`db1.table1`
where url="jdbc:hive2://127.0.0.1:10000"
and driver="org.apache.hadoop.hive.jdbc.HiveDriver"
and user=""
and password=""
and fetchsize="100";
```

Instruction:
- `jdbc:hive2://127.0.0.1:10000 ` is the address of HiveServer2.
- Username and password are not required for accesssing HiveServer2 by default.
- Please place the `jdbc jar` into the `libs` subdirectory of the Byzer-lang installation directory according to your Hive version.
- JDBC query performance is not as good as native query.

We can also replace the actual Hive storage with a data lake:

1. Configure the parameter `-streaming.datalake.path`  at startup to enable the data lake.
2. Configure `-spark.mlsql.datalake.overwrite.hive` and Hive uses data lake storage.

The example is as follows:

```sql
set rawText='''
{"id":9,"content":"Spark good language 1","label":0.0}
{"id":10,"content":"MLSQL is a good language6","label":0.0}
{"id":12,"content":"MLSQL is a good language7","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

select cast(id as String) as rowkey,content,label from orginal_text_corpus as orginal_text_corpus1;
save overwrite orginal_text_corpus1 as hive.`public.orginal_text_corpus1`;

load hive.`public.orginal_text_corpus1` as output ;
```

When you access Hive, it will penetrate the data lake and return Hive results if there is no data lake. If you want to write to Hive instead of the data lake, you can do this:

```
save overwrite orginal_text_corpus1 as hive.`public.orginal_text_corpus1` where storage="hive";
```

It is mandatory storage to be Hive.