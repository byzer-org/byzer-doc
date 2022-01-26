# Model training

## Stand-alone training

> `tensorflow` is used here which needs to be installed on Driver before running

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(epoch,string),field(k,string), field(b,string))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="command"
and outputTable="result"
and code='''
import ray
from pyjava import rayfix
from pyjava.api.mlsql import RayContext,PythonContext
# import tensorflow as tf

ray_context = RayContext.connect(globals(), None)

# When you cannot find the placeholder module by using the above method of importing packages, use the import method below
import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()

import numpy as np # An open source numerical computing extension for Python
import matplotlib.pyplot as plt # A drawing library for Python

np.random.seed(5) # Set the type of generating pseudo-random number
sx = np.linspace(-1, 1, 100) # Generate 100 arithmetic progressions between -1 and 1 as the abscissa of the image
# Generate ordinate according to y=2*x+1+ noise
# randn(100) means to return a sample value from the standard normal distribution of 100 samples and 0.4 is the data fluctuation range.
sy = 2 * sx + 1.0 + np.random.randn(100) * 0.4

def model(x, k, b):
    return tf.multiply(k, x) + b

def train():
    # Define parameter variables in the model and assign initial values ​​to them
    k = tf.Variable(1.0, dtype=tf.float32, name='k')
    b = tf.Variable(0, dtype=tf.float32, name='b')


    # Define placeholders of training data, x is the eigenvalue and y is the label
    x = tf.placeholder(dtype=tf.float32, name='x')
    y = tf.placeholder(dtype=tf.float32, name='y')
    # Get the predicted value yp corresponding to the eigenvalue x through the model
    yp = model(x, k, b)


    # Train the model and set training parameters (number of iterations, learning rate)
    train_epoch = 10
    rate = 0.05


    # Define mean square error as loss function
    loss = tf.reduce_mean(tf.square(y - yp))


    # Define the gradient descent optimizer and import parameters: learning rate and loss function
    optimizer = tf.train.GradientDescentOptimizer(rate).minimize(loss)
    ss = tf.Session()
    init = tf.global_variables_initializer()
    ss.run(init)

    res = []

    # Perform multiple rounds of iterative training, input each sample value ​​into the model in each round, perform the gradient descent optimization operation to get parameters and draw the model curve.
    for _ in range(train_epoch):
        for x1, y1 in zip(sx, sy):
            ss.run([optimizer, loss], feed_dict={x: x1, y: y1})
        tmp_k = k.eval(session=ss)
        tmp_b = b.eval(session=ss)
        res.append((str(_), str(tmp_k), str(tmp_b)))
    return res


res = train()
res = [{'epoch':item[0], 'k':item[1], 'b':item[2]} for item in res]
context.build_result(res)
''';
```

The results show the fitted data of the slope (k) and intercept (b) for each epoch
<p align="center">
<img alt="img" src="/byzer-lang/en-us/python/image/image-train-result.png"/>
</p>


## Distributed training

> `tensorflow` needs to be installed in Ray environment before running

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(epoch,string),field(k,string), field(b,string))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="command"
and outputTable="result"
and code='''
import ray
from pyjava import rayfix
from pyjava.api.mlsql import RayContext,PythonContext
# import tensorflow as tf
ray_context = RayContext.connect(globals(), url="127.0.0.1:10001")

@ray.remote
@rayfix.last
def train(servers):
    # When you cannot find the placeholder module by using the above method of importing packages, use the import method below
    import numpy as np # An open source numerical computing extension for Python
    import matplotlib.pyplot as plt # A drawing library for Python
    import tensorflow.compat.v1 as tf
    tf.disable_v2_behavior()
    np.random.seed(5) # Set the type of generating pseudo-random number
    sx = np.linspace(-1, 1, 100) # Generate 100 arithmetic progressions between -1 and 1 as the abscissa of the image
    # Generate ordinate according to y=2*x+1+ noise
    # randn(100) means to return a sample value from the standard normal distribution of 100 samples and 0.4 is the data fluctuation range.
    sy = 2 * sx + 1.0 + np.random.randn(100) * 0.4
    # Define parameter variables in the model and assign initial values ​​to them
    k = tf.Variable(1.0, dtype=tf.float32, name='k')
    b = tf.Variable(0, dtype=tf.float32, name='b')
    # Define placeholders of training data, x is the eigenvalue and y is the label
    x = tf.placeholder(dtype=tf.float32, name='x')
    y = tf.placeholder(dtype=tf.float32, name='y')
    # Get the predicted value yp corresponding to the eigenvalue x through the model
    yp = tf.multiply(k, x) + b
    # Train the model and set training parameters (number of iterations, learning rate)
    train_epoch = 10
    rate = 0.05
    # Define mean square error as loss function
    loss = tf.reduce_mean(tf.square(y - yp))
    # Define the gradient descent optimizer and import parameters: learning rate and loss function
    optimizer = tf.train.GradientDescentOptimizer(rate).minimize(loss)
    ss = tf.Session()
    init = tf.global_variables_initializer()
    ss.run(init)
    res = []
    # Perform multiple rounds of iterative training, input each sample value ​​into the model in each round, perform the gradient descent optimization operation to get parameters and draw the model curve.
    for _ in range(train_epoch):
        for x1, y1 in zip(sx, sy):
            ss.run([optimizer, loss], feed_dict={x: x1, y: y1})
        tmp_k = k.eval(session=ss)
        tmp_b = b.eval(session=ss)
        res.append((str(_), str(tmp_k), str(tmp_b)))
    return res


data_servers = ray_context.data_servers()
res =  ray.get(train.remote(data_servers))
res = [{'epoch':item[0], 'k':item[1], 'b':item[2]} for item in res]
context.build_result(res)
''';
```

<p align="center">
<img alt="image-train-result2" src="/byzer-lang/en-us/python/image/image-train-result2.png"/>
</p>
