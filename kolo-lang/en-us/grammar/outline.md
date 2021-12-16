# Byzer-Lang Guide

Byzer-lang is a declarative language, which is very similar to SQL. The difference is that Byzer-lang also supports Python scripts, and users can also use Scala/Java to dynamically develop and register UDF functions.

This has greatly improved the flexibility of this language.

Byzer-lang abstracts the following syntax structures for processing big data:

1. Load data/Load
2. Process data/Select|Run
3. Save data/Save|Run

and syntax structures for machine learning:

1. Model training/Train
2. Model registration/Register
3. Model prediction/Select|Predict

In addition, Byzer-lang supports scripts and package management.

## Load data


```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;
```

As the statement shown above, the keyword `load` clarifies the data loading. The loaded data format is `excel`, and the file path is `./example-data/excel/hello_world.xlsx`. During the loading process, the configuration parameters are specified in `where/options` clause. The result after loading is a table named `hello_world` specified after `as`.

Byzer-lang can load most:

1. Data sources, such as JDBC protocol databases, object storage on clouds, HDFS.
2. Data formats, such as text, image, csv, json, xml, etc.


## Process data

The keyword `select` clarifies the data processing.

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

select hello from hello_world as output;
```

In this example, the `hello-world` table is processed using Spark SQL-compatible syntax.

## Save data

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

save overwrite hello_world as csv.`./tmp/hw` where header="true";
```

`save` means to save the table. `overwrite` means to overwrite the target object. `hello_world` is the saved table. `as` follows the saved format and path. The configuration option is in the `where/options` clause.

## Reuse code

In the same project, references between scripts can be supported through the `include` statement.


```sql
include project.`./src/common/PyHeader.mlsql`;
```

This syntax works in the desktop version. Different Notebook implementations may vary, but the overall format is consistent.

If you want to achieve package-level reuse, Byzer-lang uses Github as the package manager. For example, lib-core is an example of Byzer-lang Lib:

```
https://github.com/allwefantasy/lib-core
```

You can introduce the library into your own project with the following code:

```sql
include lib.`github.com/allwefantasy/lib-core`
where 
mirror="gitee.com"
and alias="libCore";
```

Then, introduce the `hello` script, and finally you can use the `hello` function in the `select` statement:

```sql
include local.`libCore.udf.hello`;
select hello() as name as output;
```

## Macro function

There are also functions in standard SQL, and the macro functions of Byzer-lang are SQL-level.

For example, writing a complete `load` statement every time can be a frustrating thing. You can encapsulate it as follows:

```sql
set loadExcel = '''
load excel.`{0}` 
where header="true" 
as {1}
''';

!loadExcel ./example-data/excel/hello_world.xlsx helloTable;
```

Macro functions use command-line-like methods for parameter passing. You can use prefix `! ` to call a macro function.

Macro functions also support named parameters:

```sql
set loadExcel = '''load excel.`${path}` where header="true" as ${tableName}''';!loadExcel _ -path ./example-data/excel/hello_world.xlsx -tableName helloTable;
```

## Native UDF

Byzer-lang supports users to write UDF functions using Java /Scala. One of the great advantages of Byzer-lang is that you can write as you need.

```ruby
register ScriptUDF.`` as arrayLast where lang="scala"and code='''def apply(a:Seq[String])={      a.last}'''and udfType="udf";select arrayLast(array("a","b")) as lastChar as output;
```

The above code defines an `arrayLast` function whose logic is to get the last value in the array. After the registration is completed through the `register` clause, it can be directly used in the `select` statement, and it works the same as the built-in function.

## Variable

Byzer-lang also supports variables. Variables are declared using `set`.

For example:

```sql
set a="b";
```

Variables can be applied to the `select` statement：

```sql
select "${a}" as a as output;
```

Variable are mainly referenced in the form of `${}`. The branch conditional expressions are special cases, which are referenced in the form of `: VariableName`.

## Branch statement

Byzer-lang supports high-level branch statements.

For example:

```sql
set a = "wow,jack";!if ''' split(:a,",")[0] == "wow" ''';   select 1 as a as b;!else;   select 2 as a as b;!fi;select * from b as output;
```

Or:

```sql
select 1 as a as mockTable;set b_count=`select count(*) from mockTable ` where type="sql" and mode="runtime";!if ''':b_count == 1 ''';        select 1 as a  as final_table;!else;        select 2 as a  as final_table;!fi;    select * from final_table as output;
```

## Machine learning

`The load/select` statement can complete the loading, association, preprocessing and other related work of data.

After the processing is completed, the result table can be trained using the `train` sentence pattern.

```sql
train mock_data as RandomForest.`/tmp/models/randomforest` wherekeepVersion="true" and evaluateTable="mock_data_validate"and `fitParam.0.labelCol`="label"and `fitParam.0.featuresCol`="features"and `fitParam.0.maxDepth`="2";
```

This sentence means that the `mock_data` table is used as the training data, and the RandomForest is used for training. The parameters of the training are stated in the `where/options` clause. The resulting model is stored in the `/tmp/models/randomforest`.

After obtaining the trained model, it can be registered as a UDF function for the subsequent application of batch analysis, streaming analysis or APIs.

At this time, you can use the `register` clause to complete the registration of the model to the UDF.

```sql
register RandomForest.`/tmp/models/randomforest` as model_predict;select vec_array(model_predict(features)) as predicted_value from mock_data as output;
```

## Byzer-python

Byzer supports Python scripting through Byzer-python. It will be easier to use if users use it in Byzer Notebook.

Here is a piece of Byzer-lang script:

```sql
select 1 as a as mockTable;-- specify the output schema of python!python conf "schema=st(field(a,long))";-- specify the python code will be executed in which virtual env.!python env "PYTHON_ENV=source /opt/miniconda3/bin/activate ray1.8.0";run command as Ray.`` where inputTable="mockTable"and outputTable="newMockTable"and code='''from pyjava.api.mlsql import RayContextray_context = RayContext.connect(globals(),None)newrows = []for row in ray_context.collect():    row["a"] = 2    newrows.append(row)    context.build_result(newrows)''';select * from newMockTable as output;
```


In Notebook, the syntax is simplified and Python scripts can be written in a separate cell.

## Plugin

`run/train` and data sources can be extended through plug-ins.

It is easy to install and use third-party plug-ins. For example:

```sql
!plugin app remove  "mlsql-mllib-3.0";!plugin app add - "mlsql-mllib-3.0";
```

The Plugin Manager automatically downloads the latest version of the specified plug-in from the `store.mlsql.tech` website.

Once installed, you can use an ET called `SampleDatasetExt`.

Test data can be generated using this ET:

```sql
run command as SampleDatasetExt.`` where columns="id,features,label" and size="100000" and featuresSize="100" and labelSize="2" as mockData;
```

The ET will produce a table called `mockData` with 3 fields `id`, `feature`, `label`, This table has 100000 rows, and its feature length is 100 and the classification type is 2.

## Scope

Byzer-lang is an interpreted language. Variables, macro functions, UDF registration, `select` temporary tables, etc., all follow the following rules:

1. Can be used after declaration;
2. For multiple statements, the latter will overwrite the previous;
3. Except for variables, the life cycle of macro functions is per request, and other elements such as UDF registration and `select `temporary tables have session-wise life cycles.

> * request, valid only during the current execution phase, cannot be used across cells.
> * session, user life time binding, can be used across cells. By default, the user session will be released after no access occurs for 1 hour.

