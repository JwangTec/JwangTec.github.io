---
title: 分布式数据库架构实践07--Mycat企业级运维
categories: 分布式数据库架构
tags:
  - Mycat-Web性能监控平台
  - Mycat调优
top: 12
abbrlink: 2395128656
date: 2019-09-01 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/DB1.jpeg" width="1000" height="200" align="middle" />


## Mycat-Web性能监控平台

<!--more-->

​	在现在的企业开发中，作为一个合格的开发人员来说，不仅要完成正常的编码任务，同时也要掌握一定的运维能力。当线上系统出现问题时，要能够快速的将隐藏问题找出来并进行解决。

​	Mycat-web是mycat的可视化运维监控平台。其能够管理和监控mycat的流量、连接数、线程数、JVM、内存。并且基于内部统计还能够分析出慢SQL与高频SQL。为sql优化提供了重要的依据。

###  Mycat-web安装

1）安装zookeeper

```
#创建zk文件夹
mkdir -p /usr/local/zookeeper

#在zk文件夹下下载zk安装包
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz

#解压安装包
tar -zxvf zookeeper-3.4.9.tar.gz

#进入/conf文件夹，修改配置文件名称
cp zoo_sample.cfg zoo.cfg

#修改配置文件内容
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/usr/local/services/zookeeper/zookeeper-3.4.9/data
dataLogDir=/usr/local/services/zookeeper/zookeeper-3.4.9/logs
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

#配置环境变量
export ZOOKEEPER_HOME=/usr/local/zookeeper/zookeeper-3.4.9/
export PATH=$JAVA_HOME/bin:$PATH:$MYCAT_HOME/bin:$ZOOKEEPER_HOME/bin

#启动zk
zkServer.sh start
```

2）Mycat-web安装

```
#解压mycat安装包
tar -zxvf Mycat-web-1.0-SNAPSHOT-20170102153329-linux.tar.gz

#启动mycat-web，默认端口8082
./start.sh

#查看mycat-web是否启动成功
netstat -ant | grep 8082

#访问mycat-web
ip:8082/mycat
```

![image-20200628211259421](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628211259421.png)

### mycat-web使用

​	mycat-web的使用非常简单，其内部已经提供了mycat配置、mycat监控、sql监控与sql上线检查。只需要在其内部配置好自己的mycat服务器信息即可完成使用。

##  Mycat调优

​	在mycat使用过程中，也有可能涉及到对其进行调优。对于mycat调优主要是从JVM、操作系统、mycat本身、缓存、I/O、mysql这几部分分别进行调优

### JVM优化

​	JVM调优主要分为两部分**堆内存**和**直接内存**。直接内存尽可能的大，合理情况下应在操作系统的50%~67%之间。以16G内存服务器为例：

```
-server -Xms4G -Mmx4G XX:MaxPermSize=64M -XX:MaxDirectMemorySize=6G
```

​	Mycat中JVM参数修改可配置/conf/wrapper.conf

```properties
wrapper.java.additional.4=-XX:MaxDirectMemorySize=2G
# Initial Java Heap Size (in MB)
#wrapper.java.initmemory=3

# Maximum Java Heap Size (in MB)
#wrapper.java.maxmemory=64
```

### 操作系统优化

​	Linux系统对每个进行打开的文件句柄数量是有限的，可以把mysql和mycat服务器的最大文件句柄数量设置为5000~10000，可以通过ulimit命令修改，但只对当前用户有效，且服务器重启后失效。

###  mycat优化

​	修改/conf/server.xml

```xml
<!--设置可用CPU数量，当CPU压力小时，可以通过该参数优化mycat-->
<property name="processors">1</property>

<!--设置可用CPU线程池大小，一般为16~64之间，根据系统能力决定-->
<property name="processorExecutor">32</property>
```

​	修改/conf/schema.xml

```xml
<!--checkSQLschema建议设置为false，可以优化sql解析-->
<schema name="userDB" checkSQLschema="true" dataNode="dn142" sqlMaxLimit="500"></schema>

<!--maxCon建议设置在1000~2000之间，同一个mysql实例上所有dataNode节点共享本datahost上的所有物理节点-->
<dataHost name="dh142" balance="3" maxCon="100" minCon="10"  dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000"></dataHost>
```

###  缓存优化

​	在mycat中通过`show @@cache`可以查看当前mycat缓存的使用情况

```
mysql -umycat -h192.168.200.142 -P9066 -pmycat

show @@cache
```

![image-20200628231722460](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628231722460.png)

​	如果CUR接近MAX，而PUT比MAX大很多，则表明MAX需要增大。HIT/ACCESS为缓存命中率，该值越高越好。当调整后需要观察缓存命中率是否增加、PUT是否在下降。

​	可以修改**/conf/cacheservice.properties**修改缓存配置，其使用的是encache，在encache.xml中设置了encache缓存的全局属性

```properties
#used for mycat cache service conf
factory.encache=io.mycat.cache.impl.EnchachePooFactory
#key is pool name ,value is type,max size, expire seconds
#SQL解析和路由使用的缓存
pool.SQLRouteCache=encache,10000,1800
#ER分片时使用的缓存
pool.ER_SQL2PARENTID=encache,1000,1800
#当根据主键查询比较多时，该值设置的较大，可以有效提升性能
layedpool.TableID2DataNodeCache=encache,10000,18000
layedpool.TableID2DataNodeCache.TESTDB_ORDERS=50000,18000
```