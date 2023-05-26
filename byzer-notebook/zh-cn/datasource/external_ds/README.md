# 外部数据源

Byzer 具备加载和存储多种数据源的能力。支持的外部数据源如下：

- JDBC
- [RestApi](../../../../byzer-notebook/zh-cn/datasource/external_ds/restapi.md)
- [ElasticSearch](../../../../byzer-notebook/zh-cn/datasource/external_ds/es.md)
- [Kafka](../../../../byzer-notebook/zh-cn/datasource/external_ds/kafka.md)
- [MockStreaming](../../../../byzer-notebook/zh-cn/datasource/external_ds/mock_streaming.md)
- [其他](../../../../byzer-notebook/zh-cn/datasource/external_ds/other.md)

您可在设置页面新增、编辑和删除外部数据源。

### 新增

点击**外部数据源**下方的**新增**按钮，在弹窗中输入以下数据源信息即可新增数据源。

> 注意：目前该新增方法仅支持添加交互式 JDBC 外部数据源，若您需要添加其他外部数据源，请参考[加载和存储多种数据源](/byzer-lang/zh-cn/datasource/README.md)。

<img style="zoom: 70%;" src="/byzer-notebook/zh-cn/datasource/images/add-external_datasource.png">

### 编辑和删除

您可以点击外部数据源列表中操作栏下方按钮对每个数据源进行编辑和删除。

<p><img style="zoom: 70%;" src="/byzer-notebook/zh-cn/datasource/images/list-external_datasource.png"></p>

在编辑外部数据源时，输入**参数名称**和**参数值**，并点击**连接**，可以测试是否连接成功。

<p><img style="zoom: 70%;" src="/byzer-notebook/zh-cn/datasource/images/edit-external_datasource.png"></p>



