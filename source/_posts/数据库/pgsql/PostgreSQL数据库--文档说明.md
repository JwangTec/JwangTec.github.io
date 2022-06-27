---
title: PostgreSQL数据库--文档说明
categories: 数据库
tags:
  - PostgreSQL
top: 13
abbrlink: 938370106
password:
---


# 第一部分-了解PostgreSQL

##  特性


 复杂查询、外键、触发器、视图、事务完整性、多版本并发控制。另外，PostgreSQL 可以用许多方法进行扩展，比如通过增加新的：数据类型、函数、操作符、聚集函数、索引方法、过程语言

<!--more-->

### 体系

- PostgreSQL 使用一种客户端/服务器的模式。一次 PostgreSQL 会话由下列相关的进程(程序)组成

 > 1. 一个服务器进程，它管理数据库文件、接受来自客户端应用与数据库的联接并且代表客户端在数据库上执行操作。 该数据库服务器程序叫做postgres。
 > 2. 那些需要执行数据库操作的用户的客户端（前端）应用。 客户端应用可能本身就是多种多样的：可以是一个面向文本的工具， 也可以是一个图形界面的应用，或者是一个通过访问数据库来显示网页的网页服务器，或者是一个特制的数据库管理工具。 一些客户端应用是和 PostgreSQL发布一起提供的，但绝大部分是用户开发的。
 > 3. 和典型的客户端/服务器应用（C/S应用）一样，这些客户端和服务器可以在不同的主机上。 这时它们通过 TCP/IP 网络联接通讯。 你应该记住的是，在客户机上可以访问的文件未必能够在数据库服务器机器上访问（或者只能用不同的文件名进行访问）。

-  PostgreSQL服务器可以处理来自客户端的多个并发请求。 因此，它为每个连接启动（“forks”）一个新的进程。 从这个时候开始，客户端和新服务器进程就不再经过最初的 postgres进程的干涉进行通讯。


## 基础入门

### 创建一个数据库


`$ createdb mydb`


#### 创建数据库常见错误记录


```pgsql
createdb: command not found
```

> PostgreSQL没有安装好。或者是根本没安装， 或者是shell搜索路径没有设置正确

> 绝对路径调用该命令:`$ /usr/local/pgsql/bin/createdb mydb`

---

```pgsql
createdb: could not connect to database postgres: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?
```

> 该服务器没有启动，或者没有按照createdb预期地启动

---

```pgsql
createdb: could not connect to database postgres: FATAL:  role "joe" does not exist
```

> 管理员没有创建PostgreSQL用户帐号,需要变成安装PostgreSQL的操作系统用户的身份（通常是 postgres）才能创建第一个用户帐号。 也有可能是赋予PostgreSQL用户名和你的操作系统用户名不同； 这种情况下，需要使用-U选项或者使用PGUSER环境变量指定你的PostgreSQL用户名

---

```pgsql
createdb: database creation failed: ERROR:  permission denied to create database
```

> 没有创建数据库所需要的权限

###  删除一个数据库

`$ dropdb mydb` : 将在物理上把所有与该数据库相关的文件都删除并且不可取消

### 访问数据库

#### 访问方式

- 运行PostgreSQL的交互式终端程序，它被称为psql， 它允许你交互地输入、编辑和执行SQL命令。

- 使用一种已有的图形化前端工具，比如pgAdmin或者带ODBC或JDBC支持的办公套件来创建和管理数据库。

- 使用多种绑定发行的语言中的一种写一个自定义的应用。



#### 启动psql

> 如果不提供数据库名字，那么它的缺省值就是用户账号名字

`$ psql mydb`

```pgsql
psql (10.1)
Type "help" for help.

mydb=>
或者
mydb=#   这个提示符意味着你是数据库超级用户
```


psql程序有一些不属于SQL命令的内部命令。它们以反斜线开头，“\”。 欢迎信息中列出了一些这种命令。比如，你可以用下面的命令获取各种PostgreSQL的SQL命令的帮助语法：`mydb=> \h` , 要退出psql，输入：`mydb=> \q`,psql将会退出并且让你返回到命令行shell



## SQL 语言

- 可以在PostgreSQL源代码的目录src/tutorial/中找到（二进制PostgreSQL发布中可能没有编译这些文件）。要使用这些文件，首先进入该目录然后运行make：

```pgsql
$ cd ..../src/tutorial
$ make
```

- 创建了那些脚本并编译了包含用户定义函数和类型的 C 文件

```pgsql
$ cd ..../tutorial
$ psql -s mydb
...

mydb=> \i basics.sql
```

- `\i`命令从指定的文件中读取命令。psql的`-s`选项把你置于单步模式，它在向服务器发送每个语句之前暂停。 在本节使用的命令都在文件basics.sql中。


###  创建、删除新表

```pgsql
CREATE TABLE weather (
    city            varchar(80),  --存储最长 80 个字符的任意字符串的数据类型
    temp_lo         int,           -- 最低温度
    temp_hi         int,           -- 最高温度
    prcp            real,          -- 湿度 real是一种用于存储单精度浮点数的类型
    date            date
);
```

- 可以在 SQL 命令中自由使用空白（即空格、制表符和换行符）。 这就意味着可以用和上面不同的对齐方式键入命令，或者将命令全部放在一行中。两个划线`（“--”）`引入注释。 任何跟在它后面直到行尾的东西都会被忽略。SQL 是对关键字和标识符大小写不敏感的语言，只有在标识符用双引号包围时才能保留它们的大小写

- PostgreSQL支持标准的SQL类型int、smallint、real、double precision、char(N)、varchar(N)、date、time、timestamp和interval，还支持其他的通用功能的类型和丰富的几何类型。PostgreSQL中可以定制任意数量的用户定义数据类型。因而类型名并不是语法关键字，除了SQL标准要求支持的特例外。


```pgsql
--将保存城市和它们相关的地理位置
CREATE TABLE cities (
    name            varchar(80),
    location        point --point就是一种PostgreSQL特有数据类型
);
```

```pgsql
--删除
DROP TABLE tablename;
```

### 插入数据


#### 命令行形式

```pgsql
INSERT INTO weather VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27'); --那些不是简单数字值的常量通常必需用单引号（'）包围

INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)'); --point类型要求一个坐标对作为输入

INSERT INTO weather (city, temp_lo, temp_hi, prcp, date) VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');

INSERT INTO weather (date, city, temp_hi, temp_lo) VALUES ('1994-11-29', 'Hayward', 54, 37);
```

#### 拷贝

```pgsql
COPY weather FROM '/home/user/weather.txt'; --可以使用COPY从文本文件中装载大量数据
```

### 查询表数据

```pgsql
SELECT * FROM weather;

SELECT city, temp_lo, temp_hi, prcp, date FROM weather;

SELECT city, (temp_hi+temp_lo)/2 AS temp_avg, date FROM weather;

SELECT * FROM weather WHERE city = 'San Francisco' AND prcp > 0.0;

SELECT * FROM weather ORDER BY city;

SELECT * FROM weather ORDER BY city, temp_lo;

SELECT DISTINCT city FROM weather ORDER BY city;
```

### 表连接

```pgsql
SELECT * FROM weather, cities WHERE city = name;

SELECT * FROM weather LEFT OUTER JOIN cities ON (weather.city = cities.name);
```

### 聚集函数

和大多数其它关系数据库产品一样，PostgreSQL支持聚集函数。 一个聚集函数从多个输入行中计算出一个结果。 比如，我们有在一个行集合上计算count（计数）、sum（和）、avg（均值）、max（最大值）和min（最小值）的函数。

```pgsql
SELECT max(temp_lo) FROM weather;
```


```pgsql
SELECT city FROM weather WHERE temp_lo = max(temp_lo);  --这个方法不能运转，因为聚集max不能被用于WHERE子句中（存在这个限制是因为WHERE子句决定哪些行可以被聚集计算包括；因此显然它必需在聚集函数之前被计算）

SELECT city FROM weather WHERE temp_lo = (SELECT max(temp_lo) FROM weather); --该读数发生在哪个城市


SELECT city, max(temp_lo)  FROM weather GROUP BY city; --获取每个城市观测到的最低温度的最高值

SELECT city, max(temp_lo) FROM weather GROUP BY city HAVING max(temp_lo) < 40;  --所有temp_lo值曾都低于 40的城市

SELECT city, max(temp_lo)  FROM weather  WHERE city LIKE 'S%'   GROUP BY city HAVING max(temp_lo) < 40; --只关心那些名字以“S”开头的城市
```

#### where和having

WHERE和HAVING的基本区别如下：WHERE在分组和聚集计算之前选取输入行（因此，它控制哪些行进入聚集计算）， 而HAVING在分组和聚集之后选取分组行。因此，WHERE子句不能包含聚集函数； 因为试图用聚集函数判断哪些行应输入给聚集运算是没有意义的。相反，HAVING子句总是包含聚集函数（严格说来，你可以写不使用聚集的HAVING子句， 但这样做很少有用。同样的条件用在WHERE阶段会更有效）。

### 更新和删除数据

```pgsql
UPDATE weather
    SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
    WHERE date > '1994-11-28';
```

```pgsql
DELETE FROM weather WHERE city = 'Hayward'; --对Hayward的天气不再感兴趣
```




## 特性

`advanced.sql`文件可查看


### 视图

假设天气记录和城市为止的组合列表对我们的应用有用，但我们又不想每次需要使用它时都敲入整个查询。我们可以在该查询上创建一个视图，这会给该查询一个名字，我们可以像使用一个普通表一样来使用它：

```pgsql
CREATE VIEW myview AS
    SELECT city, temp_lo, temp_hi, prcp, date, location
        FROM weather, cities
        WHERE city = name;

SELECT * FROM myview;
```

### 外键

```pgsql
CREATE TABLE cities (
        city     varchar(80) primary key,
        location point
);

CREATE TABLE weather (
        city      varchar(80) references cities(city),
        temp_lo   int,
        temp_hi   int,
        prcp      real,
        date      date
);
```

### 事务


事务是所有数据库系统的基础概念。事务最重要的一点是它将多个步骤捆绑成了一个单一的、要么全完成要么全不完成的操作。步骤之间的中间状态对于其他并发事务是不可见的，并且如果有某些错误发生导致事务不能完成，则其中任何一个步骤都不会对数据库造成影响。

例如，考虑一个保存着多个客户账户余额和支行总存款额的银行数据库。假设我们希望记录一笔从Alice的账户到Bob的账户的额度为100.00美元的转账。在PostgreSQL中，开启一个事务需要将SQL命令用BEGIN和COMMIT命令包围起来。因此我们的银行事务看起来会是这样：

```pgsql
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
-- etc etc
COMMIT;  --在事务执行中我们并不想提交 ROLLBACK命令
```

PostgreSQL实际上将每一个SQL语句都作为一个事务来执行。如果我们没有发出BEGIN命令，则每个独立的语句都会被加上一个隐式的BEGIN以及（如果成功）COMMIT来包围它。一组被BEGIN和COMMIT包围的语句也被称为一个事务块。

#### 保存点

也可以利用保存点来以更细的粒度来控制一个事务中的语句。保存点允许我们有选择性地放弃事务的一部分而提交剩下的部分。在使用SAVEPOINT定义一个保存点后，我们可以在必要时利用ROLLBACK TO回滚到该保存点。该事务中位于保存点和回滚点之间的数据库修改都会被放弃，但是早于该保存点的修改则会被保存。

```pgsql
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
-- oops ... forget that and use Wally's account
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;
```

在一个事务块中使用保存点存在很多种控制可能性。此外，ROLLBACK TO是唯一的途径来重新控制一个由于错误被系统置为中断状态的事务块，而不是完全回滚它并重新启动。


### 窗口函数

一个窗口函数在一系列与当前行有某种关联的表行上执行一种计算。这与一个聚集函数所完成的计算有可比之处。但是窗口函数并不会使多行被聚集成一个单独的输出行，这与通常的非窗口聚集函数不同。取而代之，行保留它们独立的标识。在这些现象背后，窗口函数可以访问的不仅仅是查询结果的当前行。

```pgsql
SELECT depname, empno, salary, avg(salary) OVER (PARTITION BY depname) FROM empsalary; --将每一个员工的薪水与他/她所在部门的平均薪水进行比较
```

```
  depname  | empno | salary |          avg
-----------+-------+--------+-----------------------
 develop   |    11 |   5200 | 5020.0000000000000000
 develop   |     7 |   4200 | 5020.0000000000000000
 develop   |     9 |   4500 | 5020.0000000000000000
 develop   |     8 |   6000 | 5020.0000000000000000
 develop   |    10 |   5200 | 5020.0000000000000000
 personnel |     5 |   3500 | 3700.0000000000000000
 personnel |     2 |   3900 | 3700.0000000000000000
 sales     |     3 |   4800 | 4866.6666666666666667
 sales     |     1 |   5000 | 4866.6666666666666667
 sales     |     4 |   4800 | 4866.6666666666666667
(10 rows)
```
最开始的三个输出列直接来自于表empsalary，并且表中每一行都有一个输出行。第四列表示对与当前行具有相同depname值的所有表行取得平均值（这实际和非窗口avg聚集函数是相同的函数，但是OVER子句使得它被当做一个窗口函数处理并在一个合适的窗口帧上计算。）。

一个窗口函数调用总是包含一个直接跟在窗口函数名及其参数之后的OVER子句。这使得它从句法上和一个普通函数或非窗口函数区分开来。OVER子句决定究竟查询中的哪些行被分离出来由窗口函数处理。OVER子句中的PARTITION BY子句指定了将具有相同PARTITION BY表达式值的行分到组或者分区。对于每一行，窗口函数都会在当前行同一分区的行上进行计算。


我们可以通过OVER上的ORDER BY控制窗口函数处理行的顺序（窗口的ORDER BY并不一定要符合行输出的顺序。）

```pgsql
SELECT depname, empno, salary,
       rank() OVER (PARTITION BY depname ORDER BY salary DESC) FROM empsalary;
       
-- rank函数在当前行的分区内按照ORDER BY子句的顺序为每一个可区分的ORDER BY值产生了一个数字等级。rank不需要显式的参数，因为它的行为完全决定于OVER子句。
```

#### 窗口帧

对于每一行，在它的分区中的行集被称为它的窗口帧。 一些窗口函数只作用在窗口帧中的行上，而不是整个分区。默认情况下，如果使用ORDER BY，则帧包括从分区开始到当前行的所有行，以及后续任何与当前行在ORDER BY子句上相等的行。如果ORDER BY被忽略，则默认帧包含整个分区中所有的行

```pgsql
SELECT salary, sum(salary) OVER () FROM empsalary;


 salary |  sum
--------+-------
   5200 | 47100
   5000 | 47100
   3500 | 47100
   4800 | 47100
   3900 | 47100
   4200 | 47100
   4500 | 47100
   4800 | 47100
   6000 | 47100
   5200 | 47100
(10 rows)

--由于在OVER子句中没有ORDER BY，窗口帧和分区一样，而如果缺少PARTITION BY则和整个表一样。换句话说，每个合计都会在整个表上进行，这样我们为每一个输出行得到的都是相同的结果

```

```pgsql

SELECT salary, sum(salary) OVER (ORDER BY salary) FROM empsalary;


 salary |  sum
--------+-------
   3500 |  3500
   3900 |  7400
   4200 | 11600
   4500 | 16100
   4800 | 25700
   4800 | 25700
   5000 | 30700
   5200 | 41100
   5200 | 41100
   6000 | 47100
(10 rows)


--加上一个ORDER BY子句，我们会得到非常不同的结果
--这里的合计是从第一个（最低的）薪水一直到当前行，包括任何与当前行相同的行（注意相同薪水行的结果）
```

#### 注意

窗口函数只允许出现在查询的SELECT列表和ORDER BY子句中。它们不允许出现在其他地方，例如GROUP BY、HAVING和WHERE子句中。这是因为窗口函数的执行逻辑是在处理完这些子句之后。另外，窗口函数在非窗口聚集函数之后执行。这意味着可以在窗口函数的参数中包括一个聚集函数，但反过来不行。

如果需要在窗口计算执行后进行过滤或者分组，我们可以使用子查询。例如：

```pgsql
SELECT depname, empno, salary, enroll_date
FROM
  (SELECT depname, empno, salary, enroll_date,
          rank() OVER (PARTITION BY depname ORDER BY salary DESC, empno) AS pos
     FROM empsalary
  ) AS ss
WHERE pos < 3;

--仅仅显示了内层查询中rank低于3的结果
```


当一个查询涉及到多个窗口函数时，可以将每一个分别写在一个独立的OVER子句中。但如果多个函数要求同一个窗口行为时，这种做法是冗余的而且容易出错的。替代方案是，每一个窗口行为可以被放在一个命名的WINDOW子句中，然后在OVER中引用它。例如：

```pgsql
SELECT sum(salary) OVER w, avg(salary) OVER w
  FROM empsalary
  WINDOW w AS (PARTITION BY depname ORDER BY salary DESC);
```

### 继承

继承是面向对象数据库中的概念。它展示了数据库设计的新的可能性。

让我们创建两个表：表cities和表capitals。自然地，首都也是城市，所以我们需要有某种方式能够在列举所有城市的时候也隐式地包含首都。如果真的聪明，我们会设计如下的模式：

```pgsql
CREATE TABLE capitals (
  name       text,
  population real,
  altitude   int,    -- (in ft)
  state      char(2)
);

CREATE TABLE non_capitals (
  name       text,
  population real,
  altitude   int     -- (in ft)
);

CREATE VIEW cities AS
  SELECT name, population, altitude FROM capitals
    UNION
  SELECT name, population, altitude FROM non_capitals;
```

这个模式对于查询而言工作正常，但是当我们需要更新一些行时它就变得不好用了。

更好的方案是：

```pgsql
CREATE TABLE cities (
  name       text,
  population real,
  altitude   int     -- (in ft)
);

CREATE TABLE capitals (
  state      char(2)
) INHERITS (cities);
```

在这种情况下，一个capitals的行从它的父亲cities继承了所有列（name、population和altitude）。列name的类型是text，一种用于变长字符串的本地PostgreSQL类型。州首都有一个附加列state用于显示它们的州。在PostgreSQL中，一个表可以从0个或者多个表继承。

例如，如下查询可以寻找所有海拔500尺以上的城市名称，包括州首都：


```pgsql
SELECT name, altitude
  FROM cities
  WHERE altitude > 500;

   name    | altitude
-----------+----------
 Las Vegas |     2174
 Mariposa  |     1953
 Madison   |      845
(3 rows)


--在另一方面，下面的查询可以查找所有海拔高于500尺且不是州首府的城市：

SELECT name, altitude
    FROM ONLY cities
    WHERE altitude > 500;
    
   name    | altitude
-----------+----------
 Las Vegas |     2174
 Mariposa  |     1953
(2 rows)
```

其中cities之前的ONLY用于指示查询只在cities表上进行而不会涉及到继承层次中位于cities之下的其他表。很多我们已经讨论过的命令 — SELECT、UPDATE 和DELETE — 都支持这个ONLY记号。


# 第二部分-PostgreSQL中SQL语言运用

## SQL语法

### 语法结构

#### 标识符和关键字

受限标识符或被引号修饰的标识符。它是由双引号（"）包围的一个任意字符序列。一个受限标识符总是一个标识符而不会是一个关键字。因此"select"可以用于引用一个名为“select”的列或者表，而一个没有引号修饰的select则会被当作一个关键词，从而在本应使用表或列名的地方引起解析错误。在上例中使用受限标识符的例子如下：

```pgsql
UPDATE "my_table" SET "a" = 5;
```

受限标识符可以包含任何字符，除了代码为0的字符（如果要包含一个双引号，则写两个双引号）。这使得可以构建原本不被允许的表或列的名称，例如包含空格或花号的名字。但是长度限制依然有效。

一种受限标识符的变体允许包括转义的用代码点标识的Unicode字符。这种变体以U&（大写或小写U跟上一个花号）开始，后面紧跟双引号修饰的名称，两者之间没有任何空白，如U&"foo"（注意这里与操作符&似乎有一些混淆，但是在&操作符周围使用空白避免了这个问题） 。在引号内，Unicode字符可以以转义的形式指定：反斜线接上4位16进制代码点号码或者反斜线和加号接上6位16进制代码点号码。例如，标识符"data"可以写成：

```pgsql
U&"d\0061t\+000061"

U&"\0441\043B\043E\043D" --用斯拉夫语字母写出了俄语单词 “slon”（大象）

U&"d!0061t!+000061" UESCAPE '!' --使用其他转义字符来代替反斜线，可以在字符串后使用UESCAPE子句
```

转义字符可以是除了16进制位、加号、单引号、双引号、空白字符之外的任意单个字符。注意转义字符是被写在单引号而不是双引号内。

为了在标识符中包括转义字符本身，将其写两次即可。

Unicode转义语法只有在服务器编码为UTF8时才起效。当使用其他服务器编码时，只有在ASCII范围内（最高到\007F）的编码点才能被使用。4位和6位形式都可以被用来定义UTF-16代理对来组成代码点大于U+FFFF的字符，尽管6位形式的存在使得这种做法变得不必要（代理对并不被直接存储，而是被被绑定到一个单独的代码点然后被编码到UTF-8）。

将一个标识符变得受限同时也使它变成大小写敏感的，反之非受限名称总是被转换成小写形 式。例如，标识符FOO、foo和"foo"在PostgreSQL中被认为是相同的，而"Foo"和"FOO"则互 不相同且也不同于前面三个标识符（PostgreSQL将非受限名字转换为小写形式与SQL标准是不兼容 的，SQL标准中要求将非受限名称转换为大写形式。这样根据标准， foo应该和 "FOO"而不是"foo"相同。如果希望写一个可移植的应用，我们应该总是用引号修饰一个特定名字或者 从不使用 引号修饰）。

#### 常量


在PostgreSQL中有三种隐式类型常量：字符串、位串和数字。常量也可以被指定显示类型，这可以使得它被更精确地展示以及更有效地处理

- 字符串常量，一个字符串常量是一个由单引号（'）包围的任意字符序列

```pgsql
-- 两个只由空白及至少一个新行分隔的字符串常量会被连接在一起，并且将作为一个写在一起的字符串常量来对待
SELECT 'foo'
'bar';
--等同于
SELECT 'foobar';
--错误写法
SELECT 'foo'      'bar';
```

- C风格转义的字符串常量


反斜线转义序列|解释|
:-:|:-:|
\b|	退格
\f|	换页
\n|	换行
\r|	回车
\t|	制表符
\o, \oo, \ooo (o = 0 - 7)	|八进制字节值
\xh, \xhh (h = 0 - 9, A - F)	|十六进制字节值
\uxxxx, \Uxxxxxxxx (x = 0 - 9, A - F)	|16 或 32-位十六进制 Unicode 字符值

- 带有 Unicode 转义的字符串常量,PostgreSQL也支持另一种类型的字符串转义语法，它允许用代码点指定任意 Unicode 字符。一个 Unicode 转义字符串常量开始于U&（大写或小写形式的字母 U，后跟花号），后面紧跟着开引号，之间没有任何空白，例如U&'foo'（注意这产生了与操作符&的混淆。在操作符周围使用空白来避免这个问题）。在引号内，Unicode 字符可以通过写一个后跟 4 位十六进制代码点编号或者一个前面有加号的 6 位十六进制代码点编号的反斜线来指定

```pgsql
-- 字符串'data'可以被写为
U&'d\0061t\+000061'
--用斯拉夫字母写出了俄语的单词“slon”（大象）
U&'\0441\043B\043E\043D'
--如果想要一个不是反斜线的转义字符，可以在字符串之后使用UESCAPE子句来指定
U&'d!0061t!+000061' UESCAPE '!'
```

- 美元引用的字符串常量,一个美元引用的字符串常量由一个美元符号（$）、一个可选的另个或更多字符的“标签”、另一个美元符号、一个构成字符串内容的任意字符序列、一个美元符号、开始这个美元引用的相同标签和一个美元符号组成

```pgsql
--两种不同的方法使用美元引用指定字符串“Dianne's horse”：
$$Dianne's horse$$
$SomeTag$Dianne's horse$SomeTag$

--可以通过在每一个嵌套级别上选择不同的标签来嵌套美元引用字符串常量。这最常被用在编写函数定义上
$function$
BEGIN
    RETURN ($1 ~ $q$[\t\r\n\v\\]$q$);
END;
$function$
```

- 位串常量, 位串常量看起来像常规字符串常量在开引号之前（中间无空白）加了一个B（大写或小写形式），例如B'1001'。位串常量中允许的字符只有0和1。
作为一种选择，位串常量可以用十六进制记号法指定，使用一个前导X（大写或小写形式）,例如X'1FF'。这种记号法等价于一个用四个二进制位取代每个十六进制位的位串常量。

- 数字常量，在这些一般形式中可以接受数字常量：

```pgsql
digits
digits.[digits][e[+-]digits]
[digits].digits[e[+-]digits]
digitse[+-]digits

42
3.5
4.
.001
5e2
1.925e-3
```

如果一个不包含小数点和指数的数字常量的值适合类型integer（32 位），它首先被假定为类型integer。否则如果它的值适合类型bigint（64 位），它被假定为类型bigint。再否则它会被取做类型numeric。包含小数点和/或指数的常量总是首先被假定为类型numeric。

一个数字常量初始指派的数据类型只是类型转换算法的一个开始点。在大部分情况中，常量将被根据上下文自动被强制到最合适的类型。必要时，你可以通过造型它来强制一个数字值被解释为一种指定数据类型。例如，你可以这样强制一个数字值被当做类型real（float4）：

```pgsql
REAL '1.23'  -- string style
1.23::REAL   -- PostgreSQL (historical) style
```

- 其他类型的常量

一种任意类型的一个常量可以使用下列记号中的任意一种输入：

```pgsql
type 'string'
'string'::type
CAST ( 'string' AS type )
```

字符串常量的文本被传递到名为type的类型的输入转换例程中。其结果是指定类型的一个常量。如果对该常量的类型没有歧义（例如，当它被直接指派给一个表列时），显式类型造型可以被忽略，在那种情况下它会被自动强制。

字符串常量可以使用常规 SQL 记号或美元引用书写。也可以使用一个类似函数的语法来指定一个类型强制：`typename ( 'string' )`


::、CAST()以及函数调用语法也可以被用来指定任意表达式的运行时类型转换。要避免语法歧义，type 'string'语法只能被用来指定简单文字常量的类型。type 'string'语法上的另一个限制是它无法对数组类型工作，指定一个数组常量的类型可使用::或CAST()。

CAST()语法符合 SQL。type 'string'语法是该标准的一般化：SQL 指定这种语法只用于一些数据类型，但是PostgreSQL允许它用于所有类型。带有::的语法是PostgreSQL的历史用法，就像函数调用语法一样。


#### 操作符


一个操作符名是最多NAMEDATALEN-1（默认为 63）的一个字符序列，其中的字符来自下面的列表：

```
+ - * / < > = ~ ! @ # % ^ & | ` ?
```

不过，在操作符名上有一些限制：

`-- `和 `/*`不能在一个操作符名的任何地方出现，因为它们将被作为一段注释的开始。

一个多字符操作符名不能以+或-结尾，除非该名称也至少包含这些字符中的一个：

```
~ ! @ # % ^ & | ` ?
```

例如，`@-`是一个被允许的操作符名，但`*-`不是。这些限制允许PostgreSQL解析 SQL 兼容的查询而不需要在记号之间有空格。

当使用非 SQL 标准的操作符名时，你通常需要用空格分隔相邻的操作符来避免歧义。例如，如果你定义了一个名为`@`的左一元操作符，你不能写`X*@Y`，你必须写`X* @Y`来确保PostgreSQL把它读作两个操作符名而不是一个。

#### 特殊字符

一些不是数字字母的字符有一种不同于作为操作符的特殊含义。这些字符的详细用法可以在描述相应语法元素的地方找到。这一节只是为了告知它们的存在以及总结这些字符的目的。

- 跟随在一个美元符号（$）后面的数字被用来表示在一个函数定义或一个预备语句中的位置参数。在其他上下文中该美元符号可以作为一个标识符或者一个美元引用字符串常量的一部分。

- 圆括号（()）具有它们通常的含义，用来分组表达式并且强制优先。在某些情况中，圆括号被要求作为一个特定 SQL 命令的固定语法的一部分。

- 方括号（[]）被用来选择一个数组中的元素。

- 逗号（,）被用在某些语法结构中来分割一个列表的元素。

- 分号（;）结束一个 SQL 命令。它不能出现在一个命令中间的任何位置，除了在一个字符串常量中或者一个被引用的标识符中。

- 冒号（:）被用来从数组中选择“切片”。在某些 SQL 的“方言”（例如嵌入式 SQL）中，冒号被用来作为变量名的前缀。

- 星号（*）被用在某些上下文中标记一个表的所有域或者组合值。当它被用作一个聚合函数的参数时，它还有一种特殊的含义，即该聚合不要求任何显式参数。

- 句点（.）被用在数字常量中，并且被用来分割模式、表和列名。

#### 注释

```pgsql
-- This is a standard SQL comment

/* multiline comment
 * with nesting: /* nested block comment */
 */
```


#### 操作符优先级

PostgreSQL 中操作符的优先级和结合性。大部分操作符具有相同的优先并且是左结合的。 操作符的优先级和结合性被硬写在解析器中。

当使用二元和一元操作符的组合时，有时你将需要增加圆括号。例如：

```pgsql

SELECT 5 ! - 6; --> 自动解析为：SELECT 5 ! (- 6); 被定义为一个后缀操作符而不是一个中缀操作符

想获得的行为

SELECT (5 !) - 6;

```

<strong> **操作符优先级** </strong>

|操作符/元素|	结合性|	描述
|:-:|:-:|:-:|
.	|左	|表/列名分隔符
::	|左	|PostgreSQL-风格的类型转换
[ ]|	左	|数组元素选择
+ -|	右	|一元加、一元减
^	|左	|指数
* / %	|左|	乘、除、模
+ -	|左|	加、减
（任意其他操作符）|	左	|所有其他本地以及用户定义的操作符
BETWEEN IN LIKE ILIKE SIMILAR	 ||	范围包含，设置成员，字符串匹配
< > = <= >= <>	 ||	比较操作符
IS ISNULL NOTNULL	 ||	IS TRUE、IS FALSE、IS NULL、IS DISTINCT FROM等
NOT	|右	|逻辑否定
AND	|左	|逻辑合取
OR|	左	|逻辑析取


> 注意该操作符有限规则也适用于与上述内建操作符具有相同名称的用户定义的操作符。例如，如果你为某种自定义数据类型定义了一个“+”操作符，它将具有和内建的“+”操作符相同的优先级，不管你的操作符要做什么。当一个模式限定的操作符名被用在OPERATOR语法中时，如下面的例子：


```pgsql
SELECT 3 OPERATOR(pg_catalog.+) 4;

## OPERATOR结构被用来为“任意其他操作符”获得表中默认的优先级。不管出现在 OPERATOR()中的是哪个指定操作符，这都是真的。
```

##### 注意

版本 9.5 之前的PostgreSQL使用的操作符优先级规则略有不同。 特别是，<=、>=和<> 习惯于被当作普通操作符，IS测试习惯于具有较高的优先级。 并且在一些具有NOT而不是BETWEEN优先级的情况下， NOT BETWEEN和相关的结构的行为不一致。 为了更好地兼容 SQL 标准并且减少对逻辑上等价的结构不一致的处理， 这些规则也得到了修改。在大部分情况下，这些变化不会导致行为上的变化， 或者可能会产生“no such operator”错误，但可以通过增加圆括号解决。 不过在一些极端情况中，查询可能在没有被报告解析错误的情况下发生行为的改变。 如果你担心这些改变悄悄地破坏了一些事情，可以打开 operator_precedence_warning配置参数， 然后测试你的应用看看有没有一些警告被记录。

### 值表达式

值表达式被用于各种各样的环境中，例如在SELECT命令的目标列表中、作为INSERT或UPDATE中的新列值或者若干命令中的搜索条件。为了区别于一个表表达式（是一个表）的结果，一个值表达式的结果有时候被称为一个标量。值表达式因此也被称为标量表达式（或者甚至简称为表达式）。表达式语法允许使用算数、逻辑、集合和其他操作从原始部分计算值。

#### 值表达式范围

* 一个常量或文字值
* 一个列引用
* 在一个函数定义体或预备语句中的一个位置参数引用
* 一个下标表达式
* 一个域选择表达式
* 一个操作符调用
* 一个函数调用
* 一个聚合表达式
* 一个窗口函数调用
* 一个类型转换
* 一个排序规则表达式
* 一个标量子查询
* 一个数组构造器
* 一个行构造器
* 另一个在圆括号（用来分组子表达式以及重载优先级）中的值表达式

在这个列表之外，还有一些结构可以被分类为一个表达式，但是它们不遵循任何一般语法规则。这些通常具有一个函数或操作符的语义。一个例子是`IS NULL`子句。

#### 列引用

> 一个列可以以下面的形式被引用 `correlation.columnname`

correlation是一个表（有可能以一个模式名限定）的名字，或者是在FROM子句中为一个表定义的别名。如果列名在当前索引所使用的表中都是唯一的，关联名称和分隔用的句点可以被忽略

#### 位置参数

一个位置参数引用被用来指示一个由 SQL 语句外部提供的值。参数被用于 SQL 函数定义和预备查询中。某些客户端库还支持独立于 SQL 命令字符串来指定数据值，在这种情况中参数被用来引用那些线外数据值。一个参数引用的形式是`$number`

考虑一个函数dept的定义：

```pgsql	
CREATE FUNCTION dept(text) RETURNS dept
    AS $$ SELECT * FROM dept WHERE name = $1 $$    ##这里$1引用函数被调用时第一个函数参数的值。
    LANGUAGE SQL;
```

#### 下标

如果一个表达式得到了一个数组类型的值，那么可以抽取出该数组值的一个特定元素. `expression[subscript]`
或者抽取出多个相邻元素（一个“数组切片”) `expression[lower_subscript:upper_subscript]`


通常，数组表达式必须被加上括号，但是当要被加下标的表达式只是一个列引用或位置参数时，括号可以被忽略。还有，当原始数组是多维时，多个下标可以被连接起来。例如：

```pgsql
mytable.arraycolumn[4]
mytable.two_d_column[17][34]
$1[10:42]
(arrayfunction(a,b))[42]
```

#### 域选择

如果一个表达式得到一个组合类型（行类型）的值，那么可以抽取该行的指定域 `expression.fieldname`

