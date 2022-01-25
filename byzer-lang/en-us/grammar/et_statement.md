# Estimator/Transformer: Train|Run|Predict

Train/Run/Predict are unique Byzer statements that support extension.

## Basic syntax

### Train

`train`  is training, and it is mainly used when training the algorithm. A typical example is as follows:

```sql

load json.`/tmp/train` as trainData;

train trainData as RandomForest.`/tmp/rf` where
keepVersion="true"
and fitParam.0.featuresCol="content"
and fitParam.0.labelCol="label"
and fitParam.0.maxDepth="4"
and fitParam.0.checkpointInterval="100"
and fitParam.0.numTrees="4"
;
```



The first line of code means to load the data located in the `/tmp/train` directory, the data format is JSON, and will name this table as `trainData`,
The second line of code means to use  `trainData` as the dataset, RandomForest as the algorithm, and save the model under `/tmp/rf`, and the training parameters are those specified with `fitParam. 0.*`.


Among them, `fitParam.0` represents the first group of parameters, users can add more groups of parameters, Byzer-lang will automatically run these groups, and return the result list.

### Run

The semantics of `run` are data processing, not training.

Here's an example:

```sql
run testData as TableRepartition.`` where partitionNum="5" as newdata;
```

The format is the same as that of `train`. It means to run the `testData` dataset and use `ET TableRepartition` to do the repartition, the processed parameter is `partitionNum="5"`, and the processed table is called `newdata`.


### Predict

`predict` is related to machine learning predictions. For example, in the train example above, users place the random forest model under the`/tmp/rf` directory. Users can load the model through the `predict` statement to predict the table `testData`.

The sample code is as follows:

```sql
predict testData as RandomForest.`/tmp/rf`;
```


## Estimator/Transformer

Whether it is Train/Run/Predict, the kernel part is to realize **table in and table out** (there may be some process files) with the corresponding algorithm or processing tool, to rectify the shortcomings of traditional SQL.
In Byzer-Lang, they are called Estimator/Transformer (ET). 

ET are all extensible, users can compile their own ET components. In Developer Guide, you can find more information on how to develop your own ET.

## Check available ETs

All available ETs can be viewed with the following command:

```
!show et;
```

## Query ET with fuzzy matching

Byzer also supports approximate string matching for ETs, you can use the following commands:

```sql
!show et;
!lastCommand named ets;
select * from ets where name like "%Random%" as output;
```

Similarly, you can also implement fuzzy retrieval of `doc` fields with keywords.

## Check ET code sample and documentation

After you obtain the  name of the ET, you can check the usage example and other information with the code below:

```
!show et/RandomForest;
```

## Check optional ET parameters

To check the detailed ET parameters,  you can use the following command:

```
!show et/params/RandomForest;
```







