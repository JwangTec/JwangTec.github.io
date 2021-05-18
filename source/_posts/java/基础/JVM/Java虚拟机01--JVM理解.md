---
title: Java虚拟机01--JVM理解
categories: JVM
tags:
  - 深入理解JVM
top: 10
abbrlink: 3952652746
date: 2019-09-01 18:18:19
password:
---



<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/JVM.png" width="1000" height="200" align="middle" />



​	对于一个线上系统来说，经常性的会发生如：

- 系统突然卡死，无法访问，甚至出现OOM。
- 服务器的CPU负载突然升高。
- 直接使用默认JVM参数上线，最终发现系统宕机。
- 想要调整JVM参数，但是无从下手。。。。。

对于这些问题的出现，都是因为对JVM了解的不够多而导致的。本章节会主要讲解JVM相关内容。

<!--more-->

##   概述

​	JVM全称Java Virtual Machine，即Java虚拟机。它本身是一个虚拟计算机。Java虚拟机基于二进制字节码执行，由一套字节码指令集、一组寄存器、一个栈、一个垃圾回收堆、一个方法区等组成。JVM屏蔽了与操作系统平台相关的信息，从而能够让Java程序只需要生成能够在JVM上运行的字节码文件。通过该机制实现的跨平台性。因此这也是为什么说Java能够做到“一处编译、处处运行”的原因。

## JVM生命周期

​	JVM的生命周期分为三个阶段，分别为：启动、运行、死亡。

- **启动：**

  当启动一个Java程序时，JVM的实例就已经产生。对于拥有main函数的类就是JVM实例运行的起点。

- **运行：**

  main()方法是一个程序的初始起点，任何线程均可由在此处启动。在JVM内部有两种线程类型，分别为：用户线程和守护线程。JVM通常使用的是守护线程，而main()使用的则是用户线程。守护线程会随着用户线程的结束而结束。

- **死亡：**

  当程序中的用户线程都中止，JVM才会退出。

##  内存结构

​	JVM内存结构是JVM学习中非常重要的一部分，并且在JDK7和JDK8中也进行了一些改动。

​	内存是非常重要的系统资源，是硬盘和 CPU 的中间仓库及桥梁，承载着操作系统和应用程序的实时运行。JVM 内存结构规定了 Java 在运行过程中内存申请、分配、管理的策略，保证了 JVM 的高效稳定运行。

![image-20201019231114563](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20201019231114563.png)

![image-20201019231126133](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20201019231126133.png)

**虚拟机栈：**

​	线程私有的，虚拟机栈对应方法调用到执行完成的整个过程。保存执行方法时的**局部变量、动态连接信息、方法返回地址信息**等等。方法开始执行的时候会进栈，方法执行完会出栈【相当于清空了数据】。不需要进行GC。

**本地方法栈：**

​	与虚拟机栈类似。本地方法栈是为虚拟机**执行本地方法时提供服务的**。不需要进行GC。本地方法一般是由其他语言编写。

**程序计数器：**

​	线程私有的。内部保存的字节码的行号。用于记录正在执行的字节码指令的地址。

![image-20200801234325253](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200801234325253.png)

​	java虚拟机对于多线程是通过线程轮流切换并且分配线程执行时间。在任何的一个时间点上，一个处理器只会处理执行一个线程，如果当前被执行的这个线程它所分配的执行时间用完了【挂起】。处理器会切换到另外的一个线程上来进行执行。并且这个线程的执行时间用完了，接着处理器就会又来执行被挂起的这个线程。

​	那么现在有一个问题就是，当前处理器如何能够知道，对于这个被挂起的线程，它上一次执行到了哪里？那么这时就需要从程序计数器中来回去到当前的这个线程他上一次执行的行号，然后接着继续向下执行。

​	程序计数器是JVM规范中唯一一个没有规定出现OOM的区域，所以这个空间也不会进行GC。

**本地内存：**

​	它又叫做**堆外内存**，线程共享的区域，本地内存这块区域是不会受到JVM的控制的，也就是说对于这块区域是不会发生GC的。因此对于整个java的执行效率是提升非常大的。

**堆：**

​	线程共享的区域。主要用来保存**对象实例，数组**等，当堆中没有内存空间可分配给实例，也无法再扩展时，则抛出OutOfMemoryError异常。

​	在JAVA7中堆内会存在**年轻代、老年代和方法区(永久代)**。

​	1）Young区被划分为三部分，Eden区和两个大小严格相同的Survivor区，其中，Survivor区间中，某一时刻只有其中一个是被使用的，另外一个留做垃圾收集时复制对象用。在Eden区变满的时候， GC就会将存活的对象移到空闲的Survivor区间中，根据JVM的策略，在经过几次垃圾收集后，任然存活于Survivor的对象将被移动到Tenured区间。

​	2）Tenured区主要保存生命周期长的对象，一般是一些老的对象，当一些对象在Young复制转移一定的次数以后，对象就会被转移到Tenured区。

​	3）Perm代主要保存**保存的类信息、静态变量、常量、编译后的代码**，在java7中堆上方法区会受到GC的管理的。方法区【永久代】是有一个大小的限制的。如果大量的动态生成类，就会放入到方法区【永久代】，很容易造成OOM。

​	为了避免方法区出现OOM，所以在java8中将堆上的方法区【永久代】给移动到了本地内存上，重新开辟了一块空间，叫做**元空间**。那么现在就可以避免掉OOM的出现了。

##  元空间(MetaSpace)介绍

​	在 HotSpot JVM 中，永久代（ ≈ 方法区）中用于存放类和方法的元数据以及常量池，比如Class 和 Method。每当一个类初次被加载的时候，它的元数据都会放到永久代中。

​	永久代是有大小限制的，因此如果加载的类太多，很有可能导致永久代内存溢出，即OutOfMemoryError，为此不得不对虚拟机做调优。

​	那么，Java 8 中 PermGen 为什么被移出 HotSpot JVM 了？

官网给出了解释：http://openjdk.java.net/jeps/122

~~~
This is part of the JRockit and Hotspot convergence effort. JRockit customers do not need to configure the permanent generation (since JRockit does not have a permanent generation) and are accustomed to not configuring the permanent generation.

移除永久代是为融合HotSpot JVM与 JRockit VM而做出的努力，因为JRockit没有永久代，不需要配置永久代。
~~~

1）由于 PermGen 内存经常会溢出，引发OutOfMemoryError，因此 JVM 的开发者希望这一块内存可以更灵活地被管理，不要再经常出现这样的 OOM。

2）移除 PermGen 可以促进 HotSpot JVM 与 JRockit VM 的融合，因为 JRockit 没有永久代。

​	准确来说，Perm 区中的字符串常量池被移到了堆内存中是在 Java7 之后，Java 8 时，PermGen 被元空间代替，其他内容比如**类元信息、字段、静态属性、方法、常量**等都移动到元空间区。比如 java/lang/Object 类元信息、静态属性 System.out、整型常量等。

​	元空间的本质和永久代类似，都是对 JVM 规范中方法区的实现。不过元空间与永久代之间最大的区别在于：元空间并不在虚拟机中，而是使用本地内存。因此，默认情况下，元空间的大小仅受本地内存限制。
​	
​
​





