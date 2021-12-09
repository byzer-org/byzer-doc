## 代码引入/Include

Kolo-lang 支持复杂的代码组织结构，这赋予了Kolo-lang强大的代码复用能力。

1. 我们可以将一个Kolo脚本引入到另外一个Kolo脚本
2. 也可以将一堆Kolo脚本组装成一个功能集，然后以Lib的方式提供给其他用户使用

### 引入第三方依赖库

lib-core 是allwefantasy 维护的一个Kolo-lang Lib库，里面有很多用Kolo-lang写成的一些功能。Kolo-lang 使用github来作为Lib管理工具。

如果你需要引入lib-core,可以通过如下方式：

```sql
include lib.`github.com/allwefantasy/lib-core`
where 
-- libMirror="gitee.com"
-- commit="xxxxx"
-- force="true"
alias="libCore";
```
> 若果熟悉编程的同学，可以理解为这是maven中的jar包申明，亦或是go语言中的module申明。
> 同传统语言不同的是，Kolo-lang是纯解释型语言，所以引入库可以变成语言运行时的一部分。

在上面的代码示例中，我们通过include 引入了lib-core库，并且我们给其取了一个别名叫libCore，方便我们后续使用。
除了alias参数以外，还有其他三个可选参数：

1. libMirror  可以配置库的镜像地址。比如如果gitee也同步了该库，那么可以通过该配置使得国内下载速度加快。
2. commit 可以指定库的版本
3. force 决定每次执行的时候，都强制删除上次下载的代码，然后重新下载。如果你每次都希望获得最新的代码，那么可以开启该选项。

引入该库后，就可以使用库里的包。比如我们希望使用一个叫`hello` 的函数，该函数在lib-core里的`udf.hello`中被实现。
我们可以通过如下语法引入该函数：

```sql
include local.`libCore.udf.hello`;
```

现在，我们可以在select句式中使用该函数了：


```sql
select hello() as name as output;
```

### 项目内脚本引用

为了完成一个复杂项目的开发，我们往往需要将功能代码拆解成多个脚本，实现代码的复用和交互组织。在Kolo-lang中，分成两种情况。

1. 项目作为第三方Lib提供给别人用，就像libCore一样。
2. 仅仅是本项目内部的互相使用

#### Lib内脚本依赖

第一种情况，该Lib下所有脚本互相引用引用都需要通过 `include local.\`[PATH]\` `。 这里的Path要求是全路径。如果在libCore里有个脚本需要
引入了本lib中的hello函数，那么需要使用如下写法：

```sql
include local.`github.com/allwefantasy/lib-core.udf.hello`;
```

#### 普通项目内脚本依赖
第二种情况，则取决于你是使用Web(比如byzer notebook) 还是桌面(比如 Kolo-desktop)。

如果是Web端的，那么具体使用方式要参考Web端的文档。如果是桌面版的，则使用`project`关键字，比如在`src/algs/a.kolo` 中引入`src/algs/b.kolo`,
那么可以使用如下方式：

```sql
include project.`src/algs/b.kolo`;
```


#### Kolo-lang对Python脚本的引用

此外，Kolo-lang支持python脚本，我们也支持Python脚本单独成一个独立的文件。比如`src/algs/xgboost.py`。 同样的，如果你是在开发一个lib库，
那么必须使用 local + 全路径，如下：

```sql
 !pyInclude local 'github.com/allwefantasy/lib-core.alg.xgboost.py' named rawXgboost;
```

而如果仅仅是在自己项目中互相影响，则使用project + 全路径或者相对路径都可以。

```sql
!pyInclude project 'src/algs/xgboost.py' named rawXgboost;
```

通过`!pyInclude`我们通过名字rawXgboost（表）来引用一个脚本。接下来在ET Ray中我们可以这么用：

```sql
run command as Ray.`` where 
inputTable="${inputTable}"
and outputTable="${outputTable}"
and code='''py.rawXgboost''';
```

可以看到，我们通过 `py.rawXgboost` 进行脚本的引用，系统会自动将这部分内容替换为实际的python脚本内容。通过将Python代码和Kolo-lang代码分离,可以有效的
帮助用户提升开发效率.在lib-core中，我们也大量使用了该技巧。

对于一个库的开发者，可以通过分支语句来判定是应该使用模块include还是普通的项目脚本Include:

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



> 注意到,如果是Python文件,是需要后缀名`.py`的。



