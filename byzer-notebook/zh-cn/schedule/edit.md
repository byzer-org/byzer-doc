# 设置调度

### 1. 入口

在菜单栏中选择**调度**菜单进入调度页面。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/set_sch_menu.png" alt="name"  width="800"/>
</p>

### 2. 页面

在**操作**列中，有**设置**、**上线/下线**、**更多**按钮。

- **设置**按钮只有在**调度**处于**下线**状态时才能使用

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/set_sch_settings_disabled.png" alt="name"  width="800"/>
    <img src="/byzer-notebook/zh-cn/schedule/images/set_sch_settings.png" alt="name"  width="800"/>
</p>

- **更多**按钮有**运行**、**删除**、**查看 DAG**、**查看实例** 4 个下拉项
    - **运行**按钮只在调度处于**上线**状态时可用
    - **删除**按钮只在调度处于**下线**状态时可用
    - 点击**查看 DAG**按钮将跳转至 **DAG** 页面，**DAG** 页面只展示当前调度的节点 DAG 图
    - 点击**查看实例**按钮会跳转至[调度实例](/byzer-notebook/zh-cn/schedule/instance.md)页面

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/set_sch_more.png" alt="name"  width="200"/>
</p>

### 3. 设置调度

点击**设置**按钮弹出**设置调度**弹框。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/set_sch_settings_btn.png" alt="name"  width="600"/>
</p>

弹窗中有如下字段：

**调度名称**：必填项，类型为输入框，最大长度为 50 个字符。

**调度描述**：非必填，类型为输入框，最大长度为 50 个字符。

**起止日期**：必选项，类型为日期范围选择框

**定时**：必填项，类型为输入框，可手动输入 7 位 cron 表达式或者在弹出的悬浮窗中点选年、月、天、时、分、秒规则

**未来 5 次执行时间**：类型为文本框，禁用模式，点击**定时**右侧的**执行时间**按钮后，将会根据 cron 表达式自动计算并展示在文本框中

修改完成后点击**确定**更新调度信息。