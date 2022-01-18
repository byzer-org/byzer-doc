# Byzer Language Design Principles

### Design concept

Byzer is a new-generation of programming language for data and AI, when design this language, we have considered many different factors:

First, we want the language could be simple and flexible, so we combined a SQL-like structure and features of imperative programming, hoping to shorten the learning curve.

Second,  we want to design it as an interpreted language. Byzer wants to solve the efficiency problem of data pipeline processing and AI adoption. In big data and AI area, we care more about the throughput than processing delay, so we need an abstract, easy-to-use, and cross-platform language. That's why we used the interpreted language design.

Third,  we want to maximize the ecology of the industry to make Byzer a natural cloud native and distributed language, so we use Spark/Ray as its execution engine, which helps to enrich Byzer's ecology.

When we tried to build this abstract language, we found that the work in the data industry is actually data processing, with facts hidden in the 2D or multi-dimentional data tables, SQL is acutally the abstract data operations on these 2D data tables.  Therefore, the kernel concept of Byzer is **Everything is a table**. We hope that developers can easily extract any entity objects into a 2D table through Byzer, and then do data processing and training based on these tables.
<fragment 0008>


With all these considerations, Byzer has carried on the easy-to-use and easy-to-understand advantages of SQL, while providing more advanced programming capabilities with extensions.   Byzer Notebook (the IDE tool for Byzer Language) is another product in Byzer community, with which you can do project management, and code demo in the form of Notebook. Note: It's still under continuous iterative development.  


### Byzer language structure

Below is the language structure of Byzer:

byzer-lang-arch

As an interpretive language, Byzer consists of an Interpreter and a Runtime environment. Byzer Interpreter will first run a lexical analysis on the Byzer scripts, generate corresponding Java/Scala/Python/SQL codes based on this analysis, and then submit the codes to Runtime for execution. The generated Java or Scale codes are Byzer Native codes.

Byzer uses **Github** as its Package Manager, which contains the built-in lib and third party libs. lib is a function module compiled by Byzer Language.  

### Byzer extensions

Byzer language provides rich interfaces for developments, in Byzer, these interfaces are called extensions, which can be divided into 2 types:
- Engineers who use Byzer to develop applications, focus on business logic code and extensions
- Engineers who develop Byzer language, focus on improving the capabilities of Byzer language and Byzer engine.


Byzer provides **Variable** and **Macro Function** at the language level, and also provides the **Lib** moudle and Package feature. Developers can encapsulate code with the Macro Function, improve the language with Byzer's syntactic sugar, use Package to organize codes so as to develop function libraries that can be used by third parties.

Extension



#### Byzer-lang Application Ecosystem Extensions

This is for Scale/Java engineers. Byzer-lang can help to handle different service requirements. It can be divided into the following types:

- **Data source extension** (Data source extension can be further distinguished from accessing data and consuming data pespectives):
   - Access data, to extract data source into Byzer tables
   - Consume data, to expose the data processed Byzer to the downstream with API
- **Estimator-Transformer (ET)**`: ET defines the extension interface for table processing, the following extensions can be implemented through the ET interface:
   - UDF functions
   - Byzer-Python, to enhance the table processing capability with Python's ecosystem
   - `!plugin`, for plugins and plugin management
   - Macro Function, for the implementation of ET.
- **App extension**: to extend the app function through the Byzer interface
   - For example, by implementing the LSP protocol and exposing the auto-suggest interface, we can provide intelligent code completion function in Byzer.

#### Language layer Byzer extensions

This type of extension is for Byzer-lang coders, for example when writing Byzer libraries.

Users can use the following extensions in Byzer syntax to extend the language capabilities:
- Macro Function
- UDF functions (allows users to write Scala/Java UDF functions that act on select/branch conditional expressions)
- Byzer-python (acts on the run statement) Python script supported)

#### Kernel layer Byzer-lang extensions

The type of extensions is for the core developers of Byzer-lang. These extension can enhance the engine capabilities. Actually it is the interpreter that enhances Byzer-Lang.

1. The kernel life cycle extension is to support plug-ins. Here, life cycle refers to load the plugins before or after the initialization of Runtime. For example, Byzer CLI is to load the plug-in before the initialization.
2. New syntax extension, for example, to add a syntax keyword.
3. Customized extension, for example, authorization, interface access control, alarm handling, or clearance request.

#### IDE support

Byzer-lang already supports the web IDE, that is, Byzer-notebook, and it also supports users to use VSCode for script editing or to use Notebook.

As a language, Byzer should support various IDEs, such as highlighting, intelligent code completion and running. At present, the more popular way is to implement **language server protocol (LSP)**, so users can use the related functions directly in the editor or IDE. Byzer has officially supported VSCode. For more information, please read [byzer-desktop](https://github.com/byzer-org/byzer-desktop) and [byzer-language server](https://github.com/byzer-org/byzer-extension/tree/master/mlsql-language-server).

Byzer-lang is a scripting language that is interpreted, so you can use the built-in macro function `!show` to achieve parameter introspection and return it to the caller through **code suggestion api** to complete the intelligent code completion.
