# Load

Byzer-Lang's design philosophy is `Everything is a table `, so you can abstract various file data sources, databases, data warehouses, data lakes and even Rest APIs into a table in Byzer-Lang, and then process it in a two-dimensional table way. This is mainly achieved through the `load` statement.


### Basic operation

Let's look at a simple load statement:

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
```

In this example, a variable named `abc` is registered as a view (table) through the `jsonStr` data source using the `load` statement.

The results are as follows:

```
dataType  x         y   z

A         group	100	200	200
B         group	120	100	260

```

In the statement, the first keyword `load` is followed by a data source or format name. For example, the above example is `jsonStr`, which means loading a Json string. 

Data source  is followed by `.` and `abc`. Usually there is a path inside the inverted quotation mark. For example, 

```
csv.`/tmp/csvfile`
```

To simplify the  reference to the loaded result table, we use the `as` sentence pattern and name the result as `table1`. 
`table1` can be referenced by subsequent `select` sentences:

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
select * from table1 as output;
```

### Show available data sources

View the data sources supported by the current instance (built-in or installed through the plug-in) through the following instructions:

```sql
!show datasources;
```

Users can use fuzzy matching to locate a data source:

```sql
!show datasources;
!lastCommand named datasources;
select * from datasources where name like "%csv%" as output;
```

When users want to know some parameters of a data source (such as `csv`), they can view it with the following command:

```sql
!show datasources/params/csv;
```

### Load Connect

`load `supports references to `connect `statements.

For example:

```sql
select 1 as a as tmp_article_table

connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="xxxxx"
and password="xxxxx"
as db_1;

load jdbc.`db_1.crawler_table` as output;
```

The `connect `statement does not really connect to the database, but only record the parameters to acoid repeatedly filling them in the `load/save `statement.

In the example, jdbc + db_1 is unique. When the system encounters jdbc. `db_1.crawler _table` in the following `load` statement, it will find all the configuration parameters such as driver, user, url, etc. through jdbc and db_1, and then automatically attach them to the `load` statement.

### Direct Query

Some data sources support direct query mode, and currently the JDBC data source is built-in.

For example:

```sql
connect jdbc where url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false" and driver="com.mysql.jdbc.Driver" and user="xxxx" and password="xxxx" as mysql_instance;load jdbc.`mysql_instance.test1` where directQuery='''select * from test1 limit 10''' as newtable;select * from newtable as output;
```

In the `where/options` parameter of the JDBC data source, the user can configure a `directQuery` parameter.

This parameter can write the syntax supported by the data source. For example, for ClickHouse it may be a ClickHouse SQL, and for MySQL it may be SQL that conforms to the MySQL syntax.

Byzer-lang pushes the `directQuery` query down to the underlying engine and registers the result as a new table.

In the above example, the name of the new table is `newtable`. This table can be referenced by subsequent Byzer-lang code.