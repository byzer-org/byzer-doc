# Excel 数据源

Excel 数据源使用方式如下：

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

## 常见使用方式

In the following example, We will use  the comment option to tell Byzer to ignore any rows that start with the comment character when reading the Excel file..

The comment option is set to `#`, assuming that `#` is used to indicate a comment line in the Excel file. You can replace this with the actual comment character used in your file.

By setting header and inferSchema to true, Byzer will automatically detect the header row and infer the data types of the columns. 

Notice that `#` is a speicial charactor in Byzer template grammar. So we need to escape it with `#[[ ESCAPSE CHARACRTORS ]]#`.


```sql
load excel.`./example-data/hello_world.xlsx` 
where header="true" 
-- Set the comment character to '#' (replace with your own)
and comment="#[[#]]#"
and dataAddress="comment"
as hello_world;
```




