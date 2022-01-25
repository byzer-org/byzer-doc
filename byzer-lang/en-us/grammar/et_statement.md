# Extension: Train|Run|Predict

Train/Run/Predict are unique statements in Byzer-lang.

## Basic grammar

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




The first line of code means: load the data located in the `/tmp/train` directory, the data format is JSON, and name this table `trainData`,
The second line of code means: provide `trainData` as the dataset, use the algorithm RandomForest, save the model under `/tmp/rf`, and the training parameters are those `fitParam. 0.*` specified.


Among them, `fitParam.0` represents the first group of parameters, users can set N groups incrementally, Byzer-lang will automatically run multiple groups, and finally return the result list.

### Run

The semantics of `run` are data processing, not training.

Here's an example:

```sql
run testData as TableRepartition.`` where partitionNum="5" as newdata;
```

The format is the same as that of `train`. It means: run the `testData` dataset and use ET TableRepartition to repartition it, the processed parameter is `partitionNum="5"`, and the final processed table is called `newdata`.


### Predict

`predict` is related to machine learning predictions. For example, in the train example above, users place the random forest model under the`/tmp/rf` directory. Users can load the model through the `predict` statement and predict the table `testData`.

The sample code is as follows:

```sql
predict testData as RandomForest.`/tmp/rf`;
```


## ET concept

Whether it is Train/Run/Predict, its core is the corresponding algorithm or processing tool, which realizes table input and table output (there may be file output in the middle process) and makes up for the shortcomings of traditional SQL.
In Byzer-lang, they are called `ET`, which is the abbreviation of Estimator/Transformer.

`ET` are all extensible, users can complete their own `ET` components. In the developer guide, there is a more detailed introduction on how to develop your own `ET`.

## View ET available to the system

All available `ET` can be viewed with the following command:

```
!show et;
```

## Query ET with fuzzy matching

To implement fuzzy matching of the name of a `ET`, please use the following methods:

```sql
!show et;
!lastCommand named ets;
select * from ets where name like "%Random%" as output;
```

In the same way, you can also implement fuzzy retrieval of `doc` fields based on keywords.

## View ET sample code and usage documentation

With the name of `ET`, you can view the usage example of the `ET` and other information:

```
!show et/RandomForest;
```

## View ET optional parameters

If you want to see very detailed parameter information, you can use the following command:

```
!show et/params/RandomForest;
```







