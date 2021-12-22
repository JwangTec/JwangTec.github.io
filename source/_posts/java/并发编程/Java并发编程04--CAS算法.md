---
title: Java并发编程04--CAS算法
categories: Java并发编程
tags:
  - CAS
  - 并发编程
  - Java
top: 18
abbrlink: 2545724321
date: 2019-08-02 18:18:19
password:
---


<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc.jpeg" width="1000" height="200" align="middle" />

#  CAS算法

##  什么是CAS

> CAS（Compare and Swap），即比较并替换，是用于实现多线程同步的原子操作。

<!--more-->

​	所谓原子操作是指不会被线程调度机制打断的操作。这种操作一旦开始，就一直运行到结束，中间不会有任何context switch（切换到另一个线程）。

​	实现原子操作可以使用锁，锁机制对于满足基本的原子需求是没问题的，但**synchronized**是基于阻塞的锁机制，也就是当一个线程拥有锁时，访问同一资源的其他线程需要等待，直到该线程释放锁。

​	同时基于**synchronized**实现原子操作也会出现很多问题。

- 优先级低的线程抢到锁，被阻塞的线程优先级很高很重要怎么办？
- 获得锁的线程一直不释放锁怎么办？
- 有大量的线程来竞争资源，则CPU会花费大量时间和资源来处理这些竞争。
- 死锁问题处理。

​	其实锁机制是一种较为粗糙，粒度比较大的机制，对于一些简单的需求，如计数器显得有点过于笨重。

##  CAS实现原理 

​	现代处理器基本都支持CAS指令，每一个CAS操作过程都包含三个运算符：**内部地址V**、**期望值A**、**新值B**。操作时如果这个**内存地址V上**存放的值等于**期望值A**，则将内存地址上的值修改为新值B，否则不做任何操作。常见的CAS循环其实就是在一个循环里不断的做CAS操作，直到成功为止。

​	CAS对于线程安全的实现，其是语言层面无任何处理，我们将其交CPU和内存完成，利用多核CPU的处理能力，实现硬件层面的阻塞，再加上volatile关键字的特性即可实现基于原子操作的线程安全。

![image-20200728161620715](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200728161620715.png)

##   悲观锁、乐观锁

> 说到CAS，不得不提到两个专业词语：悲观锁，乐观锁。我们先来看看什么是悲观锁，什么是乐观锁。

### 悲观锁

​	悲观锁总是假设会出现最坏的情况，每次去获取数据时，都会认为别人会修改，所以每次在获取数据时都会上锁。这样别人想拿到这个数据就会阻塞，直到它获取到锁。在关系型数据库中就大量应用了这种锁机制，如行锁、表锁、读锁、写锁。都是在操作前先上锁。Java中**synchronized**就是很直观的体现。

###   乐观锁

​	乐观锁总是假设一直都是最好的情况。每次获取时都认为别人不会修改，所以不会上锁，但是在更新时会判断在此期间别人有没有更新这个数据，可以使用版本号实现。乐观锁适用于**读多写少**的场景。这样可以提升系统吞吐量，而CAS就是一种乐观锁的实现。

##  CAS的典型问题

​	CAS看起来很好，但是其实现过程中会出现三个典型问题，分别为**ABA、循环时间开销大、只能保证一个共享变量的原子操作**。

###  ABA

​	根据之前的讲解CAS操作，其实现重要思路是需要取出内存地址中某个时刻的数据，而在下时刻比较并替换，那么在这个时间差就有可能导致数据的变化。

​	一个线程a将数值改成了b，接着又改成了a，此时CAS认为是没有变化，其实是已经变化过了，这种过程就叫ABA问题。

​	对于ABA问题的解决，常见的解决方式就是通过添加数据版本号实现，避免该问题的发生。后续讲到的原子类就是基于版本号避免ABA问题的出现。

###  循环时间长开销大

​	CAS会基于CPU进行自旋操作，如果CAS失效，就会一直进行尝试，如果自旋时间过长，会给CPU带来巨大性能开销。

```java
public class CasTest {

    private static AtomicInteger count = new AtomicInteger(0);
    /**
     * Cas 自旋操作
     */
    public static void accumulation() {
        //自旋
        for (; ; ) {
            //获取旧值
            int oldValue = count.get();
            //比较并且交换
            boolean flag = count.compareAndSet(oldValue, oldValue + 1);
            //如果成功退出自旋
            if (flag) {
                break;
            }
            //失败打印信息再来一次
            System.out.println("数据已被修改自旋再来一次");
        }
    }

    public static void main(String[] args) throws InterruptedException {
        //五个线程再跑
        for (int i = 0; i < 5; i++) {
            new Thread(() -> {
                try {
                    TimeUnit.SECONDS.sleep(1);
                    //每个线程让count自增100000次
                    for (int n = 0; n < 100000; n++) {
                        accumulation();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

            }).start();
        }
       TimeUnit.SECONDS.sleep(2);

        System.out.println(count);
    }
}
```

![image-20200728172201973](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200728172201973.png)

​	可以看到在高并发下，compareAndSet会很大概率失败，因此导致了CPU不断自旋，造成CPU性能浪费。

###   只能保证一个共享变量的原子操作

​	当对一个变量执行操作时，可以使用CAS循环方式保证原子操作，但对多个变量操作时，CAS则无法保证操作的原子性。因为对于一个内存地址来说，其内部只会存储一个变量。如果要对多个变量操作的话，则需要使用到锁或者进行合并(i=2,j=3 -> 合并ij为一个变量 -> 包装为一个引用类型 -> 进行原子操作)。





