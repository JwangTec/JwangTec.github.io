​---
title: Java并发编程06--显示锁(XXXLock)
categories: Java并发编程
tags:
	- Lock
top: 10
date: 2019-08-02 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc2.jpeg)

​<!--more-->


##  基础介绍

​	在程序中可以通过synchronized实现锁功能，对于它可以称为内置锁，是由Java语言层面直接为我们提供使用的。可以在程序中隐式的获取锁。但是对于它的使用方式是固化的，只能先获取再释放。而且在使用的过程中，当一个线程获取到某个资源的锁后，其他线程再要获取该资源则必须要进行等待。synchronized并没有提供中断或超时获取的操作。

​	为了解决这些问题，所以才出现了显示锁。在显示锁中其提供了三个很常见方法：lock()、unLock()、tryLock()。
​


![image-20200729114736511](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729114736511.png)

Lock的标准用法

```java
//加锁
lock.lock();
//业务逻辑
try{
    i++;
}finally{
    //解锁
    lock.unLock();
}
```

​	不要将获取锁的过程写在try中，因为如果在获取锁时发生异常，异常抛出的同时会导致锁的释放。

​	在 finally 块中释放锁，目的是保证在获取到锁之后，最终能够被释放。

##   何时选择用synchronized还是Lock

​	如果在锁的使用过程中，不需要考虑尝试取锁或锁中断的这些特性的话。尽量使用synchronized。因为synchronized在现在的JDK中对于synchronized的优化是很多的。如锁优化升级。

​	同时synchronized要比显示锁的内存消耗要少。为什么呢？ 因为synchronized是一个语言层面的内容，而lock是一个接口，在使用Lock时需要获取其对象实例后才能进行操作。特别在锁很多的情况下，如没特殊需求，建议使用synchronized。

##   ReentrantLock

###  标准使用方式

​	根据源码可知Lock本身是一个接口，那么对于其实现类来说，最常用的就是ReentrantLock。

![image-20200729141310930](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729141310930.png)

​	那么ReentrantLock应该如何来使用呢？ 其实很简单，只要遵循使用规范即可。

```java
//通过两个线程对value进行count次自增
public class LockTest extends Thread{

    private static int count = 100000;
    private static int value = 0;

    private static Lock lock = new ReentrantLock();

    @Override
    public void run() {

        for (int i = 0; i < count; i++) {
            lock.lock();
            try {
                System.out.println(Thread.currentThread().getName()+" : "+value);
                value++;
            }finally {
                lock.unlock();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        LockTest l1 = new LockTest();
        LockTest l2 = new LockTest();

        l1.start();
        l2.start();
        TimeUnit.SECONDS.sleep(5);
        System.out.println(value);
    }
}
```

​	在加锁时务必要注意，对于解锁需要在finally中执行，因为在执行业务逻辑时，有可能出现异常，导致锁无法被释放。

​	而synchronized的使用要么作用在方法，要么作用在语句块。当出现异常后，代表脱离了执行的代码块，锁自然就会被释放。而显示锁本身是一个对象的实例，如果加锁后，没有进行释放的话，那么锁就会一直存在。

###  可重入

​	ReentrantLock一般会把它称之为**可重入锁**，其是一种递归无阻塞的同步机制。它可以等同于synchronized的使用，但是ReentrantLock提供了比synchronized更强大、灵活的锁机制，可以减少死锁发生的概率。

​	简单来说就是：**同一个线程对于已经获取的锁，可以多次继续申请到该锁的使用权**。而 synchronized 关键字隐式的支持重进入，比如一个 synchronized修饰的递归方法，在方法执行时，执行线程在获取了锁之后仍能连续多次地获得
该锁。ReentrantLock 在调用 lock()方法时，已经获取到锁的线程，能够再次调用lock()方法获取锁而不被阻塞。

​	其内部实现流程为：

1. 每个锁关联一个线程持有者和计数器，当计数器为0时表示该锁没有被任何线程持有，那么线程都会可能获得该锁而调用对应方法。
2. 当某个线程请求成功后，JVM会记录锁的持有线程，并将计数器置为1，此时其他线程请求获取锁，则必须等待。
3. 当持有锁的线程如果再次请求这个锁，就可以再次拿到这个锁，同时计数器递增。
4. 当持有锁的线程退出同步代码块时，计数器递减，如果计数器为0，则释放该锁。

**synchronized可重入**

```java
public class SynDemo {

    public static synchronized void lock1(){
        System.out.println("lock1");
        lock2();
    }

    public static synchronized void lock2(){
        System.out.println("lock2");
    }
    
    public static void main(String[] args) {
        new Thread(){
            @Override
            public void run() {
                lock1();
            }
        }.start();
    }
}
```

执行结果

```
lock1
lock2
```

根据执行结果可以看到，当同一个线程调用多个同步方法时，当其第一次获取锁成功时，接着调用其他同步方法时，仍然可以继续向下调用，不会发生阻塞。实现了锁的可重入。

**ReentrantLock可重入**

```java
public class ReentrantTest {

    private static Lock lock = new ReentrantLock();
    private static int count = 0;

    public static int getCount() {
        return count;
    }

    public void test1(){
        lock.lock();
        try {
            count++;
            test2();
        }finally {
            lock.unlock();
        }
    }

    public void test2(){
        lock.lock();
        try {
            count++;
        }finally {
            lock.unlock();
        }
    }

    static class MyThread implements Runnable{

        private ReentrantTest reentrantTest;

        public MyThread(ReentrantTest reentrantTest) {
            this.reentrantTest = reentrantTest;
        }

        @Override
        public void run() {
            for (int i = 0; i < 10000; i++) {
                reentrantTest.test1();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        ReentrantTest reentrantTest = new ReentrantTest();
        new Thread(new MyThread(reentrantTest)).start();
        TimeUnit.SECONDS.sleep(2);
        System.out.println(count);
    }
}
```

​	运行可以发现，虽然进行了多次加锁，但是并没有被阻塞。代表其也是支持可重入的。

###   公平锁与非公平锁

####   原理

​	在多线程并发执行中，当有多个线程同时来获取同一把锁，如果是按照谁等待时间最长，谁先获取锁，则代表这是一把公平锁。反之如果是随机获取的话，CPU时间片轮询到哪个线程，哪个线程就获取锁，则代表这是一把非公平锁。

​	那么公平锁和非公平锁哪个性能最好呢？ 答案是非公平锁的性能更好，因为其充分利用了CPU，减少了线程唤醒的上下文切换的时间。

![image-20200729154422765](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729154422765.png)

公平锁

![image-20200729154633299](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729154633299.png)

非公平锁

![image-20200729154821354](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729154821354.png)

####   代码实现

在ReentrantLock和synchronized中，默认都为非公平锁。ReentrantLock可以通过参数将其开启使用公平锁。

![image-20200729160508082](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729160508082.png)

**1）ReentrantLock公平锁**

```java
public class FairLockTest {

    //开启公平锁
    private static Lock lock = new ReentrantLock(true);

    public static void test(){

        for (int i = 0; i < 2; i++) {
            lock.lock();
            try {
                System.out.println(Thread.currentThread().getName()+"获取到锁");
                TimeUnit.MILLISECONDS.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }
    }

    public static void main(String[] args) {
        new Thread("线程A"){
            @Override
            public void run() {
                test();
            }
        }.start();

        new Thread("线程B"){
            @Override
            public void run() {
                test();
            }
        }.start();
    }
}
```

​	根据结果可以看到，其获取锁的过程是按照公平策略来进行。

**2）ReentrantLock非公平锁**

​	只需要在实例化ReentrantLock时，不传入参数即为非公平锁。 根据执行结果可以看到，是按照非公平策略来进行锁的获取。

###  ReentrantLock与synchronized的比较

**相似点：**

​	都是以阻塞性方式进行加锁同步，也就是说如果当一个线程获得了对象锁，执行同步代码块，则其他线程要访问都要阻塞等待，直到获取锁的线程释放锁才能继续获取锁。

**不同点：**

- 对于Synchronized来说，它是java语言的关键字，是原生语法层面的互斥，需要jvm实现。而ReentrantLock它是JDK 1.5之后提供的API层面的互斥锁，需要lock()和unlock()方法配合try/finally语句块来完成。
- Synchronized的使用比较方便简洁，并且由编译器去保证锁的加锁和释放，而ReenTrantLock需要手工声明来加锁和释放锁，为了避免忘记手工释放锁造成死锁，所以最好在finally中声明释放锁。
- ReenTrantLock的锁粒度和灵活度要优于Synchronized。

##   ReentrantReadWriteLock

​	对于之前学习的ReentrantLock或synchronized都可以称之为**独占锁、排他锁**，可以理解为是悲观锁，这些锁在同一时刻只允许一个线程进行访问。但是对于互联网应用来说，绝大多数的场景都是读多写少，比例大概在10：1。按照数据库的场景来说，对于读多写少的处理，就会进行读写分离。

​	**在读多写少的场景下**，对于业务代码的处理，此时也可以考虑进行读写分别加锁的操作，此时就可以使用**ReentrantReadWriteLock**。其对ReadWriteLock接口进行实现，内部会维护一对锁，分别为读锁、写锁。

![image-20200729161746584](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729161746584.png)

###   读写锁特性

1. 读操作不互斥，写操作互斥，读和写互斥。
2. 公平性：支持公平性和非公平性。
3. 重入性：支持锁重入。
4. 锁降级：写锁能够降级成为读锁，遵循获取写锁、获取读锁在释放写锁的次序。读锁不能升级为写锁。

###  读写锁实现原理

​	ReentrantReadWriteLock实现接口ReadWriteLock，该接口维护了一对相关的锁，一个用于读操作，另一个用于写入操作。

![image-20200729165051019](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729165051019.png)

​	ReadWriteLock定义了两个方法。readLock()返回用于读操作的锁，writeLock()返回用于写操作的锁。ReentrantReadWriteLock定义如下：

![image-20200729165201591](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729165201591.png)

​	其内部的writeLock()用于获取写锁，readLock()用于获取读锁。

###  读写锁演示

​	读写锁的特点在于写互斥、读不互斥、读写互斥。下面就通过例子来演示具体效果：

```java
public class ReentrantReadWriteLockDemo {

    private static int count = 0;

    private static class WriteDemo implements Runnable{

        ReentrantReadWriteLock lock ;

        public WriteDemo(ReentrantReadWriteLock lock) {
            this.lock = lock;
        }

        @Override
        public void run() {
            for (int i = 0; i < 5; i++) {
                try {
                    TimeUnit.MILLISECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                lock.writeLock().lock();
                count++;
                System.out.println("写锁: "+count);
                lock.writeLock().unlock();
            }
        }
    }

    private static class ReadDemo implements Runnable{
        ReentrantReadWriteLock lock ;

        public ReadDemo(ReentrantReadWriteLock lock) {
            this.lock = lock;
        }

        @Override
        public void run() {

            try {
                TimeUnit.MILLISECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            lock.readLock().lock();
            count++;
            System.out.println("读锁: "+count);
            lock.readLock().unlock();
        }
    }

    public static void main(String[] args) {
        ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
        WriteDemo writeDemo = new WriteDemo(lock);
        ReadDemo readDemo = new ReadDemo(lock);
        //运行多个写线程，不会重复，证明写互斥
        //运行多个读线程，可能重复，证明读不互斥
        //同时运行，读锁和写锁后面不会出现重复的数字，证明读写互斥
        for (int i = 0; i < 3; i++) {
            new Thread(writeDemo).start();
        }
        for (int i = 0; i < 3; i++) {
            new Thread(readDemo).start();
        }
    }
}
```

###   锁降级

​	读写锁是支持锁降级的，但不支持锁升级。写锁可以被降级为读锁，但读锁不能被升级写锁。什么意思呢？简单来说就是**获取到了写锁的线程能够再次获取到同一把锁的读锁**，因为支持提到过ReentrantReadWriteLock这把锁内部是维护了两个锁的。 而**获取到了读锁的线程不能再次获取同一把锁的写锁**。

**1）写锁降级读锁**

```java
public class LockDegradeDemo1 {

    private static class Demo{

        ReentrantReadWriteLock lock = new ReentrantReadWriteLock();

        public void fun1(){
            //获取写锁
            lock.writeLock().lock();
            System.out.println("fun1");
            fun2();
            lock.writeLock().unlock();
        }

        public void fun2(){
            //获取读锁
            lock.readLock().lock();
            System.out.println("fun2");
            lock.readLock().unlock();

        }
    }

    public static void main(String[] args) {

        new Demo().fun1();
    }
}
```

​	根据执行结果可知，当一个线程获取到了写锁后，其可以继续向下来获取同一把锁的读锁。

**2）读锁升级写锁**

```java
public class LockDegradeDemo2 {

    private static class Demo{

        ReentrantReadWriteLock lock = new ReentrantReadWriteLock();

        public void fun1(){
            //获取写锁
            lock.writeLock().lock();
            System.out.println("fun1");
            //fun2();
            lock.writeLock().unlock();
        }

        public void fun2(){
            //获取读锁
            lock.readLock().lock();
            System.out.println("fun2");
            fun1();
            lock.readLock().unlock();

        }
    }

    public static void main(String[] args) {

        new Demo().fun2();
    }
}
```

​	根据执行结果可知。当线程获取到读锁，不能继续获取写锁。

###   性能优化演示

​	在读多写少的情况下，通过读写锁可以优化原有的synchronized对于程序执行的性能。

```java
public class Sku {

    private String name;
    private double totalMoney;//总销售额
    private int storeNumber;//库存数

    public Sku(String name, double totalMoney, int storeNumber) {
        this.name = name;
        this.totalMoney = totalMoney;
        this.storeNumber = storeNumber;
    }

    public double getTotalMoney() {
        return totalMoney;
    }

    public int getStoreNumber() {
        return storeNumber;
    }

    public void changeNumber(int sellNumber){
        this.totalMoney += sellNumber*25;
        this.storeNumber -= sellNumber;
    }
}
```

```java
public interface SkuService {

    //获得商品的信息
    Sku getSkuInfo();

    //设置商品的数量
    void setNum(int number);
}
```

以synchronized形式运行

```java
public class SkuServiceImplSync implements SkuService{

    private Sku sku;

    public SkuServiceImplSync(Sku sku) {
        this.sku = sku;
    }

    @Override
    public synchronized Sku getSkuInfo() {
        try {
            TimeUnit.MILLISECONDS.sleep(5);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return this.sku;
    }

    @Override
    public synchronized void setNum(int number) {
        try {
            TimeUnit.MILLISECONDS.sleep(5);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        sku.changeNumber(number);
    }
}
```



```java
public class SkuExec {

    //读写线程的比例
    static final int readWriteRatio = 10;

    //最少线程数
    static final int minthreadCount = 3;

    //读操作
    private static class ReadThread implements Runnable{

        private SkuService skuService;

        public ReadThread(SkuService skuService) {
            this.skuService = skuService;
        }

        @Override
        public void run() {
            long start = System.currentTimeMillis();
            for (int i = 0; i < 100; i++) {
                skuService.getSkuInfo();
            }
            System.out.println(Thread.currentThread().getName()+"读取商品数据耗时："
                               +(System.currentTimeMillis()-start)+"ms");
        }
    }

    //写操作
    private static class WriteThread implements Runnable{

        private SkuService skuService;

        public WriteThread(SkuService skuService) {
            this.skuService = skuService;
        }

        @Override
        public void run() {
            long start = System.currentTimeMillis();
            Random r = new Random();
            for(int i=0;i<10;i++){//操作10次
                skuService.setNum(r.nextInt(10));
            }
            System.out.println(Thread.currentThread().getName()
                               +"写商品数据耗时："+(System.currentTimeMillis()-start)+"ms---------");
        }
    }

    public static void main(String[] args) throws InterruptedException {
        Sku sku = new Sku("computer",10000,10000);
        SkuService skuService = new SkuServiceImplSync(sku);

        for(int i = 0;i<minthreadCount;i++){

            Thread setT = new Thread(new WriteThread(skuService));

            for(int j=0;j<readWriteRatio;j++) {
                Thread getT = new Thread(new ReadThread(skuService));
                getT.start();
            }

            TimeUnit.MILLISECONDS.sleep(100);
            setT.start();
        }
    }
}
```

执行结果

```
Thread-0写商品数据耗时：58ms---------
Thread-11写商品数据耗时：58ms---------
Thread-22写商品数据耗时：58ms---------
Thread-4读取商品数据耗时：2577ms
Thread-5读取商品数据耗时：3029ms
Thread-6读取商品数据耗时：3040ms
Thread-9读取商品数据耗时：4016ms
Thread-29读取商品数据耗时：4980ms
Thread-15读取商品数据耗时：8971ms
Thread-13读取商品数据耗时：9742ms
Thread-18读取商品数据耗时：10257ms
Thread-19读取商品数据耗时：10417ms
Thread-25读取商品数据耗时：10805ms
Thread-26读取商品数据耗时：11250ms
Thread-27读取商品数据耗时：11645ms
Thread-31读取商品数据耗时：12137ms
Thread-3读取商品数据耗时：13257ms
Thread-7读取商品数据耗时：13714ms
Thread-10读取商品数据耗时：13911ms
Thread-32读取商品数据耗时：13730ms
Thread-28读取商品数据耗时：14101ms
Thread-23读取商品数据耗时：14409ms
Thread-1读取商品数据耗时：14808ms
Thread-20读取商品数据耗时：14986ms
Thread-17读取商品数据耗时：15150ms
Thread-14读取商品数据耗时：15691ms
Thread-16读取商品数据耗时：16312ms
Thread-21读取商品数据耗时：16494ms
Thread-24读取商品数据耗时：16514ms
Thread-30读取商品数据耗时：16637ms
Thread-8读取商品数据耗时：16867ms
Thread-2读取商品数据耗时：16982ms
Thread-12读取商品数据耗时：16986ms
```

**以ReentrantReadWriteLock形式执行**

```java
public class SkuServiceImplReen implements SkuService{

    private Sku sku;

    public SkuServiceImplReen(Sku sku) {
        this.sku = sku;
    }

    private ReadWriteLock lock = new ReentrantReadWriteLock();
    private Lock readLock = lock.readLock();
    private Lock writeLock = lock.writeLock();

    @Override
    public Sku getSkuInfo() {
        readLock.lock();
        try {
            TimeUnit.MILLISECONDS.sleep(5);
            return this.sku;
        } catch (InterruptedException e) {
            e.printStackTrace();
            return null;
        } finally {
            readLock.unlock();
        }

    }

    @Override
    public  void setNum(int number) {
        writeLock.lock();
        try {
            TimeUnit.MILLISECONDS.sleep(5);
            sku.changeNumber(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            writeLock.unlock();
        }
    }
}
```

修改启动类

```java
SkuService skuService = new SkuServiceImplReen(sku);
```

执行结果

```
Thread-0写商品数据耗时：66ms---------
Thread-11写商品数据耗时：68ms---------
Thread-22写商品数据耗时：62ms---------
Thread-2读取商品数据耗时：765ms
Thread-8读取商品数据耗时：764ms
Thread-10读取商品数据耗时：764ms
Thread-5读取商品数据耗时：765ms
Thread-1读取商品数据耗时：765ms
Thread-4读取商品数据耗时：765ms
Thread-7读取商品数据耗时：764ms
Thread-6读取商品数据耗时：764ms
Thread-3读取商品数据耗时：765ms
Thread-9读取商品数据耗时：770ms
Thread-15读取商品数据耗时：760ms
Thread-17读取商品数据耗时：760ms
Thread-12读取商品数据耗时：760ms
Thread-13读取商品数据耗时：760ms
Thread-14读取商品数据耗时：760ms
Thread-18读取商品数据耗时：759ms
Thread-16读取商品数据耗时：760ms
Thread-20读取商品数据耗时：765ms
Thread-19读取商品数据耗时：765ms
Thread-21读取商品数据耗时：765ms
Thread-31读取商品数据耗时：704ms
Thread-28读取商品数据耗时：705ms
Thread-25读取商品数据耗时：705ms
Thread-30读取商品数据耗时：704ms
Thread-29读取商品数据耗时：705ms
Thread-27读取商品数据耗时：705ms
Thread-26读取商品数据耗时：705ms
Thread-23读取商品数据耗时：705ms
Thread-24读取商品数据耗时：705ms
Thread-32读取商品数据耗时：704ms
```

​	根据最终结果可以看出，其性能的提升是非常巨大的。

##  StamptedLock

​	StampedLock类是在JDK8引入的一把新锁，其是对原有ReentrantReadWriteLock读写锁的增强，增加了一个乐观读模式，内部提供了相关API不仅优化了读锁、写锁的访问，也可以让读锁与写锁间可以互相转换，从而更细粒度的控制并发。

###   ReentrantReadWriteLock存在的问题

​	在使用读写锁时，还容易出现写线程饥饿的问题。主要是因为读锁和写锁互斥。比方说：当线程 A 持有读锁读取数据时，线程 B 要获取写锁修改数据就只能到队列里排队。此时又来了线程 C 读取数据，那么线程 C 就可以获取到读锁，而要执行写操作线程 B 就要等线程 C 释放读锁。由于该场景下读操作远远大于写的操作，此时可能会有很多线程来读取数据而获取到读锁，那么要获取写锁的线程 B 就只能一直等待下去，最终导致饥饿。

​	对于写线程饥饿问题，可以通过公平锁进行一定程度的解决，但是它是以牺牲系统吞吐量为代价的。

###  StampedLock特点

1）获取锁的方法，会返回一个票据（stamp），当该值为0代表获取锁失败，其他值都代表成功。

2）释放锁的方法，都需要传递获取锁时返回的票据，从而控制是同一把锁。

3）StampedLock是**不可重入的**，如果一个线程已经持有了写锁，再去获取写锁就会造成死锁。

4）StampedLock提供了三种模式控制读写操作：写锁、悲观读锁、乐观读锁

```
写锁：
	使用类似于ReentrantReadWriteLock，是一把独占锁，当一个线程获取该锁后，其他请求线程会阻塞等待。 对于一条数据没有线程持有写锁或悲观读锁时，才可以获取到写锁，获取成功后会返回一个票据，当释放写锁时，需要传递获取锁时得到的票据。
```

```
悲观读锁：
	使用类似于ReentrantReadWriteLock，是一把共享锁，多个线程可以同时持有该锁。当一个数据没有线程获取写锁的情况下，多个线程可以同时获取到悲观读锁，当获取到后会返回一个票据，并且阻塞线程获取写锁。当释放锁时，需要传递获取锁时得到的票据。
```

```
乐观读锁：
	这把锁是StampedLock新增加的。可以把它理解为是一个悲观锁的弱化版。当没有线程持有写锁时，可以获取乐观读锁，并且返回一个票据。值得注意的是，它认为在获取到乐观读锁后，数据不会发生修改，获取到乐观读锁后，其并不会阻塞写入的操作。
	那这样的话，它是如何保证数据一致性的呢？ 乐观读锁在获取票据时，会将需要的数据拷贝一份，在真正读取数据时，会调用StampedLock中的API，验证票据是否有效。如果在获取到票据到使用数据这期间，有线程获取到了写锁并修改数据的话，则票据就会失效。 如果验证票据有效性时，当返回true，代表票据仍有效，数据没有被修改过，则直接读取原有数据。当返回flase，代表票据失效，数据被修改过，则重新拷贝最新数据使用。
	乐观读锁使用与一些很短的只读代码，它可以降低线程之间的锁竞争，从而提高系统吞吐量。但对于读锁获取数据结果必须要进行校验。
```

5）在StampedLock中读锁和写锁可以相互转换，而在ReentrantReadWriteLock中，写锁可以降级为读锁，而读锁不能升级为写锁。

###   使用示例

此处引用Oracle官方案例。https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/locks/StampedLock.html

```java
class Point {

    //定义共享数据
    private double x, y;

    //实例化锁
    private final StampedLock sl = new StampedLock();

    //写锁案例
    void move(double deltaX, double deltaY) { 

        //获取写锁
        long stamp = sl.writeLock();

        try {
            x += deltaX;
            y += deltaY;
        } finally {
            //释放写锁
            sl.unlockWrite(stamp);
        }
    }

    //使用乐观读锁案例
    double distanceFromOrigin() { 

        long stamp = sl.tryOptimisticRead(); //获得一个乐观读锁

        double currentX = x, currentY = y; //将两个字段读入本地局部变量

        if (!sl.validate(stamp)) { //检查发出乐观读锁后同时是否有其他写锁发生？

            stamp = sl.readLock(); //如果有，我们再次获得一个读悲观锁
            try {
                currentX = x; // 将两个字段读入本地局部变量
                currentY = y; // 将两个字段读入本地局部变量
            } finally {
                sl.unlockRead(stamp);
            }
        }
        return Math.sqrt(currentX * currentX + currentY * currentY);
    }

    //使用悲观读锁并锁升级案例
    void moveIfAtOrigin(double newX, double newY) {

        // 获取悲观读锁
        long stamp = sl.readLock();

        try {
            while (x == 0.0 && y == 0.0) { //循环，检查当前状态是否符合

                //锁升级，将读锁转为写锁
                long ws = sl.tryConvertToWriteLock(stamp); 

                //确认转为写锁是否成功
                if (ws != 0L) { 
                    stamp = ws; //如果成功 替换票据
                    x = newX; //进行状态改变
                    y = newY; //进行状态改变
                    break;
                }
                else { //如果不成功
                    sl.unlockRead(stamp); //显式释放读锁
                    stamp = sl.writeLock(); //显式直接进行写锁 然后再通过循环再试
                }
            }
        } finally {
            //释放读锁或写锁
            sl.unlock(stamp); 
        }
    }
}
```



