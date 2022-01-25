# Data warehouse/Data lake

Big data processing is inseparable from data warehouses or data lakes. Byzer supports both traditional `Hive` operations and the latest `Delta` data sources.

There are three problems in the data warehouse. The first is data synchronization, the second is streaming support and the third is the problem of small files.
This chapter will explain how Byzer solves them.

The easiest way for Byzer to access Hive is to place Hive-related configuration files (hive-site.xml) into the `SPARK_HOME/conf` directory.

In addition, Byzer supports accessing Hive through JDBC, but the performance may be relatively low.
