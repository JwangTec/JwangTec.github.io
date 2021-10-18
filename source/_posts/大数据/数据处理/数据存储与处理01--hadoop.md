---
title: 数据存储与处理01--hadoop
categories: 大数据
tags: [数据存储, 数据处理, 大数据]
top: 4
abbrlink: 1462761565
date: 2019-05-02 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/date.jpeg" width="1000" height="300" align="middle" />


## hadoop

<!--more-->

### 前期准备

#### 软件下载

>jdk下载: 
>最好下载以前的稳定版本，此次使用的jdk版本为1.8
>
>[下载地址](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

>hadoop下载：下载稳定版本， 此次使用Hadoop版本为2.7.7
>
>[下载地址](https://hadoop.apache.org/releases.html)


#### 环境变量


```
#vim ~/.bash_profile

#Setting PATH for hadoop 2.7.7
export HADOOP_HOME=/Users/rimi/Desktop/hadoop-2.7.7
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin

#Setting JAVA_HOME for jdk 1.8
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_231.jdk/Contents/Home

```

>编辑保存完成后，执行命令： source .bash_profile 
>
>查看是否配置成功：echo $JAVA_HOME  /  echo $HADOOOP_HOME

```
#修改hadoop-env.sh配置文件(可不用)
#hadoop-2.7.7/etc/hadoop
#vim hadoop-env.sh

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_231.jdk/Contents/Home

```
### hadoop伪分布式配置


1. hadoop/etc/hadoop/core-site


|No.|	参数名	|默认值	|参数解释
|:-:|:-:|:-:|:-:|
1	|fs.defaultFS	|file:///|	文件系统主机和端口
2	|io.file.buffer.size	|4096	|流文件的缓冲区大小
3	|hadoop.tmp.dir|	/tmp/hadoop-${user.name }|临时文件夹


```
# vim core-site.xml

<configuration>
       <!--指定namenode的地址(必须)-->
   <property>
               <name>fs.defaultFS</name>
               <value>hdfs://10.2.0.104</value>
   </property>
   <!--用来指定使用hadoop时产生文件的存放目录-->
   <property>
            <name>hadoop.tmp.dir</name>
            <value>file:/data/hadoop/hadoop-2.6.0/tmp</value> 
   </property>
   	<property>
   	   <!--用来指定使用hadoop时的节点数（需要）-->
            <name>dfs.replication</name>
            <value>1</value>
    </property>
    	<!--用来设置检查点备份日志的最长时间-->
    	<name>fs.checkpoint.period</name> 
    	<value>3600</value>
</configuration>


```


2. hadoop/ect/hadoop/hdfs-site

|No.|	参数名|	默认值	|参数解释
|:-:|:-:|:-:|:-:|
1|	dfs.namenode.secondary.http-address	|0.0.0.0:50090|定义HDFS对应的HTTP服务器地址和端口
2	|dfs.namenode.name,dir	|file://${hadoop.tmp.dir}/dfs/name|定义DFS的名称节点在本地文件系统的位置
3|	dfs,datanode.data.dir	|file://${hadoop.tmp.dir}/dfs/data|定义DFS数据节点存储数据块时存储在本地文件系统的位置
4|	dfs.replication|	3	|缺省的块复制数量
5	|dfs.webhdfs.enabled|	true	|是否通过http协议读取hdfs文件，如果选是，则集群安全性较差



```
# vim hdfs-site.xml

<configuration>
	<!--指定hdfs保存数据的副本数量-->
    <property>
             <name>dfs.replication</name>
             <value>2</value>
    </property>
	<property>
	<!--指定hdfs中namenode的存储位置-->
				<name>dfs.namenode.name.dir</name>
				<value>file:///Users/rimi/Desktop/bigdata/namenode</value>
	</property>
	<property>
	<!--指定hdfs中datanode的存储位置-->
      		   <name>dfs.datanode.data.dir</name>
      		   <value>file:///Users/rimi/Desktop/bigdata/datanode</value>
    </property>
</configuration>

```


3. 重新格式化： hdfs namenode -format


### 常用命令

1.查看集群上所有文件：
>hdfs dfs -ls /

2.分别启动namenode/datanode: 
>hdfs --daemon start namenode / hdfs --daemon start datanode

3.查看该集群此ip下的文件：
>hdfs dfs -ls hdfs://10.2.0.104/

4.创建文件夹：
>hdfs dfs -mkdirs hdfs://10.2.0.104/text

5.logs 中可以查看日志 查看错误

>cd hadoop-2.7.7/logs/

6.hadoop 2.* 版本可以网页查看所有namenode datanode
>浏览器输入：10.2.0.104:50070  

7.停止namenode/datanode
>hdfs stop namenode(datanode)

8.对地址统一管理：
> hadoop/etc/hadoop/  
> 
> 编辑workers: vim workers   注意：前面版本名字为slaves  

9.停止和开始所有hadoop服务：
>sbin/
>
>stop-dfs.sh  停止

>start-dfs.sh 开始


10.从集群下载文件
>hdfs dfs -get hdfs://10.0.0.252:9000/data/hadoop-2.7.7.tar.gz ./  下载

11.实现域名重定向

```
#sudo vim /etc/hosts

127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
0.0.0.0 1020104.local  
```

12.配置Hadoop的主要5个文件

|序号|	配置文件名|	配置对象	|主要内容
|:-:|:-:|:-:|:-:|
1|	hadoop-env.sh	|hadoop运行环境|	用来定义hadoop运行环境相关的配置信息
2|	core-site.xml	|集群全局参数|	用于定义系统级别的参数，如HDFS URL 、Hadoop的临时目录等
3|	hdfs-site.xml	|HDFS	|如名称节点和数据节点的存放位置、文件副本的个数、文件的读取权限等
4|	mapred-site.xml|	Mapreduce参数	|包括JobHistory Server 和应用程序参数两部分，如reduce任务的默认个数、任务所能够使用内存的默认上下限等
5	|yarn-site.xml	|集群资源管理系统参数|	配置ResourceManager ，nodeManager的通信端口，web监控端口等


### 分布式配置：

#### 分配ip

```
# etc/hadoop/ 
# vim workers(或者slaves) 

10.2.0.104      1020104.local     namenode（存储的是文件属性）  datanode
10.2.0.195      Mac-of-Jack.local  datanode （存储文件数据）
10.2.0.166      rimideiMac-5.local  datanode （存储文件数据）

```



#### yarn-site.xml 


1. 重要参数

|No.	|参数名|	默认值|	参数解释
|:-:|:-:|:-:|:-:|
1	|yarn.resourcemanager.address|	0.0.0.0:8032|ResourceManager（以下简称RM） 提供客户端访问的地址。客户端通过该地址向RM提交应用程序，杀死应用程序等
2|	yarn.resourcemanager.scheduler.address|0.0.0.0:8030|RM提供给ApplicationMaster的访问地址。ApplicationMaster同通过该地址向RM申请资源、释放资源等
3	|yarn,resoucemanager.resource.resource-tracker.address|0.0.0.0:8031|RM提供NodeManager的地址。NodeManager通过该地址向RM汇报心跳，领取任务等
4	|yarn.resourcemanager.admin.address	|0.0.0.0:8033|RM提供管理员的访问地址。管理员通过该地址向RM发送管理命令等
5|	yarn.resourcemanager.webapp.address	|0.0.0.0:8088|RM对web服务提供地址。用户可通过该地址在浏览器中查看集群各类信息
6	|yarn.nodemanager.aux-services	|	|通过该配置项，用户可以自定义一些服务，例如Map-Reduce的shuffle功能就是采用这种方式实现的，这样就可以在NodeManager上扩展自己的服务


>注意：不同版本配置可能不同

```
#hadoop 3.1
#etc/hadoop
#vim yarn-site.xml

<property>
  <name>yarn.scheduler.capacity.root.queues</name>
  <value>a,b,c</value>
  <description>The queues at the this level (root is the root queue).
  </description>
</property>

<property>
  <name>yarn.scheduler.capacity.root.a.queues</name>
  <value>a1,a2</value>
  <description>The queues at the this level (root is the root queue).
  </description>
</property>

<property>
  <name>yarn.scheduler.capacity.root.b.queues</name>
  <value>b1,b2,b3</value>
  <description>The queues at the this level (root is the root queue).
  </description>
</property>

#hadoop 2.7

<configuration>
<!-- Site specific YARN configuration properties -->
	<property>
  			<name>yarn.nodemanager.aux-services</name>
  			<value>mapreduce_shuffle</value>
	</property>
</configuration>

```

2. mapred-site.xml  

>注意hadoop 2.7 需要将 mapre-site.xml.template 重新命名为 mapred-site.xml 

```
#etc/hadoop
#mv mapre-site.xml.template mapred-site.xml 
#vim mapred-site.xml

<configuration>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>>
</configuration>

```

3. mapred-site.xml 重要参数说明

|No.	|参数名|	默认值|	参数解释
|:-:|:-:|:-:|:-:|
1	|mapreduce.framework.name	|local	|取值local、classic或yarn其中之一，如果不是yarn，则不会使用yarn集群来实现资源的分配
2	|mapreduce.jobhistory.address	|0.0.0.0:10020|定义历史服务器的地址和端口，通过历史服务器查看已经运行完的Mapreduce作业记录
3	|mapreduce.jobhistory.webapp.address	|0.0.0.0:19888|定义历史服务器web应用访问的地址和端口

4. 启动资源管理器：

>yarn --daemon start resourcemanager 
>
> hadoop 2.7版本：sbin/yarn-daemon.sh start resourcemanager



#### 完整步骤（错误解决/127 99999）

1.jdk环境变量  

2.Hadoop环境变量

```		
# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH=/usr/local/bin:$PATH
export PATH=$PATH:Desktop/bs4/chrom/chromedriver

export #Setting PATH for hadoop 2.7.7
export HADOOP_HOME=/Users/rimi/Desktop/hadoop-2.7.7
export PATH=$PATH:$HADOOP_HOME/bin
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-12.jdk/Contents/Home
```

3.停止所有：sbin/stop-all.sh

4.开始所有：sbin/start-all.sh

5.查看是否存在进程：jps 存在则杀死该进程  kill 6163

6.脚本启动：sbin/hadoop-daemon.sh --script hdfs start namenode(datanode)

7.查看是否启动：jps

8.开启resourcemanager:sbin/yarn-daemon.sh start resourcemanager(nodemanager) 重复7

9.hdfs dfs -mkdirs hdfs://10.2.0.104/text hdfs创建文件

10.推送数据到hdfs：hdfs dfs -put 本地路径 上传路径

11.hdfs dfs -ls hdfs://10.2.0.104/

12.执行某一个分析 

>hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.7.7.jar -input hdfs://10.2.0.104/mewas/data.txt -mapper ~/Desktop/mewas/map.py -reducer ~/Desktop/mevas/reduce.py  -output /data-output

>出现错误： builtin-java classes where applicable 
>
>解释：文件必须是可执行的 并且数据在hdfs中存在(ls -l查看文件权限)
>
>解决：本地检查map运行是否正确：运行： cat data.txt | python ./map.py 
>
>在.py中加入注释：#!/usr/bin/env python  表面这是一个python文件使用python编码解释器

13.数据处理方法编写：map/reduce (详细请看 :  [MapReduce Tutorial](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html))

14.若运行过12则需要删除output再重新运行：

>hdfs dfs -rm -r /data-output
>
>hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.7.7.jar -input hdfs://10.2.0.104/mewas/data.txt -mapper ~/Desktop/mewas/map.py -reducer ~/Desktop/mevas/reduce.py  -output /data-output




