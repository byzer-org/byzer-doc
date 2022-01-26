# Build-in macro functions


Byzer-Lang has a lot of built-in macro functions, which can help users to have better interaction.

- `!show`

Use this command to check system information.

Check the current engine version:

```
!show version;
```

Show all subcommands of `show`:

```
!show commands;
```

List all tables:

```
!show tables;
```

List all tables from specified `db`

```
!show tables from [DB name];
```

List all currently running tasks:


```
!show jobs;
```

List task related information :

```
!show "jobs/v2/[jobGroupId]";
!show "jobs/[jobGroupId]";
!show "jobs/get/[jobGroupId]";
```

The contents returned by the three command are different, you can try and see the difference. 

List all available data sources:

```
!show datasources;
```

List all REST interfaces:

```
!show "api/list";
```

List all supported configuration parameters (for a complete list, see the documentation):

```
!show "conf/list";
```

View log:

```
!show "log/[file offset]";
```

List the parameters of the data source:

```
!show "datasources/params/[datasource name]";
```

List current system resources:

```
!show resource;
```

List all ET components:

```
!show et;
```

List information about certain ET component:

```
!show "et/[ET component name]";
```

List all functions:

```
!show functions;
```

List a function:

```
!show "function/[function name]";
```

- `!hdfs`

`!hdfs` is mainly used to view the file system, it supports most HDFS viewing commands.

View help:

```
!hdfs -help;
!hdfs -usage;
```

Here are some common operations:

List all files in a directory:

```
!hdfs -ls /tmp;
```

Delete the file directory:


```
!hdfs -rmr /tmp/test;
```

Copy files:


```
!hdfs -cp /tmp/abc.txt /tmp/dd;
```

- `!kill`

This command is mainly used to kill tasks.

```
!kill [groupId or Job Name];
```

- `!desc`

View the table structure.

```
!desc [table name];
```


- `!cache/!unCache`

Cache the table.

```
!cache [table name] [cache cycle];
```

There are three options for the cache cycle:

1. script
2. session
3. application

Manually clear cache:

```
!unCache [table name];
```

- `!println`

Print text:

```
!println '''text content''';
```

- `!runScript`

Execute a piece of text as a Byzer script:

```
!runScript ''' select 1 as a as b; ''' named output;
```

- `!lastCommand`

Assign a table name for the output of the previous command for subsequent use:

```
!hdfs -ls /tmp;
!lastCommand named table1;
select * from table1 as output;
```

- `!lastTableName`

Remember the previous table name, then you can get it next time:

```
select 1 as a as table1;
!lastTableName;
select "${__last_table_name__}" as tableName as output;
```

The output is `table1`;

- `!tableRepartition`

Partition the table:

```
!tableRepartition _ -i [table name] -num [number of partitions] -o [output table name];
```


- `!saveFile`

If a table has only one record which has only one column and the column is in binary format, then we can save the content of the column as a file. Compare

```
!saveFile _ -i [table name] -o [save path];
```

- `!emptyTable`

For example, sometimes we don't want to have output so we can add this statement to the last sentence:

```
!emptyTable;
```

- `!profiler`

Execute native SQL:

```
!profiler sql ''' select 1 as a ''' ;
```

View the configuration of all spark coreness:

```
!profiler conf;
```

View the execution plan of a table:

```
!profiler explain [table name or an SQL];
```


- `!python`

Some Python runtime environments can be set up with this command.


- `!delta`

Show help:

```
!delta help;
```

List all delta tables:

```
!delta show tables;
```

Version history:

```
!delta history [db/table];
```

Table information:

```
!delta info [db/table];
```

File merge:

```
!delta compact [table path] [version number] [number of files] [whether running in the background];
!delta compact db/tablename 100 3 background;
```

The above code means that the files of the version before `db/table 100` are merged and only three files are kept in each directory.


- `!plugin`

Plugin installation and uninstallation

- `!kafkaTool`

Kafka related tools

- `!callback`

Streaming Event callback