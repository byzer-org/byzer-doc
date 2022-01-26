# Degree of parallelism in Byzer-python

You can directly use Byzer-python to process tables. But when data size is relatively large, we often use `!tableRepartition` to repartition data before processing.

For example:

```sql
!tableRepartition _ -i simpleDataTemp -num 3 -o simpleData;

!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(_id,string),field(x,double),field(y,double))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="simpleData"
and outputTable="output_table"
and code='''
# do something here
''';
```

Here, before processing the table `simpleDataTemp`, we re-divide it into a new table `simpleData` with 3 partitions and then process it by using Python code. There are three main reasons:

#### 1. Resources

Take the partition number 3 above as an example:

- If you do not use Ray, then your cluster needs 3+1 cores for running code. This means that if your partitions are too large and the cluster is busy or has few resources, it may run with errors.


- If you use Ray, you need to ensure that Ray has at least 3 CPU resources. The cluster needs to have at least 3+3 resources, otherwise it may not be able to run tasks correctly.

#### 2. Efficiency

In theory, the larger the partition, the faster the speed. But it will be limited by available resources.

#### 3. Automation

Although you may have 3 partitions set up, the cluster may not run with 3 partitions unless resources are sufficient. Sufficient resources mean that the remaining available resource cores in the cluster are > 3 * 2.

Assuming that your remaining resources are N, if the number of partitions you set is less than N/2, it will run according to your settings; if the number of partitions you set is > N/2, the system will adjust the number of partitions to N/ 2-1.
