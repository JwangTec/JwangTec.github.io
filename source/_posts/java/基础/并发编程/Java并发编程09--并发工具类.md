---
title: Java并发编程09--并发工具类
categories: Java并发编程
tags:
  - 并发工具类
top: 10
abbrlink: 873762885
password:
---
​	
​    
​在JDK并发包下提供了几个很有用的并发工具类。CountDownLatch、CyclicBarrier、Semaphore、Exchanger。通过他们可以在不同场景下完成一些特定的功能。

<!--more-->

## CountDownLatch闭锁

###   简介

​	CountDownLatch一般会把它称之为**闭锁**，其**允许一个或多个线程等待其他线程完成操作**。

![image-20200730194204167](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730194204167.png)

​	CountDownLatch内部是通过计数器实现，当执行到某个节点后，就会开始等待其他任务执行。每完成一个任务，计数器就会减一，当计数器等于0时，代表任务已全部完成，则恢复之前的等待线程继续向下运行。

###  使用场景

​	根据其工作的特性，使用的场景也是比较多的。假设现在要解析一个Excel文件，其内部会存在多个sheet，则设定每个线程解析一个sheet，等到解析完所有sheet后。再进行后续操作。这就是一个很常见的场景。

### 代码实现

```java
public class CountDownLatchDemo {

    static CountDownLatch countDownLatch = new CountDownLatch(5);

    //任务线程
    private static class TaskThread implements Runnable{

        @Override
        public void run() {
            countDownLatch.countDown();
            System.out.println("task thread is running");
        }
    }

    //等待线程
    private static class WaitThread implements Runnable{

        @Override
        public void run() {
            try {
                countDownLatch.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("wait thread is running");
        }
    }

    public static void main(String[] args) throws InterruptedException {

        //等待线程执行
        for (int i = 0; i < 2; i++) {
            new Thread(new WaitThread()).start();
        }

        for (int i = 0; i < 5; i++) {
            new Thread(new TaskThread()).start();
        }

        TimeUnit.SECONDS.sleep(3);
    }
}
```

##   CycliBarrier同步屏障

###   简介

​	CycliBarrier翻译过来叫做**可循环的屏障**。其可以实现当一组线程执行时，当到达某个屏障（同步点）被阻塞，直到最后一个线程到达屏障后，才会让这一组线程继续向下执行。 其内部也是基于计数器思想实现。

![image-20200730204742730](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730204742730.png)

​	对于CycliBarrier来说，其在基本流程的基础上，也进行了一个扩展。查看源码可知，其构造函数不仅可以传入需要等待的线程数，同时还可以传入一个Runnable。对于这个runnable可以作为一个扩展任务来使用。

![image-20200730204940461](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730204940461.png)

###   代码实现

####  基础实现

```java
public class CyclicBarrierDemo {

    static CyclicBarrier barrier = new CyclicBarrier(3);

    public static void main(String[] args) throws InterruptedException {
        new Thread(()->{

            try {
                System.out.println(Thread.currentThread().getName()+": do somethings");
                barrier.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (BrokenBarrierException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName()+":continue somethings");
        }).start();

        new Thread(()->{

            try {
                System.out.println(Thread.currentThread().getName()+": do somethings");
                barrier.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (BrokenBarrierException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName()+":continue somethings");
        }).start();

        //主线程
        try {
            System.out.println(Thread.currentThread().getName()+": do somethings");
            barrier.await();
        } catch (BrokenBarrierException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName()+":continue somethings");
    }
}
```

运行结果

```
Thread-0: do somethings
main: do somethings
Thread-1: do somethings
main:continue somethings
Thread-1:continue somethings
Thread-0:continue somethings
```

​	根据运行结果可知，子线程与主线程间首先会进行相互等待，只有等到其他线程都执行完毕后，才能继续向下执行。因为主线程和子线程是由CPU来进行调度，所以顺序不可控。

​	此时如果将线程数由3改为4则会永久等待，因为没有第四个线程执行await()方法，即没有第四个线程到达屏障，所以之前到达屏障的三个线程都不会继续向下执行。

####   扩展实现

​	CyclicBarrier还提供了一个更高级的构造函数，不仅可以设置等待线程数量，同时还能够设置一个优先执行的Runnable，方便处理更为复杂的业务场景。

![image-20200730220902843](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730220902843.png)

![image-20200730223241276](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730223241276.png)

```java
public class CyclicBarrierDemo2 {

    static CyclicBarrier barrier = new CyclicBarrier(3,new ExtendTask());

    public static void main(String[] args) throws InterruptedException {
        new Thread(()->{

            try {
                System.out.println(Thread.currentThread().getName()+": do somethings");
                barrier.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (BrokenBarrierException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName()+":continue somethings");
        }).start();

        new Thread(()->{

            try {
                System.out.println(Thread.currentThread().getName()+": do somethings");
                barrier.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (BrokenBarrierException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName()+":continue somethings");
        }).start();

        //主线程
        try {
            System.out.println(Thread.currentThread().getName()+": do somethings");
            barrier.await();
        } catch (BrokenBarrierException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName()+":continue somethings");
    }

    static class ExtendTask implements Runnable{

        @Override
        public void run() {
            System.out.println("extend task running");
        }
    }
}
```

###   与CountDownLatch的区别

1）CountDownLatch.await 一般阻塞工作线程，所有的进行预备工作的线程执行countDown，而 CyclicBarrier 通过工作线程调用 await 从而自行阻塞，直到所有工作线程达到指定屏障，再大家一起往下走。

2）在控制多个线程同时运行上，CountDownLatch 可以不限线程数量，而CyclicBarrier 是固定线程数。

##   Semaphore信号量

###   简介

​	其可以用于做流量控制，通过控制同时访问资源的线程数量，从而保证资源能够被更加合理的使用，如连接资源。假设现在要获取几万个文件资源，那么现在可以开启若干线程进行并发读取。但是读取后还要把这些数据写入到数据库。而数据库连接现在只有100个，此时就需要人为干预，控制只有100个线程同时获取数据库连接资源保存数据。

![image-20200730223617565](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730223617565.png)

###   代码实现

```java
public class SemaphoreDemo {

    private static final int THREAD_COUNT=30;

    private static ExecutorService executorService = Executors.newFixedThreadPool(THREAD_COUNT);

    static Semaphore semaphore = new Semaphore(10);

    public static void main(String[] args) {
        for (int i = 0; i < THREAD_COUNT; i++) {
            executorService.execute(()->{

                try {
                    //获取资源
                    semaphore.acquire();
                    System.out.println("do somethings");
                    //释放资源
                    semaphore.release();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

            });
        }

        executorService.shutdown();
    }
}
```

​	根据上述实现，虽然有三十个线程执行，但是每次同时只能有十个线程能同时获取到资源。 如果将释放资源API注释，则只会有十条打印，因为资源已被耗尽，其他线程无法获取到资源。

##  Exchanger交换器

###   简介

​	Exchanger是一个线程协作工具类，**可以进行线程间的数据交换**，但是只局限于两个线程间协作。它提供了一个同步点，在这个同步点，两个线程可以交换彼此的数据。

![image-20200730225242985](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730225242985.png)

###   代码实现

```java
public class ExchangerDemo {

    private static final Exchanger<Set<String>> exchange = new Exchanger<Set<String>>();

    public static void main(String[] args) {

        new Thread(new Runnable() {
            @Override
            public void run() {
                Set<String> setA = new HashSet<String>();//存放数据的容器
                try {
                    setA.add("a1");
                    setA = exchange.exchange(setA);//交换set
                    /*处理交换后的数据*/
                    System.out.println(Thread.currentThread().getName()+" : "+setA.toString());
                } catch (InterruptedException e) {
                }
            }
        },"setA").start();

        new Thread(new Runnable() {
            @Override
            public void run() {
                Set<String> setB = new HashSet<String>();//存放数据的容器
                try {
                    /*添加数据
                     * set.add(.....)
                     * set.add(.....)
                     * */
                    setB.add("a2");
                    setB = exchange.exchange(setB);//交换set
                    /*处理交换后的数据*/
                    System.out.println(Thread.currentThread().getName()+" : "+setB.toString());
                } catch (InterruptedException e) {
                }
            }
        },"setB").start();

    }
}
```

运行结果

```
setB : [a1]
setA : [a2]
```

