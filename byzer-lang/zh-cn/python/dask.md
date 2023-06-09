# SQL表转化为分布式Pandas

运行本示例之前，需要安装dask:

```
pip install dask==2022.10.1
```

我们先通过 Byzer 语句加载一个数据集：

```sql
load csv.`/tmp/upload/iris-test.csv` where header="true" and inferSchema="true" 
as iris;
```

接着我们在 Byzer-python中将该表转化为 分布式 Pandas  API：

```python
#%python
#%input=iris
#%output=iris_scale1
#%schema=st(field(species,string),field(mean,double))
#%runIn=driver
#%dataMode=model
#%cache=true
#%pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python
#%env=source /home/winubuntu/miniconda3/bin/activate byzerllm-desktop

from pyjava.api.mlsql import RayContext,PythonContext
import pandas as pd

context:PythonContext = context

ray_context = RayContext.connect(globals(),"127.0.0.1:10001")
# 把SQL表格数据转换为分布式 DataFrame
df = ray_context.to_dataset().to_dask()

print(df.head(10))

df2 = df.groupby("species").sepal_length.mean().compute()
df3 =  pd.DataFrame({"species":df2.index,"mean":df2.to_list()})

# 输出表格数据,供后续 SQL 使用
ray_context.build_result_from_dataframe(df3)
```

最后输出的结果可以继续在SQL中处理：


```sql
select * from iris_scale1 as output;
```