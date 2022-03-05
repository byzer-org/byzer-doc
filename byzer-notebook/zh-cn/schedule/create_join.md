# 创建和加入调度

### 1. 入口

打开 Byzer Notebook 的**工作区**，选择一个已经写好的**笔记本**（调度功能暂不支持**工作流**文件），可以看到在顶部操作按钮中有一个**添加到调度**。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_btn.png" alt="name"  width="800"/>
</p>

### 2. 参数

点击**添加到调度**按钮会弹出**添加调度**弹窗。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_dialog.png" alt="name"  width="600"/>
</p>

弹窗中有如下字段：

**任务名称**：必填项，类型为输入框，默认填充当前**笔记本**的名称，不带后缀名，可输入字母、数字、下划线。

**任务描述**：必填项，类型为输入框，最大长度为 50 个字符。

**添加方式**：必选项，类型为单选框，默认选中**新增调度**，分为**新增调度**和**添加到已有调度**两种。

**调度名称**：必填项
- 如果**添加方式**为**新增调度**，类型为输入框，最大长度为 50 个字符。
- 如果**添加方式**为**添加到已有调度**，类型为下拉单选框，选项为已有调度列表。

**调度描述**：非必填，类型为输入框，最大长度为 50 个字符。

**前一个任务**：只有在**添加方式**为**添加到已有调度**并且选择了**调度名称**之后该项才展示，类型为下拉单选框，选项为当前选中调度的所有任务节点。

**起止日期**：类型为日期范围选择框
- **添加方式**为**新增调度**时可选且必填
- **添加方式**为**添加到已有调度**时禁用，新加入的**笔记本**的**起止日期**会跟随所选调度的**起止日期**

**定时**：类型为输入框
- **添加方式**为**新增调度**时可选且必填，可手动输入 7 位 cron 表达式或者在弹出的悬浮窗中点选年、月、天、时、分、秒规则
- **添加方式**为**添加到已有调度**时禁用，新加入的**笔记本**的**定时**会跟随所选调度的**定时**

**未来 5 次执行时间**：类型为文本框，禁用模式，点击**定时**右侧的**执行时间**按钮后，将会根据 cron 表达式自动计算并展示在文本框中

### 3. 创建调度

如下图所示参数，点击**确定**按钮可创建调度。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_param_1.png" alt="name"  width="400"/>
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_param_2.png" alt="name"  width="400"/>
</p>

### 4. 上线调度

创建完成后需要至**调度**页面**手动将调度上线**。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_online.png" alt="name"  width="800"/>
</p>

### 5. 加入调度

如果想要将**笔记本**添加到已有调度中，只需要在**添加方式**中选择**添加到已有调度**，然后依次选择要加入的**调度名称**和**前一个任务**即可。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_join_select.png" alt="name"  width="400"/>
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_join_select_pre.png" alt="name"  width="400"/>
</p>

完整参数如下图所示。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_join.png" alt="name"  width="600"/>
</p>

加入的调度如果是**上线**状态，会弹出提示，勾选**上线调度**按钮可在加入调度之后设置调度为**上线**状态。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_schedule_join_online.png" alt="name"  width="600"/>
</p>

### 6. 版本控制

在**笔记本**进入**调度**作为**节点**后，会锁定当前的版本，后续如果修改**笔记本**的内容，**调度**中运行的仍然是之前的版本，因此，在更新**笔记本**之后，需要先**移除节点**，然后重新**加入调度**。