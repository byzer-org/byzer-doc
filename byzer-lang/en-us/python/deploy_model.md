# Model deployment

In Byzer, we can register a Byzer-python-trained AI model as a UDF in the same way as the built-in algorithm, so that models can be applied to batches, streams, and web services. Next we will show Byzer-python's whole process demo based on Ray, from model training to model deployment.

#### Data preparation

First, prepare `mnist` dataset (you need to install `tensorflow` and `keras`):

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(image,array(long)),field(label,long),field(tag,string))";
!python conf "runIn=driver";
!python conf "dataMode=model";

run command as Ray.`` where
inputTable="command"
and outputTable="mnist_data"
and code='''
from pyjava.api.mlsql import RayContext, PythonContext
from keras.datasets import mnist

ray_context = RayContext.connect(globals(), None)

(x_train, y_train),(x_test, y_test) = mnist.load_data()

train_images = x_train.reshape((x_train.shape[0], 28 * 28))
test_images = x_test.reshape((x_test.shape[0], 28 * 28))

train_data = [{"image": image.tolist(), "label": int(label), "tag": "train"} for (image, label) in zip(train_images, y_train)]
test_data = [{"image": image.tolist(), "label": int(label), "tag": "test"} for (image, label) in zip(test_images, y_test)]
context.build_result(train_data + test_data)
''';

save overwrite mnist_data as delta.`ai_datasets.mnist`;
```

The above Byzer-python script gets  `mnist` dataset that comes with keras, then saves the dataset to the data lake.

#### Model training

Then train with the test data `minist`. The following is the model training code:

```sql
-- get training dataset
load delta.`ai_datasets.mnist` as mnist_data;
select image, label from mnist_data where tag="train" as mnist_train_data;

!python env "PYTHON_ENV=source activate dev";
!python conf "schema=file";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="mnist_train_data"
and outputTable="mnist_model"
and code='''
import ray
import os
import tensorflow as tf
from pyjava.api.mlsql import RayContext
from pyjava.storage import streaming_tar
import numpy as np


ray_context = RayContext.connect(globals(),"10.1.3.197:10001")
data_servers = ray_context.data_servers()

train_dataset = [item for item in RayContext.collect_from(data_servers)]

x_train = np.array([np.array(item["image"]) for item in train_dataset])
y_train = np.array([item["label"] for item in train_dataset])

x_train = x_train.reshape((len(x_train),28, 28))

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=5)

model_path = os.path.join("tmp","minist_model")
model.save(model_path)
model_binary = [item for item in streaming_tar.build_rows_from_file(model_path)]

ray_context.build_result(model_binary)
''';
```

Finally, save the model to the data lake:

```sql
save overwrite mnist_model as delta.`ai_model.mnist_model`;
```

#### Register the model as a UDF

After training the model, we can use Byzer-lang's Register syntax to register the model as a Ray-based service. The following is the code for model registration:

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(content,string))";
!python conf "mode=model";
!python conf "runIn=driver";
!python conf "rayAddress=10.1.3.197:10001";


-- Load the previously trained tf model
load delta.`ai_model.mnist_model` as mnist_model;

-- Register the model as a udf
register Ray.`mnist_model` as model_predict where
maxConcurrency="8"
and debugMode="true"
and registerCode='''

import ray
import numpy as np
from pyjava.api.mlsql import RayContext
from pyjava.udf import UDFMaster,UDFWorker,UDFBuilder,UDFBuildInFunc

ray_context = RayContext.connect(globals(), context.conf["rayAddress"])

# predict function
def predict_func(model, v):
    test_images = np.array([v])
    predictions = model.predict(test_images.reshape((1,28*28)))
    return {"value":[[float(np.argmax(item)) for item in predictions]]}

# Submit the predictive function to ray_context
UDFBuilder.build(ray_context, UDFBuildInFunc.init_tf, predict_func)

''' and
predictCode='''

import ray
from pyjava.api.mlsql import RayContext
from pyjava.udf import UDFMaster,UDFWorker,UDFBuilder,UDFBuildInFunc

ray_context = RayContext.connect(globals(), context.conf["rayAddress"])

#
UDFBuilder.apply(ray_context)

''';
```

> Here `UDFBuilder` and `UDFBuildInFunc` are both advanced API provided by Pyjava to register Python script as UDF.

#### Use the model to make predictions

Byzer provides SQL-like statements for batch query. Load your data set and then predict data.

```sql
load delta.`ai_datasets.mnist` as mnist_data;
select cast(image as array<double>) as image, label as label from mnist_data where tag = "test" limit 100 as mnist_test_data;
select model_predict(array(image))[0][0] as predicted, label as label from mnist_test_data as output;
```

<p align="center">
    <img src="/byzer-lang/en-us/python/image/image-deploy.png" alt="name"  width="800"/>
</p>
Afterwards, you can directly call Byzer-engine's Rest API and use the registered UDF to predict your dataset.
