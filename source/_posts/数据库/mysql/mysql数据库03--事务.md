---
title: mysql数据库03--事务
categories: 数据库
tags:
  - mysql数据库事务
top: 8
abbrlink: 864966898
date: 2019-05-06 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/mysql.jpeg" width="1000" height="200" align="middle" />

###  mysql隔离级别

<!--more-->

隔离级别是mysql进行事务提交的时候,对数据的一种表现形式

####  1. 事务的基本要素（ACID）

1.1 原子性（Atomicity）：

事务开始后所有操作，要么全部做完，要么全部不做，不可能停滞在中间环节。事务执行过程中出错，会回滚到事务开始前的状态，所有的操作就像没有发生一样。也就是说事务是一个不可分割的整体，就像化学中学过的原子，是物质构成的基本单位。

1.2 一致性（Consistency）：

事务开始前和结束后，数据库的完整性约束没有被破坏 。比如A向B转账，不可能A扣了钱，B却没收到。

1.3 隔离性（Isolation）：

同一时间，只允许一个事务请求同一数据，不同的事务之间彼此没有任何干扰。比如A正在从一张银行卡中取钱，在A取钱的过程结束前，B不能向这张卡转账。

1.4 持久性（Durability）：

事务完成后，事务对数据库的所有更新将被保存到数据库，不能回滚。

#### 2. 事务的操作方式

提交使用commit 回滚使用 rollback

	
	begin
	
	'''''语句快
	
	commit
	

#### 3.事务的并发问题

3.1 脏读：事务A读取了事务B更新的数据，然后B回滚操作，那么A读取到的数据是脏数据

3.2 不可重复读：事务 A 多次读取同一数据，事务 B 在事务A多次读取的过程中，对数据作了更新并提交，导致事务A多次读取同一数据时，结果 不一致。

3.3 幻读：系统管理员A将数据库中所有学生的成绩从具体分数改为ABCDE等级，但是系统管理员B就在这个时候插入了一条具体分数的记录，当系统管理员A改结束后发现还有一条记录没有改过来，就好像发生了幻觉一样，这就叫幻读。


|事物隔离级别|胀读|不可重复读|幻读|
|:-:|:-:|:-:|:-:|
|读未提交（read-uncommitted）|是|是|是
|不可重复读（read-committed）	|否|	是|	是
|可重复读（repeatable-read）	|否|	否|	是
|串行化（serializable）	|否|	否|	否



3.4 语句实现

```
	
说明: 我们使用a,b两个端 a负责开启事务,并且修改数据。b负责开启事务,并且在a执行事务的时候不断去获取数
	  据。以此研究数据的影响.a先执行,因为a需要去修改数据,所以a要首先获取到锁才行

1.脏读:
首先在b中去设置隔离级别
a客户端
	start transaction
	update `Employee` set Name='test2' where Id=1
b客户端
	set session transaction isolation level read uncommitted
	start transaction
	select * from `Employee`
可以看到a中修改的数据,b中已经可以查看到,但是a的数据并没有commit,b读取到了a还没有提交上
去的脏数据,称为脏读

2.不可复读:
a客户端
	start transaction
	update `Employee` set Name='test2' where Id=1
b客户端
	set session transaction isolation level read committed
	start transaction
	select * from `Employee`
这时候再去查看数据就不会出现脏读的情况,但是在a提交之后,再使用b去查看的话就会有一定的问题

a客户端
	commit
b客户端
	select * from `Employee`
这时候b的中表的数据就变了,虽然没有脏读的情况,但是b中的数据两次不一样, 所以称之为不可复读

3.幻读:
a客户端
	start transaction
	update `Employee` set Name='test2' where Id=1
b客户端
	set session transaction isolation level REPEATABLE read
	start transaction
	select * from `Employee`
这个时候,b中查看的数据没有没有问题,他看到的一直都是老数据。这里使用了mvvc技术

a客户端
	commit
b客户端
	select * from `Employee`
但是有一个问题,当a表去Insert一条数据数据并且commit了之后,b去select的时候就会看到a表中新加的数据,就像幻读
一样,多出了一条数据来

a
	start transaction
	insert into `Employee` (name,id)value('test',10
	commit
为了避免这个问题,b可以设置
	set session transaction isolation level serializable
在a操作事务的时候,b操作事务会一直卡住,直到a表操作完成b才能去select操作，这就是串行化

4. mysql默认的级别是不可复读
```


3.5 不可重复读 和 幻读

不可复读是针对同一条数据两次读取会有变化 幻读是说当select到数据id=9的时候,这个时候我们可以去插入id=10的数据,但是其他的事务已经插入了id=10的记录,这个时候就会报错。但是从本事务的观点来看id为10的东西是不存在的。所以就想有幻觉一样,称为幻读。

其实对于 幻读, MySQL的InnoDB引擎默认的RR级别已经通过MVCC自动帮我们(部分)解决了。因为当其他事务增加一条数据的时候。我们两次执行查询语句结果都是一样的。这是使用了mvcc模式来实现的,在RR模式下面，事务每次读取的都是一个快照。同一个事务中每次都读取同一份快照。所以就算数据更新了。读的也是老数据