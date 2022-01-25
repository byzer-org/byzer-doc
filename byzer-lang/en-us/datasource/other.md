## Other data sources

If the data source you want to use is not supported for Byzer for the time being, it can also be integrated which conforms to the standard of Spark datasource API.
The specific methods are as follows:

```
> LOAD unknow.`` WHERE implClass="Full package name of data source" AS table;
> SAVE table AS unknow.`/tmp/...` WHERE implClass="Full package name of data source";
```

The word `unknow` is arbitrary because Byzer uses the full package name configured in `implClass`.

If the driver has other parameters, they can be configured in the `where` clause.

