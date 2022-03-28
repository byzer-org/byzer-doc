# 工作流

### 创建工作流

1. 点击左侧导航栏**工作区**旁的 **+ -> 工作流**创建工作流文件。

<p align="center">
    <img style="zoom: 70%" src="/byzer-notebook/zh-cn/workflow/images/create_method1.png" alt="name"  width="400"/>
</p>

2. 输入**工作流名称**，并点击**创建**，您会自动进入到**工作流**页面

<p align="center">
    <img style="zoom: 70%" src="/byzer-notebook/zh-cn/workflow/images/create_method2.png" alt="name"  width="400"/>
</p>

在该页面，您可以创建、编辑、重命名、克隆和删除工作流。

<p align="center">
    <img style="zoom: 70%" src="/byzer-notebook/zh-cn/workflow/images/workflow_create.png" alt="name"  width="800"/>
</p>

您也可以在左侧导航栏中的**工作区**模块对创建的工作流进行重命名、克隆、移动、导出和删除操作。

### 工作流节点

目前 Byzer 支持的工作流节点有五类：

#### 1. Basic Node 基本节点：

- Load：加载数据
- Select：选择
- Save：保存
- Train：训练
- Predict：预测
- Register：注册

#### 2. Algorithm Node 算法节点：

- ALSInPlace：交替最小二乘法（Alternating Least Square）， 一种协同推荐算法。
- TfldfinPlace：词频-逆向文件频率（Term Frequency-Inverse Document Frequency），是一种统计方法，用以评估一字词对于一个文件集或一个语料库中的其中一份文件的重要程度。
- KMeans：K均值聚类算法。
- LogisticRegression：逻辑回归是一个广义线性回归分析模型，常被用于二分类或多分类场景。
- NaiveBayes：朴素贝叶斯，用于监督学习。
- RandomForest：随机森林算法，利用多个决策树去训练，分类和预测样本。
- Linear Regression：线性回归是一种统计分析方法，它利用回归分析来确定两种或两种以上变量间相互依赖的定量关系。

#### 3. Feature Engineering Node 特征工程节点：

- Discretizer：将连续的特征转化为离散的特征。
- NormalizelnPlace：特征归一化，本质上是为了统一量纲，让一个向量里的元素变得可以比较。
- ScalerlnPlace：特征平滑，可以将输入的特征中的异常数据平滑到一定范围。
- Word2VeclnPlace：将文本内容转变成向量。

#### 4. Data Processing Node 数据处理节点：

- JsonExpandExt：可以轻松地将一个 JSON字段扩展为多个字段。
- RateSampler：数据集切分，支持对每个分类的数据按比例切分。
- TableRepartition：可以修改分区数量。例如，在我们保存文件前或使用 Python 时，我们需要使用 TableRepartition 来使 Python workers 尽可能地并行运行。 

#### 5. Tool Node 应用工具节点：

- SyntaxAnalyzeExt: 被用来完成表格抽取和解析所有在 SQL 中的表。
- TreeBuildExt: 被用来处理树状分析。

### 创建/删除节点

拖动您想要创建的节点至工作流画布页面任意位置，在弹窗中填写需要配置的参数，点击**确定**完成节点创建。您可以创建多个节点，创建完成后，Byzer Notebook 会根据节点之间的输入输出关系自动连线。您也可以在画布上拖动节点改变节点位置。

若您需要更新某个创建好的节点，点击该节点，在页面右侧的编辑框中根据您的需求修改节点参数即可。保存修改后，节点间的连线也会更新。

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/workflow_node.png" alt="name"  width="500">
</p>

若您需要删除某个创建好的节点，点击该节点，再按 `delete` 或 `backspace` 即可删除该节点。

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/delete_load.png" alt="name" width="500"/>
</p>

### 存储为笔记本

您可以通过两种方式将当前工作流存储为笔记本。

1. 点击页面保存按钮，即可完成保存。
2. 若您希望先行预览，点击画布右上角的**笔记本**页签，即可预览。

> 注意：这时您可以预览内容，但不可以对其进行编辑。

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/preview_notebook.png" alt="name"  width="500"/>
</p>

若内容确认无误，可点击页面保存按钮，并在弹窗中输入笔记本名称，再点击**创建**。创建成功后将自动进入该笔记本编辑页面。

> 注意：将工作流存储为笔记本后，原来的工作流依然存在，您可以在左侧导航栏的**工作区**模块中查看。

### 示例

在本例中，我们将对一个名为 feature 的文件进行切分，切分后的文件中的数据量分别为源文件的10%和90%。

1. 创建一个新的工作流。
2. 在左侧导航栏的**数据目录**模块中，点击 **File System** 旁的浮标 **+** ，并上传文件 features。

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/upload_file.png" alt="name"  width="500"/>
</p>

3. 在左侧导航栏的**工作流**模块中，将 **Basic Node** 中的 **Load** 拖至工作流画布中，并填写相关配置参数：Data Source 选择 HDFS，Data Type 选择 json，Source File Name 选择 tmp -> upload -> features.txt，在 Output 中输入 result_1。最后点击**确定**，该节点创建成功。

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/example_node.png" alt="name"  width="400"/>
</p>

4. 在左侧导航栏的**工作流**模块中，将 **Data Processing Node** 中的 **RateSampler** 拖至工作流画布中，并填写相关配置参数：Select the Input Table 选择上一步中输出的 result_1，isSplitWithSubLable 默认为 true，labelCol 默认为 label，sampleRate 默认为 0.9,0.1，在 Output Name 中输入 rateSampler_result。最后点击**确定**，该节点创建成功。

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/example_node1.png" alt="name"  width="400"/>
</p>

创建的两个节点根据输入输出关系自动连线，如下图所示：

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/example_node2.png" alt="name"  width="400"/>
</p>

5. 点击页面保存按钮，输入笔记本名称，将其保存为笔记本，页面将自动进入笔记本编辑页面。点击页面工具栏中的运行按钮，结果如下图所示：

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/example_node_result1.png" alt="name"  width="500"/>
</p>

<p align="center">
    <img src="/byzer-notebook/zh-cn/workflow/images/example_node_result2.png" alt="name"  width="500"/>
</p>






