# 网络安装插件

如果你内网（也可以通过自己设置代理）可以访问 [http://store.mlsql.tech](http://store.mlsql.tech)，那么你可以直接使用命令行方式在Kolo-notebook里安装。

比如如果需要安装excel支持，一行命令在Kolo-notebook里即可搞定：

```shell
!plugin ds add - "mlsql-excel-3.0";
```

接着就可以用读取和保存excel格式数据了：

```
load excel.`/tmp/upload/example_en.xlsx` 
where useHeader="true" and 
maxRowsInMemory="100" 
and dataAddress="A1:C8"
as data;

select * from data as output;
```

更多可用插件到这里来看[kolo-extension](https://github.com/byzer-org/kolo-extension)

