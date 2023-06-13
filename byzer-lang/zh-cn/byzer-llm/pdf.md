# Byzer-LLM 如何处理PDF

本文内容同时适合其他非结构化文本，诸如 Word,Markdown等。


首先我们可以以二进制文本方式加载 PDF:

```sql
load binaryFile.`/tmp/upload/**/*.pdf` as pdfs_temp;
select content from pdfs_temp as pdfs;
!emptyTable;
```

这样会递归加载所有 PDF 文件。注意，我们最后使用 !emptyTable 是希望不要有任何输出。否则比如一个 100m的PDF文件如果输出到
Notebook里会直接导致链接断开。

接着我们要抽取出每个PDF文件的文本,这里使用 Python 代码抽取。

```sql
!python conf "rayAddress=127.0.0.1:10001";
!python conf "pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python";
!python conf "dataMode=data";
!python conf "runIn=driver";
!python conf "num_gpus=0";
!python conf "schema=st(field(content,string))";



run command as Ray.`` 
where 
inputTable="pdfs"
and outputTable="pdfs_text"
and code='''
import ray
from langchain.document_loaders import PyPDFLoader
from pyjava.api.mlsql import RayContext,PythonContext
import io
import os
import uuid

ray_context = RayContext.connect(globals(),"127.0.0.1:10001")

def process_pdf(row):
    pdf_file = io.BytesIO(row["content"])
    
    temp = os.path.join("/tmp",str(uuid.uuid4()))

    with open(temp, 'wb') as f:
        f.write(pdf_file.read())
    
    loader = PyPDFLoader(temp)
    docs = loader.load()
    os.remove(temp)
    
    content = "\n".join([doc.page_content for doc in docs])
    row["content"]=content
    return row
    

ray_context.foreach(process_pdf)
''';

save overwrite pdfs_text as parquet.`/tmp/pdfs_texts`;
```

为了方便调试 Python 代码，用户有两个选择，一个是在 Jupyter中写好，然后黏贴过来。第二种是使用 Byzer-notebook 提供的语法糖来熟悉。可以参考文档 [Byzer-python 工具语法糖](https://docs.byzer.org/#/byzer-lang/zh-cn/python/suger)。比如上面的代码其实在 Byzer-notebook 也可以写成这样：

```python
#%python
#%input=pdfs
#%output=pdfs_text
#%schema=st(field(content,string))
#%runIn=driver
#%dataMode=data
#%cache=true
#%env=source /home/winubuntu/miniconda3/bin/activate byzerllm-desktop
#%pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python

import ray
from langchain.document_loaders import PyPDFLoader
from pyjava.api.mlsql import RayContext,PythonContext
import io
import os
import uuid

ray_context = RayContext.connect(globals(),"127.0.0.1:10001")

def process_pdf(row):
    pdf_file = io.BytesIO(row["content"])
    
    temp = os.path.join("/tmp",str(uuid.uuid4()))

    with open(temp, 'wb') as f:
        f.write(pdf_file.read())
    
    loader = PyPDFLoader(temp)
    docs = loader.load()
    os.remove(temp)
    
    content = "\n".join([doc.page_content for doc in docs])
    row["content"]=content
    return row
    

ray_context.foreach(process_pdf)
```

缺点是没办法输出空表，如果某个PDF特别大，输出可能会导致 Byzer Notebook 出问题。而前面的方案我们是直接保存数据到文件，不会有问题。

现在可以加载PDF文本数据了，得到新表：

```sql
load  parquet.`/tmp/pdfs_texts` as pdfs_texts_sources;
!emptyTable;
```

启动一个 chatglm6b 模型作为 embedding服务。

```sql
!python conf "rayAddress=127.0.0.1:10001";
!python conf "pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python";
!python conf "dataMode=model";
!python conf "runIn=driver";

!python conf "num_gpus=1";
!python conf "maxConcurrency=1";
!python conf "standalone=true";
!python conf "owner=william";
!python conf "schema=file";

run command as LLM.`` where 
action="infer"
and pretrainedModelType="chatglm"
and localPathPrefix="/my8t/byzerllm/jobs"
and localModelDir="/home/winubuntu/projects/glm-model/chatglm-6b-model"
and modelWaitServerReadyTimeout="300"
and reconnect="false"
and udfName="chatglm_chat"
and modelTable="command";
```

对PDF文本进行知识库的构建：

```sql
!python conf "rayAddress=127.0.0.1:10001";
!python conf "pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python";
!python conf "dataMode=model";
!python conf "runIn=driver";

!python conf "num_gpus=0";
!python conf "maxConcurrency=1";
!python conf "standalone=true";
!python conf "owner=william";
!python conf "schema=file";


select "test" as source, content as page_content from pdfs_texts_sources as newData2;

-- 这里可以控制数据分片并行度 ，详细参看知识库相关文档
run newData2 as TableRepartition.`` where partitionNum="1" as newData3;

-- 使用业务数据构建向量数据库
run command as LLMQABuilder.`` 
where inputTable="newData3" 
and batchSize="0"
and embeddingFunc="chatglm_chat"
and chatFunc="chatglm_chat"
and localPathPrefix="/my8t/byzerllm/jobs/pdfs"
and chunkSize="300"
and outputTable="movies_vec_store_test";

-- 保存到数据湖
save overwrite movies_vec_store_test as delta.`ai_model.movies_vec_store_test`;
```

