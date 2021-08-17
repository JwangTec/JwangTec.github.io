---
title: 消息中间件03-RocketMQ
categories: 消息中间件
tags:
  - 消息队列
  - RocketMQ
top: 13
abbrlink: 986289229
date: 2021-07-13 18:18:19
password:
---


# RocketMQ简介

## 为什么使用

 系统的耦合性越高，容错性就越低。以电商为例，用户创建完订单后，如果耦合调用库存系统、物流系统、支付系统，任何一个系统出现故障或者因为升级等原因暂时不可用，都回造成下单的异常，影响用户的体验。
 
 <!--more-->

- 流量削峰

应用系统如果遇到系统请求流量瞬间猛增，有可能会将系统压垮。如果有消息队列，遇到此情况，可以将大量请求存储起来，将一瞬间的峰值请求分散到一段时间进行处理，这样可以大大提高系统的稳定性

- 异步

用户调用一个接口的时候，可能该接口调用了别的方法。例如：用户注册的时候，后台可能需要调用：查询数据库，插入数据库，发送邮件等等…
但是用户可能并不需要后台将所有的任务执行完毕，那么此时在初入数据口后面加入MQ，用户就能很快得到注册成功的响应而去做一些别的事情。mq的机制又能保证最终的一致性，所以使用起来很安全很稳定。



* 概述

RocketMQ作为一款纯java、分布式、队列模型的开源消息中间件，支持事务消息、顺序消息、批量消息、定时消息、消息回溯等。

Apache Alibaba RocketMQ 是一个消息中间件。消息中间件中有两个角色：消息生产者和消息消费者。RocketMQ 里同样有这两个概念，消息生产者负责创建消息并发送到 RocketMQ 服务器，RocketMQ 服务器会将消息持久化到磁盘，消息消费者从 RocketMQ 服务器拉取消息并提交给应用消费。

* 应用场景

> 订单操作：打车 司机+乘客
> 
> 乘客下单（消息的提供者），司机接单（消息的消费者）--点对点
> 
> 公众号：发布订阅模式
> 
> 公众号发布一个消息，订阅该公众号的都可以收到消息
> 
> 更新通知：广播模式


* 消息队列的作用

削峰填谷： 主要解决瞬时写压力大于应用服务能力导致消息丢失、系统奔溃等问题

异步处理(在注册的同时,异步去处理短信的发送与邮件的发送)

系统解耦： 解决不同重要程度、不同能力级别系统之间依赖导致一死全死

提升性能： 当存在一对多调用时，可以发一条消息给消息系统，让消息系统通知相关系统

蓄流压测： 线上有些链路不好压测，可以通过堆积一定量消息再放开来压测


  ​
## RocketMQ特点

* RocketMQ是一款分布式、队列模型的消息中间件，支持严格的消息顺序，支持topic与Queue两种模式，有亿级消息堆积能力，同时支持pull和push方式的消费消息

## 优势

目前主流的 MQ 主要是 RocketMQ、kafka、RabbitMQ，其主要优势有：

* 支持事务型消息（消息发送和 DB 操作保持两方的最终一致性，RabbitMQ 和 Kafka 不支持）
* 支持结合 RocketMQ 的多个系统之间数据最终一致性（多方事务，二方事务是前提）
* 支持 18 个级别的延迟消息（RabbitMQ 和 Kafka 不支持）
* 支持指定次数和时间间隔的失败消息重发（Kafka 不支持，RabbitMQ 需要手动确认）
* 支持 Consumer 端 Tag 过滤，减少不必要的网络传输（RabbitMQ 和 Kafka 不支持）
* 支持重复消费（RabbitMQ 不支持，Kafka 支持）

## 性能

* 吞吐量
* 实效性，多少时间内能处理的有效的请求数
* 消息的可靠性

## 简单使用

[版本说明](https://github.com/alibaba/spring-cloud-alibaba/wiki/%E7%89%88%E6%9C%AC%E8%AF%B4%E6%98%8E)


[RocketMQ安装包下载](https://rocketmq.apache.org/tags/#release-notes)

* 安装RocketMQ

```java

进入到xshell中
cd /home
ls 查看rocket压缩包
使用 unzip rocketmq-all-4.7.1-bin-release.zip 解压

解压文件的时候说没有zip的命令
安装命令： yum install zip    #提示输入时，请输入y；
安装命令：yum install unzip #提示输入时，请输入y；

cd rocketmq-all-4.7.1-bin-release
cd bin/
ls


```

* 启动NameServer

```java
nohup ./bin/mqnamesrv &
查看进程
netstat -ntlp 看到有9876端口就说明启动成功了
```

* 检测是否启动

```java
netstat -an | grep 9876
```

* 启动docker,需要编辑配置文件，修改JVM内存位置，默认的内存可能过大，超过JVM内存大小

```java
cd bin/
vi runserver.sh

xmn  新生代的内存大小
xmx  堆区最大的内存大小
xms  堆区的初始值大小

---------
cd bin/
vi runbroker,sh //在JAVA_OPT中做相应处理

---------启动broker
nohup ./mqbroker -n localhost:9876 &
```

* 测试RocketMQ

```java
----消息发送
cd bin/
export NAMESRV_ADDR=localhost:9876
./tools.sh org.apache.rocketmq.example.quickstart.Producer

---消息接收
cd bin/
export NAMESRV_ADDR=localhost:9876
./tools.sh org.apache.rocketmq.example.quickstart.Consumer

---关闭RocketMQ
./bin/mqshutdown broker
./bin/mqshutdown namesrv

```

## Java实现步骤

### 实现消息发送

* 创建maven项目提供消息生产者微服务

```java
---导入pom依赖
<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-spring-boot-starter</artifactId>
    <version>2.1.0</version>
</dependency>

---生产消息
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;
public class MsgProvider {
    public static void main(String[] args) throws Exception {
        //创建消息生产者
        DefaultMQProducer producer = new DefaultMQProducer("myproducer-group");
        //设置NameServer
        producer.setNamesrvAddr("192.168.106.130:9876");
        //启动生产者
        producer.start();
        //构建消息对象                                     主题       标签  内容
        Message message = new Message("myTopic","myTag",("Test MQ").getBytes());
        //发送消息
        SendResult result = producer.send(message, 6000);
        System.out.println(result);
        //关闭生产者
        producer.shutdown();
    }
}
---启动
```

### 实现消息消费

* 创建maven项目提供消息消费者微服务

```java
-----pom.xml

        <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-spring-boot-starter</artifactId>
            <version>2.1.0</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>
----
@Slf4j
public class MsgConsumer {
    public static void main(String[] args) throws MQClientException {
        //创建消息消费者
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("myconsumer-group");
        //设置NameServer
        consumer.setNamesrvAddr("192.168.106.130:9876");
        //指定订阅的主题和标签
        consumer.subscribe("myTopic","*");
        //回调函数  创建了一个消息监听器，一直监听消息队列中的消息
        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
                log.info("Message=>{}",new String(list.get(0).getBody()));
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });
        //启动消费者
        consumer.start();
    }
}
```

## springboot整合rocketMQ

### provider

* 创建springboot项目整合模块boot-mq-provider生产者

```java
 <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-spring-boot-starter</artifactId>
            <version>2.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-client</artifactId>
            <version>4.7.0</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
```

* yml配置

```java
rocketmq:
  name-server: 192.168.248.129:9876
  producer:
    group: myprovider
server.port=8080

```

* 创建订单类

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Order {
    private Integer id;
    private String buyerName;
    private String buyerTel;
    private String address;
    private Date createDate;
}
```

* controller

```java
@RestController
public class ProviderController {

    @Autowired
    private RocketMQTemplate rocketMQTemplate;

    @GetMapping("/sendMsg")
    public Order sendMsg(){
        Order order = new Order(
                1,
                "阿松大",
                "123123",
                "软件园",
                new Date()
        );
        this.rocketMQTemplate.convertAndSend("orderTopic",order);
        return order;
    }

}
```

### consumer

* 创建springboot项目模块boot-mq-consumer消费者

```java
 <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-spring-boot-starter</artifactId>
            <version>2.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-client</artifactId>
            <version>4.7.0</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

```

* 配置yml

```java
rocketmq:
  name-server: 192.168.248.129:9876
server.port=8081

```

* 创建service，把provider订单实体类放到consumer

```java
@Slf4j
@Service                          //消息监听 consumerGroup ：消费组名称，topic=主题
@RocketMQMessageListener(consumerGroup = "myConsumer",topic = "orderTopic")
public class ConsumerService implements RocketMQListener<Order> {
    @Override
    public void onMessage(Order order) {
        log.info("新订单{},发短信",order);
        //如果能拿到新的订单，那就根据订单id生成一个减库存的操作，无非就是操作数据库

        System.out.println("需要执行减库存的操作.....");
    }
}
}
```











