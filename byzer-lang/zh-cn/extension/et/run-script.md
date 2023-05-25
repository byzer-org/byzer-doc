# 将字符串当做代码执行

### 作用

run-script 插件用于将字符串当做 byzer 脚本执行。 如果 Byzer Meta Store 采用了 MySQL 存储，那么你需要使用 https://github.com/byzer-org/byzer-extension/blob/master/stream-persist/db.sql
中的表创建到该 MySQL 中。

### 使用示例

```sql
set code1='''
select 1 as a as b;
''';

-- 使用宏命令 runScript 执行一个 byzer 代码
!runScript '''${code1}''' named output;
```