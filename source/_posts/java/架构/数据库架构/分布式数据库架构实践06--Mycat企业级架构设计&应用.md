---
title: 分布式数据库架构实践06--Mycat企业级架构设计&应用
categories: 分布式数据库架构
tags:
  - Mycat主从切换
  - 动态扩容
  - 数据迁移
  - Haproxy+keepalived+mycat高可用负载均衡集群
top: 12
abbrlink: 1100440702
date: 2019-09-01 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/DB1.jpeg)





## Mycat主从切换

<!--more-->

​	基于Mycat主从复制方案，当前存在一个主节点和一个从节点，主节点负责写操作，从节点负责读操作。当在一个dataHost中配置了两个或多个writeHost，如果第一个writeHost宕机，则Mycat会在默认3次心跳检查失败后，自动切换到下一个可用的writeHost执行DML语句，并在**conf/dnindex.properties**文件里记录当前所用的writeHost的index。

![image-20200621190210292](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621190210292.png)

​	在Mycat主从切换中，可以将从节点也配置为是一个写节点（相当于从节点同时负责读写）。当原有的master写节点宕机后，从节点会被提升为主节点，同时负责读写操作。当写节点恢复后，会被作为从节点使用，保持现有状态不变，跟随新的主节点。

​	简单点说就是：原来的主变成从，原来的从一直为主。

### 修改schema.xml

```xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

	<schema name="userdb" checkSQLschema="true" dataNode="dn142" sqlMaxLimit="500">
		<table name="tb_user" dataNode="dn142" primaryKey="user_id" />
	</schema>


	<dataNode name="dn142" dataHost="dh142" database="user"/>

	<!--
		writeType:0  所有的写操作都发送到writeHost上
		balance:1 所有读操作都发送到readHost上
		switchType:2 基于mysql主从同步的状态决定是否切换
	-->
	<dataHost name="dh142"  writeType="0" balance="1" switchType="1" maxCon="100" minCon="10"  dbType="mysql" dbDriver="jdbc"  slaveThreshold="1000">
		<!--查询心跳-->
		<heartbeat>show slave status</heartbeat>
		<!--配置写节点实际物理数据库信息-->
		<writeHost url="jdbc:mysql://192.168.200.142:3309" host="host1"  user="root" password="123456">
			<!--配置读节点实际物理数据库信息-->
			<readHost host="host2" url="jdbc:mysql://192.168.200.145:3309" user="root" password="123456" ></readHost>
		</writeHost>

		<!--配置从节点也会作为写节点使用-->
		<writeHost url="jdbc:mysql://192.168.200.145:3309" host="host2"  user="root" password="123456"></writeHost>
	</dataHost>
</mycat:schema>
```

###  测试

​	开始测试时，当前host1为master写节点，host2为slave读节点同时作为备用写节点。

1）查看conf/dnindex.properties。可以发现dn142的值0，代表为第一个写节点。

![image-20200621194835074](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621194835074.png)

2）向tb_user表中插入数据。期望效果：当前host1为写节点，数据会进入到host1中，并复制到host2中

```sql
insert into tb_user(user_name) values('zhangsan');
```

![image-20200621193213163](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621193213163.png)

![image-20200621193227331](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621193227331.png)

3）停止host1的mysql服务。并重新执行添加操作。

```sql
insert into tb_user(user_name) values('lisi')
```

此时mycat Server控制台信息

![image-20200621194645750](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621194645750.png)

同时查看conf/dnindex.properties。可以发现dn142的值已从0变为1。进行了节点更改。![image-20200621194803521](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621194803521.png)

数据可以插入成功，但是数据会进入到第二个写节点中

![image-20200621194946743](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621194946743.png)

4）重启host1服务。并重新插入数据。

```sql
insert into tb_user(user_name) values('wangwu')
```

此时可以发现数据仍然会进入到host2中，因为就算之前的host1恢复了，根据mycat的规则其也不会自动提升为写节点，因此写节点仍然为host2。 

并且当前为主从架构，并没有配置为双向复制。所以数据进入到host2后，host1中仍然没有数据，符合预期。此时host2会同时负责读、写请求。

![image-20200621195436688](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621195436688.png)

![image-20200621195444753](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200621195444753.png)

##  动态扩容&数据迁移

​	在生产环境下，当原有的数据库节点已经满足不了当前的数据存储量，此时就会在现有数据库基础上新增数据节点。但是当新增数据节点后，就要考虑原有的数据应该如何迁移一部分数据到新增的数据节点上。

​	![image-20200628172038412](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628172038412.png)

1）上传mycat，并在mycat目录下创建logs目录，并在logs目录中创建mycat.pid文件

1）/conf目录下新建newSchema.xml和newRule.xml，用于配置扩容节点。修改内容如下

```xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">


    <schema name="userdb" checkSQLschema="true" dataNode="dn180" sqlMaxLimit="500">
        <table name="tb_user" dataNode="dn180,dn181,dn182" primaryKey="user_id" rule="mod-long">
        </table>
    </schema>


    <dataNode name="dn180" dataHost="dh180" database="user"/>
    <dataNode name="dn181" dataHost="dh181" database="user"/>
    <dataNode name="dn182" dataHost="dh182" database="user"/>

    <dataHost name="dh180" balance="0" maxCon="100" minCon="10"  dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000">

        <heartbeat>select user()</heartbeat>

        <writeHost url="jdbc:mysql://192.168.200.180:3311" host="host1"  user="root" password="123456">
        </writeHost>
    </dataHost>

    <dataHost name="dh181" balance="0" maxCon="100" minCon="10"  dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000">

        <heartbeat>select user()</heartbeat>

        <writeHost url="jdbc:mysql://192.168.200.181:3311" host="host1"  user="root" password="123456">
        </writeHost>
    </dataHost>

    <dataHost name="dh182" balance="0" maxCon="100" minCon="10"  dbType="mysql" dbDriver="jdbc" writeType="0" switchType="1" slaveThreshold="1000">

        <heartbeat>select user()</heartbeat>

        <writeHost url="jdbc:mysql://192.168.200.182:3311" host="host1"  user="root" password="123456">
        </writeHost>
    </dataHost>
</mycat:schema>
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- - - Licensed under the Apache License, Version 2.0 (the "License"); 
 - you may not use this file except in compliance with the License. - You 
 may obtain a copy of the License at - - http://www.apache.org/licenses/LICENSE-2.0 
 - - Unless required by applicable law or agreed to in writing, software - 
 distributed under the License is distributed on an "AS IS" BASIS, - WITHOUT 
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. - See the 
 License for the specific language governing permissions and - limitations 
 under the License. -->
<!DOCTYPE mycat:rule SYSTEM "rule.dtd">
<mycat:rule xmlns:mycat="http://io.mycat/">
    <tableRule name="rule1">
        <rule>
            <columns>id</columns>
            <algorithm>func1</algorithm>
        </rule>
    </tableRule>

    <tableRule name="partition-by-fixed-hash">
        <rule>
            <columns>user_id</columns>
            <algorithm>partition-by-fixed-hash</algorithm>
        </rule>
    </tableRule>


    <tableRule name="sharding-by-date">
        <rule>
            <columns>create_time</columns>
            <algorithm>partbyday</algorithm>
        </rule>
    </tableRule>

    <tableRule name="rule2">
        <rule>
            <columns>user_id</columns>
            <algorithm>func1</algorithm>
        </rule>
    </tableRule>

    <tableRule name="sharding-by-intfile">
        <rule>
            <columns>sex</columns>
            <algorithm>hash-int</algorithm>
        </rule>
    </tableRule>
    <tableRule name="auto-sharding-long">
        <rule>
            <columns>age</columns>
            <algorithm>rang-long</algorithm>
        </rule>
    </tableRule>
    <tableRule name="mod-long">
        <rule>

            <columns>user_id</columns>
            <algorithm>mod-long</algorithm>
        </rule>
    </tableRule>
    <tableRule name="sharding-by-murmur">
        <rule>
            <columns>user_id</columns>
            <algorithm>murmur</algorithm>
        </rule>
    </tableRule>
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
    <tableRule name="crc32slot">
        <rule>
            <columns>id</columns>
            <algorithm>crc32slot</algorithm>
        </rule>
    </tableRule>
    <tableRule name="sharding-by-month">
        <rule>
            <columns>create_time</columns>
            <algorithm>sharding-by-month-function</algorithm>
        </rule>
    </tableRule>
    <tableRule name="latest-month-calldate">
        <rule>
            <columns>calldate</columns>
            <algorithm>latestMonth</algorithm>
        </rule>
    </tableRule>

    <tableRule name="auto-sharding-rang-mod">
        <rule>
            <columns>id</columns>
            <algorithm>rang-mod</algorithm>
        </rule>
    </tableRule>

    <tableRule name="jch">
        <rule>
            <columns>id</columns>
            <algorithm>jump-consistent-hash</algorithm>
        </rule>
    </tableRule>

    <tableRule name="sharding-by-hour">
        <rule>
            <columns>user_hour</columns>
            <algorithm>sharding-by-hour-function</algorithm>
        </rule>
    </tableRule>

    <function name="murmur"
              class="io.mycat.route.function.PartitionByMurmurHash">
        <property name="seed">0</property>
        <property name="count">2</property>
        <property name="virtualBucketTimes">160</property>
    </function>

    <function name="crc32slot"
              class="io.mycat.route.function.PartitionByCRC32PreSlot">
        <property name="count">2</property>
    </function>
    <function name="hash-int"
              class="io.mycat.route.function.PartitionByFileMap">
        <property name="mapFile">partition-hash-int.txt</property>

        <property name="type">1</property>

        <property name="defaultNode">0</property>
    </function>
    <function name="rang-long"
              class="io.mycat.route.function.AutoPartitionByLong">
        <property name="mapFile">autopartition-long.txt</property>
    </function>
    <function name="mod-long" class="io.mycat.route.function.PartitionByMod">

        <property name="count">3</property>
    </function>

    <function name="func1" class="io.mycat.route.function.PartitionByLong">
        <property name="partitionCount">8</property>
        <property name="partitionLength">128</property>
    </function>


    <function name="partition-by-fixed-hash" class="io.mycat.route.function.PartitionByLong">
        <property name="partitionCount">1,1</property>
        <property name="partitionLength">256,768</property>
    </function>

    <function name="latestMonth"
              class="io.mycat.route.function.LatestMonthPartion">
        <property name="splitOneDay">24</property>
    </function>
    <function name="partbymonth"
              class="io.mycat.route.function.PartitionByMonth">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2015-01-01</property>
    </function>


    <function name="partbyday"
              class="io.mycat.route.function.PartitionByDate">

        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sNaturalDay">0</property>

        <property name="sBeginDate">2020-01-01</property>

        <property name="sPartionDay">10</property>
    </function>

    <function name="rang-mod" class="io.mycat.route.function.PartitionByRangeMod">
        <property name="mapFile">partition-range-mod.txt</property>
    </function>

    <function name="jump-consistent-hash" class="io.mycat.route.function.PartitionByJumpConsistentHash">
        <property name="totalBuckets">3</property>
    </function>

    <function name="sharding-by-hour-function" class="io.mycat.route.function.LatestMonthPartion">

        <property name="splitOneDay">2</property>
    </function>

    <function name="sharding-by-month-function" class="io.mycat.route.function.PartitionByMonth">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2020-05-01</property>
    </function>
</mycat:rule>

```

2）修改/conf下migrateTables.properties，指定虚拟库和表

```properties
userdb=tb_user
```

3）修改/bin下dataMigrate.sh

修改该文件编码格式由原有dos修改为unix

```
#查看文件格式
:set ff

#修改文件格式
:set ff=unix
```

修改mysqldump文件路径

```
#查看mysqldump文件路径
find / -name mysqldump

#修改dataMigrate.sh文件配置
RUN_CMD="$RUN_CMD -mysqlBin=/usr/bin/"
```

4）执行数据扩容与迁移

```
cd bin

./dataMigrate.sh
```

5）执行后结果

![image-20200628173237529](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628173237529.png)

`ps:执行数据扩容&迁移时，务必注意虚拟库的名称必须要全部是小写，不能大小写混合`

6）数据迁移后还应考虑后续的数据查询，此时还需将文件进行替换，用于查询路由。

```
mv newRule.xml rule.xml

mv newSchema.xml schema.xml
```

##  Haproxy+keepalived+mycat高可用负载均衡集群

​	当线上服务器压力过大时，可以考虑基于keepalived进行高可用避免出现mycat单点问题，同时为了防止线上压力集中在某一台实例上，可以通过haproxy进行请求的负载均衡。

![image-20200628173502183](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628173502183.png)

### mycat准备

​	142&145两台机器准备mycat-server并启动

###  haproxy安装&配置

```yml
#下载haproxy镜像
docker pull haproxy:1.9.6

#在宿主机指定文件夹创建haproxy.cfg

global
    log         127.0.0.1 local2
    maxconn     4000
    daemon

defaults
        log     global
        log 127.0.0.1 local3
        mode    http
        option  tcplog
        option  dontlognull
        retries 10
        option redispatch
        maxconn         2000
        timeout connect         10s
        timeout client          1m
        timeout server          1m
        timeout http-keep-alive 10s
        timeout check           10s

listen admin_stats
        bind 0.0.0.0:10080
        mode http
        option httplog
        maxconn 10
        stats refresh 30s
        stats uri /stats
        stats realm XingCloud/ Haproxy
        stats auth admin:admin #用这个账号登录，可以自己设置
        stats hide-version
        stats admin if TRUE
        
listen  mycat
        bind 0.0.0.0:3300
        mode tcp
        balance roundrobin
        server mycat-180 192.168.200.180:8066 check port 8066 maxconn 300
        server mycat-181 192.168.200.181:8066 check port 8066 maxconn 300
        
#启动容器
docker run -d --name haproxy -p 10080:10080 -v /usr/local/haproxy:/usr/local/etc/haproxy haproxy:1.9.6

#访问web管理页面
http://192.168.200.142:10080/stats
```

http://192.168.200.142:10080/stats     帐号：admin  密码：admin

![image-20200628195202338](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628195202338.png)

###  keepalived安装&配置

1）安装epel-release源

```
yum list installed|grep epel-release
```

2）查找可用安装源

```
yum search keepalived
```

3）keepAlived安装

```
yum install keepalived -y
```

4）安装虚拟服务器管理命令

```
yum install ipvsadm -y
```

5）编写执行shell脚本

```shell
# vi /etc/keepalived/chk.sh#!/bin/bash
#
if [ $(ps -C haproxy --no-header | wc -l) -eq 0 ]; then
       killall keepalived
fi
```

6）配置keepAlived配置文件

```
cd /etc/keepalived

vi keepalvied.conf

! Configuration File for keepalived
#简单的头部，这里主要可以做邮件通知报警等的设置，此处就暂不配置了；
global_defs {
        #notificationd LVS_DEVEL
}
#预先定义一个脚本，方便后面调用，也可以定义多个，方便选择；
vrrp_script chk_haproxy {
    script "/etc/keepalived/check.sh"
    interval 2  #脚本循环运行间隔
}
#VRRP虚拟路由冗余协议配置
vrrp_instance VI_1 {   #VI_1 是自定义的名称；
    state BACKUP    #MASTER表示是一台主设备，BACKUP表示为备用设备【我们这里因为设置为开启不抢占，所以都设置为备用】
    nopreempt      #开启不抢占
    interface ens33   #指定VIP需要绑定的物理网卡
    virtual_router_id 11   #VRID虚拟路由标识，也叫做分组名称，该组内的设备需要相同
    priority 130   #定义这台设备的优先级 1-254；开启了不抢占，所以此处优先级必须高于另一台

    advert_int 1   #生存检测时的组播信息发送间隔，组内一致
    authentication {    #设置验证信息，组内一致
        auth_type PASS   #有PASS 和 AH 两种，常用 PASS
        auth_pass 111111    #密码
    }
    virtual_ipaddress {
        192.168.200.200    #指定VIP地址，组内一致，可以设置多个IP
    }
    track_script {    #使用在这个域中使用预先定义的脚本，上面定义的
        chk_haproxy
    }
}
```

7）启动keepAlived

```
systemctl start keepalived
```

8）查看keepAlived执行状态

```
ps -ef|grep keepalived
```

![image-20200628202404850](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628202404850.png)

9）此时通过ip a可以看到优先级高的机器已经有了虚拟ip

![image-20200628202617986](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628202617986.png)

10）访问haproxy

192.168.200.200:10080/stats   访问成功

![image-20200628202701140](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628202701140.png)

11）访问mycat

![image-20200628202822392](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/DB/1/assets/image-20200628202822392.png)

访问成功，现在已经成功通过keepalived+haproxy跳转到mycat上。

