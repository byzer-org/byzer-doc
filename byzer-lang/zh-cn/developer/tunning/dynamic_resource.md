# 性能调优实例

### 问题场景
在我们通过 Rest 或 UDF 发起较多请求时，执行脚本的时间会显著的增加

<center><img src="/byzer-lang/zh-cn/developer/tunning/images/without-save.png" style="zoom: 70%;" /></center>

从图中可以看到我们执行完这个 cell 需要约 34 秒，但是他的数据量仅仅只有 36 条，可以说是非常的少，那么这是为什么呢？

### 解决方案
我们先说解决方案：
	在之前的 Rest 和 UDF 发起请求后，使用 save 语法将获取的数据保存下来

<center><img src="/byzer-lang/zh-cn/developer/tunning/images/add-save.png" style="zoom: 70%;" /></center>

这两行代码看似非常多余，但是再次执行试试呢？

<center><img src="/byzer-lang/zh-cn/developer/tunning/images/save-duration.png" style="zoom: 70%;" /></center>

脚本的运行时间只要 112 ms了。

### 执行机制
在 Byzer-lang 中是将 load -> action 分解为一个个的节点，load 即数据的获取，action 可理解为我们执行的一些操作 （如一些 select 语句）。

每一个 select 后面的 “as tableName” 其实是虚表，并不是真实存在的，后续使用到该虚表，会将获取虚表的节点再执行一遍以得到虚表的数据。将数据保存下来，然后再处理数据，将可以避免找到虚表后再次运行节点，因此可以大量节省时间。