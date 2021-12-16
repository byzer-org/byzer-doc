## 其他

如果你希望使用的数据源 Byzer 暂时没有适配，如果它符合 Spark datasource API 标准，也可以进行集成。
具体做法如下：

```
> LOAD unknow.`` WHERE implClass="数据源完整包名" AS table;
> SAVE table AS unknow.`/tmp/...` WHERE implClass="数据源完整包名";
```

其中 unknow 这个词汇是可以任意的，因为 Byzer 使用的是 `implClass` 中配置的完整包名。

如果该驱动有其他参数，可以放在 `where` 从句中进行配置。

