---
title: 数据分析02--spark错误分析
categories: 大数据
tags:
  - 数据分析
top: 4
abbrlink: 3907582757
date: 2019-05-02 18:18:19
password:
---


<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/date.jpeg" width="1000" height="300" align="middle" />

## spark错误分析

<!--more-->


[官方文档](http://spark.apache.org/docs/2.4.4/)

错误1

```
1020104:sbin rimi$ ./start-master.sh 
starting org.apache.spark.deploy.master.Master, logging to /Users/rimi/Desktop/spark-2.4.4-bin-hadoop2.7/
logs/spark-rimi-org.apache.spark.deploy.master.Master-1-1020104.local.out

```
>解决：本地ip未找到，添加

```
#sudo vim /etc/hosts


127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
0.0.0.0 1020104.local   (这一个没有)
```

错误2

>spark 与 jdk 不兼容  

解决：

>下载saprk2.7 或者更加稳定版本  jdk下载1.8  8u231
>
>重新配置jdk环境