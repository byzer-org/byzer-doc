# 使用工作流

在工作区页面，您可以创建、编辑、重命名、克隆工作流。

### 创建工作流


1. 在根目录下创建工作流文件

![avartar](./images/create_method1.png)

2. 在指定文件夹下创建工作流文件

![avartar](./images/create_method2.png)

3. 创建工作流文件

![avartar](./images/workflow_create.png)


### 工作流节点

目前我们的工作流节点包含下面五类：

- Basic Node

  包含一些常用的节点，load， select，save， ...

- Algorithm Node
  
  包含一些算法相关的节点，ALSInPlace， KMeans，NaiveBayes，...

- Feature Engineering Node

  包含一些 Feature Engineering 相关的节点，Discretizer， NormalizeInPlace，ScalerInPlace，...

- Data Processing Node

  包含一些 Data Processing 相关的节点，JsonExpandExt，RateSampler，TableRepartition，

- Tool Node

  包含一些工具相关的节点，SyntaxAnalyzeExt，TreeBuildExt

### 工作流节点创建

创建完成之后自动跳转到工作流节点页面，然后拖动节点就会出现创建节点的弹窗，在每个节点中填写需要配置的参数值，创建完成之后会根据节点之间的输入输出关系自动连线。您如果觉得当前的连线不太美观，可以拖动节点改变节点位置

![avartar](./images/workflow_node.png)

例：
先创建 load 节点，再创建 select 节点, select 节点中可以点击 `检查` 进行语法检查， 其他节点中会按照输入的内容自动生成 Byzer Lang 语法

![avartar](./images/create_load.png)
![avartar](./images/create_select.png)

连线结果
![avartar](./images/node-line.png)

### 工作流和笔记本的转换
点击 workflow 页面右上角的 notebook 就会将工作流转化为 notebook，只是预览哦

![avartar](./images/workflow_notebook.png)

如果需要进一步编辑笔记本，点击 `另存为笔记本` 就可以保存成一个笔记本了

![avartar](./images/save_as_notebook.png)

### 工作流节点编辑

如果需要编辑某个节点，点击该节点，页面右侧会出现编辑框，根据自己的需要修改节点参数就可以了，保存修改后连线也会更新

![avartar](./images/node_edit.png)

### 工作流节点删除

选中需要删除的节点，再按 `delete` 或 `backspace` 就可以删除了

![avartar](./images/node_delete.png)

### 工作流的相关操作

工作流可以重命名，克隆，删除，移动（到其他文件夹），具体操作的位置如下图所示

![avartar](./images/workflow_action1.png)

![avartar](./images/workflow_action2.png)








