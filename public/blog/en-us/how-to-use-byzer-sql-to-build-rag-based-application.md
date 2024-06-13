# How to use Byzer-SQL to build RAG(Retrieval Augmented Generation) based application from scratch

Byzer is an collection of applications based on Ray which works together to serve as LLM infrastructure.

The Byzer have serveral components including:

1. Byzer-LLM: with this component, you can manage your large language model, including deploy, inference, fine-tune, etc.
2. Byzer-Retrieval: this component is a distributed retrieval system which designed as a backend for LLM RAG (Retrieval Augmented Generation). The system supports both BM25 retrieval algorithm and vector retrieval algorithm, you can also use both of them at the same time and get a fusion score for each document.

The Byzer also provides three interfaces to interact with Byzer-LLM and Byzer-retrieval:

1. Python
2. Byzer-SQL,  it's a SQL dialect which can be used to ETL, Data Analysis and AI.
3. Rest API

In this article, we will show you how to use Byzer-SQL and combine these two components to build a RAG based application from scratch.

## Installing

Bare Metal Fully Automated Deployment

> Only supports CentOS 8 / Ubuntu 20.04 / Ubuntu 22.04

### Prerequisites

If your machine is a virtual machine in the cloud, when creating the machine resource, you will usually be asked to set the hostname. It is recommended to just name it byzerllm (make sure it has sudo privileges, which is usually the default). This will save you a lot of trouble and the installation script only needs to be run once.

If using a foreign cloud vendor, there are some default parameters that can be adjusted. The current default parameters are all set for domestic use. Machines on foreign cloud vendors will be much slower. For example, PYPI_MIRROR can be set to default, GIT_MIRROR can be set to github.

### Steps

On the machine, run the following commands:

```shell
git clone https://github.com/allwefantasy/byzer-llm
cd byzer-llm/setup-machine
```

Then switch to the Root user and run the following script:

```shell
ROLE=master ./setup-machine.sh
```

This will complete the byzerllm account creation and login work.

Then switch to the byzerllm account and run again:

```shell

ROLE=master ./setup-machine.sh
```

This will fully install including GPU drivers, cuda toolkit, and the entire Byzer-LLM environment. After that, you can visit http://localhost:9002 to use Byzer-LLM.

Note: If your machine is a virtual machine created from a cloud vendor, you need to use SSH tunnel port mapping to allow local access to the remote machine's 9002/9003 ports. Refer to the code below, just replace local_port with the local port you want, and remote_host with the public IP of the cloud host:

```shell
ssh -L local_port:localhost:9003 byzerllm@remote_host
```

If users want to build a cluster, for worker nodes, you can use the following command, run twice as well:

```shell
ROLE=worker ./setup-machine.sh
```

The Byzer-retrieval component should be configured separately, try to use the following command to install it:

```shell
git clone https://github.com/allwefantasy/byzer-retrieval
mvn clean package -DskipTests
mvn dependency:copy-dependencies -DoutputDirectory=target/dependency
```

Then copy all jars in target/dependency and target/byzer-retrieval-*.jar to the Ray cluster's local disk, suppose the path is `/home/byzerllm/softwares/byzer-retrieval-lib/`.

This is the end of the installation.

If you encounter any problems, feel free to provide feedback and submit a PR.

## About Byzer Notebook

Byzer-LLM provides a notebook interface, which is designed for SQL users. You can use it to write Byzer SQL statements and run them directly. After the installation is complete, you can visit http://127.0.0.1:9002 to use it.

## Create a Table 

The first step is to create a table, which is used to store the data we want to retrieve. 
Before we can create a table, we need to create a retrieval cluster. 

## Create a Retrieval Cluster

In order to create a retrieval cluster, we should setup some environment variables first:

```sql
!byzerllm setup retrieval;
!byzerllm setup "code_search_path=/home/byzerllm/softwares/byzer-retrieval-lib/";
!byzerllm setup "JAVA_HOME=/home/byzerllm/softwares/jdk-21";
!byzerllm setup "PATH=/home/byzerllm/softwares/jdk-21/bin:/home/byzerllm/.rvm/gems/ruby-3.2.2/bin:/home/byzerllm/.rvm/gems/ruby-3.2.2@global/bin:/home/byzerllm/.rvm/rubies/ruby-3.2.2/bin:/home/byzerllm/.rbenv/shims:/home/byzerllm/.rbenv/bin:/home/byzerllm/softwares/byzer-lang-all-in-one-linux-amd64-3.3.0-2.3.7/jdk8/bin:/usr/local/cuda/bin:/usr/local/cuda/bin:/home/byzerllm/.rbenv/shims:/home/byzerllm/.rbenv/bin:/home/byzerllm/miniconda3/envs/byzerllm-dev/bin:/home/byzerllm/miniconda3/condabin:/home/byzerllm/.local/bin:/home/byzerllm/bin:/usr/local/cuda/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/byzerllm/.rvm/bin:/home/byzerllm/.rvm/bin";
```

Try to modify the value according to your environment.

Then we can create a retrieval cluster:

```sql
run command as Retrieval.``
where action="cluster/create"
and `cluster_settings.name`="cluster1"
and `cluster_settings.location`="/tmp/cluster1"
and `cluster_settings.numNodes`="1";
```

The above statement will create a retrieval cluster named `cluster1` with one node. The data of tables in this cluster will be stored in `/tmp/cluster1` directory.

With the cluster created, we can create a table now, try to run the following statement:

```sql
run command as Retrieval.``
where action="table/create/cluster1"
and `table_settings.database`="db1"
and `table_settings.table`="table2"
and `table_settings.location`="/tmp/cluster1"
and `table_settings.schema`="st(field(_id,long),field(name,string),field(content,string,analyze),field(vector,array(float)))";
```

The above statement will create a table named `table2` in database `db1`, and the table has four fields: `_id`, `name`, `content`, `vector`. The `_id` field is a long type, `name` and `content` are string type  and the `content`  should be analyzed, and `vector` is an array of float type.

Notice that we provide a new grammar to define the table schema, it's more readable and easy to use.  More details about this grammar can be found in [here](https://github.com/allwefantasy/byzer-retrieval#table-schema-description)

## Embedding/Analyzed Data

Before we can write the data into the table, we need to preprocess the data first. The data we want to retrieve is a collection of documents, each document has a name and a content field. We need to use a large language model to embed the name field into a vector, and then store the vector into the table. We also need to analyze the content so we can use some keywords to retrieve the document.

The following statement will register m3e model as an Byzer SQL function, and later we will use it to embed the name field into a vector:

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=0.4";
!byzerllm setup "maxConcurrency=2";


run command as LLM.`` where 
action="infer"
and pretrainedModelType="custom/m3e"
and localModelDir="/home/byzerllm/models/m3e-base"
and udfName="emb"
and reconnect="false"
and modelTable="command";
```

The code above will register a function named `emb` which can be used to SQL. The `pretrainedModelType` parameter specifies the model type, and the `localModelDir` parameter specifies the model path. You should download the m3e model from huggingface and put it in the location `/home/byzerllm/models/m3e-base`.

The num_gpus parameter specifies the number of GPUs one model worker will use, and the maxConcurrency parameter specifies how many workers will started. In this case, we will start two workers, and each worker will use 0.4 GPU.

Notice that after this statement is executed, you can also use the `emb` in Python or Rest API. Here is an example how to use it with Rest endpoint `http://127.0.0.1:9003/model/predict`. Try to check the details in [here](https://github.com/allwefantasy/byzer-llm/blob/master/src/byzerllm/apps/client.py#L32C24-L32C24)

The Byzer-SQL also provides a function named `parse` to analyze the content field. 

Here is the statement to embed the name field and analyze the content field:


```sql
set jsondata = '''
{"_id":3, "name":"byzer", "content":"byzer是个好东西"}
{"_id":4, "name":"sql", "content":"byzer RAG召回系统"}
''';

load jsonStr.`jsondata` as newdata;

-- Try to conver the mock data to match the table schema
-- st(field(_id,long),field(name,string),field(content,string,analyze),field(vector,array(float)))

select 
_id,
name, 
mkString(" ",parse(content)) as content, -- content, the field should be analyzed
from_json(llm_response_predict(emb(llm_param(map(
              "embedding", "true",
              "instruction",name
)))),'array<double>') as vector -- name, the field should be embedded and renamed to vector

from newdata as tableData;
```

The above statement will convert the mock data to match the table schema, including embed the name field and analyze the content field. The result will be stored in a variable named `tableData`.


Now we can write the tableData into the table:

```sql

!byzerllm setup retrieval/data;

run command as Retrieval.`` 
where action="table/data"
and clusterName="cluster1"
and database="db1"
and table="table2"
and inputTable="tableData";
```

The above statement will write the data in `tableData` into the table `table2` in database `db1` which is in the cluster `cluster1`.

## Register the retrieval system as UDF

We need to register the retrieval system as an UDF, so we can use it in SQL later. Try to run the following statement:

```sql
!byzerllm setup retrieval;
run command as Retrieval.`` where 
action="register"
and udfName="search";
```
the above statement will register a function named `search` which can be used to SQL.Notice that you can change the `udfName` parameter to any name you want.

Now you can use the `search` function in SQL, try to run the following statement:

```sql
select search(
array(to_json(map(
 "clusterName","cluster1","database","db1", "table","table2", -- specify the target table
 "query.keyword", mkString(" ",parse("系统")), -- specify the query keyword and analyze it
 "query.fields","content", -- which field should be used to retrieve
 "query.vector",llm_response_predict(emb(llm_param(map(
              "embedding", "true",
              "instruction","sql" )))), -- convert the query keyword to vector
 "query.vectorField","vector", -- specify the field name of the vector
 "query.limit","10" -- the result size
)))
)
 as c as contexts;

select c[0] as context from contexts   as new_contexts;

-- the output: [{"name": "sql", "_id": 4, "_score": 0.016666668, "content": "byzer rag 召回 系统"}, {"name": "byzer", "_id": 3, "_score": 0.-- 016393442, "content": "byzer 是 个 好 东西"}]
```

The above output indicates that the retrieval system can do full-text retrieval and vector retrieval at the same time, and rerank the results based on the fusion score.

## Larget Language Model

Now we have a retrieval system, we can use it to retrieve the documents we want and  use the retrieved documents as a context to help the language model to answer the question better.

Try to run the following statement to register the language model as an UDF, just like what we did for embedding model:

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=2";

run command as LLM.`` where 
action="infer"
and localModelDir="/home/byzerllm/models/Baichuan2-13B-Chat/"
and pretrainedModelType="custom/baichuan"
and udfName="baichuan2_13b_chat"
and quatization="8"
and reconnect="false"
and modelTable="command";
```

This will register a function named `baichuan2_13b_chat` which can be used to answer questions. The `localModelDir` parameter specifies the model path, and the `pretrainedModelType` parameter specifies the model type. You should download the Baichuan2-13B-Chat model and put it in the location `/home/byzerllm/models/Baichuan2-13B-Chat/`.

The num_gpus parameter specifies the number of GPUs one model worker will use. In this case, we will start 1 worker(by default), and each worker will use 2 GPUs.

## Answer the question

Now we can use the large language model to answer the question, try to run the following statement:

```sql
select 
llm_response_predict(baichuan2_13b_chat(llm_param(map(
              "user_role","User",
              "assistant_role","Assistant",
              "system_msg",'You are a helpful assistant. Think it over and answer the user question correctly.',
              "instruction",llm_prompt('
请参考一下的json 格式文档回答我的问题：{0} 

我的问题是: Byzer 好么？
',array(context))

))))

 as q from new_contexts as q1;

 -- the output: Byzer是一个好东西。从给出的数据可以看出，关于Byzer的评分很高，因此可以得出结论：Byzer是一个好的产品。
```

The above statement will use the retrieved documents as a context , replace the `{0}` in the prompt, and then use the language model to answer the question.

## How to use the retrieval system and the large language model in your application

Here we will show you how to intergrate the retrieval system and the language model together in your application with Rest API.

Run the following statement to start a Rest endpoint for the retrieval system:

```python

import ray

code_search_path=["/home/winubuntu/softwares/byzer-retrieval-lib/"]
env_vars = {"JAVA_HOME": "/home/winubuntu/softwares/jdk-21",
            "PATH":"/home/winubuntu/softwares/jdk-21/bin:/home/winubuntu/.cargo/bin:/usr/local/cuda/bin:/home/winubuntu/softwares/byzer-lang-all-in-one-linux-amd64-3.1.1-2.3.2/jdk8/bin:/home/winubuntu/miniconda3/envs/byzerllm-dev/bin:/home/winubuntu/miniconda3/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"}

ray.init(address="auto",namespace="default",
                 job_config=ray.job_config.JobConfig(code_search_path=code_search_path,
                                                      runtime_env={"env_vars": env_vars}),ignore_reinit_error=True
                 )
from byzerllm.utils.retrieval.rest import deploy_retrieval_rest_server
deploy_retrieval_rest_server(host="0.0.0.0",route_prefix="/retrieval")
```

Now you can use the following python code to search the documents:

```python
import requests
import json
from byzerllm.utils.retrieval.rest import SearchQueryParam


r = requests.post("http://127.0.0.1:8000/retrieval/table/search",json={
    "cluster_name":"cluster1", 
    "database":"db1", 
    "table":"table2", 
    "query":SearchQueryParam(keyword="byzer",fields=["content"],
                                vector=[],vectorField=None,
                                limit=10).dict()
})

response_text = r.text
json.loads(response_text)

# The output:
# [{'name': 'sql',
#   '_id': 4,
#   '_score': 0.08681979,
#   'content': 'byzer   rag 召回 系统'},
#  {'name': 'byzer',
#   '_id': 3,
#   '_score': 0.07927025,
#   'content': 'byzer 是 个 好 东西'}]
```

The language model also provides a Rest endpoint without any manual configuration. Try to run the following statement to access the Rest endpoint:

```python

from byzerllm.apps.client import ByzerLLMClient,ClientParams

client = ByzerLLMClient(url='http://127.0.0.1:9003/model/predict',params=ClientParams(
    owner="william",
    llm_embedding_func = "emb" ,
    llm_chat_func = "baichuan2_13b_chat"    
))


r = client.chat(f"请参考一下的json 格式文档回答我的问题：{response_text} \n 我的问题是: Byzer 好么？",
            history=[],extra_query={
    "user_role":"User",
    "assistant_role":"Assistant",
    "system_msg":'You are a helpful assistant. Think it over and answer the user question correctly.'
})

r
```

The code above use the `ByzerLLMClient` to access the Rest endpoint, and the `chat` method will use the language model to answer the question.


## Avoid the context take too much tokens

If the context take too much tokens, you can also use the language model to summarize every document, try to run the following statement:

```sql
 -- use the language model to summarize the context with specified length
 
select explode(from_json(c[0],'array<struct<_id:double,name:string,content:string,_score:double>>')) as c
from contexts as temp_contexts;
 
select c.* from temp_contexts as temp_contexts2;

select llm_response_predict(
baichuan2_13b_chat(llm_param(
map(
              "user_role","User",
              "assistant_role","Assistant",
              "system_msg",'You are a helpful assistant. Think it over and answer the user question correctly.',
              "instruction",llm_prompt(
               '请对下面的内容做精简，简化成大概100字左右。\n {0}',array(content)
              )
)))) as content,_id,name,_score from temp_contexts2 as final_contexts;

-- convert the result to json format again

select to_json(collect_list(struct(*))) as c from final_contexts as new_contexts;
```


