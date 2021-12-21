# 将字符串当做代码执行

## 作用

[run-script](https://github.com/byzer-org/byzer-extension/tree/master/run-script) 插件用于将字符串当做 byzer 脚本执行。

## 安装

> 如果byzer Meta Store 采用了MySQL存储，那么你需要使用 https://github.com/byzer-org/byzer-extension/blob/master/stream-persist/db.sql
> 中的表创建到该MySQL存储中。

完成如上操作之后，通过如下命令安装插件：

```
!plugin et add - "run-script-2.4" named runScript;
```

> 注意：示例中 byzer 的 spark 版本为 2.4 ，如果需要在 spark 3.X 的版本运行，请将安装的插件设置为 `run-script-3.0`


## 使用示例

```sql
set code1='''
select 1 as a as b;
''';

-- 使用宏命令 runScript 执行一个 byzer 代码
!runScript '''${code1}''' named output;
```