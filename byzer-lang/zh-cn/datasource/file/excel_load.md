# 读取Excel文件

Excel 读取的典型方式如下：

```sql
load excel.`./example-data/hello_world.xlsx` 
where header="true" 
and dataAddress="roles"
as hello_world;
```

## 扩展安装

如果提示 excel 数据源不存在，那么可以通过在线方式安装：

```
!plugin app add "tech.mlsql.plugins.ds.MLSQLExcelApp" "mlsql-excel-3.3";
```

离线安装方式如下：

1. 下载插件jar包： https://download.byzer.org/byzer-extensions/nightly-build/
2. 将jar包拷贝到 ${BYZER_HOME}/plugin 目录里

然后在  `${BYZER_HOME}/conf/byzer.properties.overwrite` 中添加如下参数 `streaming.plugin.clzznames=tech.mlsql.plugins.ds.MLSQLExcelApp` ，因为我已经添加了一些扩展，所以这里看起来会是这样你在的：

```
streaming.plugin.clzznames=tech.mlsql.plugins.ds.MLSQLExcelApp,tech.mlsql.plugins.assert.app.MLSQLAssert,tech.mlsql.plugins.shell.app.MLSQLShell,tech.mlsql.plugins.mllib.app.MLSQLMllib,tech.mlsql.plugins.llm.LLMApp
```

## 如何指定 sheet name

可以通过 `sheetName` 参数指定。

```sql
load excel.`/tmp/upload/it.xlsx` where header="true"
and sheetName="技术文档"
as it_table;

select uuid() as id,* from it_table as it_table;
```

## 如何忽略注释

在下面的示例中,我们将使用comment选项告诉Byzer在读取Excel文件时忽略任何以评论字符开头的行。
评论选项设置为“#”,假设“#”用于表示Excel文件中的评论行。
您可以用文件中实际使用的评论字符替换它。

通过将header和inferSchema设置为true,拜泽将自动检测标题行并推断列的数据类型。

请注意,“#”是Byzer模板语法中的特殊字符。所以我们需要用“#[[ 转义字符 ]]#”对其进行转义。

总的来说,这个示例做了以下几件事:

1. 使用评论选项告诉Byzer忽略Excel文件中以“#”开头的评论行。
2. 将header和inferSchema设置为true,这样拜泽可以自动检测标题行和推断每列的数据类型。
3. 因为“#”在拜泽的模板语法中是一个特殊字符,所以需要用“#[[ 转义字符 ]]#”对其进行转义。 
4. 可以用文件中实际使用的评论字符替换“#”。

```sql
load excel.`./example-data/hello_world.xlsx` 
where header="true" 
-- Set the comment character to '#' (replace with your own)
and comment="#[[#]]#"
and dataAddress="comment"
as hello_world;
```

## 如何指定一个区间进行加载

在下面的示例中,我们正在读取位于”./example-data/hello_world.xlsx”的Excel文件。

我们使用dataAddress选项指定我们只想读取“comment2”工作表上的“B6:C7”范围内的单元格。 

这在您只想读取工作表的一部分时非常有用。

总的来说,这个示例说明了:

1. 我们正在读取位于”./example-data/hello_world.xlsx”的Excel文件
2. 我们使用dataAddress选项指定只想读取“comment2”工作表上的“B6:C7”范围内的单元格
3. 使用dataAddress选项读取工作表的一部分而不是全部可以在某些情况下非常有用,比如您只需要工作表中的某些特定数据。

dataAddress允许您通过指定单元格的范围来读取Excel工作表中的特定部分,而不是整个工作表。这可以提高效率,特别是当工作表很大且您只需要其中一小部分数据时。

```sql
load excel.`./example-data/hello_world.xlsx` 
where header="true" 
and dataAddress="'comment2'!B6:C7"
as hello_world;
```

## 如何控制内存使用

如果Excel文件很大,我们可以通过一些选项控制内存使用量。

在下面的示例中,我们将`maxRowsInMemory`选项设置为1000,这意味着拜泽在读取Excel文件时每个时间只会保留最多1000行在内存中。如果文件中有超过1000行,拜泽将以1000行为批次进行读取。

我们还将maxRowsPerSheet选项设置为10000,这意味着拜泽将从Excel文件中的每个工作表最多读取10000行。如果工作表有超过10000行,拜泽将只读取前10000行并忽略其余行。 

总的来说,这个示例说明了:
1. 如果Excel文件很大,我们可以通过设置maxRowsInMemory和maxRowsPerSheet选项来控制拜泽的内存使用量。
2. maxRowsInMemory控制拜泽在任何给定时间可以保留在内存中的最大行数。如果文件中有更多行,拜泽将分批读取。
3. maxRowsPerSheet控制拜泽可以从每个工作表读取的最大行数。如果工作表有更多行,拜泽将停止读取该工作表并继续下一工作表。
4. 通过这两个选项,我们可以防止拜泽因读取过大的Excel文件而消耗太多内存。

```sql
load excel.`./example-data/hello_world.xlsx` 
where header="true" 
and dataAddress="'comment2'!B6:C7"
and maxRowsInMemory="1000"
and maxRowsPerSheet="10000"
as hello_world;
```

## 日期字段的处理

在下面的例子中，我们展示如何使用 date/timestamp 格式。

```sql
load excel.`./example-data/hello_world.xlsx` 
where header="true" 
and inferSchema="true"
and dataAddress="'dateformat'!A1:B3"
and dateFormat="yyyy/MM/dd"
as hello_world;

-- you can check the schema with the following command:
-- !desc hello_world;
```

写入时：

```sql
-- you can use save to create a excel file.
save overwrite hello_world as excel.`/tmp/hellow.xlsx` 
where header="true" and dateFormat="yyyy-MM-dd";
```