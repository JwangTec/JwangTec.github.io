---
title: Java并发编程07--AQS抽象队列同步器
categories: Java并发编程
tags: [AQS, 并发编程]
top: 10
abbrlink: 3407258096
password:
---


AQS(AbstractQueuedSynchronizer），即队列同步器。它是构建锁或者其他同步组件的基础框架（如ReentrantLock、ReentrantReadWriteLock、Semaphore等），JUC并发包的作者期望它能够成为实现大部分同步需求的基础。它是JUC并发包中的核心基础组件。
​	
​​<!--more-->

##   CLH队列锁

​	CLH队列锁即Craig, Landin, and Hagersten (CLH) locks。这是三个人的名字。 同时它也是现在PC机内部对于锁的实现机制。**Java中的AQS就是基于CLH队列锁的一种变体实现。**

​	CLH 队列锁也是一种基于**单向链表**的可扩展、公平的**自旋锁**，申请线程仅仅在本地变量上自旋，它不断轮询前驱的状态，假设发现前驱释放了锁就结束自旋。

​	1）现在有一个队列，队列中的每一个QNode对应一个请求获取锁的线程，Qnode中包含两个属性，分别为myPred（前驱节点的引用）、locked（是否需要获取锁）

![image-20200729190734068](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729190734068.png)

​	2）当多个线程要请求获取锁时，则会按照请求顺序放入队列中。同时将myPred指向前驱节点的引用。

![image-20200729191742115](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729191742115.png)

​	3）线程会对自己的myPred进行不断自旋查询，查看前驱节点是否释放锁。一旦发现前驱节点释放锁（locked属性变为false），则其会马上进行锁的获取。

![image-20200729191905034](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729191905034.png)

​	4）当后续节点获取到锁后，则将原有的前驱节点从队列中移除。

![image-20200729191953432](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729191953432.png)

##   AQS的设计模式

​	AQS本身是一个抽象类，其主要使用方式是继承，子类通过继承AQS并实现其内部定义的抽象方法。

![image-20200729194810012](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729194810012.png)



​	之前学习的ReentrantLock、ReentrantReadWriteLock其内部其实都是基于AQS实现的。

![image-20200729194504217](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729194504217.png)

![image-20200729194532179](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729194532179.png)

​	此时结合源码和之前的学习可知，他们两个并没有直接继承AQS，而是在其内部扩展了静态内部类来继承AQS。 这么做的原因，其思想就是通过区分使用者和实现者，来让使用者可以更加方便的完成对于锁的操作。

​	锁是面向使用者的，它定义了锁与使用者的交互实现方式，同时隐藏了实现细节。而AQS面向的是锁的实现者，其内部完成了锁的实现方式。从而通过区分锁和同步器让使用者和实现者能够更好的关注各自的领域。

##  AQS的实现思路

​	AQS的设计模式使用的是**模版设计模式**。通过源码可以看到，在AQS中其并没有对方法进行具体实现，这些方法都是需要开发者自行来实现的。

![image-20200729214640021](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729214640021.png)

![image-20200729214528495](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729214528495.png)

​	模版设计模式在开发中涉及的非常多，简单来说就是：**在一个方法中定义一个流程的骨架，对于流程的具体实现让其在子类中完成**。以Spring为例，其内部就大量应用到了模版设计模式，如JDBCTemplate、RedisTemplate、RabbitTemplate等等。

###  模版模式实现

```java
//自定义模版抽象类
public abstract class AbstractCake {

    protected abstract void shape();
    protected abstract void apply();
    protected abstract void brake();

    /*模板方法*/
    public final void run(){
        this.shape();
        this.apply();
        this.brake();
    }
    

    protected boolean shouldApply(){
        return true;
    }
}
```

```java
//自定义抽象实现类
public class CheeseCake  extends AbstractCake {

    @Override
    protected void shape() {
        System.out.println("芝士蛋糕造型");
    }

    @Override
    protected void apply() {
        System.out.println("芝士蛋糕涂抹");
    }

    @Override
    protected void brake() {
        System.out.println("芝士蛋糕烘焙");
    }
}
```

```java
public class CreamCake extends AbstractCake {
    @Override
    protected void shape() {
        System.out.println("奶油蛋糕造型");
    }

    @Override
    protected void apply() {
        System.out.println("奶油蛋糕涂抹");
    }

    @Override
    protected void brake() {
        System.out.println("奶油蛋糕烘焙");
    }
}
```

```java
//执行类
public class MakeCake {
    public static void main(String[] args) {
        AbstractCake cake1 = new CheeseCake();
        AbstractCake cake2 = new CreamCake();
        cake1.run();
        cake2.run();
    }
}
```

​	根据上述实现方式可以发现，只需自定义一个抽象类，将执行流程的骨架定义好。接着可以通过实现类对其进行不同的实现。这种实现思想就是模版设计模式。

###   AQS中的模版模式

​	根据上述内容的讲解，其实在AQS中大量使用到了模版设计模式。查看其源码如：**acquire(int arg)**、**release(int arg)**、**acquireShared(int arg)**等等都是模版方法。

​	其内部的模版方法大致可以分为三类：

- xxSharedxx：共享式获取与释放，如读锁。

- acquire：独占式获取与释放，如写锁。
- 查询同步队列中等待线程情况。

###  AQS的同步状态

​	AQS对于锁的操作是通过同步状态切换来完成的，其有一个变量state，用于表示线程获取锁的状态。当state>0时表示当前已有线程获取到了资源，当state = 0时表示释放了资源。

![image-20200729222337298](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729222337298.png)

​	在多线程下，一定会有多个线程来同时修改state变量，所以在AQS中也提供了一些方法能够安全的对state值进行修改。分别为：

![image-20200729222606006](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729222606006.png)

![image-20200729222623253](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729222623253.png)

![image-20200729222655772](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729222655772.png)

##   AQS实现原理

###  Node节点

​	之前提到过AQS是基于CLH队列锁的思想来实现的，其内部不同于CLH单向链表，而是使用的是**双向链表**。那么对于一个队列来说，其内部一定会通过一个节点来保存线程信息，如：前驱节点、后继节点、当前线程节点、线程状态这些信息。

​	根据源码可知，AQS内部定义一个Node对象用于存储这些信息。

![image-20200729231620835](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729231620835.png)

​	**两种线程等待模式：**

- SHARED：表示线程以**共享模式等待锁**，如读锁。
- EXCLUSIVE：表示线程以**独占模式等待锁**，如写锁。

   **五种线程状态：**

- 初始Node对象时，默认值为0。

- CANCELLED：表现线程获取锁的请求已经取消，值为1。

- SINNAL：表现线程已经准备就绪，等待锁空闲给我，值为-1。

- CONDITION：表示线程等待某一个条件被满足，值为-2。
- PROPAGETE：当线程处于SHARED模式时，该状态才会生效，用于表示线程可以被共享传播，值为-3。

   **五个成员变量：**

- waitStatus：表示线程在队列中的状态，值对应上述五种线程状态。
- prev：表示当前线程的前驱节点。
- next：表示当前线程的后继节点。
- thread：表示当前线程。
- nextWaiter：表示等待condition条件的节点。

`同时在AQS中还存在两个成员变量，head和tail，分别代表队首节点和队尾节点`。

![image-20200729233443780](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729233443780.png)



###   节点在同步队列的操作

​	在多线程并发争抢同步状态（锁）时，按照队列的FIFO原则，AQS会将获取锁失败的线程包装为一个Node放入队列尾部中。

![image-20200730094716741](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200730094716741.png)

​	对于加入队列的过程需要保证线程安全，**AQS提供了一个基于CAS设置尾节点的方法**`compareAndSetTail(Node expect,Node update)`。其需要传递当前期望的尾节点和当前节点，当返回true，当前节点才与队列中之前的尾节点建立连接。

![image-20200730102939636](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200730102939636.png)

​	此时可以发现头结点一定是获取锁成功的节点，头节点在释放锁时，会唤醒其后继节点。当后继节点获取锁成功后，则头节点的指针会指向该后继节点作为当前队列的头节点，接着将原先的头结点从队列中移除。

​	对于该流程来说，只有一个线程能够获取到同步状态，因此不需要CAS进行保证。只需要重新移动头部指针并断开原有引用连接即可。

​	![image-20200730103436360](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200730103436360.png)
