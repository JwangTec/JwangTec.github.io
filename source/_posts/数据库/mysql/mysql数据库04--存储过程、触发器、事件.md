---
title: mysql数据库04--存储过程、触发器、事件
categories: 数据库
tags:
  - mysql存储器
  - mysql触发器
  - mysql事件
top: 8
abbrlink: 898521826
date: 2019-05-07 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/mysql.jpeg" width="1000" height="200" align="middle" />

## mysql进阶

<!--more-->

###  1.概述


1.存储函数（stored function）。返回一个计算结果，该结果可以用在表达式里。
2.存储过程（stored procedure）。不直接返回一个结果，但可以用来完成一般的运算或是生成一个结果集并传递回客户。
3.触发器（trigger）。与数据表相关联，当那个数据表被INSERT、DELETE或UPDATE语句修改时，触发器将自动执行。
4.事件（event）。根据时间表在预定时刻自动执行。


###  2.存储过程

1.存储过程和存储函数的区别
	使用存储过程的情况主要有两种：
	（1）只需通过运算来实现某种效果或动作而无需返回一个值，
	（2）运算会返回多个结果集（函数做不到这一点）。这只是些指导性建议，不是硬性规定。
	存储函数要用CREATE FUNCTION语句来创建，存储过程要用CREATE PROCEDURE语句来创建，为了与数据表或数据列的名字有所区别，给参数起名字时将使用p_前缀。

2.分隔符,由于mysql默认分隔符是 ; 如果我们使用了;表示存储过程已经结束,但是mysql默认语句也是;结束,如果我们想要在存储过程中多加几个sql语句怎么办？我们需要先修改分割符,然后写sql语句和存储过程然后恢复到默认的分隔符。

3.delimiter命令把mysql程序的语句分隔符重定义为另一个字符或字符串，它必须是在存储例程的定义里没有出现过的。

```
创建存储过程：
delimiter $
create procedure show_born()
begin
select 1;
select 2;
end$
delimiter ;
存储过程调用：
call show_born
存储过程参数传入：
create procedure p1 (p_id INT) begin select p_id; end$

创建存储函数：
delimiter $
create function show()
begin
select 1;
select 2;
end$
delimiter ;

```

###  3.触发器

1.触发器是与特定数据表相关联的存储过程，当相应的数据表被INSERT、DELETE或UPDATE语句修改时，触发器将自动执行。
触发器可以被设置成在这几种语句处理每个数据行之前或之后触发。触发器的定义包括一条将在触发器被触发时执行的语句。


2.创建触发器

```
每次创建新值的时候,新的数据列test2都会变成999:
create trigger test1_t before insert on test1 for each row begin set NEW.test2=999; end$

```

### 4.事件

1.我们可以把数据库操作安排在预定时间执行。事件是与一个时间表相关联的存储程序，时间表用来定义事件发生的时间、次数以及何时消失。事件非常适合用来执行各种无人值守的系统管理任务，如定期更新汇总报告、清理过期失效的数据、对日志数据表进行轮转等。

2.默认条件下，事件不会执行，需要启动事件调度器：
	
	把以下语句添加到一个选项文件中（服务器在启动时将读取）： [mysqld] event_scheduler=ON

3.查看事件调度器状态：show variables like 'event_scheduler'

4.创建事件：
	
	create event e1 on schedule every 5 second do insert into test1 (test1)values('8888');
	
	do 定义语句部分
	
5.事件禁用和激活
	
	事件禁用：
		alter event e1 disable;
	事件激活：
		alter event e1 enable;