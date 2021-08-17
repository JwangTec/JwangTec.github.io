---
title: 消息中间件01-RabbitMQ入门
categories: 消息中间件
tags:
  - 消息队列
  - RabbitMQ的使用操作
  - RabbitMQ的5种模式
  - SpringBoot整合RabbitMQ
top: 13
abbrlink: 2259534704
date: 2019-10-01 18:18:19
password:
---



## 1. 消息队列概述

### 1.1. 消息队列MQ

MQ全称为Message Queue，消息队列是应用程序和应用程序之间的通信方法。

 为什么使用MQ

```properties
在项目中，可将一些无需即时返回且耗时的操作提取出来，进行异步处理，而这种异步处理的方式大大的节省了服务器的请求响应时间，从而提高了系统的吞吐量。
```
<!--more-->
开发中消息队列通常有如下应用场景：

```properties
1、任务异步处理
	将不需要同步处理的并且耗时长的操作由消息队列通知消息接收方进行异步处理。提高了应用程序的响应时间。
	
2、应用程序解耦合
	MQ相当于一个中介，生产方通过MQ与消费方交互，它将应用程序进行解耦合。
```



### 1.2. AMQP 和 JMS

MQ是消息通信的模型；实现MQ的大致有两种主流方式：AMQP、JMS。



#### 1.2.1. AMQP

AMQP高级消息队列协议，是一个进程间传递异步消息的网络协议，更准确的说是一种binary wire-level protocol（链接协议）。这是其和JMS的本质差别，AMQP不从API层进行限定，而是直接定义网络交换的数据格式。



#### 1.2.2. JMS

JMS即Java消息服务（JavaMessage Service）应用程序接口，是一个Java平台中关于面向消息中间件（MOM）的API，用于在两个应用程序之间，或分布式系统中发送消息，进行异步通信。



#### 1.2.3. AMQP 与 JMS 区别

- JMS是定义了统一的接口，来对消息操作进行统一；AMQP是通过规定协议来统一数据交互的格式

- JMS限定了必须使用Java语言；AMQP只是协议，不规定实现方式，因此是跨语言的。

- JMS规定了两种消息模式；而AMQP的消息模式更加丰富

  ```
  JMS
  ①订阅模式
  ②点对点消息模式
  ```






### 1.3. 消息队列产品

市场上常见的消息队列有如下：

目前市面上成熟主流的MQ有Kafka 、RocketMQ、RabbitMQ，我们这里对每款MQ做一个简单介绍。

**Kafka**

```properties
Apache下的一个子项目，使用scala实现的一个高性能分布式Publish/Subscribe消息队列系统。
	1.快速持久化：通过磁盘顺序读写与零拷贝机制，可以在O(1)的系统开销下进行消息持久化；
	2.高吞吐：在一台普通的服务器上既可以达到10W/s的吞吐速率；
	3.高堆积：支持topic下消费者较长时间离线，消息堆积量大；
	4.完全的分布式系统：Broker、Producer、Consumer都原生自动支持分布式，依赖zookeeper自动实现复杂均衡；
	5.支持Hadoop数据并行加载：对于像Hadoop的一样的日志数据和离线分析系统，但又要求实时处理的限制，这是一个可行的解决方案。
```



**RocketMQ**

```properties
RocketMQ的前身是Metaq，当Metaq3.0发布时，产品名称改为RocketMQ。RocketMQ是一款分布式、队列模型的消息中间件，具有以下特点 ：
	1.能够保证严格的消息顺序
 	2.提供丰富的消息拉取模式
 	3.高效的订阅者水平扩展能力
 	4.实时的消息订阅机制
 	5.支持事务消息
 	6.亿级消息堆积能力
```



**RabbitMQ**

```properties
使用Erlang编写的一个开源的消息队列，本身支持很多的协议：AMQP，XMPP, SMTP,STOMP，也正是如此，使的它变的非常重量级，更适合于企业级的开发。同时实现了Broker架构，核心思想是生产者不会将消息直接发送给队列，消息在发送给客户端时先在中心队列排队。对路由(Routing)，负载均衡(Load balance)、数据持久化都有很好的支持。多用于进行企业级的ESB整合。
```







### 1.4. RabbitMQ

RabbitMQ是由erlang语言开发，基于AMQP（Advanced Message Queue 高级消息队列协议）协议实现的消息队列，它是一种应用程序之间的通信方法，消息队列在分布式系统开发中应用非常广泛。

RabbitMQ官方地址：http://www.rabbitmq.com/



RabbitMQ提供了6种模式：简单模式，work模式，Publish/Subscribe发布与订阅模式，Routing路由模式，Topics主题模式，RPC远程调用模式（远程调用，不太算MQ；不作介绍）；

官网对应模式介绍：https://www.rabbitmq.com/getstarted.html



![1555988678324](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1555988678324.png)



## 2. 安装及配置RabbitMQ

### 2.1. 安装说明

1.安装erlang，如下图：注意使用**管理员身份**打开即可

![1583835912197](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1583835912197.png)

2.安装rabbitmq-server：

​	如上图使用**管理员身份**打开那个rabbitma-server-3.7.4.exe文件。

3.配置环境变量

![1583836036418](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1583836036418.png)

配置：elang-home:,指定你的erlang的安装目录

![1583836074919](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1583836074919.png)



添加到path中：

![1583836125601](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1583836125601.png)

（3）cmd到rabbitmq-server的 sbin目录下 打开cmd命令行工具

```shell
cd C:\Program Files\RabbitMQ Server\rabbitmq_server-3.7.4\sbin
```

执行命令：

```shell
rabbitmq-plugins.bat enable rabbitmq_management
```



![1583836333935](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1583836333935.png)



(4)重启rabbitmq服务器：

此电脑--》右击 点击管理界面--》双击服务和应用程序--》双击 服务--》点击重启按钮即可

![1583836445304](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1583836445304.png)



（5）浏览器中输入localhost:15672 输 guest/guest

![1583836696619](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1583836696619.png)



### 2.2. 用户以及Virtual Hosts配置

#### 2.2.1. 用户角色

RabbitMQ在安装好后，可以访问http://localhost:15672 ；其自带了guest/guest的用户名和密码；如果需要创建自定义用户；那么也可以登录管理界面后，如下操作：

![1562510312338](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562510312338.png)

**角色说明**：

1、 超级管理员(administrator)

可登陆管理控制台，可查看所有的信息，并且可以对用户，策略(policy)进行操作。

2、 监控者(monitoring)

可登陆管理控制台，同时可以查看rabbitmq节点的相关信息(进程数，内存使用情况，磁盘使用情况等)

3、 策略制定者(policymaker)

可登陆管理控制台, 同时可以对policy进行管理。但无法查看节点的相关信息(上图红框标识的部分)。

4、 普通管理者(management)

仅可登陆管理控制台，无法看到节点信息，也无法对策略进行管理。

5、 其他

无法登陆管理控制台，通常就是普通的生产者和消费者。



#### 2.2.2. Virtual Hosts配置

像mysql拥有数据库的概念并且可以指定用户对库和表等操作的权限。RabbitMQ也有类似的权限管理；在RabbitMQ中可以虚拟消息服务器Virtual Host，每个Virtual Hosts相当于一个相对独立的RabbitMQ服务器，每个VirtualHost之间是相互隔离的。exchange、queue、message不能互通。 相当于mysql的db。Virtual Name一般以/开头。



**(1)创建Virtual Hosts**

![1562510535211](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562510535211.png)



**(2)设置Virtual Hosts权限**

![1562510799676](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562510799676.png)

![1562511048889](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562511048889.png)

参数说明：

```properties
user：用户名
configure ：一个正则表达式，用户对符合该正则表达式的所有资源拥有 configure 操作的权限
write：一个正则表达式，用户对符合该正则表达式的所有资源拥有 write 操作的权限
read：一个正则表达式，用户对符合该正则表达式的所有资源拥有 read 操作的权限
```





## 3. RabbitMQ入门

入门案例将使用RabbitMQ的简单模式实现。



### 3.1. 搭建示例工程

#### 3.1.1. 创建工程

工程坐标如下：

```xml
<groupId>com.jwang</groupId>
<artifactId>rabbitmq-demo</artifactId>
<version>1.0-SNAPSHOT</version>
```



#### 3.1.2. 添加依赖

往heima-rabbitmq的pom.xml文件中添加如下依赖：

```xml
<dependency>
    <groupId>com.rabbitmq</groupId>
    <artifactId>amqp-client</artifactId>
    <version>5.6.0</version>
</dependency>
```



### 3.2. 生产者

生产者的创建分为如下几个步骤：

```properties
//创建链接工厂对象
//设置RabbitMQ服务主机地址,默认localhost
//设置RabbitMQ服务端口,默认5672
//设置虚拟主机名字，默认/
//设置用户连接名，默认guest
//设置链接密码，默认guest
//创建链接
//创建频道
//声明队列
//创建消息
//消息发送
//关闭资源
```



按照上面的步骤，我们创建一个消息生产者，创建com.jwang.rabbitmq.simple.Producer类，代码如下：

```java
public class Producer {

    /***
     * 消息生产者
     * @param args
     * @throws IOException
     * @throws TimeoutException
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接工厂对象
        ConnectionFactory connectionFactory = new ConnectionFactory();

        //设置RabbitMQ服务主机地址,默认localhost
        connectionFactory.setHost("localhost");

        //设置RabbitMQ服务端口,默认5672
        connectionFactory.setPort(5672);

        //设置虚拟主机名字，默认/
        connectionFactory.setVirtualHost("/szjwang");

        //设置用户连接名，默认guest
        connectionFactory.setUsername("admin");

        //设置链接密码，默认guest
        connectionFactory.setPassword("admin");

        //创建链接
        Connection connection = connectionFactory.newConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         * **/
        channel.queueDeclare("simple_queue",true,false,false,null);

        //创建消息
        String message = "hello!welcome to jwang!";

        /**
         * 消息发送
         * 参数1：交换机名称，如果没有指定则使用默认Default Exchage
         * 参数2：路由key,简单模式可以传递队列名称
         * 参数3：消息其它属性
         * 参数4：消息内容
         */
        channel.basicPublish("","simple_queue",null,message.getBytes());

        //关闭资源
        channel.close();
        connection.close();
    }
}
```



在执行上述的消息发送之后；可以登录rabbitMQ的管理控制台，可以发现队列和其消息：

![1562512944426](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562512944426.png)

如果想查看消息，可以点击`队列名称->Get Messages`,如下图：

![1562513030629](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562513030629.png)



### 3.3. 消费者

消费者创建可以按照如下步骤实现：

```properties
//创建链接工厂对象
//设置RabbitMQ服务主机地址,默认localhost
//设置RabbitMQ服务端口,默认5672
//设置虚拟主机名字，默认/
//设置用户连接名，默认guest
//设置链接密码，默认guest
//创建链接
//创建频道
//创建队列
//创建消费者，并设置消息处理
//消息监听
//关闭资源(不建议关闭，建议一直监听消息)
```

按照上面的步骤创建消息消费者com.jwang.rabbitmq.simple.Consumer代码如下：

```java
public class Consumer {

    /***
     * 消息消费者
     * @param args
     * @throws IOException
     * @throws TimeoutException
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接工厂对象
        ConnectionFactory connectionFactory = new ConnectionFactory();

        //设置RabbitMQ服务主机地址,默认localhost
        connectionFactory.setHost("localhost");

        //设置RabbitMQ服务端口,默认5672
        connectionFactory.setPort(5672);

        //设置虚拟主机名字，默认/
        connectionFactory.setVirtualHost("/szjwang");

        //设置用户连接名，默认guest
        connectionFactory.setUsername("admin");

        //设置链接密码，默认guest
        connectionFactory.setPassword("admin");

        //创建链接
        Connection connection = connectionFactory.newConnection();

        //创建频道
        Channel channel = connection.createChannel();

        //创建队列
        channel.queueDeclare("simple_queue",true,false,false,null);

        //创建消费者，并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            /***
             * @param consumerTag   消息者标签，在channel.basicConsume时候可以指定
             * @param envelope      消息包的内容，可从中获取消息id，消息routingkey，交换机，消息和重传标志(收到消息失败后是否需要重新发送)
             * @param properties    属性信息
             * @param body           消息
             * @throws IOException
             */
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由的key
                String routingKey = envelope.getRoutingKey();
                //获取交换机信息
                String exchange = envelope.getExchange();
                //获取消息ID
                long deliveryTag = envelope.getDeliveryTag();
                //获取消息信息
                String message = new String(body,"UTF-8");
                System.out.println("routingKey:"+routingKey+",exchange:"+exchange+",deliveryTag:"+deliveryTag+",message:"+message);
            }
        };

        /**
         * 消息监听
         * 参数1：队列名称
         * 参数2：是否自动确认，设置为true为表示消息接收到自动向mq回复接收到了，mq接收到回复会删除消息，设置为false则需要手动确认
         * 参数3：消息接收到后回调
         */
        channel.basicConsume("simple_queue",true,defaultConsumer);

        //关闭资源(不建议关闭，建议一直监听消息)
        //channel.close();
        //connection.close();
    }
}
```

执行后，控制台输入如下：

![1562515242811](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562515242811.png)

RabbitMQ控制台如下：

![1562515330648](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562515330648.png)



### 3.4 工具抽取

(1)工具类抽取

无论是消费者，还是生产者，我们发现前面的几个步骤几乎一模一样，所以可以抽取一个工具类,将下面这段代码抽取出去。

![1562515515174](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562515515174.png)



创建com.jwang.rabbitmq.util.ConnectionUtil工具类对象，用于创建Connection，代码如下：

```java
public class ConnectionUtil {

    /***
     * 创建链接对象
     * @return
     * @throws IOException
     * @throws TimeoutException
     */
    public static Connection getConnection() throws IOException, TimeoutException {
        //创建链接工厂对象
        ConnectionFactory connectionFactory = new ConnectionFactory();

        //设置RabbitMQ服务主机地址,默认localhost
        connectionFactory.setHost("localhost");

        //设置RabbitMQ服务端口,默认5672
        connectionFactory.setPort(5672);

        //设置虚拟主机名字，默认/
        connectionFactory.setVirtualHost("/szjwang");

        //设置用户连接名，默认guest
        connectionFactory.setUsername("admin");

        //设置链接密码，默认guest
        connectionFactory.setPassword("admin");

        //创建链接
        Connection connection = connectionFactory.newConnection();
        return connection;
    }
}
```



(2)生产者优化

修改com.jwang.rabbitmq.simple.Producer，链接对象使用上面的ConnectionUtil工具类创建，代码如下：

```java
//创建链接
Connection connection = ConnectionUtil.getConnection();
```



(3)消费者优化

修改com.jwang.rabbitmq.simple.Consumer，链接对象使用上面的ConnectionUtil工具类创建，代码如下：

```java
//创建链接
Connection connection = ConnectionUtil.getConnection();
```





### 3.4. 小结

上述的入门案例中中其实使用的是如下的简单模式：

![1555991074575](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1555991074575.png)

在上图的模型中，有以下概念：

```properties
P：生产者，也就是要发送消息的程序
C：消费者：消息的接受者，会一直等待消息到来。
queue：消息队列，图中红色部分。类似一个邮箱，可以缓存消息；生产者向其中投递消息，消费者从其中取出消息。
```

在rabbitMQ中消息者是一定要到某个消息队列中去获取消息的



## 4. RabbitMQ工作模式

### 4.1. Work queues工作队列模式

#### 4.1.1. 模式说明

![1562516450360](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562516450360.png)

`Work Queues`与入门程序的`简单模式`相比，多了一个或一些消费端，多个消费端共同消费同一个队列中的消息。

**应用场景**：对于 任务过重或任务较多情况使用工作队列可以提高任务处理的速度。



#### 4.1.2. 代码

`Work Queues`与入门程序的`简单模式`的代码是几乎一样的；可以完全复制，并复制多一个消费者进行多个消费者同时消费消息的测试。



(1)生产者

创建com.jwang.rabbitmq.work.WorkProducer消息生产者对象，代码如下：

```java
public class WorkProducer {

    /***
     * 消息生产者
     * @param args
     * @throws IOException
     * @throws TimeoutException
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         * **/
        channel.queueDeclare("work_queue",true,false,false,null);

        for (int i = 0; i < 10; i++) {
            String message = "hello!welcome to jwang!"+i;
            channel.basicPublish("","work_queue",null,message.getBytes());
        }

        //关闭资源
        channel.close();
        connection.close();
    }
}
```



(2)消费者One

创建第1个Work消费者com.jwang.rabbitmq.work.WorkConsumerOne,代码如下：

```java
public class WorkConsumerOne {

    /***
     * 消息消费者
     * @param args
     * @throws IOException
     * @throws TimeoutException
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        //创建队列
        channel.queueDeclare("work_queue",true,false,false,null);

        //创建消费者，并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            /***
             * @param consumerTag   消息者标签，在channel.basicConsume时候可以指定
             * @param envelope      消息包的内容，可从中获取消息id，消息routingkey，交换机，消息和重传标志(收到消息失败后是否需要重新发送)
             * @param properties    属性信息
             * @param body           消息
             * @throws IOException
             */
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由的key
                String routingKey = envelope.getRoutingKey();
                //获取交换机信息
                String exchange = envelope.getExchange();
                //获取消息ID
                long deliveryTag = envelope.getDeliveryTag();
                //获取消息信息
                String message = new String(body,"UTF-8");
                System.out.println("Work-One:routingKey:"+routingKey+",exchange:"+exchange+",deliveryTag:"+deliveryTag+",message:"+message);
            }
        };

        /**
         * 消息监听
         * 参数1：队列名称
         * 参数2：是否自动确认，设置为true为表示消息接收到自动向mq回复接收到了，mq接收到回复会删除消息，设置为false则需要手动确认
         * 参数3：消息接收到后回调
         */
        channel.basicConsume("work_queue",true,defaultConsumer);

        //关闭资源(不建议关闭，建议一直监听消息)
        //channel.close();
        //connection.close();
    }
}
```





(3)消费者Two

创建第2个Work消费者com.jwang.rabbitmq.work.WorkConsumerTwo，代码如下：

```java
public class WorkConsumerTwo {

    /***
     * 消息消费者
     * @param args
     * @throws IOException
     * @throws TimeoutException
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        //创建队列
        channel.queueDeclare("work_queue",true,false,false,null);

        //创建消费者，并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            /***
             * @param consumerTag   消息者标签，在channel.basicConsume时候可以指定
             * @param envelope      消息包的内容，可从中获取消息id，消息routingkey，交换机，消息和重传标志(收到消息失败后是否需要重新发送)
             * @param properties    属性信息
             * @param body           消息
             * @throws IOException
             */
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由的key
                String routingKey = envelope.getRoutingKey();
                //获取交换机信息
                String exchange = envelope.getExchange();
                //获取消息ID
                long deliveryTag = envelope.getDeliveryTag();
                //获取消息信息
                String message = new String(body,"UTF-8");
                System.out.println("Work-Two:routingKey:"+routingKey+",exchange:"+exchange+",deliveryTag:"+deliveryTag+",message:"+message);
            }
        };

        /**
         * 消息监听
         * 参数1：队列名称
         * 参数2：是否自动确认，设置为true为表示消息接收到自动向mq回复接收到了，mq接收到回复会删除消息，设置为false则需要手动确认
         * 参数3：消息接收到后回调
         */
        channel.basicConsume("work_queue",true,defaultConsumer);

        //关闭资源(不建议关闭，建议一直监听消息)
        //channel.close();
        //connection.close();
    }
}
```



#### 4.1.3. 测试

启动两个消费者，然后再启动生产者发送消息；到IDEA的两个消费者对应的控制台查看是否竞争性的接收到消息。

![1562517664233](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562517664233.png)

![1562517631409](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562517631409.png)



#### 4.1.4. 小结

在一个队列中如果有多个消费者，那么消费者之间对于同一个消息的关系是**竞争**的关系。



### 4.2. 订阅模式类型

订阅模式示例图：

![1556014499573](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1556014499573.png)

前面2个案例中，只有3个角色：

```properties
P：生产者，也就是要发送消息的程序
C：消费者：消息的接受者，会一直等待消息到来。
Queue：消息队列，图中红色部分
```



而在订阅模型中，多了一个exchange角色，而且过程略有变化：

```properties
P：生产者，也就是要发送消息的程序，但是不再发送到队列中，而是发给X（交换机）
C：消费者，消息的接受者，会一直等待消息到来。
Queue：消息队列，接收消息、缓存消息。
Exchange：交换机，图中的X。一方面，接收生产者发送的消息。另一方面，知道如何处理消息，例如递交给某个特别队列、递交给所有队列、或是将消息丢弃。到底如何操作，取决于Exchange的类型。Exchange有常见以下3种类型：
	Fanout：广播，将消息交给所有绑定到交换机的队列
	Direct：定向，把消息交给符合指定routing key 的队列
	Topic：通配符，把消息交给符合routing pattern（路由模式） 的队列
```

**Exchange（交换机）只负责转发消息，不具备存储消息的能力**，因此如果没有任何队列与Exchange绑定，或者没有符合路由规则的队列，那么消息会丢失！





### 4.3. Publish/Subscribe发布与订阅模式

#### 4.3.1. 模式说明

![1562518625240](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562518625240.png)

发布订阅模式：

```properties
1.每个消费者监听自己的队列。
2.生产者将消息发给broker，由交换机将消息转发到绑定此交换机的每个队列，每个绑定交换机的队列都将接收
到消息
```



#### 4.3.2. 代码

(1)生产者

生产者需要注意如下3点：

```properties
1.声明交换机
2.声明队列
3.队列需要绑定指定的交换机
```



创建com.jwang.rabbitmq.ps.PublishSubscribeProducer消息生产者，代码如下：

```java
public class PublishSubscribeProducer {

    /***
     * 订阅模式
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明交换机
         * 参数1：交换机名称
         * 参数2：交换机类型，fanout、topic、direct、headers
         */
        channel.exchangeDeclare("fanout_exchange", BuiltinExchangeType.FANOUT);

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("fanout_queue_1",true,false,false,null);
        channel.queueDeclare("fanout_queue_2",true,false,false,null);

        //队列绑定交换机
        channel.queueBind("fanout_queue_1","fanout_exchange","");
        channel.queueBind("fanout_queue_2","fanout_exchange","");

        //消息
        String message = "发布订阅模式:欢迎来到传深圳黑马训练营程序员中心！";
        /**
         * 参数1：交换机名称，如果没有指定则使用默认Default Exchage
         * 参数2：路由key,简单模式可以传递队列名称
         * 参数3：消息其它属性
         * 参数4：消息内容
         */
        channel.basicPublish("fanout_exchange","",null,message.getBytes());

        //关闭资源
        channel.close();
        connection.close();
    }
}
```



(2)消费者One

创建com.jwang.rabbitmq.ps.PublishSubscribeConsumerOne消息消费对象，代码如下：

```java
public class PublishSubscribeConsumerOne {

    /***
     * 订阅模式消息消费者
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("fanout_queue_1",true,false,false,null);

        //创建消费者；并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由key
                System.out.println("路由key为：" + envelope.getRoutingKey());
                //交换机
                System.out.println("交换机为：" + envelope.getExchange());
                //消息id
                System.out.println("消息id为：" + envelope.getDeliveryTag());
                //收到的消息
                System.out.println("消费者One-接收到的消息为：" + new String(body, "utf-8"));
            }
        };

        //消息监听
        channel.basicConsume("fanout_queue_1",true,defaultConsumer);

        //关闭资源
        //channel.close();
        //connection.close();
    }
}
```



(3)消费者Two

创建com.jwang.rabbitmq.ps.PublishSubscribeConsumerTwo消息消费对象，代码如下：

```java
public class PublishSubscribeConsumerTwo {

    /***
     * 订阅模式消息消费者
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("fanout_queue_2",true,false,false,null);

        //创建消费者；并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由key
                System.out.println("路由key为：" + envelope.getRoutingKey());
                //交换机
                System.out.println("交换机为：" + envelope.getExchange());
                //消息id
                System.out.println("消息id为：" + envelope.getDeliveryTag());
                //收到的消息
                System.out.println("消费者Two-接收到的消息为：" + new String(body, "utf-8"));
            }
        };

        //消息监听
        channel.basicConsume("fanout_queue_2",true,defaultConsumer);

        //关闭资源
        //channel.close();
        //connection.close();
    }
}
```


#### 4.3.3. 测试

启动所有消费者，然后使用生产者发送消息；在每个消费者对应的控制台可以查看到生产者发送的所有消息；到达**广播**的效果。

![1562521323525](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562521323525.png)

![1562521354709](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562521354709.png)

在执行完测试代码后，其实到RabbitMQ的管理后台找到`Exchanges`选项卡，点击 `fanout_exchange` 的交换机，可以查看到如下的绑定：

![1562521478420](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562521478420.png)



#### 4.3.4. 小结

交换机需要与队列进行绑定，绑定之后；一个消息可以被多个消费者都收到。



**发布订阅模式与work队列模式的区别**

```properties
1、work队列模式不用定义交换机，而发布/订阅模式需要定义交换机。 
2、发布/订阅模式的生产方是面向交换机发送消息，work队列模式的生产方是面向队列发送消息(底层使用默认交换机)。
3、发布/订阅模式需要设置队列和交换机的绑定，work队列模式不需要设置，实际上work队列模式会将队列绑 定到默认的交换机 。
```





### 4.4. Routing路由模式

#### 4.4.1. 模式说明

路由模式特点：

```properties
1.队列与交换机的绑定，不能是任意绑定了，而是要指定一个RoutingKey（路由key）
2.消息的发送方在 向 Exchange发送消息时，也必须指定消息的 RoutingKey。
3.Exchange不再把消息交给每一个绑定的队列，而是根据消息的Routing Key进行判断，只有队列的Routingkey与消息的 Routing key完全一致，才会接收到消息
```

![1562522054280](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562522054280.png)

图解：

```properties
P：生产者，向Exchange发送消息，发送消息时，会指定一个routing key。
X：Exchange（交换机），接收生产者的消息，然后把消息递交给 与routing key完全匹配的队列
C1：消费者，其所在队列指定了需要routing key 为 error 的消息
C2：消费者，其所在队列指定了需要routing key 为 info、error、warning 的消息
```





#### 4.4.2. 代码

在编码上与 `Publish/Subscribe发布与订阅模式` 的区别是交换机的类型为：Direct，还有队列绑定交换机的时候需要指定routing key。



(1)生产者

创建com.jwang.rabbitmq.toutekey.RouteKeyProducer消息生产者，代码如下：

```java
public class RouteKeyProducer {

    /***
     * 订阅模式-RouteKey
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明交换机
         * 参数1：交换机名称
         * 参数2：交换机类型，fanout、topic、direct、headers
         */
        channel.exchangeDeclare("direct_exchange", BuiltinExchangeType.DIRECT);

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("direct_queue_insert",true,false,false,null);
        channel.queueDeclare("direct_queue_update",true,false,false,null);

        //队列绑定交换机
        channel.queueBind("direct_queue_insert","direct_exchange","insert");
        channel.queueBind("direct_queue_update","direct_exchange","update");

        //消息-direct_queue_insert
        String message_insert = "发布订阅模式-RouteKey-Insert:欢迎来到传深圳黑马训练营程序员中心！";
        /**
         * 消息发送
         * 参数1：交换机名称，如果没有指定则使用默认Default Exchage
         * 参数2：路由key,简单模式可以传递队列名称
         * 参数3：消息其它属性
         * 参数4：消息内容
         */
        channel.basicPublish("direct_exchange","insert",null,message_insert.getBytes());

        //消息-direct_queue_update
        String message_update = "发布订阅模式-RouteKey-Update:欢迎来到传深圳黑马训练营程序员中心！";
        channel.basicPublish("direct_exchange","update",null,message_update.getBytes());

        //关闭资源
        channel.close();
        connection.close();
    }
}
```


(2)消费者RouteKey-Insert

创建`direct_queue_insert`队列的消费者com.jwang.rabbitmq.toutekey.ConsumerInsert，代码如下：

```java
public class ConsumerInsert {

    /***
     * 订阅模式消息消费者-RouteKey-insert
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("direct_queue_insert",true,false,false,null);

        //创建消费者；并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由key
                System.out.println("路由key为：" + envelope.getRoutingKey());
                //交换机
                System.out.println("交换机为：" + envelope.getExchange());
                //消息id
                System.out.println("消息id为：" + envelope.getDeliveryTag());
                //收到的消息
                System.out.println("消费者Insert-接收到的消息为：" + new String(body, "utf-8"));
            }
        };

        //消息监听
        channel.basicConsume("direct_queue_insert",true,defaultConsumer);

        //关闭资源
        //channel.close();
        //connection.close();
    }
}
```


(3)消费者-RouteKey-Update

创建`direct_queue_update`队列的消费者com.jwang.rabbitmq.toutekey.ConsumerUpdate，代码如下：

```java
public class ConsumerUpdate {

    /***
     * 订阅模式消息消费者-RouteKey-update
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("direct_queue_update",true,false,false,null);

        //创建消费者；并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由key
                System.out.println("路由key为：" + envelope.getRoutingKey());
                //交换机
                System.out.println("交换机为：" + envelope.getExchange());
                //消息id
                System.out.println("消息id为：" + envelope.getDeliveryTag());
                //收到的消息
                System.out.println("消费者Two-接收到的消息为：" + new String(body, "utf-8"));
            }
        };

        //消息监听
        channel.basicConsume("direct_queue_update",true,defaultConsumer);

        //关闭资源
        //channel.close();
        //connection.close();
    }
}
```



#### 4.4.3. 测试

启动所有消费者，然后使用生产者发送消息；在消费者对应的控制台可以查看到生产者发送对应routing key对应队列的消息；到达**按照需要接收**的效果。

![1562524433139](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562524433139.png)

![1562524462832](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562524462832.png)

在执行完测试代码后，其实到RabbitMQ的管理后台找到`Exchanges`选项卡，点击 `direct_exchange` 的交换机，可以查看到如下的绑定：

![1562524518586](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562524518586.png)



#### 4.4.4. 小结

Routing模式要求队列在绑定交换机时要指定routing key，消息会转发到符合routing key的队列。





### 4.5. Topics通配符模式

#### 4.5.1. 模式说明

![1562524697140](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562524697140.png)

`Topic`类型与`Direct`相比，都是可以根据`RoutingKey`把消息路由到不同的队列。只不过`Topic`类型`Exchange`可以让队列在绑定`Routing key` 的时候**使用通配符**！

`Routingkey` 一般都是有一个或多个单词组成，多个单词之间以”.”分割，例如： `item.insert`

 通配符规则：

`#`：匹配一个或多个词

`*`：匹配不多不少恰好1个词



举例：

`item.#`：能够匹配`item.insert.abc` 或者 `item.insert`

`item.*`：只能匹配`item.insert`

![1562524972321](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562524972321.png)

图解：

- 红色Queue：绑定的是`usa.#` ，因此凡是以 `usa.`开头的`routing key` 都会被匹配到
- 黄色Queue：绑定的是`#.news` ，因此凡是以 `.news`结尾的 `routing key` 都会被匹配



#### 4.5.2. 代码

(1)生产者

使用topic类型的Exchange，发送消息的routing key有3种： `item.insert`、`item.update`、`item.delete`：

创建com.jwang.rabbitmq.topic.TopicProducer实现消息生产，代码如下：

```java
public class TopicProducer {

    /***
     * 订阅模式-Topic
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明交换机
         * 参数1：交换机名称
         * 参数2：交换机类型，fanout、topic、direct、headers
         */
        channel.exchangeDeclare("topic_exchange", BuiltinExchangeType.TOPIC);

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("topic_queue_1",true,false,false,null);
        channel.queueDeclare("topic_queue_2",true,false,false,null);

        //队列绑定交换机，同时添加routekey过滤
        channel.queueBind("topic_queue_1","topic_exchange","item.update");
        channel.queueBind("topic_queue_1","topic_exchange","item.delete");
        channel.queueBind("topic_queue_2","topic_exchange","item.*");

        //消息-item.insert
        String message_insert = "发布订阅模式-Topic-item.insert:欢迎来到传深圳黑马训练营程序员中心！";
        /**
         * 消息发送
         * 参数1：交换机名称，如果没有指定则使用默认Default Exchage
         * 参数2：路由key,简单模式可以传递队列名称
         * 参数3：消息其它属性
         * 参数4：消息内容
         */
        channel.basicPublish("topic_exchange","item.insert",null,message_insert.getBytes());

        //消息-item.update
        String message_update = "发布订阅模式-Topic-item.update:欢迎来到传深圳黑马训练营程序员中心！";
        channel.basicPublish("topic_exchange","item.update",null,message_update.getBytes());

        //消息-item.delete
        String message_delete = "发布订阅模式-Topic-item.delete:欢迎来到传深圳黑马训练营程序员中心！";
        channel.basicPublish("topic_exchange","item.update",null,message_delete.getBytes());

        //关闭资源
        channel.close();
        connection.close();
    }
}
```


(2)消费者one

上面配置了路由绑定过滤的规则，如下图：

![1562525976688](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562525976688.png)

创建com.jwang.rabbitmq.topic.ConsumerOne实现对topic_queue_1队列数据的消费，代码如下：

```java
public class ConsumerOne {

    /***
     * 订阅模式消息消费者-Topic
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("topic_queue_1",true,false,false,null);

        //创建消费者；并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由key
                System.out.println("路由key为：" + envelope.getRoutingKey());
                //交换机
                System.out.println("交换机为：" + envelope.getExchange());
                //消息id
                System.out.println("消息id为：" + envelope.getDeliveryTag());
                //收到的消息
                System.out.println("消费者Topic-Queue-1-接收到的消息为：" + new String(body, "utf-8"));
            }
        };

        //消息监听
        channel.basicConsume("topic_queue_1",true,defaultConsumer);

        //关闭资源
        //channel.close();
        //connection.close();
    }
}
```


(3)消费者Two

![1562526138241](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562526138241.png)

接收所有类型的消息：新增商品，更新商品和删除商品。

创建com.jwang.rabbitmq.topic.ConsumerTwo实现消息消费，代码如下：

```java
public class ConsumerTwo {

    /***
     * 订阅模式消息消费者-Topic
     * @param args
     */
    public static void main(String[] args) throws IOException, TimeoutException {
        //创建链接对象
        Connection connection = ConnectionUtil.getConnection();

        //创建频道
        Channel channel = connection.createChannel();

        /**
         * 声明队列
         * 参数1：队列名称
         * 参数2：是否定义持久化队列
         * 参数3：是否独占本次连接
         * 参数4：是否在不使用的时候自动删除队列
         * 参数5：队列其它参数
         */
        channel.queueDeclare("topic_queue_2",true,false,false,null);

        //创建消费者；并设置消息处理
        DefaultConsumer defaultConsumer = new DefaultConsumer(channel){
            @Override
            public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
                //路由key
                System.out.println("路由key为：" + envelope.getRoutingKey());
                //交换机
                System.out.println("交换机为：" + envelope.getExchange());
                //消息id
                System.out.println("消息id为：" + envelope.getDeliveryTag());
                //收到的消息
                System.out.println("消费者Topic-Queue-2-接收到的消息为：" + new String(body, "utf-8"));
            }
        };

        //消息监听
        channel.basicConsume("topic_queue_2",true,defaultConsumer);

        //关闭资源
        //channel.close();
        //connection.close();
    }
}
```



#### 4.5.3. 测试

启动所有消费者，然后使用生产者发送消息；在消费者对应的控制台可以查看到生产者发送对应routing key对应队列的消息；到达**按照需要接收**的效果；并且这些routing key可以使用通配符。

![1562526243668](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562526243668.png)

![1562526271797](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562526271797.png)



在执行完测试代码后，其实到RabbitMQ的管理后台找到`Exchanges`选项卡，点击 `topic_exchange` 的交换机，可以查看到如下的绑定：

![1562526333555](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562526333555.png)



#### 4.5.4. 小结

Topic主题模式可以实现 `Publish/Subscribe发布与订阅模式` 和 ` Routing路由模式` 的功能；只是Topic在配置routing key 的时候可以使用通配符，显得更加灵活。



### 4.6. 模式总结

RabbitMQ工作模式：
**1、简单模式 HelloWorld**
一个生产者、一个消费者，不需要设置交换机（使用默认的交换机）

**2、工作队列模式 Work Queue**
一个生产者、多个消费者（竞争关系），不需要设置交换机（使用默认的交换机）

**3、发布订阅模式 Publish/subscribe**
需要设置类型为fanout的交换机，并且交换机和队列进行绑定，当发送消息到交换机后，交换机会将消息发送到绑定的队列

**4、路由模式 Routing**
需要设置类型为direct的交换机，交换机和队列进行绑定，并且指定routing key，当发送消息到交换机后，交换机会根据routing key将消息发送到对应的队列

**5、通配符模式 Topic**
需要设置类型为topic的交换机，交换机和队列进行绑定，并且指定通配符方式的routing key，当发送消息到交换机后，交换机会根据routing key将消息发送到对应的队列



## 5 Spring Boot整合RabbitMQ

### 5.1 简介

在Spring项目中，可以使用Spring-Rabbit去操作RabbitMQ
https://github.com/spring-projects/spring-amqp

尤其是在spring boot项目中只需要引入对应的amqp启动器依赖即可，方便的使用RabbitTemplate发送消息，使用注解接收消息。



*一般在开发过程中*：

**生产者工程：**

1. application.yml文件配置RabbitMQ相关信息；
2. 在生产者工程中编写配置类，用于创建交换机和队列，并进行绑定

3. 注入RabbitTemplate对象，通过RabbitTemplate对象发送消息到交换机



**消费者工程：**

1. application.yml文件配置RabbitMQ相关信息

2. 创建消息处理类，用于接收队列中的消息并进行处理



### 5.2 搭建生产者工程

#### 5.2.1 创建工程

创建生产者工程springboot-rabbitmq-producer，工程坐标如下：

```xml
<groupId>com.jwang</groupId>
<artifactId>springboot-rabbitmq-producer</artifactId>
<version>1.0-SNAPSHOT</version>
```



#### 5.2.2 添加依赖

修改pom.xml文件内容为如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <!--父工程-->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.4.RELEASE</version>
    </parent>

    <groupId>com.jwang</groupId>
    <artifactId>springboot-rabbitmq-producer</artifactId>
    <version>1.0-SNAPSHOT</version>

    <!--依赖-->
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-amqp</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
        </dependency>
    </dependencies>
</project>
```



#### 5.2.3 启动类

创建启动类com.jwang.ProducerApplication，代码如下：

```java
@SpringBootApplication
public class ProducerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ProducerApplication.class,args);
    }
}
```



#### 5.2.4 配置RabbitMQ

(1)application.yml配置文件

创建application.yml，内容如下：

```yml
spring:
  rabbitmq:
    host: localhost
    port: 5672
    virtual-host: /szjwang
    username: admin
    password: admin
```



(2)绑定交换机和队列

创建RabbitMQ队列与交换机绑定的配置类com.jwang.config.RabbitMQConfig,代码如下：

```java
@Configuration
public class RabbitMQConfig {

    /***
     * 声明交换机
     */
    @Bean(name = "itemTopicExchange")
    public Exchange topicExchange(){
        return ExchangeBuilder.topicExchange("item_topic_exchange").durable(true).build();
    }

    /***
     * 声明队列
     */
    @Bean(name = "itemQueue")
    public Queue itemQueue(){
        return QueueBuilder.durable("item_queue").build();
    }

    /***
     * 队列绑定到交换机上
     */
    @Bean
    public Binding itemQueueExchange(@Qualifier("itemQueue")Queue queue,
                                     @Qualifier("itemTopicExchange")Exchange exchange){
        return BindingBuilder.bind(queue).to(exchange).with("item.#").noargs();
    }
}
```



### 5.3. 搭建消费者工程

#### 5.3.1. 创建工程

创建消费者工程springboot-rabbitmq-consumer,工程坐标如下：

```xml
<groupId>com.jwang</groupId>
<artifactId>springboot-rabbitmq-consumer</artifactId>
<version>1.0-SNAPSHOT</version>
```



#### 5.3.2. 添加依赖

修改pom.xml文件内容为如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <!--父工程-->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.4.RELEASE</version>
    </parent>

    <groupId>com.jwang</groupId>
    <artifactId>springboot-rabbitmq-consumer</artifactId>
    <version>1.0-SNAPSHOT</version>

    <!--依赖-->
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-amqp</artifactId>
        </dependency>
    </dependencies>
</project>
```



#### 5.3.3. 启动类

创建启动类com.jwang.ConsumerApplication，代码如下：

```java
@SpringBootApplication
public class ConsumerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConsumerApplication.class);
    }
}
```



#### 5.3.4. 配置RabbitMQ

创建application.yml，内容如下：

```yml
spring:
  rabbitmq:
    host: localhost
    port: 5672
    virtual-host: /szjwang
    username: admin
    password: admin
```



#### 5.3.5. 消息监听处理类

编写消息监听器com.jwang.listener.MessageListener，代码如下：

```java
@Component
public class MessageListener {

    /**
     * 监听某个队列的消息
     * @param message 接收到的消息
     */
    @RabbitListener(queues = "item_queue")
    public void myListener1(String message){
        System.out.println("消费者接收到的消息为：" + message);
    }
}
```



### 5.4. 测试

在生产者工程springboot-rabbitmq-producer中创建测试类com.jwang.test.RabbitMQTest，发送消息：

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class RabbitMQTest {

    //用于发送MQ消息
    @Autowired
    private RabbitTemplate rabbitTemplate;

    /***
     * 消息生产测试
     */
    @Test
    public void testCreateMessage(){
        rabbitTemplate.convertAndSend("item_topic_exchange", "item.insert", "商品新增，routing key 为item.insert");
        rabbitTemplate.convertAndSend("item_topic_exchange", "item.update", "商品修改，routing key 为item.update");
        rabbitTemplate.convertAndSend("item_topic_exchange", "item.delete", "商品删除，routing key 为item.delete");
    }
}
```



先运行上述测试程序（交换机和队列才能先被声明和绑定），然后启动消费者；在消费者工程springboot-rabbitmq-consumer中控制台查看是否接收到对应消息。

![1562527789131](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562527789131.png)

另外；也可以在RabbitMQ的管理控制台中查看到交换机与队列的绑定：

![1562527845330](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/rabbitMQ/r1/assets/1562527845330.png)
  ​













