# Delta Lake byzer插件

该插件提供了对Delta Lake表级别的支持

在线安装
```
!plugin ds add - "delta-enhancer-3.3";
```

作为App安装:

```
!plugin app add "tech.mlsql.plugins.delta.app.ByzerDelta" "delta-enhancer-3.3";
```

### 前置SQL
```sql
set rawText='''
{"id":1,"content":"MLSQL 是一个好的语言","label":0.0},
{"id":2,"content":"Spark 是一个好的语言","label":1.0}
{"id":3,"content":"MLSQL 语言","label":0.0}
{"id":4,"content":"MLSQL 是一个好的语言","label":0.0}
{"id":5,"content":"MLSQL 是一个好的语言","label":1.0}
{"id":6,"content":"MLSQL 是一个好的语言","label":0.0}
{"id":7,"content":"MLSQL 是一个好的语言","label":0.0}
{"id":8,"content":"MLSQL 是一个好的语言","label":1.0}
{"id":9,"content":"Spark 好的语言","label":0.0}
{"id":10,"content":"MLSQL 是一个好的语言","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

save append orginal_text_corpus as delta.`test_demo.table1`;
```

###  基本使用

#### 查看表结构 `!delta desc {schema.tableName}` 
```sql
!deltaTable desc test_demo.table1;
```

#### 清空表数据 `!delta truncate {schema.tableName}`
```sql
!deltaTable truncate "test_demo.table1";
```

#### 根据条件删除数据 `!delta delete {schema.tableName} {condition}`
删除id > 1的数据
```sql
!deltaTable delete test_demo.table1 'id > 1';
```

#### 彻底删除表 `!delta remove {schema.tableName}`
```sql
!deltaTable remove "test_demo.table1";
```

#### 清除表的历史状态 `!delta vacuum {schema.tableName} {retentionHours}`
```sql
-- 删除168个小时之前的历史版本
!deltaTable vacuum test_demo.table1 168;
```

