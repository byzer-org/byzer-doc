# Byzer-Lang

### Background

For long time **SQL solos**.
What computer language is suitable for the entry data industry and has fast interaction, wide use and good scalability? The answer is always SQL.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/tables.png" alt="name"  width="400"/>
</p>
<center><i>Jokes only SQL developers can understand</i></center>

<center><i>An SQL query walks into a bar and sees two Tables, he says to them:"Can I join you?"</i></center>

Because of the popularity of Python in recent years some people may ask whether Python can replace SQL?

But for Python beginners, you may need to solve most of the problems that you don't need to solve with SQL. The main problem for beginners is data operation, but before it, you must learn various features that are only related to the language itself such as variables, functions, threads, distribution, etc.. It requires considerable learning cost. Excel, SAS, Alteryx and other similar software can also be used to operate data, but Excel has its own limitations. For example, there are many complex calculations that are not easy to do, it cannot be correlated across data sources, and the data scale is also limited. Comparing with many aspects, SQL finally wins with its low threshold, ease of use and scalability.


SQL also has shortages. First of all, it was originally designed for relational databases, and it is suitable for query rather than ETL. It is difficult to use SQL for ETL, stream processing and even AI. The second problem is that SQL is declarative. So it is lack of programmability.

**If SQL is not enough, what language can be used to realize Data + AI and unify programming? **

In order to improve the efficiency of data platform grounding and AI engineering through programming language, Byzer language was born.




### What is Byzer

**Byzer is a brand new programming language which is completely open source and low-code. Using Byzer can realize data processing, data analysis and AI. **

By using Byzer, we can do things in a single platform that we needed to use multiple languages, multiple platforms, and multiple components to realize in the past.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/pipeline.png" alt="name"  width="800"/>
</p>
<center><i>Traditional data processing link</i></center>

Byzer not only maintains all advantages of SQL such as ease to understand and use; it also allows users to perform advanced operations and provide more programming capabilities. Byzer's  **four major features**are as follows:

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/characteristics.png" alt="name"  width="800"/>
</p>

### Byzer usage scenarios/users

In Byzer, a unified interactive language can be used, and the tasks of **data processing + data analysis + data science** can be completed in a unified platform.

If a business people in the enterprise can complete the work of data scientist, data engineer and data analyst in the data team by learning the advanced version of the SQL language Byzer, then the investment cost of the enterprise in the data team will be greatly reduced. Enterprise digital transformation is not about recruiting more data experts, but making everyone become a data expert.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/customer.png" alt="name"  width="800"/>
</p>

### Byzer basic syntax


Byzer syntax is very simple, with only a few more keywords than standard SQL, and the entire learning process can be completed in a few hours.  On the basis of learning of SQL, you can master the use of declarative syntax for machine learning with a little more effort.


<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/grammar.png" alt="name"  width="500"/>
</p>

<center><i>Declarative SQL-like syntax is very simple and easy to understand</i></center>

### Byzer docks distributed computing engine

Byzer is designed based on a cloud-native architecture. Users can use the desktop version of the software to connect to the cloud engine to easily remove computing power and storage space limitations.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/clouddesign.png" alt="name"  width="650"/>
</p>


Byzer base is based on ***Spark + Ray*** where Ray can easily open or close the conncetion of Ray cluster. Both Spark and Ray are distributed, and the connection is also distributed. So we say that Byzer is naturally a distributed engine.

For enterprises, if there is only language and execution engine, and there is no third-party out-of-the-box library, everything has to be developed by itself, which is actually of little value. In order to help enterprises to better implement Data+AI, Byzer supports for many functions:

- For the support of the data lake, in Byzer-lang, you can use the engine to make a configuration and specify a directory, and then you can update and write data to the data lake.
- For the support of CDC, everyone should be familiar with Flink. Byzer directly supports CDC, and users can synchronize to the data lake in real time with two lines of code.
- There are also various out-of-the-box functions, algorithms, etc.

### Byzer supports Python

For some experienced machine learning users, they may worry that they have already used Python scikit-learn or tensorflow for model development of machine learning in other products such as Jupyter Notebook, and the project files already have a lot of code. So how to migrate to Byzer?

In Byzer, we use Byzer-python to cite and adapt Python code. Advanced Python users can continue to use the machine learning package you are used to for model development. The content of this section can be referred to the [Python extensions](/byzer-lang/zh-cn/python/README.md).

What's more powerful is that Byzer-python provides a very convenient API for users to access one or more view data in Byzer script without worrying about permissions, and generate one or more new views. Furthermore, Byzer-python also provides distributed programming capabilities and it can customize the hardware configuration (such as GPU), users can easily implement machine learning training modes that has Parameter Server structure.


Next, try Byzer now.



