---
title: mysql数据库01--基础语句
categories: 数据库
tags: [mysql数据库, 关系型数据库]
top: 8
abbrlink: 1749468513
date: 2019-05-06 18:18:19
password:
---


<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/mysql.jpeg" width="1000" height="200" align="middle" />

###  sql 基础语法


<!--more-->

1.创建学生数据库

	create database Student; 
	
2.使用学生数据库
	
	use Student; 

3.创建成绩表，字段后加not null 则表示不能为空，在查看表结构时为no，default可设置默认值

	create table score(id int(20) not null auto_increment,
				   name varchar(10) default 'aa',
				   score_num int(100)，
				   primary key (id)   
					);   

	null:代表未定义的值，不能使用在语句中，但可以通过is null判断某一个字段是否为空
	主键和外键的设置在创建字段之后设置

	auto_increment:从1递增 一个表只能添加一个递增，且该列必须为整数而且不能包含null


4.查看表结构

	desc score;  

5.删除成绩表

	drop table score； 
	
6.插入数据到成绩表中

	insert into score(id,name) values(1212,'a'); 

7.查看成绩表所有的数据

	select * from score; 

8.查看成绩表中id为1的所有数据信息

	select * from score where id = 1; 

9.这些类型使用单引号：

	char/varchar/date/datetime/time/timestamp/blob

	dec/int:不使用引号

	\': 处理字段中单引号的出现

10.查看成绩表中ID为1的名字

	select name from score where id = 1；
	
11.查询成绩表中ID为1 姓名为`a`的名字

		select name from score where id=1 and name = `a`;
		
	运算符：<> 不等于 = 等于 < <= > >= (也可以对字符进行比较) or and
	select id from score where name > `a`; 查询成绩表中名字首字母在`a`之后的所有数据的id
	select * from score where name like '%ca'; 查询成绩表中所有名字以'ca'结尾的数据
	%：任意数量的未知字符
	_: 一个未知字符
12.查询成绩表中成绩在60到100之间的所有信息

	select * from score where score_num between 60 and 101; 

13.查询成绩表中名字首字母在'a'到'b'之间的所有信息

	select * from score where name between 'a' and 'c'; 


14.查询成绩表中名字在（'a','b'）中的所有信息 反过来：not in

	select * from score where name in('a','b'); 
	not:紧跟在where后 not in是特例， 同时可以与and /or /is null 搭配使用 位置在and/or后紧跟，
	is 	null 之前

15.删除成绩表中名字为'a'的数据 所有用法与select一样

	delete from score where name='a'; 

	注意删除时若无约束条件则会删除全部 	删除只能删除一行或多行，无法删除某一个字段或值

16.修改成绩表中ID为1的名字为'b'成绩为50 无则不修改任何字段

	update score set name='b',score=50 where id=1; 

17.查看创建表的语句

	show create table score; 

18.为score表创建一个不为空的整型自增的字段并放于表首列，设置其为主键

	alter table score add column student_id int not null auto_increment first,
	add primary key (student_id); 

19.数据原子性：同一列中不会存储多个类型相同的数据，也不会用多个列存储相同的数据
	
	第一范式：每一个数据行均需包含原子性数据值，且每一个数据行都存在唯一的识别方法
	alter table score add column phone varchar(10) after id; 为score表创建
	一个电话号码字段并放于id列字段之后

20.alter...change:同时改变现有列的名称和数据类型
	
	alter table score change column id stu_id int not null auto_increment,
	add primary key (stu_id);
	将score表中ID改为stu_id并将其设置成自增和主键,必须重新命名该列数据类型

	alter...modify:修改现有列的数据类型或位置
	alter table score modify column id varchar(120);
	修改score表的id类型为varchar(120)

	alter...add:在当前表中添加一行
	alter...drop：删除表中某列

	注意：可能造成数据丢失
	alter table score rename to score_stu;将表score的名字改为score_stu
	alter table score drop primary key; 删除score表的主键

21.选出name列中从右侧开始选取的2个字符 左侧开始为left

	select right(name, 2) from score;
	select substring_index(name,',',1) from score;选取name列中以第一个逗号隔开之
	前的部分，若为2,则为第二个之前的所有部分

	其它字符串函数：substring('aaadsasd',4,3);截取‘aaadsasd'中从位置4开始长度为3
		  	upper('aa');字符串转为大写  lower('CC')；字符串转为小写
		  	reverse('cvs');反转字符串
		  	ltrim('  aaaasdf  '); rtrim('  asaadd  ');清除多余空格
		  	length('asadsad')
	运用：update contacts set state = right(location,2);取出contacts 表location字
	段中右边两字符并放入到state字段中进行遍历

	字符串函数可以和select,update,delete搭配使用



