## Kolo-Lang 语言向导

Kolo-lang 是声明式语言，这和SQL非常类似。不同的是，Kolo-lang也支持Python脚本，用户也可以使用Scala/Java动态开发和注册UDF函数。
这使得其灵活度得到了很大提高。

Kolo-lang 针对大数据领域的流程抽象出了如下几个句法结构：

1. 数据加载/Load
2. 数据转换/Select|Run
3. 数据保存,投递/Save|Run

而针对机器学习领域，也做了类似的抽象：

1. 模型训练/Train
2. 模型注册/Register
3. 模型预测/Select|Predict


此外，在代码复用上，Kolo-lang 支持脚本和包的管理。 

### 加载数据


```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;
```

在上面的语句中，通过load关键字进行加载申明。加载的数据格式为excel, 路径为 `./example-data/excel/hello_world.xlsx`,
加载的过程中配置参数在where/options 子语句中。最后，我们系统会加载为一张表，我们通过as 将其命名为hell_world.

Kolo-lang 几乎可以加载市面上主流的数据源，数据格式。各种云对象存储，亦或是HDFS,还有如支持JDBC驱动的数据库。

### 数据处理

Kolo-lang主要使用select语句处理加载后的数据。

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

select hello from hello_world as output;
```

在这里例子中，我们可以使用兼容spark-sql的语法对hello-world表进行处理。

### 数据保存

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

save overwrite hello_world as csv.`./tmp/hw` where header="true";
```

save 表示我们要对表进行保存。overwrite表示对目标对象进行覆盖。 hello_world则是被保存的表。 as 后面紧接着保存的格式和路径。 最后保存的配置选项在
where/options子句中。

### 代码复用

在同一个项目里，我们可以通过include来包含不同的文件。

```sql
include project.`./src/common/PyHeader.mlsql`;
```

这个语法在桌面版中有效。不同的Notebook 实现，则可能会有不同，但总体格式是一致的。

如果希望达到包级别的复用，Kolo-lang使用github作为包管理器。举例，笔者实现了一个Kolo-lang示例项目库：

```
https://github.com/allwefantasy/lib-core
```

我们可以通过如下代码将该库引入自己的项目：

```sql
include lib.`github.com/allwefantasy/lib-core`
where 
mirror="gitee.com"
and alias="libCore";
```

接着，我们引入hello模块，从而获得hello函数：

```sql
include local.`libCore.udf.hello`;
select hello() as name as output;
```

### 宏函数

标准SQL中也有函数，Kolo-lang的宏函数则是SQL层级的。

譬如每次都写完整的load语句是一件沮丧的事情。我们可以将其进行封装。

```sql
set loadExcel = '''
load excel.`{0}` 
where header="true" 
as {1}
''';

!loadExcel ./example-data/excel/hello_world.xlsx helloTable;
```

我们使用类似命令行的方式进行参数传递。使用`!` 进行宏函数的调用。

我们也支持命名参数：

```sql
set loadExcel = '''
load excel.`${path}` 
where header="true" 
as ${tableName}
''';

!loadExcel _ -path ./example-data/excel/hello_world.xlsx -tableName helloTable;
```

### Native UDF 

Kolo-lang支持用户使用Java/Scala编写UDF函数。 Kolo-lang的一大优势是，随写随用。

```ruby
register ScriptUDF.`` as arrayLast 
where lang="scala"
and code='''def apply(a:Seq[String])={
      a.last
}'''
and udfType="udf";

select arrayLast(array("a","b")) as lastChar as output;
```

在上面的代码中，我们定义了一个arrayLast的函数，他获取数组中最后一个值。我们通过register进行注册，之后马上可以使用。

### 变量

Kolo-lang 也支持变量。它使用set进行申明。比如：

```sql
set a="b";
```

使用示例如下：

```sql
select "${a}" as a as output;
```

我们可以在很多地方以`${}`的方式对变量进行引用。

### 分支语句

Kolo-lang支持高级别的分支语句。示例如下：

```sql
set a = "wow,jack";

!if ''' split(:a,",")[0] == "wow" ''';
   select 1 as a as b;
!else;
   select 2 as a as b;
!fi;

select * from b as output;
```

亦或是：

```sql
select 1 as a as mockTable;
set b_count=`select count(*) from mockTable ` where type="sql" and mode="runtime";

!if ''':b_count == 1 ''';    
    select 1 as a  as final_table;
!else;    
    select 2 as a  as final_table;
!fi;    

select * from final_table as output;
```

### 机器学习

使用load/select 我们可以加载，关联，预处理数据。处理得到的数据后，可以使用train进行训练。

```sql
train mock_data as RandomForest.`/tmp/models/randomforest` where

keepVersion="true" 

and evaluateTable="mock_data_validate"

and `fitParam.0.labelCol`="label"
and `fitParam.0.featuresCol`="features"
and `fitParam.0.maxDepth`="2";
```

这句话表示，我们使用mock_data表为训练数据，使用RandomForest进行训练，训练的参数在where/options子句中申明。得到的模型保存在`/tmp/models/randomforest`中。

我们可以将模型注册成UDF函数，从而方便的将模型应用于批，流，API中。

```sql
register RandomForest.`/tmp/models/randomforest` as model_predict;
select vec_array(model_predict(features)) as predicted_value from mock_data as output;
```

### Python支持

我们使用ET Ray 来支持Python

```sql
select 1 as a as mockTable;

-- specify the output schema of python
!python conf "schema=st(field(a,long))";

-- specify the python code will be executed in which virtual env.
!python env "PYTHON_ENV=source /opt/miniconda3/bin/activate ray1.8.0";

run command as Ray.`` where 
inputTable="mockTable"
and outputTable="newMockTable"
and code='''
from pyjava.api.mlsql import RayContext

ray_context = RayContext.connect(globals(),None)

newrows = []
for row in ray_context.collect():
    row["a"] = 2
    newrows.append(row)

    
context.build_result(newrows)
''';

select * from newMockTable as output;
```

## 插件支持

run/train以及数据源等很多东西都是可以通过插件进行扩展的。

安装和使用第三方插件很容易，比如：

```sql
!plugin app remove  "mlsql-mllib-3.0";
!plugin app add - "mlsql-mllib-3.0";
```

接着我们就获得了一个叫 `SampleDatasetExt` 的ET.使用该ET可以生成测试数据：

```sql
run command as SampleDatasetExt.`` 
where columns="id,features,label" 
and size="100000" 
and featuresSize="100" 
and labelSize="2" 
as mockData;
```

该ET会产生一个叫mockData的表，该表有三个字段id,features,label,条数100000, 特征长度100, 分类种类为2.

