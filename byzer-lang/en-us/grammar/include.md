# Code import/Include

Byzer-lang supports complex code organization structure, which gives Byzer-lang powerful code reuse ability.

1. It can introduce a Byzer script into another Byzer script.
2. It can also assemble a bunch of Byzer scripts into a feature set, and then provide it to other users in the form of Lib.

## Introduce third-party dependent libraries

`lib-core` is a Byzer-lang Lib library maintained by allwefantasy, which contains many functions written in Byzer-lang. Byzer-lang uses Github as a Lib management tool.

If you need to import `lib-core`, you can do it as follows:

```sql
include lib.`github.com/allwefantasy/lib-core`
where
-- libMirror="gitee.com"
-- commit="xxxxx"
-- force="true"
alias="libCore";
```

> 1. If you are familiar with programming, you can understand that this is a Jar package declaration in Maven or a Module declaration in Go language.
> 2. Unlike traditional languages, Byzer-lang is a purely interpreted language, so import libraries can become part of the language runtime.

In the above code example, the `lib-core` library is introduced through `include`. For ease to use, users can give it an alias `libCore`</ g3>.

Except the `alias` parameter, there are three other optional parameters:

1. **libMirror** can configure the mirror address of the library. For example, if gitee also synchronizes the library, the domestic download speed can be accelerated through this configuration.
2. **commit** can specify the version of the library.
3. **force** decides to force the last downloaded code to be deleted when every time it is executed, and then download it again. If you want to get the latest code every time, you can turn this option on.

Once the library is introduced, the packages in the library can be used. If users want to use a function called `hello` in `lib-core` in their project,
Then the function can be introduced with the following syntax:

```sql
include local.`libCore.udf.hello`;
```

Once introduced, the function can be used in `select` clauses:


```sql
select hello() as name as output;
```

## In-project script references

In order to complete the development of a complex project, it is necessary to disassemble the functional code into multiple scripts to achieve code reuse and interactive organization. In Byzer-lang, there are two cases.

1. The project is available to other users as a third-party Lib, just like `libCore`.
2. Cross-references between Byzer scripts in this project

### Script dependencies in Lib

All scripts in Lib need to refer to each other with the following syntax:

```sql
include local.`[PATH]`;
```

This Path requirement is the full path. If a script in `libCore` needs to introduce the `hello` function in this Lib, then it needs to use the following writing method:

```sql
include local.`github.com/allwefantasy/lib-core.udf.hello`;
```

### Byzer script dependencies in common projects

The exact way you refer depends on whether you use the web (eg byzer notebook ) or desktop (eg Byzer-desktop ).

If you use the web, please refer to the user manual of the web side (eg the function manual of byzer notebook). If you use the desktop, you can use `project` keywords. 

For example, if you want to introduce `src/algs/b.kolo` in `src/algs/a.kolo`,you can reference `b.kolo` in `a.kolo` as follows:

```sql
include project.`src/algs/b.kolo`;
```


## Byzer-lang reference to Python script

Byzer-lang supports direct reference to Python script files. However, it is completed by using the built-in macro function `!pyInclude` instead of using
`include` syntax.

If you are developing a Lib library, you must use local + full path.

Sample code:

```sql
 !pyInclude local 'github.com/allwefantasy/lib-core.alg.xgboost.py' named rawXgboost;
```

If you just refer to each other in your own project, you can use project + full path or relative path.

```sql
!pyInclude project 'src/algs/xgboost.py' named rawXgboost;
```

The file is referenced via `!pyInclude`, and then the file is then converted into a table named `rawXgboost`in the example:

```sql
run command as Ray.`` where
inputTable="${inputTable}"
and outputTable="${outputTable}"
and code='''py.rawXgboost''';
```

>   If you want to know more about `run statement`, see [Extension/Train|Run|Predict](/byzer-lang/en-us/grammar/et_statement.md).

In the above example code, the reference to the Python file script can be completed through `py.rawXgboost`, and the system will automatically replace this part of the content with the actual Python script content.

By separating the Python code from the Byzer-lang code, it is efficient to help users improve development efficiency. This trick is used extensively in `lib-core`.

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



> Note: if it is a Python file, the file needs to use the suffix `.py`.

## Limitation

Byzer-lang does not support circular references.



