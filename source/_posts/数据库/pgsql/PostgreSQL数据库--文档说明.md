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






