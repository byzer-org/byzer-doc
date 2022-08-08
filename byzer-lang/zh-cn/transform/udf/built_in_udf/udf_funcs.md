# 常用函数

### array_concat
array_concat(array(a1, a2, ..., an)) - 多个字符串数组拼接成一个数组，并且展开

**例子**：
```
> SELECT array_number_concat(array(array("a","b"), array("c","d")) AS arr;
[ "a", "b", "c", "d" ]
```

### array_intersect
array_intersect(a1, a2) - 返回数组的交集

**例子**：
```
> SELECT array_intersect(array("a","b","c"),array("a","d","e")) AS ai;
```

### array_index
array_index(array, element) - 返回数组中元素的下标

**例子**：
```
> SELECT array_index(array("a","b","c","d","e"),"b") AS index;
1
```

### array_number_concat
array_number_concat(array(a1, a2, ..., an)) - 多个数字数组拼接成一个数组，并且展开

**例子**：
```
> SELECT array_number_concat(array(array(1,2), array(3,4)) AS arr;
[ 1, 2, 3, 4 ]
```

### array_number_to_string
array_number_to_string(array) - 将数组内的元素类型转换为 string

**例子**：
```
> SELECT array_number_to_string(array(1,2,3,4)) AS arr;
[ "1", "2", "3", "4" ]
```

### array_onehot
array_onehot(array, colNums) - 返回 matrix 结构的 one hot 编码，编码是按列存储的

**参数**：
- array：希望进行 one hot 编码的分类值，必须是 int 类型。另外，分类值的数量即为矩阵的行数
- colNums：分类的最大数量，即是矩阵列的数量

**例子**：
```
> SELECT array_onehot(array(1,2,3),4) AS ma1;
{ "type": 1, "numRows": 3, "numCols": 4, "values": [ 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 ], "isTransposed": false }

> SELECT array_onehot(array(1,4),12) AS ma2;
 "type": 1, "numRows": 2, "numCols": 12, "values": [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], "isTransposed": false }
```

### array_slice
array_slice(array, from, to) - 返回数组中，从下标 from 到下标 to 的子数组。当 to = -1 时，取到数组结尾

**例子**：
```
> SELECT array_slice(array("a","b","c","d","e"),3,-1) AS sub;
[ "d", "e" ]
```

### array_string_to_double
array_number_to_string(array) - 将数组内的元素类型转换为 double

**例子**：
```
> SELECT array_string_to_double(array("1.1","2.2","3.3","4.4")) AS arr;
[ 1.1, 2.2, 3.3, 4.4 ]
```

### array_string_to_float
array_string_to_float(array) - 将数组内的元素类型转换为 float

**例子**：
```
> SELECT array_string_to_float(array("1.1","2.2","3.3","4.4")) AS arr;
[ 1.1, 2.2, 3.3, 4.4 ]
```

### array_string_to_int
array_string_to_int(array) - 将数组内的元素类型转换为 int

**例子**：
```
> SELECT array_string_to_int(array("1","2","3","4")) AS arr;
[ 1, 2, 3, 4 ]
```

### matrix_array
matrix_array(matrix) - 将矩阵转为二维数组

**例子**：
```
> SELECT matrix_array(array_onehot(array(1,2),4)) AS ma;
[ [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ] ]
```

### matrix_dense
matrix_dense(array(a1, a2, ..., an)) - 生成一个紧凑矩阵

**例子**：
```
> SELECT matrix_dense(array(array(1.0, 2.0, 3.0), array(2.0, 3.0, 4.0))) AS md;
{ "type": 1, "numRows": 2, "numCols": 3, "values": [ 1, 2, 2, 3, 3, 4 ], "isTransposed": false }
```
### matrix_sum
matrix_sum(matrix) - 对数组的列值进行求和

**例子**：
```
> SELECT matrix_sum(matrix_dense(array(array(1.0, 2.0, 3.0), array(2.0, 3.0, 4.0))), 0) AS ms;
{ "type": 1, "values": [ 3, 5, 7 ] }
```

### vec_argmax
vec_argmax(vector) - 找到向量里面最大值所在的位置（下标从 0 开始）

**例子**：
```
> SELECT vec_argmax(vec_dense(array(1.0,2.0,7.0))) AS index;
2
```

### vec_dense
vec(array) - 生成一个紧凑向量

**例子**：
```
> SELECT vec_dense(array(1.0,2.0,7.0)) as vec;
{ "type": 1, "values": [ 1, 2, 7 ] }
```
### vec_sparse
vec_sparse(size , map(k1,v1,k2,v2)) - 生成一个稀疏向量

**参数**：
- size：向量的长度
- map：稀疏向量的下标以及数值，注意下标从 0 开始 

**例子**：
```
> SELECT vec_sparse(3, map(1,2,2,4)) AS vs;
{ "type": 0, "size": 3, "indices": [ 1, 2 ], "values": [ 2, 4 ] }
```
### vec_concat
vec_concat(array(v1,v2, ..., vn)) - 拼接多个向量成为一个向量

**例子**：
```
> SELECT vec_concat(array(vec_dense(array(1.0,2.0)),vec_dense(array(3.0,4.0)))) AS vc;
{ "type": 1, "values": [ 1, 2, 3, 4 ] }
```

### vec_cosine
vec_cosine(v1, v2) - 计算 consine 向量夹角

**例子**：
```
> SELECT vec_cosine(vec_dense(array(1.0,2.0)),vec_dense(array(1.0,1.0))) AS vc;
0.9486832980505138
```
### vec_slice
vec_slice(vector, indices) - 根据下标获取子 vector 

**例子**：
```
> SELECT vec_slice(vec_dense(array(1.0,2.0,3.0,4.0)),array(0,1,2)) AS vs;
{ "type": 1, "values": [ 1, 2, 3 ] }
```
### vec_array
vec_array(vector) - 将向量转化为数组

**例子**：
```
> SELECT vec_array(vec_dense(array(1.0,2.0))) as va;
[ 1, 2 ]
```
### vec_mk_string
vec_mk_string(splitter, vector) - 使用 splitter 拼接向量，并返回字符串

**例子**：
```
> SELECT vec_mk_string("*",vec_dense(array(1.0,2.0))) AS vms;
1.0*2.0
```
### vec_wise_mul
vec_wise_mul(v1, v2) - 计算向量 v1, v2 对应矢量值的乘积，返回结果向量

**例子**：
```
> SELECT vec_dense(array(2.5,2.0,1.0)) AS v1, vec_dense(array(3.0,2.0,1.0)) AS v2 AS data1;
> SELECT vec_wise_mul(v1, v2) AS vwm FROM data1 AS data2;
{ "type": 1, "values": [ 7.5, 4, 1 ] }
```
### vec_wise_add
vec_wise_add(v1, v2) - 计算向量 v1, v2 对应矢量值的和，返回结果向量

**例子**：
```
> SELECT vec_dense(array(2.5,2.0,1.0)) AS v1, vec_dense(array(3.0,2.0,1.0)) AS v2 AS data1;
> SELECT vec_wise_add(v1, v2) AS vwm FROM data1 AS data2;
{ "type": 1, "values": [ 5.5, 4, 2 ] }
```
### vec_wise_dif
vec_wise_dif(v1, v2) - 计算向量 v1, v2 对应矢量值的差，返回结果向量

**例子**：
```
> SELECT vec_dense(array(2.5,3.0,1.0)) AS v1, vec_dense(array(3.0,2.0,1.0)) AS v2 AS data1;
> SELECT vec_wise_dif(v1, v2) AS vwm FROM data1 AS data2;
{ "type": 1, "values": [ -0.5, 1, 0 ] }
```

### vec_wise_mod
vec_wise_mod(v1, v2) - 向量 v1 的矢量值对 v2 的矢量值取模 

**例子**：
```
> SELECT vec_dense(array(11,7,3)) AS v1, vec_dense(array(2,3,4)) AS v2 AS data1;
> SELECT vec_wise_mod(v1, v2) AS vwm FROM data1 AS data2;
{ "type": 1, "values": [ 1, 1, 3 ] }
```

### vec_inplace_add
vec_inplace_add(vector, addend) - vector 每个矢量值加上 addend，返回结果向量

**例子**：
```
> SELECT vec_dense(array(2.5, 2.0, 1.0)) AS vd AS data1;
> SELECT vec_inplace_add(vd, 4.4) AS via FROM data1 AS data2;
{ "type": 1, "values": [ 6.9, 6.4, 5.4 ] }
```
### vec_inplace_ew_mul
vec_inplace_ew_mul(vector, multiplier) - vector 每个矢量值乘 multiplier，返回结果向量

**例子**：
```
> SELECT vec_dense(array(2.5, 2.0, 1.0)) AS vd AS data1;
> SELECT vec_inplace_ew_mul(vd, 4.4) AS niem FROM data1 AS data2;
{ "type": 1, "values": [ 11, 8.8, 4.4 ] }
```
### vec_ceil
vec_ceil(vector) - 将 vector 矢量值向上取整

**例子**：
```
> SELECT vec_dense(array(2.5, 2.4, 1.6)) AS vd AS data1;
> SELECT vec_ceil(vd) AS vc FROM data1 AS data2;
{ "type": 1, "values": [ 3, 3, 2 ] }
```
### vec_floor
vec_floor(vector) - 将 vector 矢量值向上取整

**例子**：
```
> SELECT vec_dense(array(2.5, 2.4, 1.6)) AS vd AS data1;
> SELECT vec_floor(vd) AS vc FROM data1 AS data2;
{ "type": 1, "values": [ 2, 2, 1 ] }
```
### vec_mean
vec_mean(vector) - 获取向量矢量值的平均值

**例子**：
```
> SELECT vec_mean(vec_dense(array(1.0,2.0,7.0,2.0))) AS vm;
3
```
### vec_stddev
vec_stddev(vector) - 获取向量标准差

**例子**：
```
> SELECT vec_stddev(vec_dense(array(3.0, 4.0, 5.0))) AS vs;
1
```
### ngram
ngram(array, size) - 以 `size` 为窗口大小，返回滑动窗口的序列

**例子**：
```
> SELECT ngram(array("a","b","c","d","e"),3) AS ngr;
[ "a b c", "b c d", "c d e" ]
```

### keepChinese
keepChinese(str, keepPunctuation, include) - 对文本字段做处理，只保留中文字符

**参数**：
- str：待处理字符串
- keepPunctuation：是否保留标点符号 true/false
- include：指定保留字符，保留字符会出现在结果集中

**例子**：
```
> SET query = "你◣◢︼【】┅┇☽☾✚〓▂▃▄▅▆▇█▉▊▋▌▍▎▏↔↕☽☾の·▸◂▴▾┈┊好◣◢︼【】┅┇☽☾✚〓▂▃▄▅▆▇█▉▊▋▌▍▎▏↔↕☽☾の·▸◂▴▾┈┊啊，..。，！?katty";
> SELECT keepChinese("${query}",false,array()) AS ch;
结果: 你好啊
```

### sleep
sleep() - 休眠函数，单位为ms，无返回

**例子**：
```
> SELETC sleep(1000) AS s1;
```
### uuid
uuid() - 返回一个唯一的字符串，去掉了"-"

**例子**：
```
> SELECT uuid() AS u1;
b4fd697ce5dc4ff48694a5e2e1804d81
```