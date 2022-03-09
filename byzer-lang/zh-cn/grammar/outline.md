# Byzer-Lang 语言向导

Byzer-lang 是声明式语言，这和 SQL 非常类似。不同的是，Byzer-lang 也支持 Python 脚本，用户也可以使用 Scala/Java 动态开发和注册 UDF 函数。
这使得其灵活度得到了很大提高。

Byzer-lang 针对大数据领域的流程抽象出了如下几个句法结构：

1. 数据加载/Load
2. 数据转换/Select|Run
3. 数据保存,投递/Save|Run

而针对机器学习领域，也做了类似的抽象：

1. 模型训练/Train
2. 模型注册/Register
3. 模型预测/Select|Predict

此外，在代码复用上，Byzer-lang 支持脚本和包的管理。 

### 加载数据


```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;
```

在上面的语句中，通过 `load` 关键字进行加载申明。加载的数据格式为 `excel` , 路径为 `./example-data/excel/hello_world.xlsx`,
加载的过程中配置参数在 `where/options` 子语句中。加载后的结果是一张表，使用 `as 语法` 进行命名，名称为 `hello_world`。

Byzer-lang 几乎可以加载市面上主流的数据源和数据格式：

1. 数据源： JDBC 协议的数据库， 多种云上对象存储，HDFS...
2. 数据格式：例如 text， image， csv， json， xml 等文件格式


### 数据处理

Byzer-lang 主要使用 `select` 句式处理加载后的数据。

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

select hello from hello_world as output;
```

在这里例子中使用兼容 Spark SQL 的语法对 `hello-world` 表进行处理。

### 数据保存

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

save overwrite hello_world as csv.`./tmp/hw` where header="true";
```

`save` 表示要对表进行保存。`overwrite` 表示对目标对象进行覆盖。 `hello_world` 则是被保存的表。 `as` 后面紧接着保存的格式和路径。 最后保存的配置选项在
`where/options` 子句中。

### 代码复用

在同一个项目里，脚本之间的引用可以通过 `include` 句式来完成。


```sql
include project.`./src/common/PyHeader.mlsql`;
```

这个语法在桌面版中有效。不同的 Notebook 实现，则可能会有不同，但总体格式是一致的。

如果希望达到包级别的复用，Byzer-lang 使用 Github 作为包管理器。举例，lib-core 是 Byzer-lang 的一个示例 Lib：

```
https://github.com/allwefantasy/lib-core
```

可以通过如下代码将该库引入自己的项目：

```sql
include lib.`github.com/allwefantasy/lib-core`
where 
libMirror="gitee.com"
and alias="libCore";
```

接着，引入 `hello` 脚本：

```sql
include local.`libCore.udf.hello`;
select hello() as name as output;
```

结果为：name: hello world，最后就可以在 `select` 句式中使用 `hello` 函数了。

### 宏函数

标准 SQL 中也有函数，Byzer-lang 的宏函数则是 SQL 层级的。

譬如每次都写完整的 `load` 语句是一件比较麻烦的事情。可以将其进行封装：

```sql
set loadExcel = '''
load excel.`{0}` 
where header="true" 
as {1}
''';

!loadExcel ./example-data/excel/hello_world.xlsx helloTable;
```

宏函数使用类似命令行的方式进行参数传递，使用前缀 `!` 进行宏函数的调用。

宏函数也支持命名参数：

```sql
set loadExcel = '''
load excel.`${path}` 
where header="true" 
as ${tableName}
''';

!loadExcel _ -path ./example-data/excel/hello_world.xlsx -tableName helloTable;
```


### Native UDF 

Byzer-lang 支持用户使用 Java/Scala 编写 UDF 函数。 Byzer-lang 的一大优势是，随写随用。

```ruby
register ScriptUDF.`` as arrayLast 
where lang="scala"
and code='''def apply(a:Seq[String])={
      a.last
}'''
and udfType="udf";

select arrayLast(array("a","b")) as lastChar as output;
```

结果为：lastChar: b

在上面的代码中定义了一个 `arrayLast` 的函数，该函数的逻辑是获取数组中最后一个值。通过 `register` 句式注册完成后，
就可以在 select 句式中直接使用，效果和内置的函数一样。

### 变量

Byzer-lang 也支持变量。变量使用 `set` 进行声明。

比如：

```sql
set a="b";
```

变量可以被应用于 `select` 句式中：

```sql
select "${a}" as a as output;
```

结果为：a

在 Byzer-lang 中，变量引用主要以 `${}` 的方式进行，分支条件表达式则是特例，它以  `:VariableName` 形式进行引用。

### 分支语句

Byzer-lang 支持高级别的分支语句。

示例如下：

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

结果为：a: 1

### 机器学习

`load/select` 句式可以完成对数据的加载，关联，预处理等相关工作。
处理完成后，可以对结果表使用 `train` 句式进行训练。

```sql
train mock_data as RandomForest.`/tmp/models/randomforest` where

keepVersion="true" 

and evaluateTable="mock_data_validate"

and `fitParam.0.labelCol`="label"
and `fitParam.0.featuresCol`="features"
and `fitParam.0.maxDepth`="2";
```

这句话表示，使用 `mock_data` 表为训练数据，使用 RandomForest 进行训练，训练的参数在 `where/options` 子句中申明。
得到的模型保存在 `/tmp/models/randomforest` 中。

训练成功得到模型文件后，就可以将模型注册成 UDF 函数供后续将模型应用于批，流，API中。
此时可以使用 `register` 句式完成模型到 UDF 的注册。

```sql
register RandomForest.`/tmp/models/randomforest` as model_predict;
select vec_array(model_predict(features)) as predicted_value from mock_data as output;
```

### Byzer-python支持

Byzer 通过 Byzer-python 支持 Python 脚本。 如果用户在  Byzer Notebook 中使用，将会更加易用。

下面展示的是一段纯 Byzer-lang 的代码：

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


在 Notebook 中，语法会得到简化，可以在单独的 cell 里写 Python 脚本。

### 插件支持

`run/train` 以及数据源等很多东西都是可以通过插件进行扩展的。

安装和使用第三方插件很容易，比如：

```sql
!plugin app remove  "mlsql-mllib-3.0";
!plugin app add - "mlsql-mllib-3.0";
```

插件管理器会自动从 `store.mlsql.tech` 网站下载最新版本的指定插件。

安装完成后，就可以使用一个名称为 `SampleDatasetExt` 的 ET 。

使用该ET可以生成测试数据：

```sql
run command as SampleDatasetExt.`` 
where columns="id,features,label" 
and size="100000" 
and featuresSize="100" 
and labelSize="2" 
as mockData;
```

该 ET 会产生一个叫 `mockData` 的表，该表有三个字段 `id，features，label`，条数 100000, 特征长度 100, 分类种类为 2.

### 作用域

Byzer-lang 是解释型语言。 变量，宏函数， UDF 注册，`select` 临时表等等， 都遵循如下规则：

1. 声明后即可使用
2. 多次声明，后面的会覆盖覆盖前面的
3. 除了变量，宏函数默认是 request 生命周期， 其他元素比如 UDF 注册， `select` 临时表等都是 session 声明周期。 

> request , 仅在当前执行阶段有效，不能跨 Cell 使用。
> session , 和用户生命周期绑定，可跨 Cell 使用。 默认 1 小时没有发生任何访问，用户 session 会被释放。



