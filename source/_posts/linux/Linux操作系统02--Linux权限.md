---
title: Linux操作系统02--Linux权限
categories: Linux操作系统
tags:
  - Linux权限
top: 9
abbrlink: 4264740339
date: 2019-05-08 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Linux.jpeg" width="1000" height="200" align="middle" />

	
## 进制计算

<!--more-->	

	二进制 ： 以111（2） 为例：1*2^0 + 1*2^1 + 1*2^2 =7 
	十六进制：以16为底：0～9 A～F
	三十六进制：以32为低：0-9 A-Z 除开 i o s z
  
## Linux权限

1. 例：使用ls -lh 文件属性字段显示信息如下
	
		d  rwx  r_x  r_x  d(文件夹) r(可读) w(可写) x(可执行) 
	      111  101  101
	       7    5    5
	       u    g    o
	     
   整个信息段表示：文件属性字段 文件硬链接数/目录子文件数 文件拥有者 文件拥有者所在组 文件大小（以字节为单位） 文件创建时间 文件名（-->符号为指向目标文件夹）
2. 	修改权限：chmod 权限的十进制 文件名 （chmod 755 1.txt）权限最高为777
   修改文件夹权限：chmod -R
3. 修改某一个权限：chmod u-x 文件名 （u-x 为 user 用户去掉可执行，还可以为u+x、u-wx、g+rx）

## 编码表

最早的字符编码表：Ascil码（不能存汉字）

中文编码：gbk（简体） big5(繁体)

世界性文字编码：unicode32  通过加工--通用编码：utf-8(可变长)、utf-16(即固定又可变)、utf-32(固定)