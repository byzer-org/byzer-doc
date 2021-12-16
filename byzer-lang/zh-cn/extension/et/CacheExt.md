# 如何缓存表

Spark有一个很酷的功能，就是cache，允许你把计算结果分布式缓存起来，但存在需要手动释放的问题。

Kolo为了解决这个问题，需要将缓存的生命周期进行划分：

1. script

2. session

3. application

默认缓存的生命周期是script。随着业务复杂度提高，一个脚本其实会比较复杂，在脚本中我们存在反复使用原始表或者中间表临时表的情况，这个时候我们可以通过cache实现。原始表被缓存，中间表只需计算一次，然后脚本一旦执行完毕，就会自动释放。使用方式也极度简单：

```sql
select 1 as a as table1;
!cache table1 script;
-- 等价于ET CacheExt 的用法
select * from table1 as output;
```

使用 `!cache` 命令，可以将表 table1 设置为

上述代码也可以使用run语法，通过执行ET的方式实现。实际ET和command只是使用方式上面的不同，在Kolo-lang内部实现使用的是相同的代码逻辑。

代码示例如下：

```sql
run table1 as CacheExt.`` where execute="cache" and lifeTime="script";
select * from table1 as output;
```

session级别暂时还没有实现。application级别则是和MLSQL Engine的生命周期保持一致。需要手动释放：

```sql
!uncache table1;
```

或者使用run语法：
```sql
run table as CacheExt.`` where execute="uncache";
```

表缓存功能极大的方便了用户使用cache。对于内存无法放下的数据，系统会自动将多出来的部分缓存到磁盘。


## CacheExt 的配置参数

| 参数名  |  参数含义 |
|---|---|
| execute | 是否开启cache，可选值为：cache、uncache，默认为cache |
| lifeTime | 设置缓存的生命周期，可选值为：script、session、application。默认为script级别 |
| isEager | 如果设置为true，会立即进行缓存。cache ET默认懒执行，该参数设置为true会立即执行，默认为false |