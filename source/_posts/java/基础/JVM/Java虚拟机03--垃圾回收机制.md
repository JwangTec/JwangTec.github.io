---
title: Java虚拟机03--垃圾回收机制
categories: JVM
tags:
  - 垃圾定位
  - 垃圾回收算法
  - 垃圾收集器
  - 分析工具GC easy
top: 10
abbrlink: 1150816938
date: 2019-09-01 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/JVM.png)


##  Java语言的垃圾回收

<!--more-->

​	为了让程序员更专注于代码的实现，而不用过多的考虑内存释放的问题，所以，在Java语言中，有了自动的垃圾回收机制，也就是我们熟悉的GC。

​	有了垃圾回收机制后，程序员只需要关心内存的申请即可，内存的释放由系统自动识别完成。

​	在进行垃圾回收时，不同的对象引用类型，GC会采用不同的回收时机，对于对象的引用类型可查看第三天的ThreadLocal部分。

​	换句话说，自动的垃圾回收的算法就会变得非常重要了，如果因为算法的不合理，导致内存资源一直没有释放，同样也可能会导致内存溢出的。

​	当然，除了Java语言，C#、Python等语言也都有自动的垃圾回收机制。

##  什么是垃圾&垃圾定位

​	简单一句就是：**如果一个或多个对象没有任何的引用指向它了，那么这个对象现在就是垃圾。**

###   引用计数法

​	一个对象被引用了一次，在当前的对象头上递增一次引用次数，如果这个对象的引用次数为0，代表这个对象可回收

```java
String demo = new String("123");
```

![image-20200802001502483](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802001502483.png)

```java
String demo = null;
```

![image-20200802001515438](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802001515438.png)

当对象间出现了循环引用的话，则引用计数法就会失效

![image-20200802001533126](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802001533126.png)

虽然a和b都为null，但是由于a和b存在循环引用，这样a和b永远都不会被回收。

优点：

- 实时性较高，无需等到内存不够的时候，才开始回收，运行时根据对象的计数器是否为0，就可以直接回收。
- 在垃圾回收过程中，应用无需挂起。如果申请内存时，内存不足，则立刻报OOM错误。
- 区域性，更新对象的计数器时，只是影响到该对象，不会扫描全部对象。

缺点：

- 每次对象被引用时，都需要去更新计数器，有一点时间开销。 
- **浪费CPU资源**，即使内存够用，仍然在运行时进行计数器的统计。
- **无法解决循环引用问题，会引发内存泄露**。（最大的缺点） 

###   可达性分析算法

​	现在的虚拟机采用的都是通过可达性分析算法来确定哪些内容是垃圾。

​	会存在一个根节点【GC Roots】，引出它下面指向的下一个节点，再以下一个节点节点开始找出它下面的节点，依次往下类推。直到所有的节点全部遍历完毕。

![image-20200802121746255](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802121746255.png)

​	M,N这两个节点是可回收的，但是**并不会马上的被回收！！** 对象中存在一个方法【finalize】。当对象被标记为可回收后，当发生GC时，首先**会判断这个对象是否执行了finalize方法**，如果这个方法还没有被执行的话，那么就会先来执行这个方法，接着在这个方法执行中，可以设置当前这个对象与GC ROOTS产生关联，那么这个方法执行完成之后，GC会再次判断对象是否可达，如果仍然不可达，则会进行回收，如果可达了，则不会进行回收。

​	finalize方法对于每一个对象来说，只会执行一次。如果第一次执行这个方法的时候，设置了当前对象与RC ROOTS关联，那么这一次不会进行回收。 那么等到这个对象第二次被标记为可回收时，那么该对象的finalize方法就不会再次执行了。

**GC ROOTS：**

​	**虚拟机栈中引用的对象**

​	**本地方法栈中引用的对象**

​	**方法区中类静态属性引用的对象**

​	**方法区中常量引用对象**

##  垃圾回收算法

###  标记清除算法

标记清除算法，是将垃圾回收分为2个阶段，分别是**标记和清除**。

1.根据可达性分析算法得出的垃圾进行标记

2.对这些标记为可回收的内容进行垃圾回收

![image-20200802123228945](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802123228945.png)

![image-20200802123241536](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802123241536.png)

可以看到，标记清除算法解决了引用计数算法中的循环引用的问题，没有从root节点引用的对象都会被回收。

同样，标记清除算法也是有缺点的：

- 效率较低，**标记和清除两个动作都需要遍历所有的对象**，并且在GC时，**需要停止应用程序**，对于交互性要求比较高的应用而言这个体验是非常差的。
- （**重要**）通过标记清除算法清理出来的内存，碎片化较为严重，因为被回收的对象可能存在于内存的各个角落，所以清理出来的内存是不连贯的。

###  复制算法

​	复制算法的核心就是，**将原有的内存空间一分为二，每次只用其中的一块**，在垃圾回收时，将正在使用的对象复制到另一个内存空间中，然后将该内存空间清空，交换两个内存的角色，完成垃圾的回收。

​	如果内存中的垃圾对象较多，需要复制的对象就较少，这种情况下适合使用该方式并且效率比较高，反之，则不适合。 

![image-20200802123304797](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802123304797.png)

![image-20200802123315514](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802123315514.png)

1）将内存区域分成两部分，每次操作其中一个。

2）当进行垃圾回收时，将正在使用的内存区域中的存活对象移动到未使用的内存区域。当移动完对这部分内存区域一次性清除。

3）周而复始。

优点：

- 在垃圾对象多的情况下，效率较高
- 清理后，内存无碎片

缺点：

- 分配的2块内存空间，在同一个时刻，只能使用一半，内存使用率较低

###   标记整理算法

​	标记压缩算法是在标记清除算法的基础之上，做了优化改进的算法。和标记清除算法一样，也是从根节点开始，对对象的引用进行标记，在清理阶段，并不是简单的直接清理可回收对象，而是将存活对象都向内存另一端移动，然后清理边界以外的垃圾，从而解决了碎片化的问题。

![image-20200802124108240](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802124108240.png)

![image-20200802124119931](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802124119931.png)

1）标记垃圾。

2）需要清除向右边走，不需要清除的向左边走。

3）清除边界以外的垃圾。

优缺点同标记清除算法，解决了标记清除算法的碎片化的问题，同时，标记压缩算法多了一步，对象移动内存位置的步骤，其效率也有有一定的影响。

###   分代收集算法

在java8时，堆被分为了两份：**新生代和老年代【1：2】**，在java7时，还存在一个永久代。

![image-20200825231704058](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200825231704058.png)

对于新生代，内部又被分为了三个区域。Eden区，S0区，S1区【8：1：1】

当对新生代产生GC：MinorGC【young GC】

当对老年代产生GC：FullGC【OldGC】

####   工作机制

1）当创建一个对象的时候，那么这个对象会被分配在新生代的Eden区。当Eden区要满了时候，触发YoungGC。

2）当进行YoungGC后，此时在Eden区存活的对象被移动到S0区，并且**当前对象的年龄会加1**，清空Eden区。

3）当再一次触发YoungGC的时候，会把Eden区中存活下来的对象和S0中的对象，移动到S1区中，这些对象的年龄会加1，清空Eden区和S0区。

4）当再一次触发YoungGC的时候，会把Eden区中存活下来的对象和S1中的对象，移动到S0区中，这些对象的年龄会加1，清空Eden区和S1区。

####   对象何时晋升到老年代

1）对象的年龄达到了某一个限定的值（**默认15岁**，CMS默认6岁  ），那么这个对象就会进入到老年代中。

2）大对象。

3）如果在Survivor区中相同年龄的对象的所有大小之和超过Survivor空间的一半，年龄大于或等于该年龄的对象就可以直接进入老年代。

当老年代满了之后，**触发FullGC**。**FullGC同时回收新生代和老年代**，当前只会存在一个FullGC的线程进行执行，其他的线程全部会被挂起。

##   七种垃圾收集器

​	前面我们讲了垃圾回收的算法，还需要有具体的实现，在jvm中，实现了多种垃圾收集器，包括：串行垃圾收集器、并行垃圾收集器、CMS（并发）垃圾收集器、G1垃圾收集器，接下来，我们一个个的了解学习。

![image-20200802221150600](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802221150600.png)

###   Serial收集器

​	**串行垃圾收集器**，作用于**新生代**。是指使用单线程进行垃圾回收，**采用复制算法**。垃圾回收时，只有一个线程在工作，并且java应用中的所有线程都要暂停，等待垃圾回收的完成。这种现象称之为STW（Stop-The-World）。**其应用在年轻代**

​	对于交互性较强的应用而言，这种垃圾收集器是不能够接受的。因此一般在Javaweb应用中是不会采用该收集器的。

![image-20200802214415076](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802214415076.png)

###   ParallelNew收集器

​	并行垃圾收集器在串行垃圾收集器的基础之上做了改进，**采用复制算法**。将单线程改为了多线程进行垃圾回收，这样可以缩短垃圾回收的时间。（这里是指，并行能力较强的机器）。但是对于其他的行为（收集算法、stop the world、对象分配规则、回收策略等）同Serial收集器一样。其也是应用在年轻代。**JDK8默认使用此垃圾回收器**

​	当然了，并行垃圾收集器在收集的过程中也会暂停应用程序，这个和串行垃圾回收器是一样的，只是并行执行，速度更快些，暂停的时间更短一些。

![image-20200802215543670](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802215543670.png)

###   Parallel Scavenge收集器

​	其是一个应用于**新生代**的**并行**垃圾回收器，**采用复制算法**。它的目标是达到一个可控的吞吐量（吞吐量=运行用户代码时间 /（运行用户代码时间+垃圾收集时间））即虚拟机总共运行了100分钟，其中垃圾收集花掉1分钟，吞吐量就是99%。这样可以高效率的利用CPU时间，尽快完成程序的运算任务，适合在后台运算而不需要太多交互的任务。

- 停顿时间越短对于需要与用户交互的程序来说越好，良好的响应速度能提升用户的体验。
-  高吞吐量可以最高效率地利用CPU时间，尽快地完成程序的运算任务，主要适合在后台运算而不太需要太多交互的任务。

###   Serial Old收集器

​	其是运行于**老年代的单线程**Serial收集器，**采用标记-整理算法**，主要是给Client模式下的虚拟机使用。

###   Parallel Old收集器

​	其是一个应用于老年代的并行垃圾回收器，**采用标记-整理算法**。在注重吞吐量及CPU资源敏感的场合，都可以优先考虑Parallel Scavenge+Parallel Old收集器。

###   CMS垃圾收集器

####  概述

​	CMS全称 Concurrent Mark Sweep，是一款**并发**的、使用**标记-清除**算法的垃圾回收器，该回收器是**针对老年代垃圾回收的**，是一款以获取最短回收停顿时间为目标的收集器，停顿时间短，用户体验就好。**其最大特点是在进行垃圾回收时，应用仍然能正常运行。** 

CMS垃圾回收器的执行过程如下：

 ![image-20200802222734870](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200802222734870.png)

**1)初始标记(Initial Mark)**：仅仅标记GC Roots能直接关联到的对象，速度快，但是需要“Stop The World”

**2)并发标记(Concurrent Mark)**：就是进行追踪引用链的过程，可以和用户线程并发执行。

**3)重新标记(Remark)**：修正并发标记阶段因用户线程继续运行而导致标记发生变化的那部分对象的标记记录，比初始标记时间长但远比并发标记时间短，需要“Stop The World”

**4)并发清除(Concurrent Sweep)**：清除标记为可以回收对象，可以和用户线程并发执行

​	由于整个过程耗时最长的并发标记和并发清除都可以和用户线程一起工作，所以总体上来看，CMS收集器的内存回收过程和用户线程是并发执行的。

####   CMS收集器缺点

​	对于CMS收集器的有三个：

- 对CPU资源敏感：

​	并发收集虽然不会暂停用户线程，但因为占用CPU资源，仍会导致系统吞吐量降低、响应变慢。

​	CMS的默认收集线程数量是=(CPU数量+3)/4。当CPU数量多于4个，收集线程占用的CPU资源多于25%，对用户程序影响可能较大；不足4个时，影响更大，可能无法接受。

- 无法处理浮动垃圾：

​	所谓浮动垃圾即在并发清除时，用户线程新产生的垃圾叫浮动垃圾。并发清除时需要预留一定的内存空间，不能像其他收集器在老年代几乎填满再进行收集。如果CMS预留内存空间无法满足程序需要，就会出现一次"Concurrent Mode Failure"失败。这时JVM启用后备预案：临时启用Serail Old收集器，而导致另一次Full GC的产生。

- 垃圾回收算法导致内存碎片：

​	因为CMS收集器采用标记-清除算法，因此会导致垃圾从内存中被清除后，会出现内存空间碎片化。这样会导致分配大内存对象时，无法找到足够的连续内存，从而需要提前触发另一次Full GC动作。

###   G1垃圾收集器

####   概述

​	对于垃圾回收器来说，前面的三种要么一次性回收年轻代，要么一次性回收老年代。而且现代服务器的堆空间已经可以很大了。为了更加优化GC操作，所以出现了G1。

​	它是一款**同时应用于新生代和老年代、采用标记-整理算法、软实时、低延迟、可设定目标(最大STW停顿时间)**的垃圾回收器，用于代替CMS，适用于较大的堆(>4~6G)，**在JDK9之后默认使用G1**。

G1的设计原则就是简化JVM性能调优，开发人员只需要简单的三步即可完成调优：

1. 第一步，开启G1垃圾收集器
2. 第二步，设置堆的最大内存
3. 第三步，设置最大的停顿时间（stw）

####   G1的内存布局

​	G1垃圾收集器相对比其他收集器而言，最大的区别在于它**取消了年轻代、老年代的物理划分**。

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/20161222153407_691.png)

​	取而代之的是将堆划分为**若干个区域（Region）**，这些区域中包含了有**逻辑上的年轻代、老年代区域**。这样做的好处就是，我们再也不用单独的空间对每个代进行设置了，不用担心每个代内存是否足够。

​	此时可以看到，现在出现了一个**新的区域Humongous**，它本身属于老年代区。当现在出现了一个巨大的对象，超出了分区容量的一半，则这个对象会进入到该区域。如果一个H区装不下一个巨型对象，那么G1会寻找连续的H分区来存储。为了能找到连续的H区 ，有时候不得不启动Full GC。

​	同时G1会估计每个Region中的垃圾比例，优先回收垃圾较多的区域。

 ![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/20161222153407_471.png)

​	在G1划分的区域中，年轻代的垃圾收集依然采用**暂停所有应用线程的方式**，将存活对象拷贝到老年代或者Survivor空间，G1收集器通过将**对象从一个区域复制到另外一个区域，完成了清理工作**。

​	这就意味着，在正常的处理过程中，G1完成了堆的压缩（至少是部分堆的压缩），这样也就不会有cms内存碎片问题的存在了。

####   垃圾回收模式

其提供了三种模式垃圾回收模式： **young GC、Mixed GC、Full GC**。在不同的条件下被触发。

#####   Young GC

​	发生在年轻代的GC算法，一般对象（除了巨型对象）都是在eden region中分配内存，当所有eden region被耗尽无法申请内存时，就会触发一次young gc，这种触发机制和之前的young gc差不多，执行完一次young gc，活跃对象会被拷贝到survivor region或者晋升到old region中，空闲的region会被放入空闲列表中，等待下次被使用。

#####   Mixed GC

​	当越来越多的对象晋升到老年代old region时，为了避免堆内存被耗尽，虚拟机会触发一个混合的垃圾收集器，即**mixed gc**，该算法并不是一个old gc，除了回收整个young region，还会回收一部分的old region，这里需要注意：**是一部分老年代，而不是全部老年代**，可以选择哪些old region进行收集，从而可以对垃圾回收的耗时时间进行控制。

​	在CMS中，当老年代的使用率达到80%就会触发一次cms gc。在G1中，mixed gc也可以通过`-XX:InitiatingHeapOccupancyPercent`设置阈值，**默认为45%**。当老年代大小占整个堆大小百分比达到该阈值，则触发mixed gc。

其执行过程和cms类似：

1. initial mark: 初始标记过程，整个过程STW，标记了从GC Root可达的对象。
2. concurrent marking: 并发标记过程，整个过程gc collector线程与应用线程可以并行执行，标记出GC Root可达对象衍生出去的存活对象，并收集各个Region的存活对象信息。
3. remark: 最终标记过程，整个过程STW，标记出那些在并发标记过程中遗漏的，或者内部引用发生变化的对象。
4. clean up: 垃圾清除过程，如果发现一个Region中没有存活对象，则把该Region加入到空闲列表中。

#####   Full GC

​	如果对象内存分配速度过快，mixed gc来不及回收，导致老年代被填满，就会触发一次full gc，G1的full gc算法就是单线程执行的serial old gc，会导致异常长时间的暂停时间，需要进行不断的调优，尽可能的避免full gc.

####   G1的最佳实践

**不断调优暂停时间指标**

  通过**XX:MaxGCPauseMillis=x**可以设置启动应用程序暂停的时间，G1在运行的时候会根据这个参数选择CSet来满足响应时间的设置。一般情况下这个值设置到100ms或者200ms都是可以的(不同情况下会不一样)，但如果设置成50ms就不太合理。暂停时间设置的太短，就会导致出现G1跟不上垃圾产生的速度。最终退化成Full GC。所以对这个参数的调优是一个持续的过程，逐步调整到最佳状态。

**不要设置新生代和老年代的大小**

  G1收集器在运行的时候会调整新生代和老年代的大小。通过改变代的大小来调整对象晋升的速度以及晋升年龄，从而达到我们为收集器设置的暂停时间目标。设置了新生代大小相当于放弃了G1为我们做的自动调优。我们需要做的只是设置整个堆内存的大小，剩下的交给G1自己去分配各个代的大小。

##   可视化GC日志分析工具-GC Easy

```java
public class SerialDemo {

    public static void main(String[] args) throws Exception {
        List<Object> list = new ArrayList<Object>();
        while (true){
            int sleep = new Random().nextInt(100);
            if(System.currentTimeMillis() % 2 ==0){
                list.clear();
            }else{
                for (int i = 0; i < 10000; i++) {
                    Properties properties = new Properties();
                    properties.put("key_"+i, "value_" + System.currentTimeMillis() + i);
                    list.add(properties);
                }
            }

            Thread.sleep(sleep);
        }
    }
}
```

设置参数输出gc日志：-XX:+UseParallelGC -XX:+UseParallelOldGC -XX:+PrintGCDetails -Xms128m -Xmx128m -Xloggc:gc.log

GC Easy是一款在线的可视化工具，易用、功能强大，网站：

http://gceasy.io/

 ![1537803536253](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/1537803536253.png)

上传后，点击“Analyze”按钮，即可查看报告。

###  JVM Heap Size

​	这一部分分别使用了表格和图形界面来展示了JVM堆内存大小

​	左侧分别展示了年轻代的内存分配分配空间大小（Allocated）和年轻代内存分配空间大小的最大峰值（Peek），然后依次是老年代（Old Generation）、元数据区（Meta Space）、堆区和非堆区（Young + Old + Meta Space）总大小。

![1537804265054](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/1537804265054.png)

 

### Key Performance Indicators

这一部分是关键的性能指标

![image-20200817184526587](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200817184526587.png)

- Throughput表示的是吞吐量
- Latency表示响应时间
  - Avg Pause GC Time 平均GC时间
  - Max Pause GC TIme 最大GC时间

### Interactive Graphs

![image-20200817185141660](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200817185141660.png)

第一部分为：回收后堆的内存图，从图中可以看出，随着GC的进行，垃圾回收器把对象都回收掉了，因此堆的大小主键增大。

第二部分为：回收前堆的使用率，随着程序的运行，堆的使用率越来越高，堆被对象占用的内存越来越大。

第三部分为：GC的持续时间。

第四部分为：GC回收掉的垃圾对象的大小。

第五部分为：年轻代的内存分配情况

第六部分为：老年代的内存分配情况

第七部分为：元数据区内存分配情况

第八部分为：堆内存分配和晋升情况

### GC Statistics

![image-20200817185501527](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200817185501527.png)

左图：表示的是堆内存中Minor GC和Full GC回收垃圾对象的内存。
中图：总计GC时间，包括Minor GC和Full GC，时间单位为ms。
右图：GC平均时间，包括了Minor GC和Full GC。

### 其他

![image-20200817185537326](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200817185537326.png)

分别表示的是总GC统计，MinorGC的统计，FullGC的统计，GC暂停程序的统计。

### GC Causes

![image-20200817185618995](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/JVM/1/assets/image-20200817185618995.png)

GC花费的时间统计



