# 编辑任务

### 1. 入口

**笔记本**如果在某个**调度**中，可以看到在顶部操作按钮中有一个**已添加到调度**。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/edit_task_btn.png" alt="name"  width="800"/>
</p>

### 2. 查看任务

点击**已添加到调度**按钮会弹出**查看任务**弹窗。弹框中展示**任务名称**、**任务描述**和**所属调度**三个字段，下方展示**所属调度**的任务节点 **DAG** 图。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/edit_task_view_task.png" alt="name"  width="800"/>
</p>

### 3. 编辑任务

点击**编辑**按钮弹出**编辑任务**弹框。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/edit_task_edit_dialog.png" alt="name"  width="600"/>
</p>

- 弹框展示**任务名称**、**任务描述**、**调度名称**、**前一个任务** 4 个字段，其中**调度名称**不可修改，其他 3 个字段可按需求修改。
- 点击**移除任务**按钮可将该任务从**所属调度**中移除
- 点击**保存**按钮将会更新当前任务的信息

该任务的**所属调度**如果是**上线**状态，会弹出提示，勾选**上线调度**按钮可在更新任务信息之后将**所属调度**重新设置为**上线**状态。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/edit_task_edit_dialog_online.png" alt="name"  width="600"/>
</p>