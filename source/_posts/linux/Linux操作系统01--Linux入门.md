---
title: Linux操作系统01--Linux入门
categories: Linux操作系统
tags:
  - Linux入门
top: 9
abbrlink: 1737435959
date: 2019-05-08 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Linux.jpeg)

### Linux版本之间的区别

<!--more-->


	             redhat  RHEL CentOs 
	                     Fedora               --> 稳定版本
	             Debian  Ubuntu
	     Linux           Mint Linux   knopix  --> 最新版本
	             SlackWare  SUSE   SLEs
	                               openSuse
	             其它发行家族 


### 基础

	top : 查看电脑当前状态，比如CPU的使用率，物理内存（Physcmem）,可看作一个
	任务管理器（使用q键退出）
	date：日期。其中取的时区为CST 代表 中国上海
	cal ：日历
	echo : 将字符串输出到屏幕  > ：输出重定向  >> : 输出追加重定向
	echo 'hello' > tmp.txt : 将字符串输出重定向，若当前目录下没有该文件，
	则会新建该文件并将字符串输出到文件，若存在该文件，则会覆盖该文件中的内容
	echo 'hello' >> tmp.txt : 与上述一样，但存在该文件时会在该文件内容后
	追加字符串
	2> : 标准错误截获，将错误提示输出到文件中
	unix时间戳（timestamp）: 以格林威治时间为准，计算机开始时间1970开始
	Tab键：命令自动补全，多个相同命令则按两下，会将全部相似的命令显示在屏幕上
	
### 文件夹操作

	cd  进入目标文件夹中
	cd .  当前目录
	cd ..  返回上一个文件夹下
	ls  查看当前所在文件夹下面所拥有的文件夹清单
	pwd 查看当前所在文件夹路径，属于绝对路径
	mkdir 创建文件夹
	rm -r -f 删除文件夹（不可恢复）
	/ 文件路径分隔符  \ 转义字符
	～ 用户根目录  ./ 当前目录
	ls -la 可显示隐藏文件  隐藏文件的创建为在名字前+“.”,例如：.match
	less 文件名  查看文件内信息  more可查看部分文件内信息
	cp 文件夹1 文件夹2  考本文件夹1到文件夹2（需要是文件夹全名）与文件操作一样
	
### 文件操作  
	
	cp -r   : 文件复制
	cp -r {文件1，文件2} 目标文件夹   ： 拷贝多个文件到一个文件夹中
	rm -rf  : 删除任何相关的文件或文件夹 删除多个使用 空格隔开或者通配符
	touch   : 新建文件（使用通配符可创建多个）
	mkdir -p : 可以创建一个新文件夹下创建新文件
	> text.txt : 创建空文件
	