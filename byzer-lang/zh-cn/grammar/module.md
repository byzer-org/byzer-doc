# Byzer 模块化编程

在生产环境里使用SQL，这意味着：

1. 成千上万的脚本
2. 单个SQL脚本成千上万行

SQL 自身的一些缺陷在面对上面问题时，会导致非常大的问题：

1. 大量重复 SQL 代码，无论完整的 SQL 语句或者 SQL 代码片段都难以复用，导致效率低下，难以协作
2. 难以沉淀精细的（比如case when片段）或者模块化（比如完整的业务逻辑单元，类似一个jar包）的业务资产

所以在当面对很复杂的业务场景时，如何有效的复用，管理和维护 SQL代码是非常重要的。Byzer 很好的解决了这方面的问题。除了本篇模块化编程以外，相辅相成的还有一个能力，就是模板编程的能力： Byzer Man：Byzer 模板编程入门。

## Byzer Notebook 里的 Notebook 之间引用

> 该功能需要 Byzer notebook 1.1.0 以及以上版本支持  

Byzer-lang 提供了很好的 IDE 工具，诸如纯 Web 版本的 Byzer Notebook  ，还有 本地版本的 Byzer-desktop (基于VsCode), 他们都是以 Notebook 形式提供了对 Byzer 语言的支持，对于用户调试、管理和模块化 Byzer 代码具有非常大的价值。当然，还有程序员们喜欢的 Byzer-shell ,Byzer-cli ， 在 Byzer 的 All-in-one 版本里都默认包含了。

话题拉回来，假设用户开发了一个 UDF 函数（Byzer 支持动态定义UDF函数，意味着不用编译，不用打包发布重启等繁琐流程），然后它可能会在很多 Notebook 里都用到这个函数。
此时，用户可以将所有 UDF 函数都放到一个 Notebook 里，然后在其他 Notebook 里引用。 具体做法分成两步。

第一步，创建一个 用于存储 UDF 的 Notebook, 比如 Notebook 名字叫 udfs.bznb,第一个cell的内容为：

```sql
register ScriptUDF.`` as arrayLast
where lang="scala"
and code='''
def apply(a:Seq[String])={
    a.last
}
'''
and udfType="udf";
```

第二步，新创建一个 Notebook, 比如叫 job.bznb， 在该 Notebook 里可以通过如下方式引入 arrayLast 函数：

```sql
include http.`project.demo.udfs`;
select arrayLast(array("a","b")) as lastChar as output;
```

这个时候上面的代码就等价于：

```sql
register ScriptUDF.`` as arrayLast
where lang="scala"
and code='''
def apply(a:Seq[String])={
    a.last
}
'''
and udfType="udf";
select arrayLast(array("a","b")) as lastChar as output;

```

实现了代码的模块化复用。

在 Byzer Notebook 中，需要在一个 Notebook 里引入另外一个 Notebook，可以通过 Include语法，其中 http 和 project 是固定的。 后面  demo.udfs 则是目录路径，只不过用 . 替换了 /。

假设 udfs 里有很多函数，不希望把所有的函数都包含进来，那么可以指定 Cell 的 序号 。 比如只包含第一个 cell, 那么可以这么写：

```sql
include http.`project.demo.udfs#1`;
select arrayLast(array("a","b")) as lastChar as output;
```

期待 Byzer notebook 以后可以支持给 cell 命名  

## 代码片段的引用

假设我们有个 case when (case when 其实是很有业务价值的东西)，我们可以创建一个 case_when 的一个 Notebook:

```sql
set gender_case_when = '''

CASE 
WHEN gender=0 THEN "男"
ELSE "女"
END
''';
```

然后我在某个 Notebook  比如 main 里就可以这么用：


```sql
select 0 as gender as mockTable;

include http.`project.demo.casewhen`;

select ${gender_case_when} as gender from mockTable
as output;

```

上面的本质是把代码片段放到一个变量里去，然后在语句中引用变量。

问题来了，在本例中，如果 case when 里的 gender 字段可能是变化的怎么办？ 可能有人叫 gender, 有人叫 sex， 该如何复用？ 这当然难不倒我们, 新写一段代码：

```sql
set gender_case_when = '''

CASE 
WHEN {0}=0 THEN "男"
ELSE "女"
END
''';

```

此时把原来写 gender 的地方改成 {0}, 然后调用时，这么调用：


```sql
select 0 as gender as mockTable;

include http.`project.demo.casewhen`;

select ${template.get("gender_case_when","gender")} as gender from mockTable
as output;

```


我们使用 `template.get` 来获取模板以及使用位置参数来渲染这个模板。更多细节参考这篇专门的文章： Byzer Man：Byzer 模板编程入门

## 宏函数的使用

Byzer 也支持函数的概念，这个函数和 SQL 中的函数不同， Byzer 的宏函数是对 SQL 代码进行复用。
我们在 case_when Notebook 中再加一段代码：

```sql
set showAll='''

select CASE 
WHEN {0}=0 THEN "男"
ELSE "女"
END as gender from mockTable 
as output

''';
```


在变量 showAll 中填写了一段完整的 Byzer 代码（注意，当前版本 Byzer 不支持 宏函数嵌套，也就是宏函数里不能再使用宏函数）。接着，我们可以在 main Notebook 中引用：


```sql
select 0 as gender as mockTable;

include http.`project.demo.casewhen#3`;

!showAll gender;
```


通过 宏函数，也能有效提升我们对 Byzer 的封装性。

## 在脚本中引入 Git 托管的 Byzer 代码

几乎所有的语言都有模块化管理代码的能力，比如 Java 的 jar, Python的 Pip, Rust 的crate 等。 Byzer 也具有相同的能力。 Byzer 支持直接引用 git 仓库的中代码。假设用户开发了一个业务库，使用 Byzer 语句，此时他可以把代码放到 gitee 上，其他人就可以通过这个方式引用这个代码库：

```sql
include lib.`gitee.com/allwefantasy/lib-core`
where 
-- commit="xxxxx" and
alias="libCore";
```

接着可以可以引用里面的具体某个文件：

```sql
include local.`libCore.udf.hello`;
select hello() as name as output;
```

在上面的案例中，我们引用了 lib-core 项目里的一个 hello 函数，然后接着就可以在 select 语法中使用。include 也支持 commit 进行版本指定，很方便。
结果如下：

使用 Git 进行 Module 的托管，可以更好的对代码进行封装。

另外，如果假设你已经进行过 lib 的include(下载到服务器上了)，那么你也可以按下面的方式
应用已经缓存在本地的lib库：

```sql
include local.`gitee.com/allwefantasy/lib-core.udf.hello`;
select hello() as name as output;
```



## Byzer desktop

Byzer desktop 如果没有配置远程的引擎地址，默认会使用内置的引擎，这意味着我们可以使用Byzer 操作本地的文件。
模块的使用和 Byzer Notebook 完全一致。但对于本地的脚本的引入略有区别，它使用 project 关键词，支持相对路径：

```sql
include project.`./udf.hello`;
```​

我们可以看到， Byzer 提供了很强的代码复用能力，结构化管理能力，能够实现代码片段到模块级别的管理能力。
对于提升用户效率，增强业务资产的沉淀能力带来很大的助力。