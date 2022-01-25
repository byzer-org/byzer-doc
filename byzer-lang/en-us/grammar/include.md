# Code import/Include

Byzer-Lang supports complex code organization structure, which gives Byzer-Lang powerful code reuse ability.

1. It can introduce one Byzer script into another Byzer script.
2. It can also assemble a bunch of Byzer scripts into a feature set, and then provide them to other users in the form of Lib.

## Introduce third-party dependent libraries

`lib-core` is a Byzer-Lang Lib library maintained by @allwefantasy, which contains many functions written in Byzer-Lang. Byzer-Lang uses Github as a Lib management tool.

If you need to import `lib-core`, you can do it as follows:

```sql
include lib.`github.com/allwefantasy/lib-core`
where
-- libMirror="gitee.com"
-- commit="xxxxx"
-- force="true"
alias="libCore";
```

> 1. If you are familiar with programming, you can understand it as a Jar package declaration in Maven or a Module declaration in Go language.
> 2. Unlike traditional languages, Byzer-Lang is a purely interpreted language, so imported libraries can become part of the language runtime.

In the above code example, the `lib-core` library is introduced through `include`. For ease of use, users can name it as `libCore`.

Besides the `alias` parameter, there are three optional parameters:

1. **libMirror**: can configure the image address of the library. 
2. **commit**: can specify the version of the library.
3. **force**: to force the deletion of the last downloaded code every time it is executed, and then download it again. If you want to get the latest code every time, you can turn this option on.

Once the library is included, the packages in the library can be used. If users want to use a function called `hello` in `lib-core` in their project,
Then the function can be introduced with the following syntax:

```sql
include local.`libCore.udf.hello`;
```

Once introduced, the function can be used in `select` clauses:


```sql
select hello() as name as output;
```

## In-project script references

In the development of a complex project, it is necessary to divide the functional code into multiple scripts to achieve code reuse and interactive organization. In Byzer-Lang, there are two cases.

1. The project can be used by other users as a third-party Lib, just like `libCore`.
2. Cross-references between Byzer scripts in this project

### Script dependencies in Lib

Use the code below to achieve interactive quotations among all scripts under Lib. 

```sql
include local.`[PATH]`;
```

The Path should be the full path. If a script in `libCore` needs to include the `hello` function in this Lib, you could write as below:

```sql
include local.`github.com/allwefantasy/lib-core.udf.hello`;
```

### Script dependencies in projects

The include method depends on whether you use the web (Byzer notebook ) or desktop (Byzer-desktop) version.

If you use the web version, please refer to the user manual of the web side (function manual of Byzer notebook). If you use the desktop version, you can use `project` keywords. 

For example, if you want to include `src/algs/b.kolo` in `src/algs/a.kolo`, you can include `b.kolo` in `a.kolo` as follows:

```sql
include project.`src/algs/b.kolo`;
```


## Quote Python script

Byzer-Lang supports direct quoting of Python script files. However, it is completed with the built-in macro function `!pyInclude` instead of using
`include` syntax.

If you are developing a Lib, you must use local + full path.

Sample code:

```sql
 !pyInclude local 'github.com/allwefantasy/lib-core.alg.xgboost.py' named rawXgboost;
```

If you are just quoting each other in your own project, you can use project + full path or relative path.

```sql
!pyInclude project 'src/algs/xgboost.py' named rawXgboost;
```

The file is quoted via `!pyInclude`, and then the file is converted into a table named `rawXgboost` in the example:

```sql
run command as Ray.`` where
inputTable="${inputTable}"
and outputTable="${outputTable}"
and code='''py.rawXgboost''';
```

>   If you want to know more about `run statement`, see [Extension/Train|Run|Predict](/byzer-lang/en-us/grammar/et_statement.md).

In the above example code, the quoting of the Python file script can be completed through `py.rawXgboost`, and the system will automatically replace this part of the content with the actual Python script content.

By separating the Python code from the Byzer-Lang code, we help users improve the development efficiency. This tip is extensively used in `lib-core`.

For a library developer, a branch statement can be used to determine whether to use a module `include` or a normal project script `include`:

```sql
-- introduce python script
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



> Note: If it is a Python file, the file needs to end with the suffix `.py`.

## Limitation

Byzer-Lang does not support loop import.



