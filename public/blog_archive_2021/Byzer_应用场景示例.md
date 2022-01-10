# Byzer 应用场景示例

### 前言
Byzer 都有哪些应用场景呢？毕竟现在是个场景为王的时代。其实 Byzer 有无限的可能性等待大家挖掘。下面我们提一些已经在应用的。

数据同步组件
比如从各个数据库里把数据同步到 HDFS 上。

ETL 平台
配合调度，传统的批处理平台。

流式平台
Byzer 很好的支持了 Structured Streaming.

开发平台
什么意思呢？就是根据业务需求，用 Byzer 开发了一个脚本，然后将脚本暴露通过 API 暴露出去，供外部调用。比如 EDM，研发接到需求后，使用 Byzer 写好脚本保存，然后对外提供一个 API 接口，给定了一个脚本 id 号，用户就可以通过 http 接口调用得到这个脚本执行后的结果了。目前主要对接的是后台业务。 Byzer 也支持变量覆盖，比如脚本里写

```sql

set input1="a" where type="default";

set input2="a" where type="default";

select ........
```

这表示用户传递过来的 input1，input2 会覆盖脚本写好的。

算法平台
Byzer Engine 提供了大量的数据预处理ET以及良好的 Python 项目支持功能，所以进行训练一点问题都没有。对于预测，Byzer 也提供了优化的 local 部署模式完成低于毫秒级的预测服务支持。

数据探索平台
Byzer Engine 优秀的语法以及宏支持，适合非研发同学学习。通过 Byzer Console 的配合，非常方便数据分析师，数据科学家进行数据数据探索，也支持运营，产品自助使用。

分析师新的交付手段
分析师写好一个脚本，系统提供了一个功能，可以将脚本以一个表单的形式提供出去，用户通过填写表单就能出发 Byzer 脚本的运行，从而得到结果。

另外通过宏的支持，分析师可以封装一个非常复杂的 SQL 脚本，然后将其作为一个命令提供出去。比如

分析师写好如下指令：

```sql
set queryEmailByName='''

select email from table1 where name="{}"

'''
```
用户可以这么用：

```sql
!queryEmailByName william;
```
总结
如果你还有更多场景，欢迎反馈。