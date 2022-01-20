# Byzer Language

### Background

For a long time, **SQL solos**. When it comes to the question what computer language is more suitable for one who just entered the data industry, which language features fast interaction, wide usage and good scalability, the answer is always SQL.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/tables.png" alt="name"  width="400"/>
</p>
<center><i>Jokes only SQL developers can understand</i></center>

<center><i>An SQL query walks into a bar and sees two Tables, he says to them:"Can I join you?"</i></center>

Consider the popularity of Python in recent years, someone may ask can Python replace SQL?

But for Python beginners, most questions you have to solve are not the questions you really need to solve. For those not majored in Computer Science, what they really need to focus on is data operation, but with Python, they must first learn various features that are only related to the language itself, such as variables, functions, threads, distribution, etc. It requires considerable learning cost. Of course, they can also use Excel, SAS, Alteryx and other similar software to operate on data, but Excel has its own limitations. For example, it is hard to define complex logics, cannot join across different data sources, and the data scale is also limited. With all these limitations, SQL still wins with its low threshold, ease-of-use and scalability.


SQL also has shortages. First of all, it was originally designed for relational databases, and it is suitable for query rather than ETL. It is difficult to use SQL for ETL, streaming processing and even AI. The second problem is that SQL is declarative. So it is lack of programmability.

**If SQL is not good enough, what unified programming language can be used to achieve Data + AI? **

To improve the efficiency of data platform launching and AI engineering from the programming language perspective, we invented Byzer language.




### What is Byzer language?

**Byzer is a brand new programming language which is completely open source and low-code. With Byzer, you can realize data processing, data analysis and AI. **

With Byzer, we can do things on one platform that used to need  multiple languages, multiple platforms, and multiple components.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/pipeline.png" alt="name"  width="800"/>
</p>
<center><i>Traditional data processing link</i></center>

Byzer not only inherits all advantages of SQL，such as ease to understand and easy to use; it also provides better programming capabilities and allows users to perform more advanced operations. Byzer's  **four major features** are as follows:

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/characteristics.png" alt="name"  width="800"/>
</p>

### Use cases/target users

Byzer is a unified interactive language. With Byzer, users can work on tasks of **data processing + data analysis + data science** with a unified platform.

For example, after learning the advanced version of the SQL -- Byzer for a while, the operation stuff  can finish the work of the data team (data scientist + data engineer + data analyst),  then the investment cost of the enterprise on the data team will be greatly reduced. Then the focus of the digital transformation in this enterprise will be to make everyone a data expert rather than recruiting more data experts.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/customer.png" alt="name"  width="800"/>
</p>

### Byzer basic syntax


Byzer syntax is very simple, with only a few more keywords than standard SQL, and the entire learning process can be completed within a few hours.  Based on your SQL knowledge, you only need to several hours of learning to master how to use a declarative syntax for machine learning.


<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/grammar.png" alt="name"  width="500"/>
</p>

<center><i>Declarative SQL-like syntax is very simple and easy to understand</i></center>

### Byzer integrates with distributed computing engine

Byzer adopts a cloud-native architecture. Users can use the desktop version to connect to the cloud engine, and thus easily leverage the computing power and storage space in the cloud.

<p align="center">
    <img src="/byzer-lang/zh-cn/introduction/images/clouddesign.png" alt="name"  width="650"/>
</p>


Byzer is based on ***Spark + pluggable Ray***. Both Spark and Ray are distributed, and the connection is also distributed. So we say that Byzer is a naturally distributed engine.

For enterprises, with out-of-the-box libraries, the language and execution engine actually will not help much, as there are too many development efforts. To help enterprises to better launch Data+AI, Byzer supports:

- For the support of the data lake, in Byzer-lang, you can use the engine to make a configuration and specify a directory, and then you can update and write data to the data lake.
- For the support of CDC, people are more familiar with Flink. Byzer directly supports CDC, and users can synchronize the data to the data lake in real time with two lines of code.
- There are also various out-of-the-box functions, algorithms, etc.

### Byzer supports Python

For some experienced machine learning users, they may worry that they have already used Python scikit-learn or tensorflow to build machine learning models with other products, such as Jupyter Notebook, and they have already done lots of coding there, so how to migrate to Byzer?

In Byzer, we use Byzer-python to cite and adapt Python code. Advanced Python users can continue to use the machine learning package that they are familiar with for model building. For more information, see [Python extensions](/byzer-lang/zh-cn/python/README.md).

Better still, Byzer-python provides a very convenient API for users to access or create data views in Byzer script, with no need to worry about permissions. What's more, Byzer-python also provides distributed programming capabilities and it supports to customize the hardware configuration (such as GPU), users can easily build machine learning training modes with structures like Parameter Server, etc.


Next, try Byzer now.



