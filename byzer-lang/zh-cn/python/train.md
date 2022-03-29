# 模型训练

### 1. 单机训练

> 这里用到 `tensorflow`，运行前需要在 Driver 端安装

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

# 上面导包找不到placeholder模块时，换下面导入方式
import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()

import numpy as np  # Python的一种开源的数值计算扩展
import matplotlib.pyplot as plt  # Python的一种绘图库

np.random.seed(5)  # 设置产生伪随机数的类型
sx = np.linspace(-1, 1, 100)  # 在-1到1之间产生100个等差数列作为图像的横坐标
# 根据y=2*x+1+噪声产生纵坐标
# randn(100)表示从100个样本的标准正态分布中返回一个样本值，0.4为数据抖动幅度
sy = 2 * sx + 1.0 + np.random.randn(100) * 0.4

def model(x, k, b):
    return tf.multiply(k, x) + b

def train():
    # 定义模型中的参数变量，并为其赋初值
    k = tf.Variable(1.0, dtype=tf.float32, name='k')
    b = tf.Variable(0, dtype=tf.float32, name='b')


    # 定义训练数据的占位符，x为特征值，y为标签
    x = tf.placeholder(dtype=tf.float32, name='x')
    y = tf.placeholder(dtype=tf.float32, name='y')
    # 通过模型得出特征值x对应的预测值yp
    yp = model(x, k, b)


    # 训练模型，设置训练参数(迭代次数、学习率)
    train_epoch = 10
    rate = 0.05


    # 定义均方差为损失函数
    loss = tf.reduce_mean(tf.square(y - yp))


    # 定义梯度下降优化器，并传入参数学习率和损失函数
    optimizer = tf.train.GradientDescentOptimizer(rate).minimize(loss)
    ss = tf.Session()
    init = tf.global_variables_initializer()
    ss.run(init)
    
    res = []
    
    # 进行多轮迭代训练，每轮将样本值逐个输入模型，进行梯度下降优化操作得出参数，绘制模型曲线
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

结果展示了每一个 epoch 的斜率（k）和截距（b）的拟合数据
<p align="center">
<img alt="img" src="/byzer-lang/zh-cn/python/image/image-train-result.png"/>
</p>

### 2. 分布式训练

> 运行前需要在 Ray 环境中安装 `tensorflow`

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
    # 上面导包找不到placeholder模块时，换下面导入方式
    import numpy as np  # Python的一种开源的数值计算扩展
    import matplotlib.pyplot as plt  # Python的一种绘图库
    import tensorflow.compat.v1 as tf
    tf.disable_v2_behavior()
    np.random.seed(5)  # 设置产生伪随机数的类型
    sx = np.linspace(-1, 1, 100)  # 在-1到1之间产生100个等差数列作为图像的横坐标
    # 根据y=2*x+1+噪声产生纵坐标
    # randn(100)表示从100个样本的标准正态分布中返回一个样本值，0.4为数据抖动幅度
    sy = 2 * sx + 1.0 + np.random.randn(100) * 0.4
    # 定义模型中的参数变量，并为其赋初值
    k = tf.Variable(1.0, dtype=tf.float32, name='k')
    b = tf.Variable(0, dtype=tf.float32, name='b')
    # 定义训练数据的占位符，x为特征值，y为标签
    x = tf.placeholder(dtype=tf.float32, name='x')
    y = tf.placeholder(dtype=tf.float32, name='y')
    # 通过模型得出特征值x对应的预测值yp
    yp = tf.multiply(k, x) + b
    # 训练模型，设置训练参数(迭代次数、学习率)
    train_epoch = 10
    rate = 0.05
    # 定义均方差为损失函数
    loss = tf.reduce_mean(tf.square(y - yp))
    # 定义梯度下降优化器，并传入参数学习率和损失函数
    optimizer = tf.train.GradientDescentOptimizer(rate).minimize(loss)
    ss = tf.Session()
    init = tf.global_variables_initializer()
    ss.run(init)
    res = []
    # 进行多轮迭代训练，每轮将样本值逐个输入模型，进行梯度下降优化操作得出参数，绘制模型曲线
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
<img alt="image-train-result2" src="/byzer-lang/zh-cn/python/image/image-train-result2.png"/>
</p>
