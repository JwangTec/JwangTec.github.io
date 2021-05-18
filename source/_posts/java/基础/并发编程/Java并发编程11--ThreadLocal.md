​---
title: Java并发编程11--ThreadLocal
categories: Java并发编程
tags:
	- ThreadLocal
top: 10
date: 2019-08-03 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc3.jpeg" width="1000" height="300" align="middle" />


##   概述

​	ThreadLocal是多线程中对于解决线程安全的一个操作类，它会**为每个线程都分配一个独立的线程副本**从而解决了变量并发访问冲突的问题。ThreadLocal比直接使用synchronized同步机制解决线程安全问题更简单，更方便，且结果程序拥有更高的并发性。

<!--more-->

​	一个经典的例子，使用JDBC操作数据库时，会将每一个线程的Connection放入各自的ThreadLocal中，从而保证每个线程都在各自的 Connection 上进行数据库的操作，避免A线程关闭了B线程的连接。

![image-20201017180859674](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20201017180859674.png)

##  ThreadLocal与Synchonized区别

​	ThreadLocal和Synchonized都用于解决多线程并发访问。Synchronized用于线程间的数据共享，而ThreadLocal则用于线程间的数据隔离。Synchronized通过锁机制使得变量在同一时刻只能被一个线程访问，而ThreadLocal为每一个线程提供一个变量副本，使得每个线程都只能对自己线程内部数据进行维护，从而实现共享数据的线程隔离。

##   ThreadLocal入门应用

```java
public class ThreadLocalTest {

    static ThreadLocal<String> localVar = new ThreadLocal<>();

    static void print(String str) {

        //打印当前线程中本地内存中本地变量的值
        System.out.println(str + " :" + localVar.get());
        
        //清除本地内存中的本地变量
        localVar.remove();
    }

    public static void main(String[] args) {

        Thread t1 = new Thread(()->{

            localVar.set("localVar1");
            print("thread1");
            System.out.println("after remove : " + localVar.get());
        });


        Thread t2 = new Thread(()->{

            localVar.set("localVar2");
            print("thread2");
            System.out.println("after remove : " + localVar.get());
        });

        t1.start();
        t2.start();
    }
}
```

运行结果

```
thread2 :localVar2
after remove : null
thread1 :localVar1
after remove : null
```

根据结果可知，每个线程都会维护自己的ThreadLocal值。

##   实现原理&源码解析

​	ThreadLocal本质来说就是一个线程内部存储类，从而让多个线程只操作自己内部的值，从而实现线程数据隔离。官方解释如下

![image-20201017183427869](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20201017183427869.png)

​	翻译过来即：该类提供了线程局部变量的能力，每个线程都拥有独立的变量副本，通过set和get方法进行操作，该类通常是私有的，通过用于存储和线程相关的信息，如用户id、交易id等。

源码结构如下：

![image-20201017183854272](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20201017183854272.png)

​	源码结构可知，在ThreadLocal内部维护了一个内部类ThreadLocalMap。而且在ThreadLocalMap中又维护了一个Entry内部类和一个Entry数组。有很多人对于ThreadLocal的介绍都会说：ThreadLocal内部维护了一个map，key是当前线程，value为需要存储的数据。根据源码可知，这句话并不准确，实际上，在ThreadLocal内部的维护了一个ThreadLocalMap，**每个线程持有一个ThreadLocalMap对象**，在ThreadLocalMap中为每一个线程都维护了一个数组table，而这个数组中会通过**下标**来确定存储数据的位置。

![image-20201017193236701](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20201017193236701.png)

###   ThreadLocalMap源码解析

```java
//Entry为ThreadLocalMap静态内部类，对ThreadLocal的若引用
//同时让ThreadLocal和储值形成key-value的关系
static class Entry extends WeakReference<ThreadLocal<?>> {
    /** The value associated with this ThreadLocal. */
    Object value;

    Entry(ThreadLocal<?> k, Object v) {
        super(k);
        value = v;
    }
}

//ThreadLocalMap构造方法
ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
    //内部成员数组，INITIAL_CAPACITY值为16的常量
    table = new Entry[INITIAL_CAPACITY];
    //位运算，结果与取模相同，计算出需要存放的位置
    int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
    table[i] = new Entry(firstKey, firstValue);
    size = 1;
    setThreshold(INITIAL_CAPACITY);
}
```

​	ThreadLocalMap在实例化时，会创建一个16位长度的Entry数组，通过hashCode与长度计算出下标值i，接着创建Entry对象，通过计算出的下标值i，确定该Entry在数组中的位置。

​	根据之前的讲解，每一个线程都拥有一个独属于自己的ThreadLocal，而在ThreadLocal中又会存在ThreadLocalMap，因此相当于每个线程都拥有一个自己的ThreadLocalMap，那么假设在一个线程中声明了不同类型的ThreadLocal，那么其实最终他们对应的是同一个ThreadLocalMap。

```java
ThreadLocal<A> sThreadLocalA = new ThreadLocal<A>();
ThreadLocal<B> sThreadLocalB = new ThreadLocal<B>();
ThreadLocal<C> sThreadLocalC = new ThreadLocal<C>();
```

​	对于上述多个类型的ThreadLocal，他们在同一个线程内，对应的是同一个ThreadLocalMap。那么他们在ThreadLocalMap的Entry数组中，又是如何来确定位置的呢？

```java
private void set(ThreadLocal<?> key, Object value) {

    Entry[] tab = table;
    int len = tab.length;
    //计算数组下标值
    int i = key.threadLocalHashCode & (len-1);

    //遍历tab，如果该key已存在，则更新
    for (Entry e = tab[i];
         e != null;
         e = tab[i = nextIndex(i, len)]) {
        ThreadLocal<?> k = e.get();

        if (k == key) {
            e.value = value;
            return;
        }

        if (k == null) {
            replaceStaleEntry(key, value, i);
            return;
        }
    }

    //如果没有遍历到，则创建Entry对象，并放入数组对应位置
    tab[i] = new Entry(key, value);

    //数组大小自增
    int sz = ++size;

    //当数组长度大于等于阈值，则执行扩容，扩容为原大小的两倍
    if (!cleanSomeSlots(i, sz) && sz >= threshold)
        rehash();
}
```

```java
private void resize() {
    Entry[] oldTab = table;
    int oldLen = oldTab.length;
    int newLen = oldLen * 2;
    Entry[] newTab = new Entry[newLen];
    int count = 0;

    for (int j = 0; j < oldLen; ++j) {
        Entry e = oldTab[j];
        if (e != null) {
            ThreadLocal<?> k = e.get();
            if (k == null) {
                e.value = null; // Help the GC
            } else {
                int h = k.threadLocalHashCode & (newLen - 1);
                while (newTab[h] != null)
                    h = nextIndex(h, newLen);
                newTab[h] = e;
                count++;
            }
        }
    }

    setThreshold(newLen);
    size = count;
    table = newTab;
}
```

​	对于上述源码分析内容，总结如下：

- **对于同一线程的不同ThreadLocal来讲，这些ThreadLocal实例共享一个table数组，然后每个ThreadLocal实例在数组中的下标值i是不同的。**
- **对于某一个ThreadLocal来讲，他的下标值i是确定的，在不同线程之间访问时访问的是不同的table数组的同一位置即都为table[i]，只不过这个不同线程之间的table是独立的。**

###   set()源码分析

```java
public void set(T value) {
    
    //获取当前线程对象
    Thread t = Thread.currentThread();
    
    //根据当前线程对象，获取ThreadLocal中的ThreadLocalMap
    ThreadLocalMap map = getMap(t);
    
    //如果map存在
    if (map != null)
        //执行map中的set方法，进行数据存储
        map.set(this, value);
    else
        //否则创建ThreadLocalMap，并存值
        createMap(t, value);
}
```

###  get()源码分析

```java
public T get() {
    Thread t = Thread.currentThread();
    
    //根据线程对象，获取对应的ThreadLocalMap
    ThreadLocalMap map = getMap(t);
    
    if (map != null) {
        //获取ThreadLocalMap中对应的Entry对象
        ThreadLocalMap.Entry e = map.getEntry(this);
        if (e != null) {
            @SuppressWarnings("unchecked")
            //获取Entry中的value
            T result = (T)e.value;
            return result;
        }
    }
    return setInitialValue();
}
```

```java
private Entry getEntry(ThreadLocal<?> key) {
    //确定数组下标位置
    int i = key.threadLocalHashCode & (table.length - 1);
    
    //得到该位置上的Entry
    Entry e = table[i];
    if (e != null && e.get() == key)
        return e;
    else
        return getEntryAfterMiss(key, i, e);
}
```

##  应用场景

​	对于ThreadLocal在框架底层实现以及实际开发中都非常常见，利用ThreadLocal的特性可以实现线程数据隔离，从而解决多线程数据冲突问题。当某些数据是以线程为作用域并且不同线程具有不同的数据副本的时候，就可以考虑采用ThreadLocal。

###   Spring事务中的使用

​	Spring采用Threadlocal来保证单个线程中的数据库操作使用的是同一个数据库连接，同时，采用这种方式可以使业务层使用事务时不需要感知并管理connection对象，通过传播级别管理多个事务配置之间的切换，挂起和恢复。在Spring内部中存在一个类**TransactionSynchronizationManager**，该类实现了事务管理与数据访问服务的解耦，同时也保证了多线程环境下connection的线程安全问题。

​	在Spring中，当我们要获取dao层的Bean时，最原始的方式可以通过getBean()来进行获取

```java
ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext-jdbc.xml");

UserDaoImpl userDaoImpl = (UserDaoImpl) ac.getBean("userDaoImpl");

System.out.println(userDaoImpl.insertUserInfo("zhangsan", 25));
```

​	对于spring的事务实现，只要某个类的方法、类或者接口上有事务配置，spring就会对该类的实例生成代理，所以userDaoImpl是UserDaoImpl实例的**代理实例**的引用，而不是UserDaoImpl的目标实例的引用；

​	若目标方法被@Transactional修饰，那么代理方法会先执行增强（判断当前线程是否存在connection、不存在则新建并绑定到当前线程等等），然后通过反射执行目标方法，最后回到代理方法执行增强（事务回滚或事务提交、connection归还到连接池）。这里的绑定connection到当前线程就用到了ThreadLocal。

###  业务中的应用

####   线上日期错误

​	开发中经常会使用到SimpleDataFormat进行日期格式化，当调用SimpleDataFormat的parse方法进行日期解析时，会先调用SimpleDataFormat内部的Calendar.clear()，然后调用Calendar.add()，如果一个线程先调用了add()然后另一个线程又调用了clear()，这时候parse方法解析的时间就不对了，最终导致部分用户的日期不对。

​	解决方案：对于这个问题的解决思路，就是让每个线程都拥有一个自己的SimpleDataFormat，可是直接new的方式性能并不好，此时就可以通过ThreadLocal进行解决，使用线程池加上ThreadLocal包装 SimpleDataFormat ，让每个线程有一个 SimpleDataFormat 的副本，从而解决了线程安全的问题，也提高了性能。

####   跨服务方法传参

​	在项目开发中，有可能存在一个线程横跨若干服务若干方法调用，经常需要传递一些状态性的信息，如用户认证信息等。如果要想完成这件事，其中一种方式可以通过Context上下文对象进行传参，但是通过上下文传参的话，有可能导致参数传不进去，所以通过ThreadLocal进行改造，当set完数据后，只要保证是在同一个线程中，则其他地方还需要get就可以了。

##   ThreadLocal经典问题-内存泄露

###   内存泄露

####   何为内存泄露

​	ThreadLocal在使用过程中的一个经典问题即：内存泄露。所谓的内存泄露即：程序在申请内存后，无法释放已申请的内存空间。一次内存泄露危害可以忽略，但内存泄露堆积后果则非常严重，无论多少内存，迟早都会被占光。简单一句话就是：不会再被使用的对象或变量占用的内存不能被回收。

####   Java对象的四种引用类型

​	要想理解内存泄露的话，则必须先要理解Java对象中的四种引用类型：**强引用、软引用、弱引用、虚引用**。

​	**强引用：**最为普通的引用方式，表示一个对象处于**有用且必须**的状态，如果一个对象具有强引用，则GC并不会回收它。即便堆中内存不足了，宁可出现OOM，也不会对其进行回收

```java
User user = new User();
```

​	**软引用：**表示一个对象处于**有用且非必须**状态，如果一个对象处于软引用，在内存空间足够的情况下，GC机制并不会回收它，而在内存空间不足时，则会在OOM异常出现之间对其进行回收。但值得注意的是，因为GC线程优先级较低，软引用并不会立即被回收。

```java
User user = new User();
SoftReference softReference = new SoftReference(user);
```

​	**弱引用：**表示一个对象处于**可能有用且非必须**的状态。在GC线程扫描内存区域时，一旦发现弱引用，就会回收到弱引用相关联的对象。对于弱引用的回收，无关内存区域是否足够，一旦发现则会被回收。同样的，因为GC线程优先级较低，所以弱引用也并不是会被立刻回收。

```java
User user = new User();
WeakReference weakReference = new WeakReference(user);
```

​	**虚引用：**表示一个对象处于**无用**的状态。在任何时候都有可能被垃圾回收。虚引用的使用必须和引用队列Reference Queue联合使用

```java
User user = new User();
ReferenceQueue referenceQueue = new ReferenceQueue();
PhantomReference phantomReference = new PhantomReference(user,queue);
```

####   内存泄露原因分析

​	根据前面对于ThreadLocal的源码分析可知，每一个Thread维护一个ThreadLocalMap，在ThreadLocalMap中的Entry对象继承了WeakReference。其中key为使用**弱引用**的ThreadLocal实例，value为线程变量的副本。

```java
static class Entry extends WeakReference<ThreadLocal<?>> {
    /** The value associated with this ThreadLocal. */
    Object value;

    Entry(ThreadLocal<?> k, Object v) {
        super(k);
        value = v;
    }
}
```

​	那么为什么要把key定义为使用弱引用的ThreadLocal呢？假设将key定义为强引用，回收ThreadLocal时，因为ThreadLocalMap还持有ThreadLocal的强引用，如果没有手动删除，ThreadLocal不会被回收，最终导致Entry内存泄漏。

​	为了避免该问题，则将key定义为弱引用，但是当GC时，则会造成因为key是弱引用，因此会被回收掉，但是value是强引用，仍然会存在，最终造成value的内存泄露。

![image-20201017224941180](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20201017224941180.png)

​	如要避免ThreadLocal内存泄露的出现，也非常的简单。对于ThreadLocal的使用，务必记得要在最后一步执行remove即可。
​	
​

