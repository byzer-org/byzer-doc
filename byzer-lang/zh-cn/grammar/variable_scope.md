# 额外篇：关于变量作用域问题

Byzer SQL 脚本也有作用域的概念。作用域是指变量的生命周期。

## 常见具备作用域的变量

1. 临时表，比如 `select 1 as number as tempTable;` 这个 tempTable 就是一个临时表。默认是用户级别的作用域。
2. set 语法变量，比如 `set a=1;` 这个 a 就是一个变量。变量可以手动设置作用域。比如 `set a=1 where scope="session";` 这个 a 就是一个 用户级别的 作用域的变量。默认是 request 级别，也就是单次和引擎的交互中有效。
3. 分支条件语句里. 比如 `if ":number > 10" ;` 这种可以引用外部的 set 变量，但是只在分支条件语句里有效。
4. connect 语句中的连接名称。他是 applicaiton 级别的。所有用户都可以使用。

## 作用域

Byzer SQL 中的作用域分成三种：

1. request 级别，也就是单次和引擎的交互中有效。
2. session/user 级别，也就是用户级别的作用域。比如用户登录后，可以在 session 级别的作用域里设置变量，这个变量在用户的整个会话中有效。
3. application 级别，也就是应用级别的作用域。比如在应用启动后，可以在 application 级别的作用域里设置变量，这个变量在应用的整个生命周期中有效。


## request 级别作用域

前面我们看到， 目前只有 `set` 一个变量，这个变量的作用域默认就是 request 级别的。也就是说，这个变量只在当前的请求中有效。

你可以通过 `set a=1 where scope="request";` 来显式的设置一个变量的作用域为 request 级别。为了能够跨 Cell/Notebook 有效，你可以在 `set` 语句中加入 `where scope="session"` 来改成 session/user 级别的作用域。

## session/user 级别作用域

这个作用域最主要就是为了方便在 Byzer Notebook 中调试。比如你在一个 Notebook 中设置了一个变量，你希望在另外一个 Notebook 中也能够使用这个变量，那么你就可以在 `set` 语句中加入 `where scope="session"` 来改成 session/user 级别的作用域。

或者你在一个 Notebook 得到一个表，在另外一个 Notebook 中继续使用这个表，方便调试和使用。

> 注意： Byzer Notebook 和 Jupyter 不一样， Byzer Notebook 的不同的 Notebook 默认是共享一个 Byzer 引擎实例的，所以同一个用户的不同 Notebook 之间是可以共享变量的。

## 常见问题

1. 假设我写了两个脚本，A，B ，现在我同时提交了 A，B 到引擎，此时会导致 A,B 之间的变量互相冲突，导致结果异常。

分析： 因为表名是 session/user 级别作用域的。只要是以同一个账户提交的，那么不同脚本之间是可以互相看到对方变量的。这个时候因为执行顺序问题，会发生变量互相覆盖的问题，导致结果异常。为了解决这个问题，可以在提交的时候，同时设置两个HTTP请求参数：

1. sessionPerUser=true
2. sessionPerRequest=true

第一个是默认的，就是每个用户是绑定一个session的，第二个设置为true，表示在 session/user 隔离的基础上，每次请求，都复制一个session出来，不同副本之间就毫无关系了，这样就可以避免不同脚本之间的变量互相冲突的问题。

2. 如果我写了很多脚本，放到调度系统里去，脚本之间互相有依赖，是不是可以利用同一个用户的 session/user 级别作用域来实现数据表之间的呢？

答案是不推荐。如果你开启了  `sessionPerRequest=true`, 那么这种依赖就会失效。 如果你没有开启，复杂的依赖里，会有脚本并行执行的可能性，导致前面我们提到的异常。并且还会产生一个比较大的问题，在 A 脚本中设置了一个变量，在B 脚本中没有重置，会导致这个变量影响到了 B 脚本。

所以，如果你的脚本是有依赖的，那么你可以保证脚本的独立性，脚本和脚本之间通过持久化存储来完成衔接。