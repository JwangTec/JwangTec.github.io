---
title: mysql数据库02--进阶语句
categories: 数据库
tags:
  - mysql数据库
top: 8
abbrlink: 1482967651
date: 2019-05-06 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/mysql.jpeg" width="1000" height="200" align="middle" />

###  mysql进阶

<!--more-->

1.case...end

```
update movie_table 
set category = 
case 
	when drama = 'T' then 'drama'  
//相当于：update movie_table set category = 'drama' where drama = 'T' 
	when comedy = 'T' and sciti = 'T' then 'comedy' 
	else 'misc'
end;

//找到符合when语句时则直接执行该语句并跳到end
```

2.order by  :排序

```
select title, category from movie_table 
where
category = 'family'
order by title,purcheased

desc:倒序
```

3.sum avg min max count（属于函数） distinct(去重 不一样的值  属于关键字)
函数需要加括号 关键字不需要


```
select distinct sale_date
from cookie_eales
order by sale_date;

```

4.group by :分组(与3搭配使用  属于关键字)

```

select first_name,sum(sales)
from cookie_eales
group by first_name
order by sum(sales) desc;

```

5.limit 查询结果的数量

```
select first_name,sum(sales)
from cookie_eales
group by first_name
order by sum(sales) desc;
limit 0,2;  //从0开始1结束 一共两行数据

```
6.in,between in表示在其中的数据,between表示在两个数之间的数据

```
select * from atable where column beteen min and max  //表示在min 和max之间的数据
elect * from atable where column in(n1,n2,n3) //表示数据是 n1或者n2或者n3
```

7.or,and 表示在数据满足一个或者全部都满足
8.运算符,可以使用运算符表示数据大于 小于等于等情况,
9.like 模糊查询,使用like语句表示查询的时候匹配查询, %表示0，1或者多个字符的占位符, _ 表示一个字符的占位
符

10.having表示筛选 和where不同点在于having后面可以跟上聚合函数

```
SELECT region, SUM(population), SUM(area)
FROM bbc
GROUP BY region
HAVING SUM(area)>1000000
```


### 多表查询



1.创建带有外键的表

```
create table intereste(
int_id int not null auto_increment primary key,
interest varchar(20) not null,
contact_id int not null,

constraint my_contacts_contact_id 
foreign key (contact_id) references my_contacts (contact_id)
);

```

2.内连接(笛卡儿积)

```
select * from t1 inner join t2;	
select t1.*,t2.* from t1 inner join t2;
加入筛选条件：on
select t1.*,t2.* from t1 join t2 on t1.i1=t2.i2;
别名：
select a.i1,b.i2 from t1 as a join t2 as b on a.i1=b.i2;	
```

3.外连接
外联结除了显示同样的匹配结果，还可以把其中一个数据表在另一个数据表里没有匹配的数据行也显示出来。外联结分左联结和右联结两种。

```
左连接
select a.i1,b.i2 from t1 as a left join t2 as b on a.i1=b.i2;
右连接
elect a.i1,b.i2 from t1 as a right join t2 as b on a.i1=b.i2;
用处：
select a.i1,b.i2 from t1 as a right join t2 as b on a.i1=b.i2 
where a.i1 is null;

```

4.some any 

	some和any会帮助我们筛选出最小的一个数来作为条件
	select * from salary_table where salary > some (select salary from salary_table 
	where position = 'Python');
	
5.all
	
	all 会筛选出满足所有条件的选项
	select * from salary_table where salary > all (select salary from salary_table 
	where position = 'java');

6.in (=some any)
	
	SELECT * FROM salary_table WHERE salary IN (SELECT salary FROM salary_table 
	WHERE 
	position = 'Python');
	
	SELECT * FROM salary_table WHERE salary =some (SELECT salary FROM salary_table 
	WHERE 
	position = 'Python');
	
7.exists 会判断数据是否存在 如果不存在则不会筛选数据

	select * from salary_table 
	where exists(SELECT * from salary_table where id = 1)