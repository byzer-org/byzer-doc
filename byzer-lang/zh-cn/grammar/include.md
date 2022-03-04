# 代码引入/Include

Byzer-lang 支持复杂的代码组织结构，这赋予了 Byzer-lang 强大的代码复用能力。

1. 可以将一个 Byzer 脚本引入到另外一个 Byzer 脚本
2. 也可以将一堆 Byzer 脚本组装成一个功能集，然后以 Lib 的方式提供给其他用户使用

## 引入第三方依赖库

`lib-core` 是 @allwefantasy 维护的一个 Byzer-lang Lib 库，里面有很多用 Byzer-lang 写成的一些功能。Byzer-lang 使用 Github 来作为 Lib 管理工具。

如果需要引入 `lib-core`,可以通过如下方式：

```sql
include lib.`github.com/allwefantasy/lib-core`
where 
-- libMirror="gitee.com"
-- commit="xxxxx"
-- force="true"
alias="libCore";
```

> 1. 如果熟悉编程的同学，可以理解为这是 Maven 中的 Jar 包声明，亦或是 Go 语言中的 Module 声明
> 2. 同传统语言不同的是，Byzer-lang 是纯解释型语言，所以引入库可以变成语言运行时的一部分

在上面的代码示例中，通过 `include` 引入了 `lib-core` 库，为了方便使用它，用户可以给其取了一个别名叫 `libCore`。

除了 `alias` 参数以外，还有其他三个可选参数：

1. `libMirror` ：可以配置库的镜像地址。比如如果 gitee 也同步了该库，那么可以通过该配置使得国内下载速度加快。
2. `commit` ：可以指定库的版本
3. `force` ：决定每次执行的时候，都强制删除上次下载的代码，然后重新下载。如果你每次都希望获得最新的代码，那么可以开启该选项。

引入该库后，就可以使用库里的包。假设用户希望在自己的项目中使用 `lib-core` 里一个叫 `hello` 的函数，
那么可以通过如下语法引入该函数：

```sql
include local.`libCore.udf.hello`;
```

引入后，就可以在 `select` 句式中使用该函数了：


```sql
select hello() as name as output;
```

## 项目内脚本引用

为了完成一个复杂项目的开发，往往需要将功能代码拆解成多个脚本，实现代码的复用和交互组织。在 Byzer-lang 中，分成两种情况。

1. 项目作为第三方 Lib 提供给其他用户用，就像 `libCore` 一样
2. 本项目内 Byzer 脚本之间的互相引用

### Lib 内脚本依赖

Lib 下所有脚本互相引用引用都需要下面的语法进行引用： 

```sql
include local.`[PATH]`; 
```

这里的 Path 要求是全路径。如果在 `libCore` 里有个脚本需要引入了本 Lib 中的 `hello` 函数，那么需要使用如下写法：

```sql
include local.`github.com/allwefantasy/lib-core.udf.hello`;
```

### 普通项目内 Byzer 脚本依赖

具体引用方式，取决于你是使用 Web （比如 Byzer Notebook ）还是桌面（比如 Byzer-desktop）。

如果是 Web 端的，请参考 Web 端的使用手册（比如 Byzer Notebook 的使用功能手册） 。如果是桌面版的，则使用 `project` 关键字，比如希望在 `src/algs/a.byzer` 中引入 `src/algs/b.byzer` ，那么可以在 `a.byzer` 中使用如下方式对 `b.byzer` 进行引用：

```sql
include project.`src/algs/b.byzer`;
```


## Byzer-lang 对 Python 脚本的引用

Byzer-lang 支持直接引用 Python 脚本文件。 不过对于 Python 脚本的引用是使用内置宏函数 `!pyInclude` 来完成的，而不是使用 `include` 句式来完成。

如果你是在开发一个 Lib 库，那么必须使用 local + 全路径。

示例代码：

```sql
 !pyInclude local 'github.com/allwefantasy/lib-core.alg.xgboost.py' named rawXgboost;
```

如果仅仅是在自己项目中互相引用，则使用 project + 全路径或者相对路径就可以。

```sql
!pyInclude project 'src/algs/xgboost.py' named rawXgboost;
```

通过 `!pyInclude` 对文件进行引用，然后该文件会被转化为一张表，表名在示例中为 `rawXgboost`：

```sql
run command as Ray.`` where 
inputTable="${inputTable}"
and outputTable="${outputTable}"
and code='''py.rawXgboost''';
```

> `run句式` 可以参考[扩展/Train|Run|Predict](/byzer-lang/zh-cn/grammar/et_statement.md)

在上面的示例代码中， 通过 `py.rawXgboost` 可以完成对 Python 文件脚本的引用，系统会自动将这部分内容替换为实际的 Python 脚本内容。

通过将 Python 代码和 Byzer-lang 代码分离,可以有效的帮助用户提升开发效率。在 `lib-core` 中大量使用了该技巧。

对于一个库的开发者，可以通过分支语句来判定是应该使用模块 `include` 还是普通的项目脚本 `include`:

```sql
-- 引入python脚本
set inModule="true" where type="defaultParam";
!if ''' :inModule == "true" ''';
!then;
    !println "include from module";
    !pyInclude local 'github.com/allwefantasy/lib-core.alg.xgboost.py' named rawXgboost;
!else;
    !println "include from project";
    !pyInclude project 'src/algs/xgboost.py' named rawXgboost;
!fi;    
```



> 注意到,如果是 Python 文件,是需要后缀名 `.py` 的。

## 限制

Byzer-lang 不支持循环引用。



