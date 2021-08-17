---
title: Java并发编程01--线程、并发基础
categories: Java并发编程
tags:
  - 并发基础
  - 线程
  - 守护线程
  - 线程状态
top: 10
abbrlink: 2347443716
date: 2019-08-01 18:18:19
password:
---

​	Java从诞生开始，其就已经内置了对于多线程的支持。当多个线程能够同时执行时，大多数情况下都能够显著提升系统性能，尤其现在的计算机普遍都是多核的，所以性能的提升会更加明显。但是，多线程在使用中也需要注意诸多的问题，如果使用不当，也会对系统性能造成非常严重的影响。
​	
​<!--more-->

##  并发编程核心概念

要理解并发编程，务必要先理解三个概念，分别为：原子性、可见性、有序性。

###  原子性

​	所谓原子性即：一个或者多个操作，要么全部执行并且执行的过程不会被任何因素打断，要么就都不执行。

​	在原子操作中，本质上拒绝多线程操作的，不论是单核或多核服务器，当要对某一个数据进行原子操作时，同一时刻只有有一个线程能够对其进行操作，简单来说，在整个操作过程中不会被线程调度器打断，如a=1就是一个原子操作，但a++则不是一个原子操作，因为其内部会额外产生一个新的Integer对象。

​	举个例子，假设对一个32位的变量赋值，操作分为两步：低16位赋值、高16位赋值。当线程A对低16位数据写入成功后，线程A被中断。而此时另外的线程B去读取a的值，那么读取到的就是错误的数据。

​	在Java中的原子性操作包括：

- 基本类型的读取和赋值操作，且赋值必须是数字赋值给变量，变量之间的相互赋值不是原子性操作。
- 所有引用的赋值操作。
- java.concurrent.Atomic.* 包中所有原子操作类的一切操作。

###  可见性

​	所谓可见性：即当多个线程访问同一个共享变量时，一个线程修改了该共享变量的值后，其他线程能够立即查看到修改后的值。

​	在多线程环境下，一个线程对共享变量的操作对其他线程是默认是不可见的，也就是说一个线程对某一共享的修改，默认其他线程是无法进行查看的。而如果要做到可见，Java中的volatile、synchronized、Lock都能保证可见性。如一个变量被volatile修饰后，表示当一个线程修改共享变量后，其会立即被更新到主内存中，其他线程读取共享变量时，会直接从主内存中读取。而synchronized和Lock能保证同一时刻只有一个线程获取锁然后执行同步代码，并且在释放锁之前会将对变量的修改刷新到主存当中。因此可以保证可见性。

```java
public class VolatileTest {

    static int a=1;

    public static void main(String[] args) throws InterruptedException {

        new Thread(new Runnable() {

            @Override
            public void run() {
                System.out.println(Thread.currentThread().getName()+"线程启动了");
                while(true) {
                    //当a=3 跳出死循环
                    if(a==3) {
                        break;
                    }
                }
                System.out.println(Thread.currentThread().getName()+"线程停止了");
            }
        },"t2").start();

        new Thread(new Runnable() {

            @Override
            public void run() {
                System.out.println(Thread.currentThread().getName()+"线程启动了");
                while(true) {
                    //当a=3 跳出死循环
                    if(a==3) {
                        break;
                    }
                }
                System.out.println(Thread.currentThread().getName()+"线程停止了");
            }
        },"t1").start();

        Thread.sleep(1000);
        //在主线程里边修改变量，测试其他线程是否对这个修改可见
        a=3;
    }
}
```

​	通过上述程序运行效果可以发现，对于变量a如果没有加volatile关键字，则线程1和线程2会进入死循环，因为在主线程中修改变量a，线程1和线程2是无法感知的。而当对变量a添加了volatile关键字后，则不会死循环，因为其已经可以保证线程可见性。

###  有序性

​	所谓有序性：即程序执行的顺序会按照代码的先后顺序执行。

​	其可以理解为**在本线程内，所有的操作都是有序的。而如果在A线程中观察B线程，所有的操作都是无序的**。在JMM中为了提升程序的执行效率，允许编译器和处理器对**指令重排序**。对于单线程来说，指令重排并不会产生问题，而在多线程下则不可以。

​	在Java中可以通过synchronized和Lock来保证有序性，synchronized和Lock保证每个时刻是有一个线程执行同步代码，相当于是让线程顺序执行同步代码，自然就保证了有序性。

​	另外还可以通过volatile来保证一定的有序性。最著名的例子就是单例模式的DCL（双重检查锁）。

```java
public class Singleton {
    
    private volatile static Singleton instance = null;
    
    public  static Singleton getInstance() {
        
        if(null == instance) { 
            
            synchronized (Singleton.class) {
                
                if(null == instance) {   
                    
                    instance = new Singleton();   
                }
            }
        }

        return instance;    

    }
}
```

**对于并发编程来说，要想保证程序的正确执行，对于原子性、可见性、有序性的保证是非常重要的！！！**

## 	  进程、线程

###   什么是进程

​	进程可以理解为就是应用程序的启动实例。如微信、Idea、Navicat等，当打开它们后，就相当于开启了一个进程。每个进程都会在操作系统中拥有独立的内存空间、地址、文件资源、数据资源等。**进程是资源分配和管理的最小单位**

![image-20200723204916791](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723204916791.png)

###  什么是线程  

​	线程从属于进程，是程序的实际执行者，一个进程中可以包含若干个线程，并且也可以把线程称为轻量级进程。每个线程都会拥有自己的计数器、堆栈、局部变量等属性，并且能够访问共享的内存变量。**线程是操作系统（CPU）调度和执行的最小单位**。CPU会在这些线程上来回切换，让使用者感觉线程是在同时执行的。

![image-20200723204935791](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723204935791.png)

###  线程使用带来的问题

​	有很多人都会存在一个误区，在代码中使用多线程，一定会为系统带来性能提升，这个观点是错误的。并发编程的目的是为了让程序运行的更快，但是，绝对不是说启动的线程越多，性能提升的就越大，其会受到很多因素的影响，如锁问题、线程状态切换问题、线程上下文切换问题，还会受到硬件资源的影响，如CPU核数。

####  什么叫做线程上下文切换 

​	不管是在多核甚至单核处理器中，都是能够以多线程形式执行代码的，CPU通过给每个线程分配CPU时间片来实现线程执行间的快速切换。 所谓的时间片就是CPU分配给每个线程的执行时间，当某个线程获取到CPU时间片后，就会在一定时间内执行，当时间片到期，则该线程会进入到挂起等待状态。时间片一般为几十毫秒，通过在CPU的高速切换，让使用者感觉是在同时执行。

​	同时还要保证线程在切换的过程中，要记录线程被挂起时，已经执行了哪些指令、变量值是多少，那这点则是通过每个线程内部的程序计数器来保证。 

​	简单来说：线程从挂起到再加载的过程，就是一次上下文切换。其是比较耗费资源的。

引起上下文切换的几种情况：

- 时间片用完，CPU正常调度下一个任务。
- 被其他优先级更高的任务抢占。
- 执行任务碰到IO阻塞，调度器挂起当前任务，切换执行下一个任务。
- 用户代码主动挂起当前任务让出CPU时间。
- 多任务抢占资源，由于没有抢到被挂起。
- 硬件中断。

##   CPU时间片轮转机制&优化

​	之前已经提到了线程的执行，是依赖于CPU给每个线程分配的时间来进行。在CPU时间片轮转机制中，如果一个线程的时间片到期，则CPU会挂起该线程并给另一个线程分配一定的时间分片。如果进程在时间片结束前阻塞或结束，则 CPU 会立即进行切换。

​	时间片太短会导致频繁的进程切换，降低了 CPU 效率: 而太长又可能引起对短的交互请求的响应变差。时间片为 **100ms** 通常是一个比较合理的折衷。

##   并行与并发的理解

​	对于这两个概念，如果刚看到的话，可能会很不屑。但是真的理解什么叫做并行，什么叫做并发吗？

​	所谓并发即让多个任务能够**交替**执行，一般都会附带一个时间单位，也就是所谓的在单位时间内的并发量有多少。

![image-20200723205250316](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723205250316.png)

所谓并行即让多个任务能够**同时**执行。比如说：你可以一遍上厕所，一遍吃饭。  

![image-20200723205302865](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723205302865.png)

##  线程启动&中止

​	线程的实现方式有两种：继承Thread类、实现Runnable接口。但是有一些书籍或者文章会说有三种方式，即实现Callable接口。但通过该接口定义线程并不是Java标准的定义方式，而是基于Future思想来完成。 Java官方说明中，已经明确指出，只有两种方式。

![image-20200723205452047](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723205452047.png)

​	那么Thread和Runnable有什么区别和联系呢？ 一般来说，Thread是对一个线程的抽象，而Runnable是对业务逻辑的抽象，并且Thread 可以接受任意一个 Runnable 的实例并执行。

###   线程启动

```java
/**
 * 新建线程
 */
public class NewThread {

    private static class UseThread extends Thread{
        @Override
        public void run() {

            System.out.println(Thread.currentThread().getName()+": use thread");
        }
    }

    private static class UseRunnable implements Runnable{

        @Override
        public void run() {

            System.out.println(Thread.currentThread().getName()+": use runnable");
        }
    }

    public static void main(String[] args) {

        System.out.println(Thread.currentThread().getName()+": use main");

        UseThread useThread = new UseThread();
        useThread.start();

        Thread thread = new Thread(new UseRunnable());
        thread.start();
    }
}
```

优化：启动线程前，最好为这个线程设置特定的线程名称，这样在出现问题时，给开发人员一些提示，快速定位到问题线程。

```java
Thread.currentThread().setName("Runnable demo");
```

###   线程中止

​	线程在正常下当run执行完，或出现异常都会让该线程中止。

####   理解suspend()、resume()、stop()

​	这三个方法对应的是暂停、恢复和中止。对于这三个方法的使用效果演示如下：

```java
public class Srs {

    private static class MyThread implements Runnable{
        @Override
        public void run() {
            DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");

            while (true){

                System.out.println(Thread.currentThread().getName()+"run at"+dateFormat.format(new Date()));
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }


    public static void main(String[] args) throws InterruptedException {

        Thread thread = new Thread(new MyThread());

        //开启线程
        System.out.println("开启线程");
        thread.start();
        TimeUnit.SECONDS.sleep(3);

        //暂停线程
        System.out.println("暂停线程");
        thread.suspend();
        TimeUnit.SECONDS.sleep(3);

        //恢复线程
        System.out.println("恢复线程");
        thread.resume();
        TimeUnit.SECONDS.sleep(3);

        //中止线程
        System.out.println("中止线程");
        thread.stop();
    }
}
```

执行结果

```java
开启线程
my threadrun at22:42:24
my threadrun at22:42:25
my threadrun at22:42:26
暂停线程
恢复线程
my threadrun at22:42:30
my threadrun at22:42:31
my threadrun at22:42:32
中止线程
```

​	可以看到这三个方式，很好的完成了其本职工作。但是三个已经在Java源码中被标注为过期方法。那这三个方式为什么会被标记为过期方法呢？

​	当调用**suspend()**时，线程不会将当前持有的资源释放(如锁)，而是占有者资源进入到暂停状态，这样的话，容易造成死锁问题的出现。

```java
public class Srs {

    private static  Object obj = new Object();//作为一个锁

    private static class MyThread implements Runnable{


        @Override
        public void run() {

            synchronized (obj){

                DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");

                while (true){
                    System.out.println(Thread.currentThread().getName()+"run at"+dateFormat.format(new Date()));

                    try {
                        TimeUnit.SECONDS.sleep(1);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }

        }
    }


    public static void main(String[] args) throws InterruptedException {

        Thread thread = new Thread(new MyThread(),"正常线程");
        Thread thread1 = new Thread(new MyThread(),"死锁线程");

        //开启线程
        thread.start();
        TimeUnit.SECONDS.sleep(3);

        //暂停线程
        thread.suspend();
        System.out.println("暂停线程");
        
        thread1.start();
        TimeUnit.SECONDS.sleep(3);

        //恢复线程
        /*thread.resume();
        System.out.println("恢复线程");
        TimeUnit.SECONDS.sleep(3);*/

        //中止线程
        /*thread.stop();
        System.out.println("中止线程");*/
    }
}
```

​	在上述代码中，正常线程持有了锁，当调用**suspend()**时，因为该方法不会释放锁，所以死锁线程因为获取不到锁而导致无法执行。

```java
正常线程run at23:37:28
正常线程run at23:37:29
正常线程run at23:37:30
暂停线程
```

​	当调用stop()时，会**立即停止run()中剩余的操作**。因此可能会导致一些的工作得不到完成，如文件流，数据库等关闭。并且**会立即释放该线程所持有的所有的锁**，导致数据得不到同步的处理，出现数据不一致的问题。

```java
public class StopProblem {

    public static void main(String[] args) throws Exception {

        TestObject testObject = new TestObject();

        Thread t1 = new Thread(() -> {
            try {
                testObject.print("1", "2");
            } catch (Exception e) {
                e.printStackTrace();
            }
        });

        t1.start();
        //让子线程有执行时间
        Thread.sleep(1000);
        t1.stop();
        System.out.println("first : " + testObject.getFirst() + " " + "second : " + testObject.getSecond());
    }
}

class TestObject {

    private String first = "ja";
    private String second = "va";

    public synchronized void print(String first, String second) throws Exception {
        System.out.println(Thread.currentThread().getName());
        this.first = first;
        //2.模拟数据不一致
        //TimeUnit.SECONDS.sleep(3);
        this.second = second;
    }

    public String getFirst() {
        return first;
    }

    public String getSecond() {
        return second;
    }
}
```

####   线程中止的安全且优雅姿势

​	Java对于线程安全中止设计了一个**中断属性**，其可以理解是线程的一个标识位属性。它用于表示一个运行中的线程是否被其他线程进行了中断操作。好比其他线程对这个线程打了一个招呼，告诉它你该中断了。通过**interrupt()**实现。

```java
public class InterruptDemo {


    private static class MyThread implements Runnable{

        @Override
        public void run() {

            while (true){

                System.out.println(Thread.currentThread().getName()+" is running");
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        Thread thread = new Thread(new MyThread(),"myThread");

        thread.start();

        TimeUnit.SECONDS.sleep(3);

        thread.interrupt();
    }
}
```

​	添加该方法后，会出现一个异常，但是可以发现并不会线程的继续执行。

​	线程通过检查自身是否被中断来进行响应，可以通过**isInterrupted()**进行判断，如果返回值为true，代表添加了中断标识，返回false，代表没有添加中断标识。通过它可以对线程进行中断操作。

```java
public class InterruptDemo {


    private static class MyThread implements Runnable{

        @Override
        public void run() {

            //while (true){
            while (!Thread.currentThread().isInterrupted()){

                System.out.println(Thread.currentThread().getName()+" is running");
            }

            System.out.println(Thread.currentThread().getName()+" Interrupt flag is : "+Thread.currentThread().isInterrupted());
        }
    }

    public static void main(String[] args) throws InterruptedException {

        Thread thread = new Thread(new MyThread(),"myThread");

        thread.start();

        TimeUnit.SECONDS.sleep(3);

        thread.interrupt();
    }
}
```

​	对线程中断属性的判断，可以利用其进行线程执行的中断操作。

​	线程也可以通过静态方法**Thread.interrupted()**查询线程是否被中断，并对中断标识进行复位，如果该线程已经被添加了中断标识，当使用了该方法后，会将线程的中断标识由true改为false。

![image-20200727142422111](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200727142422111.png)

```java
public class InterruptDemo {


    private static class MyThread implements Runnable{

        @Override
        public void run() {

            //while (true){
            //while (!Thread.currentThread().isInterrupted()){
            while (!Thread.interrupted()){

                System.out.println(Thread.currentThread().getName()+" is running");
            }

            System.out.println(Thread.currentThread().getName()+" Interrupt flag is : "+Thread.currentThread().isInterrupted());
        }
    }

    public static void main(String[] args) throws InterruptedException {

        Thread thread = new Thread(new MyThread(),"myThread");

        thread.start();

        TimeUnit.SECONDS.sleep(3);

        thread.interrupt();
    }
}
```

同时要注意：**处于死锁下的线程，无法被中断**

##  深入线程操作常见方法

###  理解run()&start()

​	这两个方法都可以启动线程，但是它俩是有本质上的区别的。当线程执行了 start()方法后，才真正意义上的启动线程，其会让一个线程进入就绪状态等待分配CPU时间片，分到时间片后才会调用run()。注意，同一个线程的start(**)不能被重复调用**，否则会出现异常，因为重复调用了，start方法，线程的state就不是new了，那么threadStatus就不等于0了。 

```java
//start源码分析
public synchronized void start() {
    /**
        Java里面创建线程之后，必须要调用start方法才能创建一个线程，该方法会通过虚拟机启动一个本地线程，本地线程的创建会调用当前系统去创建线程的方法进行创建线程。
        最终会调用run()将线程真正执行起来
        0这个状态，等于‘New’这个状态。
         */
    if (threadStatus != 0)
        throw new IllegalThreadStateException();

    /* 线程会加入到线程分组，然后执行start0() */
    group.add(this);

    boolean started = false;
    try {
        start0();
        started = true;
    } finally {
        try {
            if (!started) {
                group.threadStartFailed(this);
            }
        } catch (Throwable ignore) {
            /* do nothing. If start0 threw a Throwable then
                  it will be passed up the call stack */
        }
    }
}
```

![image-20200723210331930](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723210331930.png)

​	而run()则仅仅是一个普通方法，与类中的成员方法意义相同。在该方法中可以实现线程执行的业务逻辑。但并不会以异步的方式将线程启动，换句话说就是并不会去开启一个新的线程。其可以单独执行，也**可以重复执行**。

###   wait()、notify()

wait()、notify()、notifyAll()是三个定义在Object类里的方法，可以用来控制线程的状态。

**注意：一定要在线程同步中使用,并且是同一个锁的资源**

wait和notify方法例子，打开关闭开关：

```java
public class WaitNotify {

    static boolean flag = false;
    static Object lock = new Object();


    //创建等待线程
    static class WaitThread implements Runnable{

        @Override
        public void run() {
            synchronized (lock){
                while (!flag){
                    //条件不满足，进入等待
                    System.out.println(Thread.currentThread().getName()+" flag is false,waiting");
                    try {
                        lock.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }

                //条件满足，退出等待
                System.out.println(Thread.currentThread().getName()+" flag is true");
            }
        }
    }

    static class NotifyThread implements Runnable{

        @Override
        public void run() {
            synchronized (lock){
                System.out.println(Thread.currentThread().getName()+" hold lock");
                lock.notify();
                flag=true;

                try {
                    TimeUnit.SECONDS.sleep(5);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        new Thread(new WaitThread(),"wait").start();
        TimeUnit.SECONDS.sleep(1);
        new Thread(new NotifyThread(),"notify").start();
    }


}
```

![image-20200727175738217](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200727175738217.png)

1）WaitThread首先获取对象锁。

2）WaitThread调用对象的wait()方法，放弃锁并进入对象的等待队列WaitQueue，进行**等待状态**。

3）由于WaitThread释放了对象锁，NotifyThread随机获取对象锁。

4）NotifyThread获取对象锁成功后，调用notify()或notifyAll()，将WaitThread从等待队列WaitQueue移到同步队列

SynchronizedQueue，此时WaitThread为**阻塞状态**。

5）NotifyThread释放锁后，WaitThread再次获取锁并从wait()方法继续执行。

####   等待通知范式

​	多线程的等待通知是一道非常常见的面试题，常见于笔试中。对于等待通知来说，需要有生产者（通知方）与消费者（等待方）

等待方：

- 获取对象锁。
- 如果条件不满足，那么调用对象的wait方法，被通知后仍要检查条件。
- 条件满足则执行对应逻辑。

```java
synchronized(对象){
    while(条件不满足){
        对象.wait();
    }
    条件满足，执行业务逻辑。
}
```

通知方：

- 获取对象锁。
- 改变条件。
- 通知等待在该对象上的线程。

```java
synchronized(对象){
    改变条件
    对象.notify()
}
```

###  wait与sleep区别

* 对于sleep()方法，首先要知道该方法是属于Thread类中的。而wait()方法，则是属于Object类中的。

* sleep()方法导致了程序暂停执行指定的时间，让出cpu调度其他线程，但是他的监控状态依然保持者，当指定的时间到了又会自动恢复运行状态。

  wait()是把控制权交出去，然后进入等待此对象的等待锁定池处于等待状态，只有针对此对象调用notify()方法后本线程才进入对象锁定池准备获取对象锁进入运行状态。

* 在调用sleep()方法的过程中，线程不会释放锁。而当调用wait()方法的时候，线程会释放锁。

###   理解yield()

​	当某个线程调用了这个方法后，该线程立即释放自己持有的时间片。线程会进入到就绪状态，同时CPU会重新选择一个线程赋予时间分片，但注意，调用了这个方法的线程，也有可能被CPU再次选中赋予执行。

​	而且**该方法不会释放锁**。 如需释放锁的话，可以在调用该方法前自己手动释放。

```java
public class YieldDemo {


    static class MyThread implements Runnable{

        @Override
        public void run() {

            for (int i = 0; i < 10; i++) {

                System.out.println(Thread.currentThread().getName()+" : "+i);

                if (i == 5){

                    System.out.println(Thread.currentThread().getName());
                    Thread.yield();
                }
            }
        }
    }

    public static void main(String[] args) {

        new Thread(new MyThread()).start();
        new Thread(new MyThread()).start();
        new Thread(new MyThread()).start();
    }
}
```

从结果看出，当调用了该方法后线程会让出自己的时间分片，但也有可能被再次选中执行。

```
Thread-3 0
Thread-1 0
Thread-5 0
Thread-5 1
Thread-5 2
Thread-5 3
Thread-5 4
Thread-5 5
Thread-5
Thread-1 1
Thread-1 2
Thread-1 3
Thread-1 4
Thread-1 5
Thread-1
Thread-1 6
Thread-1 7
Thread-1 8
Thread-1 9
Thread-3 1
Thread-3 2
Thread-3 3
Thread-3 4
Thread-3 5
Thread-3
Thread-5 6
Thread-5 7
Thread-5 8
Thread-5 9
Thread-3 6
Thread-3 7
Thread-3 8
Thread-3 9
```

###   理解join()

​	该方法的使用，在实际开发中，应用的是比较少的。但在面试中，常常伴随着产生一个问题，如何保证线程的执行顺序？ 就可以通过该方法来设置。

####   使用

​	当线程调用了该方法后，线程状态会从就绪状态进入到运行状态。

```java
public class JoinDemo {

    private static class MyThread extends Thread{

        int i;
        Thread previousThread; //上一个线程

        public MyThread(Thread previousThread,int i){
            this.previousThread=previousThread;
            this.i=i;
        }

        @Override
        public void run() {
            //调用上一个线程的join方法. 不使用join方法解决是不确定的
            //previousThread.join();
            System.out.println("num:"+i);
        }
    }

    public static void main(String[] args) {

        Thread previousThread=Thread.currentThread();

        for(int i=0;i<10;i++){
            //每一个线程实现都持有前一个线程的引用。
            MyThread joinDemo=new MyThread(previousThread,i);
            joinDemo.start();
            previousThread=joinDemo;
        }
    }
}
```

```
num:0
num:2
num:3
num:6
num:7
num:1
num:5
num:9
num:8
num:4
```

可以等到开启了join之后，结果就是有序的了。

```
num:0
num:1
num:2
num:3
num:4
num:5
num:6
num:7
num:8
num:9
```

根据结果可以看到，当前线程需要等待previousThread线程终止之后才从thread.join返回。可以理解为，线程会在join处等待。

####  原理剖析

```java
public final void join() throws InterruptedException {
    join(0);
}
...
    public final synchronized void join(long millis) throws InterruptedException {
    long base = System.currentTimeMillis();
    long now = 0;
    if (millis < 0) {
        throw new IllegalArgumentException("timeout value is negative");
    }
    //判断是否携带阻塞的超时时间，等于0表示没有设置超时时间
    if (millis == 0) { 
        //isAlive获取线程状态，无限等待直到previousThread线程结束
        while (isAlive()) {
            //调用Object中的wait方法实现线程的阻塞
            wait(0); 
        }
    } else { //阻塞直到超时
        while (isAlive()) { 
            long delay = millis - now;
            if (delay <= 0) {
                break;
            }
            wait(delay);
            now = System.currentTimeMillis() - base;
        }
    }
}
```

​	可以看到该方法是被synchronized修饰的，因为在其内部对于线程阻塞的实现，是通过Object中wait方法实现的，而要调用wait()，则必须添加synchronized。

​	总的来说，Thread.join其实底层是通过wait/notifyall来实现线程的通信达到线程阻塞的目的；当线程执行结束以后，会触发两个事情，第一个是设置native线程对象为null、第二个是通过notifyall方法，让等待在previousThread对象锁上的wait方法被唤醒。

##   线程优先级

​	操作对于线程执行，是通过CPU时间片来调用运行的。那么一个线程被分配的时间片的多少，就决定了其使用资源的多少。而线程优先级就是决定线程需要能够使用资源多少的线程属性。

​	线程优先级的**范围是1~10**。一个线程的**默认优先级是5**，可以在构建线程时，通过**setPriority()**修改该线程的优先级。优先级高的线程分配时间片的数量会高于优先级低的线程。

​	一般来说对于频繁阻塞的线程需要设置优先级高点，而偏重计算的线程优先级会设置低些，确保处理器不会被独占。

​	但**注意，线程优先级不能作为线程执行正确性的依赖，因为不同的操作系统可能会忽略优先级的设置。**

##  守护线程

​	守护线程是一种支持型的线程，我们之前创建的线程都可以称之为用户线程。通过守护线程可以完成一些支持性的工作，如GC、分布式锁续期。守护线程会伴随着用户线程的结束而结束。

​	对于守护线程的创建，可以通过setDaemon()设置。

```java
public class DaemonDemo {

    private static class MyThread implements Runnable{

        @Override
        public void run() {

            while (true){

              System.out.println(Thread.currentThread().getName());
            }
        }
    }


    public static void main(String[] args) throws InterruptedException {

        Thread thread = new Thread(new MyThread());
        //设置守护线程
        thread.setDaemon(true);
        thread.start();
        TimeUnit.SECONDS.sleep(2);
    }
}
```

​	当线程实例没有被设置为守护线程时，该线程并不会随着主线程的结束而结束。但是当被设置为守护线程后，当主线程结束，该线程也会伴随着结束。同时守护线程**不一定**会执行finally代码块。所以当线程被设定为守护线程后，无法确保清理资源等操作一定会被执行。

##  线程状态

​	理解了上述方法后，再来看一下这些对于线程状态转换能起到什么样的影响。

![image-20200723221434772](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723221434772.png)



​	
