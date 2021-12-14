## Kolo 对 Python 的支持之路
### 前言
Python 是做机器学习框架一定要支持的。Kolo 很早就支持集成 Python 脚本做模型的训练和预测。

训练的使用方式：

```sql
load libsvm.`sample_libsvm_data.txt` as data;
 
train data as PythonAlg.`/tmp/model1`
where
pythonScriptPath="/tmp/train.py"
 
-- keep the vertion of every model you train
and keepVersion="true"
 
and  enableDataLocal="true"
and  dataLocalFormat="json"
 
and  `fitParam.0.batchSize`="1000"
and  `fitParam.0.labelSize`="2"
 
and validateTable="data"
 
and `systemParam.pythonPath`="python"
and `systemParam.pythonVer`="2.7"
and `kafkaParam.bootstrap.servers`="127.0.0.1:9092"
;
```

可以看到，你可以直接指定一个 python 脚本路径。预测也是同样的：

```sql
load libsvm.`sample_libsvm_data.txt` as data;
 
-- register the model we have trained as a funciton.
register PythonAlg.`/tmp/model1` as npredict options
pythonScriptPath="/tmp/predict.py"
;
 
-- use the predict udf
select npredict(features) from data
as newdata;
```

### 问题
前面的支持方式有三个巨大的缺陷，我们在实际使用过程中也是体会明显：

1. 没有解决 Python 环境问题。因为是常驻服务模式，让问题变得更加复杂。
2. 没有项目的概念。对于自己实现的复杂算法，不大可能放在一个脚本中，而且预测脚本和训练脚本往往会依赖一堆的基础脚本。
3. 没有区分批预测和 API 预测。批预测适合在批处理或者流式计算中使用。API 预测则适合部署成 http 接口。

### 解决办法
通过 conda 解决环境问题，每个项目有自己的 python 运行环境。
提出项目的概念，即使配置的是一个脚本，系统也会自动生成一个项目来运行。
以 MLFlow 为蓝本，指定了一个项目的标准。标准项目应该在根目录有一个 MLproject 描述文件。
对应的 MLproject 文件如下：

```yaml
name: tutorial
 
conda_env: conda.yaml
 
entry_points:
  main:
    train:
        parameters:
          alpha: {type: float, default: 0.5}
          l1_ratio: {type: float, default: 0.1}
        command: "python train.py 0.5 0.1"
    batch_predict:
        parameters:
          alpha: {type: float, default: 0.5}
          l1_ratio: {type: float, default: 0.1}
        command: "python batchPredict.py"
    api_predict:
        parameters:
          alpha: {type: float, default: 0.5}
          l1_ratio: {type: float, default: 0.1}
        command: "python predict.py"
```

用户需要提供三个核心脚本：批处理，批预测，API 预测。具体如何写可以看看示例项目。我们现在来看看怎么使用这个项目：

首先是训练部分：

```sql
load csv.`/Users/allwefantasy/CSDNWorkSpace/mlflow/examples/sklearn_elasticnet_wine/wine-quality.csv` 
where header="true" and inferSchema="true" 
as data;
 
train data as PythonAlg.`/tmp/abc` where pythonScriptPath="/Users/allwefantasy/CSDNWorkSpace/mlflow/examples/sklearn_elasticnet_wine"
 and keepVersion="true"
 and  enableDataLocal="true"
 and  dataLocalFormat="csv"
 ;
```
非常简单，你只要指定项目地址即可。接着我们做批量预测：

```sql
predict data as PythonAlg.`/tmp/abc`;
```

这里我们无需指定项目地址，原因是在 /tmp/abc 里已经保存了所有需要的元数据。

接着我们部署一个 API 服务，
通过 http 接口利用如下语句注册模型：

```sql
 register PythonAlg.`/tmp/abc` as pj;
 ```
 
接着就可以预测了(我写了段程序模拟请求)

```python
import org.apache.http.client.fluent.{Form, Request}
 
object Test {
  def main(args: Array[String]): Unit = {
    val sql = "select pj(vec_dense(features)) as p1 "
 
    val res = Request.Post("http://127.0.0.1:9003/model/predict").bodyForm(Form.form().
      add("sql", sql).
      add("data", s"""[{"features":[ 0.045, 8.8, 1.001, 45.0, 7.0, 170.0, 0.27, 0.45, 0.36, 3.0, 20.7 ]}]""").
      add("dataType", "row")
      .build()).execute().returnContent().asString()
    println(res)
  }
}
```

完成。

