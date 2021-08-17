---
title: Java并发编程03--volatile关键字
categories: Java并发编程
tags:
  - volatile
top: 10
abbrlink: 3511257114
date: 2019-08-01 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc.jpeg" width="1000" height="200" align="middle" />


<!--more-->

##  概述

​	Java中提供了一种较弱的同步机制，即volatile关键字。可以把它看成是synchronized的轻量级实现，但是**其并不能完全替代synchronized，或者说将其当做锁来使用**。volatile具有可见性与有序性，但不具有原子性。即通过volatile修饰的共享变量（**类的成员变量和静态成员变量**）不直接存在于工作线程的副本，而是存在于主内存中。线程每次读取时，都会去主内存中进行读取，从而保证其他线程每次对于该成员变量都能获取最新值。

​	简单来说，一个共享变量一旦被volatile修饰后，其就具备了两个特性：

- 保证多线程下对该变量的可见性。
- 保证多线程下对该变量的有序性。

##   特性详解

###  不能保证共享变量的原子性

```java
public class AtomicityTest {

    public volatile int inc = 0;

    public void increment() {
        inc++;
    }

    public static void main(String[] args) throws InterruptedException {

        final AtomicityTest test = new AtomicityTest();

        for(int i=0;i<10;i++){
            new Thread(){
                @Override
                public void run() {
                    for(int j=0;j<1000;j++) {
                        test.increment();
                    }
                };
            }.start();
        }

        //保证前面的线程都执行完
        TimeUnit.SECONDS.sleep(3);
        System.out.println(test.inc);
    }
}
```

​	通过上述程序运行结果可以发现，最终结果并非期望的10000，因为volatile并不能保证原子性，因此在多线程下操作时，一个线程可能会读取到另外一个线程并未修改的数据。

###   能够保证共享变量的可见性

​	通过volatile修饰的变量，JMM并不会将其放入线程的本地内存，而是放入主内存中。从而该变量对于其他线程都是立即可见的。

###  能够保证共享变量的有序性

​	volatile能够**禁止指令重排**，因此能够在一定程度上保证有序性。当对volatile变量操作时，其前面的操作肯定全部已经执行完毕，其后面的操作肯定还没有执行。

##   使用场景

​	通过前面的讲解可知，volatile不具备原子性，因此其并不能当做锁来使用。一般来说通过volatile修饰的变量都会独立于任何程序，一般volatile会通过与synchronized组合来保证并发时能够正确执行。对其的使用必须同时满足下面两个条件才能保证在并发环境的线程安全：

- 对变量的写操作不依赖于当前值（比如 i++），或者说是单纯的变量赋值（boolean flag = true）
- 该变量没有包含在具有其他变量的不变式中，也就是说，不同的 volatile 变量之间，不能互相依赖。只有在状态真正独立于程序内其他内容时才能使用 volatile。

​	同时volatile更适用于读多写少的场景。如有N个线程在读值，而只有一个线程在写值，则该值可以通过volatile修饰，即可保证多线程下的可见性，也可以保证变量的原子性。

```java
public class SequenceTest {

    static int n =0;

    public static void add(){
        n++;
    }

    public static void main(String[] args) {

        new Thread(){

            @Override
            public void run() {

                try {
                    TimeUnit.SECONDS.sleep(3);
                    for(int i=0;i<200;i++){
                        add();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }.start();

        while (n<100){}

        System.out.println("end");
    }
}
```

​	如果n不加volatile，程序会进入死循环，因为n对于子线程来说是不可见的。当对n添加了volatile后，则程序可以结束。

##  扩展

**单例模式的DCL为什么要添加volatile**

```java
public class Singleton {
    
    private volatile static Singleton instance = null;
    
    public  static Singleton getInstance() {  //1
        
        if(null == instance) {   //2
            
            synchronized (Singleton.class) {//3
                
                if(null == instance) {   //4
                    
                    instance = new Singleton();       //5 
                }
            }
        }

        return instance;    

    }
}
```

​	在上述代码中对于`instance = new Singleton();`在执行时，其内部主要会发生三件事：分配内存、对象初始化、设置instance指向刚分配的地址。因此多线程下在编译时，有可能发生指令重排，假设当线程A在执行第5行代码时，B线程进来执行到第2行代码。假设此时A执行的过程中发生了指令重排序，即先执行了a和c，没有执行b。那么由于A线程执行了c导致instance指向了一段地址，所以B线程判断instance不为null，会直接跳到第6行并返回一个未初始化的对象。
