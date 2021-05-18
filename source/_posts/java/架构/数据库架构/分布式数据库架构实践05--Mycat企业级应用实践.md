---
title: 分布式数据库架构实践05--Mycat企业级应用实践
categories: 分布式数据库架构
tags:
  - Mycat
  - 全局序列号
  - Mycat分库
  - Mycat读写分离
  - MyCat分片规则
  - 跨库join
top: 12
abbrlink: 3881685427
date: 2019-09-01 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/DB1.jpeg" width="1000" height="200" align="middle" />


<!--more-->

##  环境参数配置

​	在server.xml 文件中的system标签下配置所有的参数，全部为环境参数，可以根据当前需要进行开启和配置，如：设置mycat连接端口号

```xml
<property name="serverPort">8066</property>
```

![image-20200603010530819](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200603010530819.png)

##  数据非分片

###  配置初始化信息

​	应用连接mycat的话，也需要设置用户名、密码、被连接数据库信息，要配置这些信息的话，可以修改server.xml，在其内部添加内容如下：

```xml
<!--配置自定义用户信息-->
<!--连接用户名-->
<user name="mycat">
    <!--连接密码-->
    <property name="password">mycat</property>
    <!--创建虚拟数据库-->
    <property name="schemas">userdb</property>
    <!--指定该库是否只读-->
    <!--<property name="readOnly">true</property>-->
</user>
```

###  配置虚拟数据库&表

当配置了一个虚拟数据库后，还需要修改schema.xml，对虚拟库进行详细配置

```xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

	<!--配置虚拟数据库-->
	<!--name：虚拟逻辑数据库名称，对应server.xml中的schemas属性值-->
	<!--dataNode：逻辑库中逻辑表的默认数据节点-->
	<!--sqlMaxLimit：类似于SQL上添加limit，如schema为非分片库，则该属性无效-->
	<schema name="userdb" checkSQLschema="true" dataNode="localdn" sqlMaxLimit="500">
		<!--配置虚拟逻辑表-->
		<!--name：逻辑表名称，必须唯一-->
		<!--dataNode：逻辑表所处的数据节点，值必须与dataNode标签中的name属性对应。如果值过多可以用$连接，如：dn$1-99,dn$200-400-->
		<!--primaryKey：逻辑表对应的真实表的主键id的字段名-->
		<table name="tb_user" dataNode="localdn" primaryKey="user_id"/>
	</schema>

	<!--配置dataNode信息-->
	<!--name：当前datanode名称-->
	<!--dataHost：分片节点所处的节点主机，该值必须与dataHost标签中的name属性对应-->
	<!--database：当前数据节点所对应的实际物理数据库-->
	<dataNode name="localdn" dataHost="localdh" database="user"/>

	<!--配置节点主机-->
	<!--balance：用于进行读操作指向，有三个值可选
		0：所有读操作都发送到当前可用的writeHost上
		1：所有读操作都随机的发送到readHost上
		2：所有读操作都随机发送在writeHost与readHost上
	-->
	<!--maxCon：指定每个读写实例连接池的最大连接。也就是说，标签内嵌套的writeHost、readHost标签都会使用这个属性的值来实例化出连接池的最大连接数-->
	<!--minCon：指定每个读写实例连接池的最小连接，初始化连接池的大小-->
	<!--name：当前节点主机名称，不允许出现重复-->
	<!--dbType：当时使用的数据库类型-->
	<!--dbDriver：当前使用的数据库驱动-->
	<!--writeType：用于写操作指向，有三个值可选
		0：所有写操作都发送到可用的writeHost上
		1：所有写操作都随机发送到readHost上
		2：所有写操作都随机发送在writeHost与readHost上
	-->
	<!--readHost是从属于writeHost的，即意味着它从那个writeHost获取同步数据。
		因此，当它所属的writeHost宕机了，则它也不会再参与到读写分离中来，即“不工作了”。这是因为此时，它的数据已经“不可靠”了。
		基于这个考虑，目前mycat 1.3和1.4版本中，若想支持MySQL一主一从的标准配置，并且在主节点宕机的情况下，从节点还能读取数据。
		则需要在Mycat里配置为两个writeHost并设置banlance=1。”-->
	<!--switchType：设置节点切换操作，有三个值可选
		-1：不自动切换
		1：自动切换，默认值
		2：基于mysql主从同步的状态决定是否切换
	-->
	<!--slaveThreshold：主从同步状态决定是否切换，延迟超过该值就不切换-->
	<dataHost balance="0" maxCon="100" minCon="10" name="localdh" dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000">
		<!--查询心跳-->
		<heartbeat>select user()</heartbeat>
		<!--配置写节点实际物理数据库信息-->
		<writeHost url="jdbc:mysql://localhost:3306" host="host1" password="root" user="root"></writeHost>
	</dataHost>
</mycat:schema>
```

###  测试

​	通过navicat创建本地数据库连接并创建对应数据库，同时创建mycat连接。 在mycat连接中操作表，添加数据，可以发现，本地数据库中同步的也新增了对应的数据。

![image-20200603020230476](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200603020230476.png)

![image-20200603020257486](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200603020257486.png)

## 根据ID取模数据分片

​	当一个数据表中的数据量非常大时，就需要考虑对表内数据进行分片，拆分的规则有很多种，比较简单的一种就是，通过对id进行取模，完成数据分片。

1）修改schema.xml

​	table标签新增属性：subTables、rule

```xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

	<!--配置虚拟数据库-->
	<!--name：虚拟逻辑数据库名称，对应server.xml中的schemas属性值-->
	<!--dataNode：逻辑库中逻辑表的默认数据节点-->
	<!--sqlMaxLimit：类似于SQL上添加limit，如schema为非分片库，则该属性无效-->
	<schema name="userdb" checkSQLschema="true" dataNode="localdn" sqlMaxLimit="500">
		<!--配置虚拟逻辑表-->
		<!--name：逻辑表名称，必须唯一-->
		<!--dataNode：逻辑表所处的数据节点，值必须与dataNode标签中的name属性对应。如果值过多可以用$连接，如：dn$1-99,dn$200-400-->
		<!--primaryKey：逻辑表对应的真实表的主键id的字段名-->
		<!--subTables：分表的名称。可以存在多个，tb_user1,tb_user2,tb_user3.如果分表较多，可以通过$连接：tb_user$1-3-->
		<!--rule：分片规则，对应rule.xml中配置-->
		<table name="tb_user" dataNode="localdn" primaryKey="user_id" subTables="tb_user$1-3" rule="mod-long"/>
	</schema>

	<!--配置dataNode信息-->
	<!--name：当前datanode名称-->
	<!--dataHost：分片节点所处的节点主机，该值必须与dataHost标签中的name属性对应-->
	<!--database：当前数据节点所对应的实际物理数据库-->
	<dataNode name="localdn" dataHost="localdh" database="user"/>

	<!--配置节点主机-->
	<!--balance：用于进行读操作指向，有三个值可选
		0：所有读操作都发送到当前可用的writeHost上
		1：所有读操作都随机的发送到readHost上
		2：所有读操作都随机发送在writeHost与readHost上
	-->
	<!--maxCon：指定每个读写实例连接池的最大连接。也就是说，标签内嵌套的writeHost、readHost标签都会使用这个属性的值来实例化出连接池的最大连接数-->
	<!--minCon：指定每个读写实例连接池的最小连接，初始化连接池的大小-->
	<!--name：当前节点主机名称，不允许出现重复-->
	<!--dbType：当时使用的数据库类型-->
	<!--dbDriver：当前使用的数据库驱动-->
	<!--writeType：用于写操作指向，有三个值可选
		0：所有写操作都发送到可用的writeHost上
		1：所有写操作都随机发送到readHost上
		2：所有写操作都随机发送在writeHost与readHost上
	-->
	<!--readHost是从属于writeHost的，即意味着它从那个writeHost获取同步数据。
		因此，当它所属的writeHost宕机了，则它也不会再参与到读写分离中来，即“不工作了”。这是因为此时，它的数据已经“不可靠”了。
		基于这个考虑，目前mycat 1.3和1.4版本中，若想支持MySQL一主一从的标准配置，并且在主节点宕机的情况下，从节点还能读取数据。
		则需要在Mycat里配置为两个writeHost并设置banlance=1。”-->
	<!--switchType：设置节点切换操作，有三个值可选
		-1：不自动切换
		1：自动切换，默认值
		2：基于mysql主从同步的状态决定是否切换
	-->
	<!--slaveThreshold：主从同步状态决定是否切换，延迟超过该值就不切换-->
	<dataHost balance="0" maxCon="100" minCon="10" name="localdh" dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000">
		<!--查询心跳-->
		<heartbeat>select user()</heartbeat>
		<!--配置写节点实际物理数据库信息-->
		<writeHost url="jdbc:mysql://localhost:3306" host="host1" password="root" user="root"></writeHost>
	</dataHost>
</mycat:schema>
```

2）修改rule.xml

​	在schema.xml中已经指定规则为mod-long。因此需要到该文件中修改对应信息。

```xml
<tableRule name="mod-long">
    <rule>
        <!--当用用于id取模的字段-->
        <columns>user_id</columns>
        <algorithm>mod-long</algorithm>
    </rule>
</tableRule>

<!--修改当前的分片数量-->
<function name="mod-long" class="io.mycat.route.function.PartitionByMod">
		<!-- how many data nodes -->
		<!-- 根据datanode数量进行取模分片，也就是要模几。 -->
		<property name="count">3</property>
	</function>
```

3）测试

1）向数据库中插入一千条数据，可以发现，其会根据id取模，放入不同的三张表中。

![image-20200604003934504](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200604003934504.png)

![image-20200604003948529](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200604003948529.png)

![image-20200604004000971](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200604004000971.png)

2）当根据id查询时，会通过对id的取模，确定当前要查询的分片。并且首先会先查询mycat中的ehcache缓存，再来查询数据分片

![image-20200604004554041](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200604004554041.png)

3）当查询所有数据时，会查询所有数据分片。

![image-20200604004806962](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200604004806962.png)

4）缺陷

​	通过id取模分片这种方式实际中应用较少。主要因为两点问题：

根据id取模，1）散列不均匀，出现数据倾斜。2）动态扩容时，存在rehash，出现数据丢失。

1）数据散列不均匀，容易出现数据倾斜。每张表中的数据量差距较大。

2）动态扩容后，当需要新增表时，需要对模数修改，有可能就会造成当查询某个分片时，在该分片中找不到对应数据。

3）动态扩容后，要进行rehash操作。

##  全局序列号 

​	当进行数据切分后，数据会存放在多张表中，如果仍然通过数据库自增id的方式，就会出现ID重复的问题，造成数据错乱。所以当拆分完数据后，需要让每一条数据都有自己的ID，并且在多表中不能出现重复。比较常见的会使用雪花算法来生成分布式id。

​	在Mycat中也提供了四种方式来进行分布式id生成：基于文件、基于数据库、基于时间戳和基于ZK。

###  基于本地文件方式生成

优点：本地加载，读取速度较快。

缺点：当MyCAT重新发布后，配置文件中的sequence会恢复到初始值。

​			生成的id没有含义，如时间。

​			MyCat如果存在多个，会出现id重复问题。

​	1）修改**sequence_conf.properties**

```properties
USER.HISIDS=  #使用过的历史分段，可不配置
USER.MINID=1  #最小ID值
USER.MAXID=200000  #最大ID值
USER.CURID=1000  #当前ID值
```

​	2）修改**server.xml**

```xml
<!--设置全局序号生成方式
   0：文件
   1：数据库
   2：时间戳
   3：zookeeper
  -->
<property name="sequnceHandlerType">0</property>
<!--进入序列匹配流程, 必须带有MYCATSEQ_或者 mycatseq_-->
<property name="sequnceHandlerPattern">(?:(/s*next/s+value/s+for/s*MYCATSEQ_(/w+))(,|/)|/s)*)+</property>
<property name="sequenceHanlderClass">io.mycat.route.sequence.handler.HttpIncrSequenceHandler</property>
```

​	3）测试

重启mycat，并查询是否修改成功

```sql
show @@sysparam
```

![image-20200605183431528](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200605183431528.png)

通过navicat插入数据

```sql
insert into tb_user(user_id,user_name) values('next value for MYCATSEQ_USER','wangwu')
```

通过程序插入数据

```java
@Insert("insert into tb_user(user_id,user_name) values('next value for MYCATSEQ_USER',#{userName})")
void addUser(User user);
```

### 基于数据库生成

​	优点：能够进行id批量生成，在分布式下，可以避免id重复问题。

​	缺点：ID没有意义，对数据库有压力。

1）**在实际数据库执行dbseq.sql中的sql语句**，执行完毕后，会创建一张表。

![image-20200605191200321](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200605191200321.png)

2）**修改sequence_db_conf.properties**。

```
TB_USER=localdn
```

3）**修改server.xml文件**，修改全局序列号生成方式为数据库方式

```xml
<property name="sequnceHandlerType">1</property>
```

4）修改schema.xml。在table中添加自增属性

```xml
<table name="tb_user" dataNode="localdn" primaryKey="id" subTables="tb_user$1-3" rule="mod-long" autoIncrement="true"/>
```

5）测试

通过navicat新增记录

```sql
insert into tb_user(user_id,user_name) values('next value for MYCATSEQ_TB_USER','wangwu')
```

![image-20200605194130010](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200605194130010.png)

###  基于zookeeper生成

1）修改**server.xml**，更改生成模式

```xml
<property name="sequenceHandlerType">3</property>
```

2）修改**myid.properties**，配置zk连接信息

```properties
loadZk=true
zkURL=192.168.200.131:2181
clusterId=01
myid=mycat_fz_01
clusterNodes=mycat_fz_01
#server  booster  ;   booster install on db same server,will reset all minCon to 1
#type=server
#boosterDataHosts=localhost1
```

3）修改**sequence_distributed_conf.properties**

```
INSTANCEID=ZK #声明使用zk生成
CLUSTERID=01
```

4）测试

启动mycatServer后，通过zk客户端查看节点信息。会发现新增了一个mycat节点

```
./zkCli.sh

ls /
```

![image-20200609225750661](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200609225750661.png)

插入数据

```sql
insert into tb_user(user_id,user_name) values('next value for MYCATSEQ_TB_USER12','heima')
```

next value for MYCATSEQ_  后的内容可以随意指定。

![image-20200609233738919](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200609233738919.png)

5）特性：

ID 结构：**long 64 位**，ID 最大可占 63 位

/* |current time millis(微秒时间戳 38 位,可以使用 17 年)|clusterId（机房或者 ZKid，通过配置文件配置 5位）|instanceId（实例 ID，可以通过 ZK 或者配置文件获取，5 位）|threadId（线程 ID，9 位）|increment(自增,6 位)

/* 一共 63 位，可以承受单机房单机器单线程 1000*(2^6)=640000 的并发。

/* 无悲观锁，无强竞争，吞吐量更高

###  基于时间戳生成

优点：不存在上面两种方案因为mycat的重启导致id重复的现象

​	ID= 64 位二进制 (42(毫秒)+5(机器 ID)+5(业务编码)+12(重复累加)，每毫秒可以并发 12 位二进制的累加。

缺点：数据类型太长，建议采用bigint(最大取值18446744073709551615)

1）修改**server.xml**。更改生成方式

```xml
<property name="sequenceHandlerType">2</property>
```

2）修改**sequence_time_conf.properties**

```properties
#sequence depend on TIME
#WORKID与DATAACENTERID: 0-31 任意整数。多mycat节点下，每个节点的WORKID、DATAACENTERID不能重复，组成唯一标识，总共支持32*32=1024 种组合
WORKID=01
DATAACENTERID=01
```

3）测试

新增数据

```
insert into tb_user(user_id,user_name) values('next value for MYCATSEQ_TB_USER12','heima')
```

next value for MYCATSEQ_  后的内容可以随意指定。

![image-20200609234814418](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200609234814418.png)

##  Mycat分库&读写分离  

​	之前已经基于id取模完成了分表操作，但是一个数据库的容量毕竟是有限制的，如果数据量非常大，分表已经满足不了的话，就会进行分库操作。

​	当前分库架构如下：

![image-20200612002109456](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200612002109456.png)

​	现在存在两个主库，并且各自都有从节点。 当插入数据时，根据id取模放入不同的库中。同时主从间在进行写时复制的同时，还要完成主从读写分离的配置。

1）修改schema.xml。配置多datenode与datahost。同时配置主从读写分离。

```xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

    <schema name="userdb" checkSQLschema="true" dataNode="dn09" sqlMaxLimit="500">
        <table name="tb_user" dataNode="dn09,dn10" primaryKey="user_id" rule="mod-long"/>
    </schema>

    
    <dataNode name="dn09" dataHost="dh09" database="user"/>
    <dataNode name="dn10" dataHost="dh10" database="user"/>

    <dataHost name="dh09" balance="1" maxCon="100" minCon="10"  dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000">
        <!--查询心跳-->
        <heartbeat>select user()</heartbeat>
        <!--配置写节点实际物理数据库信息-->
        <writeHost url="jdbc:mysql://192.168.200.142:3309" host="host1"  user="root" password="123456">
            <!--配置读节点实际物理数据库信息-->
            <readHost host="host2" url="jdbc:mysql://192.168.200.145:3309" user="root" password="123456" ></readHost>
        </writeHost>
    </dataHost>

    <dataHost name="dh10" balance="1" maxCon="100" minCon="10"  dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000">
        <!--查询心跳-->
        <heartbeat>select user()</heartbeat>
        <!--配置写节点实际物理数据库信息-->
        <writeHost url="jdbc:mysql://192.168.200.142:3310" host="host1"  user="root" password="123456">
            <!--配置读节点实际物理数据库信息-->
            <readHost host="host2" url="jdbc:mysql://192.168.200.145:3310" user="root" password="123456" ></readHost>
        </writeHost>
    </dataHost>
</mycat:schema>
```

2）修改rule.xml。配置取模时的模数

```xml
<function name="mod-long" class="io.mycat.route.function.PartitionByMod">
    <!-- how many data nodes -->
    <!-- 根据datanode数量进行取模分片，也就是要模几。 -->
    <property name="count">2</property>
</function>
```

3）进行批量数据添加，可以发现数据落在了不同的库中。

![image-20200612005132092](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200612005132092.png)

![image-20200612005159630](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200612005159630.png)

4）读写分离验证

​	设置log4j2.xml的日志级别为DEBUG

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="DEBUG">
		........
        <asyncRoot level="DEBUG" includeLocation="true">
			........
        </asyncRoot>
    </Loggers>
</Configuration>
```

​	基于mysql服务进行数据查看，观察控制台信息，可以看到对于read请求的数据源，分别使用的是配置文件的配置

![image-20200621213109545](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621213109545.png)

![image-20200621213153827](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621213153827.png)

##  MyCat分片规则 

###  枚举分片

#### 实现

​	适用于在特定业务场景下，将不同的数据存放于不同的数据库中，如按省份、按人员信息等。

1）修改**schema.xml**，修改**table**标签中**name**属性为当前操作的表名，**rule**属性为**sharding-by-intfile**

```xml
<table name="tb_user_sharding_by_intfile" dataNode="dn142,dn145" primaryKey="user_id" rule="sharding-by-intfile"/>
```

2）修改**rule.xml**，配置**tableRule**为**sharding-by-intfile**中**columns**属性为当前指定分片字段

```xml
<tableRule name="sharding-by-intfile">
    <rule>
        <columns>sex</columns>
        <algorithm>hash-int</algorithm>
    </rule>
</tableRule>
```

3）修改**rule.xml**中**hash-int**

```xml
<function name="hash-int"
          class="io.mycat.route.function.PartitionByFileMap">
    <property name="mapFile">partition-hash-int.txt</property>
    <!--type默认值为0，0表示Integer，非零表示String-->
    <property name="type">1</property>
    <!--defaultNode 当有一些特殊数据信息可以存放于默认节点中，如即不是male也不是female。默认节点：小于0表示不设置默认节点，大于等于0表示设置默认节点,不能解析的枚举就存到默认节点-->
    <property name="defaultNode">0</property>
</function>
```

4）修改**partition-hash-int.txt**。指定分片字段不同值存在于不同的数据库节点

```
male=0 #代表第一个datanode
female=1 #代表第二个datanode
```

5）执行测试

​	修改mapper

```java
@Insert("insert into tb_user_sharding_by_intfile(user_id,user_name,sex) values('next value for MYCATSEQ_TB_USER12',#{userName},#{sex})")
void addUserShareBySex(User user);
```

​	执行测试，此时可以发现，当sex为male时，数据会进入142节点，当sex为female时，数据会进入145节点。

![image-20200613004923752](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200613004923752.png)

![image-20200613004947984](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200613004947984.png)6.8.1.2）

#### 问题

​	该方案适用于特定业务场景进行数据分片，但该方式容易出现数据倾斜，如不同省份的订单量一定会不同。订单量大的省份还会进行数据分库，数据库架构就会继续发生对应改变。

![image-20200613005457354](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200613005457354.png)

###  固定hash分片

​	固定hash分片的工作原理类似与redis cluster槽的概念，在固定hash中会有一个范围是0-1024，内部会进行二进制运算操作，如取 id 的二进制低 10 位 与 1111111111 进行 & 运算。从而当出现连接数据插入，其有可能会进入到同一个分片中，减少了分布式事务操作，提升插入效率同时尽量减少了数据倾斜问题，但不能避免不出现数据倾斜。

![image-20200613210301026](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200613210301026.png)

​	按照上面这张图就存在两个分区，partition1和partition2。partition1的范围是0-255，partition2的范围是256-1024。

​	当向分区中存数据时，先将id值转换为二进制，接着&1111111111，再对结果值转换为十进制，从而确定当前数据应该存入哪个分区中。

- 1023的二进制&1111111111运算后为1023，故落入第二个分区 

- 1024的二进制&1111111111运算后为0，故落入第一个分区

- 266 的二进制&1111111111运算后为266，故落入第二个分区内

#### 实现

1）修改**schema.xml**，配置自定义固定hash分配规则

```xml
<table name="tb_user_fixed_hash" dataNode="dn142,dn145" primaryKey="user_id" rule="partition-by-fixed-hash"/>
```

2）修改**rule.xml**，配置自定义固定hash分片规则

```xml
<tableRule name="partition-by-fixed-hash">
    <rule>
        <columns>user_id</columns>
        <algorithm>partition-by-fixed-hash</algorithm>
    </rule>
</tableRule>

<!--
  partitionCount: 存在多少个节点，如1,1    1,1,1    1,2
  partitionLength: 每个节点分配的范围大小
 -->
<function name="partition-by-fixed-hash" class="io.mycat.route.function.PartitionByLong">
    <property name="partitionCount">1,1</property>
    <property name="partitionLength">256,768</property>
</function>
```

3）测试，添加数据，可以发现数据会根据计算，落入相应的数据库节点。

###  固定范围分片

​	该规则有点像枚举与固定hash的综合体，设置某一个字段，然后规定该字段值的不同范围值会进入到哪一个dataNode。适用于明确知道分片字段的某个范围属于某个分片

优点：适用于想明确知道某个分片字段的某个范围具体在哪一个节点； 

缺点：如果短时间内有大量的批量插入操作，那么某个分片节点可能一下子会承受比较大的数据库压力，而别的分片节点此时可能处于闲置状态，无法利用其它节点进行分担压力（热点数据问题);

1）修改**schema.xml**。

```xml
<table name="tb_user_range" dataNode="dn142,dn145" primaryKey="user_id" rule="auto-sharding-long"/>
```

2）修改**rule.xml**

```xml
<tableRule name="auto-sharding-long">
    <rule>
        <columns>age</columns>
        <algorithm>rang-long</algorithm>
    </rule>
</tableRule>
```

3）修改**autopartition-long.txt**，定义自定义范围

```
#用于定义dataNode对应的数据范围，如果配置多了会报错。
# range start-end ,data node index
# K=1000,M=10000.
#0-500M=0
#500M-1000M=1
#1000M-1500M=2

#所有的节点配置都是从0开始，0代表节点1
0-20=0
21-50=1
```

4）测试，添加用户信息，年龄分别为9和33，可以看到，数据落入到对应的数据节点

![image-20200613220321220](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200613220321220.png)

![image-20200613220333523](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200613220333523.png)

###  取模范围分片

​	这种方式结合了范围分片和取模分片，主要是为后续的数据迁移做准备。

​	优点：可以自主决定取模后数据的节点分布。

​	缺点：dataNode 划分节点是事先建好的，需要扩展时比较麻烦。

1）修改schema.xml，配置分片规则

```xml
<table name="tb_user_mod_range" dataNode="dn142,dn145" primaryKey="user_id" rule="sharding-by-partition"/>
```

2）修改rule.xml，添加分片规则

```xml
<tableRule name="sharding-by-partition">
    <rule>
        <columns>user_id</columns>
        <algorithm>sharding-by-partition</algorithm>
    </rule>
</tableRule>

<function name="sharding-by-partition" class="io.mycat.route.function.PartitionByPattern">
    <!--求模基数-->
    <property name="patternValue">256</property>
    <!--默认节点-->
    <property name="defaultNode">0</property>
    <!--指定规则配置文件-->
    <property name="mapFile">partition-pattern.txt</property>
</function>
```

3）添加partition-pattern.txt，文件内部配置节点中数据范围

```
#0-128表示id%256后的数据范围。
0-128=0
129-256=1
```

4）测试

​	可以发现数据根据id取模并进入到了不同的分片节点中。

###  字符串hash求模范围分片

​	在业务场景下，有时可能会根据某个分片字段的前几个值来进行取模。如地址信息只取省份、姓名只取前一个字的姓等。此时则可以使用该种方式。

​	其工作方式与取模范围分片类型，该分片方式支持数值、符号、字母取模。

1）修改schema.xml。

```xml
<table name="tb_user_string_hash" dataNode="dn142,dn145" primaryKey="user_id" rule="sharding-by-string-hash"/>
```

2）修改rule.xml，定义拆分规则

```xml
<tableRule name="sharding-by-string-hash">
    <rule>
        <columns>user_name</columns>
        <algorithm>sharding-by-string-hash-function</algorithm>
    </rule>
</tableRule>

<function name="sharding-by-string-hash-function" class="io.mycat.route.function.PartitionByPrefixPattern">
    <!--求模基数 -->
    <property name="patternValue">256</property>
    <!-- 截取的位数  -->
    <property name="prefixLength">1</property>
    <property name="mapFile">partition-pattern-string-hash.txt</property>
</function>
```

3）新建partition-pattern-string-hash.txt。指定数据分片节点

```
0-128=0
129-256=1
```

4）运行后可以发现 ，不同的姓名取模后，会进入不同的分片节点。

### 一致性hash分片

​	通过一致性hash分片可以最大限度的让数据均匀分布，但是均匀分布也会带来问题，就是分布式事务。

####  原理

​	一致性hash算法引入了hash环的概念。环的大小是0~2^32-1。首先通过crc16算法计算出数据节点在hash环中的位置。

![image-20200614115947722](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614115947722.png)

​	当存储数据时，也会采用同样的算法，计算出数据key的hash值，映射到hash环上。

![image-20200614120302675](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614120302675.png)

​	然后从数据映射的位置开始，以顺时针的方式找出距离最近的数据节点，接着将数据存入到该节点中。

![image-20200614121047323](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614121047323.png)

​	此时可以发现，数据并没有达到预期的数据均匀，可以发现如果两个数据节点在环上的距离，决定有大量数据存入了dataNode2，而仅有少量数据存入dataNode1。

​	为了解决数据不均匀的问题，在mycat中可以设置**虚拟数据映射节点**。同时这些虚拟节点会映射到实际数据节点。

![image-20200614121729209](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614121729209.png)

​	数据仍然以顺时针方式寻找数据节点，当找到最近的数据节点无论是实际还是虚拟，都会进行存储，如果是虚拟数据节点的话，最终会将数据保存到实际数据节点中。 从而尽量的使数据均匀分布。

#### 实现

1）修改schema.xml

```xml
<table name="tb_user_murmur" dataNode="dn142,dn145" primaryKey="user_id" rule="sharding-by-murmur"/>
```

2）修改rule.xml

```xml
<tableRule name="sharding-by-murmur">
    <rule>
        <columns>user_id</columns>
        <algorithm>murmur</algorithm>
    </rule>
</tableRule>

<function name="murmur"
          class="io.mycat.route.function.PartitionByMurmurHash">
    <property name="seed">0</property><!-- 默认是0 -->
    <property name="count">2</property><!-- 要分片的数据库节点数量，必须指定，否则没法分片 -->
    <property name="virtualBucketTimes">160</property><!-- 一个实际的数据库节点被映射为这么多虚拟节点，默认是160倍，也就是虚拟节点数是物理节点数的160倍 -->
    <!-- <property name="weightMapFile">weightMapFile</property> 节点的权重，没有指定权重的节点默认是1。以properties文件的格式填写，以从0开始到count-1的整数值也就是节点索引为key，以节点权重值为值。所有权重值必须是正整数，否则以1代替 -->
    <!-- <property name="bucketMapPath">/etc/mycat/bucketMapPath</property>
   用于测试时观察各物理节点与虚拟节点的分布情况，如果指定了这个属性，会把虚拟节点的murmur hash值与物理节点的映射按行输出到这个文件，没有默认值，如果不指定，就不会输出任何东西 -->
</function>
```

3）测试

​	循环插入一千条数据，可以数据会尽量均匀的分布在142和145两个节点中。

###  时间分片

#### 按天分片

​	当数据量非常大时，有时会考虑，按天去分库分表。这种场景是非常常见的。同时也有利于后期的数据查询。

1）修改schema.xml

```xml
<table name="tb_user_day" dataNode="dn142,dn145" primaryKey="user_id" rule="sharding-by-date"/>
```

2）修改rule.xml，每十天一个分片，从起始时间开始计算，分片不够，则报错。

```xml
<tableRule name="sharding-by-date">
    <rule>
        <columns>create_time</columns>
        <algorithm>partbyday</algorithm>
    </rule>
</tableRule>

<function name="partbyday"
          class="io.mycat.route.function.PartitionByDate">
    <!--日期格式-->
    <property name="dateFormat">yyyy-MM-dd</property>
    <property name="sNaturalDay">0</property>
    <!--从哪天开始,并且只能插入2020年的数据，2021的无法插入-->
    <property name="sBeginDate">2020-01-01</property>
    <!--每隔几天一个分片-->
    <property name="sPartionDay">10</property>
</function>
```

3）测试

```java
@Test
public void addUserDay(){

    User user = new User();
    user.setUserName("lisi");
    user.setCreateTime("2020-01-31");
    userMapper.addUserDay(user);
}
```

当时间为1月1-10号之间，会进入142节点。当时间为11-20号之间，会进入145节点，当超出则报错。

####  按月分片

​	按月进行数据分片，每月一个分片

1）修改schema.xml

```xml
<table name="tb_user_month" dataNode="dn142,dn145" primaryKey="user_id" rule="sharding-by-month"/>
```

2）修改rule.xml

```xml
<tableRule name="sharding-by-month">
    <rule>
        <columns>create_time</columns>
        <algorithm>sharding-by-month-function</algorithm>
    </rule>
</tableRule>

<function name="sharding-by-month-function" class="io.mycat.route.function.PartitionByMonth">
    <property name="dateFormat">yyyy-MM-dd</property>
    <property name="sBeginDate">2020-05-01</property>
</function>
```

3）测试

​	可以发现当为五月会进入到节点1中，当为六月会进入到节点2中。当为七月则报错，因为需要每月一个分片，当前测试只有两个分片。

##  跨库join

###  全局表

####  简介

​	系统中基本都会存在数据字典信息，如数据分类信息、项目的配置信息等。这些字典数据最大的特点就是数据量不大并且很少会被改变。同时绝大多数的业务场景都会涉及到字典表的操作。 因此为了避免频繁的跨库join操作，结合冗余数据思想，可以考虑把这些字典信息在每一个分库中都存在一份。

​	mycat在进行join操作时，当业务表与全局表进行聚合会优先选择相同分片的全局表，从而避免跨库join操作。在进行数据插入时，会把数据同时插入到所有分片的全局表中。

####  实现

1）修改**schema.xml**

```xml
<table name="tb_global" dataNode="dn142,dn145" primaryKey="global_id" type="global"/>
```

2）测试，可以发现会同时向两张表中插入数据

![image-20200614172334771](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614172334771.png)

###  ER表

#### 介绍

ER表也是一种为了避免跨库join的手段，在业务开发时，经常会使用到主从表关系的查询，如商品表与商品详情表。![image-20200614180130992](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614180130992.png)

​	根据上图就是一个简单的表关系，但是现在有可能出现一个问题：**goods_detail中goods_id为1，2这两条数据有可能存在于142中**。这样就造成了跨库join的问题的。并且在不使用ER表的情况下，还有可能出现数据丢失的问题。

​	ER表的出现就是为了让有关系的表数据存储于同一个分片中，从而避免跨库join的出现。

####  不使用ER表问题演示

1）修改schema.xml，配置商品与商品详情表信息

```xml
<table name="tb_goods" dataNode="dn142,dn145" primaryKey="goods_id" rule="sharding-by-murmur-goods"/>
<table name="tb_goods_detail" dataNode="dn142,dn145" primaryKey="goods_detail_id" rule="sharding-by-murmur-goods-detail"/>
```

2）修改rule.xml

```xml
<tableRule name="sharding-by-murmur-goods">
    <rule>
        <columns>goods_id</columns>
        <algorithm>murmur</algorithm>
    </rule>
</tableRule>
<tableRule name="sharding-by-murmur-goods-detail">
    <rule>
        <columns>goods_detail_id</columns>
        <algorithm>murmur</algorithm>
    </rule>
</tableRule>
```

3）插入数据，**不要使用自动生成id。**

```java
@Autowired
private IdWorker idWorker;

@Test
public void addGoodsInfo(){

    for (int i = 1; i <= 1000; i++) {

        Goods goods = new Goods();
        long goodsId = idWorker.nextId();
        goods.setGoodsId(goodsId);
        goods.setGoodsName("heima"+i);
        goodsMapper.addGoods(goods);

        GoodsDetail goodsDetail = new GoodsDetail();
        goodsDetail.setGoodsDetailId(idWorker.nextId());
        goodsDetail.setGoodsId(goodsId);
        goodsDetail.setGoodsDetailName("heima goodsDetail"+i);
        goodsDetailMapper.addGoodsDetail(goodsDetail);

    }
}
```

4）连接mycat查询数据，可以发现出现数据丢失。

```sql
select * from tb_goods a join tb_goods_detail b on a.goods_id = b.goods_id
```

![image-20200614194232402](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614194232402.png)

####  ER实现

1）修改schema.xml。配置er表

```xml
<table name="tb_goods" dataNode="dn142,dn145" primaryKey="goods_id" rule="sharding-by-murmur-goods">
    <childTable name="tb_goods_detail" primaryKey="goods_detail_id" joinKey="goods_id" parentKey="goods_id"></childTable>
</table>
```

2）测试

​	删除原有数据，并重新插入数据，此时再次join查询，可以发现全部的一千条数据都已经获取到了。同时有关联关系的数据，也都存在于同一个数据分片中。

![image-20200614230514278](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200614230514278.png)



