---
title: Java并发编程02--synchronized
categories: Java并发编程
tags:
  - synchronized
top: 10
abbrlink: 3357090801
date: 2019-08-01 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc.jpeg" width="1000" height="200" align="middle" />



##  synchronized基本使用 

​	对于线程来说，如果多个线程只是相互间单独执行的话，本身是没有太大意义的，一般来说，都是需要多个线程，相互间协作来进行工作的，这样使用，才会对系统带来实际的意义。

<!--more-->

​	在Java中支持多个线程同时访问一个对象或对象中的成员变量，但是如果没有任何保护机制的话，就会出现数据不一致的情况，效果如下：

```java
public class SyncTest {

    private long count = 0;

    public long getCount() {
        return count;
    }

    public void setCount(long count) {
        this.count = count;
    }

    public void incrCount(){
        count++;
    }

    private static class MyThread extends Thread{

        SyncTest syncTest;

        public MyThread(SyncTest syncTest) {
            this.syncTest = syncTest;
        }

        @Override
        public void run() {

            for (int i = 0; i < 10000; i++) {
                syncTest.incrCount();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        SyncTest syncTest = new SyncTest();

        Thread thread1 = new Thread(new MyThread(syncTest));
        Thread thread2 = new Thread(new MyThread(syncTest));

        thread1.start();
        thread2.start();

        TimeUnit.SECONDS.sleep(1);

        System.out.println(syncTest.getCount());
    }
}
```

​	根据结果可以，预计结果值是两万，但是并没有达到期望的效果。

​	现在要解决这个问题的话，就可以使用锁来进行解决。synchronized可以修饰方法或者以同步块的形式来进行使用，它主要确保多个线程在同一个时刻，只能有一个线程处于方法或者同步块中，它保证了线程对变量访问的可见性和排他性，又称为内置锁机制。

​	简单来说就像吃饭一样很多人一起来抢，我可能抢不到，但是我加了把锁，我进去先锁上门，等我吃完了，打开门，其他的人才能进来，synchronized 就是java多线程中的那把锁。

​	对于synchronized，可以把其加在方法上或者类上，或者添加同步代码块。演示效果如下

```java
//添加在方法上
public synchronized void incrCount1(){
    count++;
}
```

```java
//添加同步代码块
//需要声明一个锁对象
//作为锁对象
private Object object = new Object();

public void incrCount2(){
    synchronized (object){
        count++;
    }
}
```

​	这两种方式都可以保证，当前操作是加锁的，这样的话，在多线程下，只有等到获取到锁的线程将锁释放掉后，下一个线程才能持有锁。通过这种机制，来保证数据的一致性。

​	这种操作方式也可以叫做**对象锁**。但是如果现在通过synchronized锁定的是不同的两个对象的话，还能够保证锁的有效吗？ 这就一定不能了，因为多个线程持有的对象锁是不同的话，这样的话，是没有意义的，线程间仍然是可以并行执行的，使用效果如下：

```java
public class DiffInstance {

    private static class InstanceSyn implements Runnable{
        private DiffInstance diffInstance;

        public InstanceSyn(DiffInstance diffInstance) {
            this.diffInstance = diffInstance;
        }

        @Override
        public void run() {
            System.out.println("TestInstance is running..."+ diffInstance);
            diffInstance.instance();
        }
    }

    private static class Instance2Syn implements Runnable{
        private DiffInstance diffInstance;

        public Instance2Syn(DiffInstance diffInstance) {
            this.diffInstance = diffInstance;
        }
        @Override
        public void run() {
            System.out.println("TestInstance2 is running..."+ diffInstance);
            diffInstance.instance2();
        }
    }

    private synchronized void instance(){
        try {
            TimeUnit.SECONDS.sleep(3);
            System.out.println("synInstance is going..."+this.toString());
            TimeUnit.SECONDS.sleep(3);
            System.out.println("synInstance ended "+this.toString());
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    private synchronized void instance2(){
        try {
            TimeUnit.SECONDS.sleep(3);
            System.out.println("synInstance2 is going..."+this.toString());
            TimeUnit.SECONDS.sleep(3);
            System.out.println("synInstance2 ended "+this.toString());
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    public static void main(String[] args) throws InterruptedException {
        DiffInstance instance1 = new DiffInstance();
        Thread t3 = new Thread(new Instance2Syn(instance1));

        DiffInstance instance2 = new DiffInstance();
        Thread t4 = new Thread(new InstanceSyn(instance1));
        //Thread t4 = new Thread(new InstanceSyn(instance2));
        t3.start();
        t4.start();
        TimeUnit.SECONDS.sleep(1);
    }
}
```

​	对于synchronized，也可以加载类上进行使用。此时可以把它称为**类锁**。此时加锁的就是一个class对象了。

​	但是有一点必须注意的是，其实类锁只是一个概念上的东西，并不是真实存在的，类锁其实锁的是每个类的对应的class对象。类锁和对象锁之间也是互不干扰的。

```java
private static synchronized void synClass(){
    System.out.println(Thread.currentThread().getName()
                       +"synClass going...");
    SleepTools.second(1);
    System.out.println(Thread.currentThread().getName()
                       +"synClass end");
}
```

在使用synchronized时，建议锁定的范围，越小越好。否则的话，容易造成大量资源被锁定。

##   synchronized错误加锁问题

```java
public class ErrorSyncTest {

    private static class MyThread implements Runnable{

        private Integer i;

        public MyThread(Integer i) {
            this.i = i;
        }

        @Override
        public void run() {

            synchronized (i){
                i++;
                System.out.println(i);
                try {
                    TimeUnit.MILLISECONDS.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void main(String[] args) {

        MyThread myThread = new MyThread(1);
        for (int i = 0; i < 10; i++) {
            new Thread(myThread).start();
        }
    }
}
```

​	根据上述效果可以看到，在多线程执行时，虽然添加了锁，但是仍然不能保证数据的正确性，这是因为什么呢？ 这里主要是因为在执行i++时，其内部是重新新建了一个对象。导致锁定对象出现了不一致。只要让它保证是锁定的同一个对象即可。

##   synchronized实现原理

​	很多人对于synchronized的理解都会认为它是一把重量级锁（操作需要经过操作系统）。但是从Java1.6后，已经对synchronized进行了优化改良，在一些情况下它就已经没有那么重了。

###  实现原理解析

​	当一个线程访问同步代码块时，它首先需要先获取到锁才能执行，退出或抛出异常时必须释放锁，那么其内部又是如何实现的呢？

```java
public class SynchronizedTest {
    public void test2() {
        synchronized (this) {

        }
    }
}
```

利用javap工具查看生成的class文件信息来分析Synchronize的实现

![image-20200723223047596](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723223047596.png)

从上述内容可以看出，同步代码块是使用**monitorenter**和**monitorexit**指令实现的。而同步方法是使用另外一种方式实现的，细节在JVM规范里没有详细说明。但是可以肯定的是，同步方法可以使用这两个指令来实现。

###  锁到底存在哪里&锁里面会存储什么信息

​	synchronized用的锁会保存在**Java对象头**中。那什么是Java对象头呢？

​	一个Java对象在内存中是由三部分组成的：

- 对象头
- 实例数据
- 对齐填充字节

​	如果对象不是数组类型，则JVM用2字宽存储对象头。如果是数组类型，则用3字宽存储对象头。在32位虚拟机中，1字宽等于4字节，即32bit。在64位虚拟机中，1字宽相当于8字节，即64bit。

![image-20200723223117879](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723223117879.png)

而对象头也是由三部分组成：

- MarkWord
- 类型指针
- 数组长度（只有数组对象有）

​	Mark Word用于存储对象自身的运行时数据，如哈希码（HashCode）、GC分代年龄、锁状态标志、线程持有的锁、偏向线程 ID、偏向时间戳等等。Java对象头一般占有两个机器码（在32位虚拟机中，1个机器码等于4字节，也就是32bit）。 ![image-20200727234824553](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200727234824553.png)

![image-20200727232519217](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200727232519217.png)

###   Synchronized锁优化

​	Java1.6后为了减少获得锁和释放锁而带来的性能消耗，引入了**偏向锁**和**轻量级锁**。此时锁会存在四种状态，级别从低到高分别为：**无锁、偏向锁、轻量级锁、重量级锁**。状态间的转换会随着竞争情况逐渐升级。**锁可以升级但不能降级**，如偏向锁升级为轻量级锁后不能降级为偏向锁。

![image-20200723223154992](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723223154992.png)

#### 自旋锁 

​	线程的阻塞和唤醒需要CPU从用户态转为内核态，频繁的阻塞和唤醒对CPU来说是一件负担很重的工作，势必会给系统的并发性能带来很大的压力。同时我们发现在许多应用上面，对象锁的锁状态只会持续很短一段时间，为了这一段很短的时间频繁地阻塞和唤醒线程是非常不值得的。所以引入**自旋锁**。 

​	所谓自旋锁，就是让该线程等待一段时间，不会被立即挂起，看持有锁的线程是否会很快释放锁。怎么等待呢？执行一段无意义的循环即可（自旋）。  

​	自旋等待不能替代阻塞，先不说对处理器数量的要求（多核，貌似现在没有单核的处理器了），虽然它可以避免线程切换带来的开销，但是它占用了处理器的时间。如果持有锁的线程很快就释放了锁，那么自旋的效率就非常好，反之，自旋的线程就会白白消耗掉处理的资源，它不会做任何有意义的工作，典型的占着茅坑不拉屎，这样反而会带来性能上的浪费。所以说，自旋等待的时间（自旋的次数）必须要有一个限度，如果自旋超过了定义的时间仍然没有获取到锁，则应该被挂起。

​	自旋锁在JDK1.4中引入，默认关闭，但是可以使用**-XX:+UseSpinning**开启，在JDK1.6中默认开启。同时自旋的默认次数为10次，可以通过参数**-XX:PreBlockSpin**来调整；

​	如果通过参数**-XX:preBlockSpin**来调整自旋锁的自旋次数，会带来诸多不便。假如我将参数调整为10，但是系统很多线程都是等你刚刚退出的时候就释放了锁（假如你多自旋一两次就可以获取锁），你是不是很尴尬。于是JDK1.6引入自适应的自旋锁，让虚拟机会变得越来越聪明。 

####  自适应自旋锁

​		JDK1.6引入了更加聪明的自旋锁，即**自适应自旋锁**。所谓自适应就意味着自旋的次数不再是固定的，它是由前一次在同一个锁上的自旋时间及锁的拥有者的状态来决定。它怎么做呢？线程如果自旋成功了，那么下次自旋的次数会更加多，因为虚拟机认为既然上次成功了，那么此次自旋也很有可能会再次成功，那么它就会允许自旋等待持续的次数更多。反之，如果对于某个锁，很少有自旋能够成功的，那么在以后要或者这个锁的时候自旋的次数会减少甚至省略掉自旋过程，以免浪费处理器资源。
​		有了自适应自旋锁，随着程序运行和性能监控信息的不断完善，虚拟机对程序锁的状况预测会越来越准确，虚拟机会变得越来越聪明。 

####  锁消除

 	为了保证数据的完整性，我们在进行操作时需要对这部分操作进行同步控制，但是在有些情况下，JVM检测到不可能存在共享数据竞争，这时JVM会对这些同步锁进行锁消除。

​	锁消除发生在编译阶段，通过对运行上下文的扫描，去除不可能存在共享资源竞争的锁，通过锁消除，可以节省毫无意义的请求锁时间。

```java
public class TestLockEliminate {

    public static String getString(String s1, String s2) {
        StringBuffer sb = new StringBuffer();
        sb.append(s1);
        sb.append(s2);
        return sb.toString();
    }

    public static void main(String[] args) throws InterruptedException {
        long tsStart = System.currentTimeMillis();
        for (int i = 0; i < 10000000; i++) {
            getString("TestLockEliminate ", "Suffix");
        }
        System.out.println("一共耗费：" + (System.currentTimeMillis() - tsStart) + " ms");
    }
}
```

​	已上述代码为例，运行时间大概在500毫秒。那么在运行时，其内部又发生了什么呢？可以看到当前getString()中的StringBuffer是作为方法内部的局部变量，因此它不可能被多个线程同时访问，也就没有资源竞争，但是StringBuffer的append操作却需要执行同步操作:

![image-20200728143709230](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200728143709230.png)

​	那么此时的同步锁相当于就是白白浪费系统资源。因此在编译时一旦JVM发现此种情况就会通过锁消除方式来优化性能。在JDK1.8中锁消除是自动开启的。

​	在循环中，让其每次都睡一秒，然后查看当前程序的JVM参数。`DoEscapeAnalysis,EliminateLocks`.可以发现逃逸分析和锁消除是默认开启的。

![image-20200728144049526](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200728144049526.png)

​	在程序执行时，关闭逃逸分析和锁消除。`-server -XX:-DoEscapeAnalysis -XX:-EliminateLocks`。此时可以发现程序执行时间延长了很多。

####  锁升级过程详解

#####   偏向锁

**1）加锁**

1. 当线程初次执行到synchronized代码块时，会通过自旋方式修改MarkWord的锁标志，代表锁对象为偏向锁。
2. 执行完同步代码块后，线程并不会主动释放偏向锁。
3. 当第二次执行同步代码块时，首先会判断MarkWord中的线程ID是否为当前线程。
4. 如果是，则正常往下执行同步代码块。由于之前没有释放锁，这里也就不需要重新加锁。如果自始至终使用锁的线程只有一个，很明显偏向锁几乎没有额外开销，性能极高。
5. 如果线程ID并未指向当前线程，则通过CAS操作替换MarkWork中的线程ID。如果替换成功，则执行同步代码块；如果替换失败，执行步骤6。
6. 如果CAS替换失败，则表示有竞争。当到达全局安全点（safepoint）时获得偏向锁的线程被挂起，偏向锁升级为轻量级锁，然后被阻塞在安全点的线程继续往下执行同步代码。（撤销偏向锁的时候会导致stop the word）

**2）撤销**

​	偏向锁的撤销在上述第六步中有提到。偏向锁只有遇到其他线程尝试竞争偏向锁时，持有偏向锁的线程才会释放锁，线程不会主动去释放偏向锁。偏向锁的撤销，需要等待全局安全点（在这个时间点上没有字节码正在执行），它会首先暂停拥有偏向锁的线程，判断锁对象是否处于被锁定状态，撤销偏向锁后恢复到未锁定（标志位为“01”）或轻量级锁（标志位为“00”）的状态。

![image-20200723223236539](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723223236539.png)

**3）使用场景**

​	始终只有一个线程在执行同步块，在它没有执行完释放锁之前，没有其它线程去执行同步块，在锁无竞争的情况下使用，一旦有了竞争就升级为轻量级锁，升级为轻量级锁的时候需要撤销偏向锁，撤销偏向锁的时候会导致stop the word操作； 

​	在有锁竞争时，偏向锁会多做很多额外操作，尤其是撤销偏向所的时候会导致进入安全点，安全点会导致stw，导致性能下降；

#####  轻量级锁

​	轻量级锁是由偏向锁升级来的，偏向锁运行在一个线程进入同步块的情况下，当第二个线程加入锁争用的时候，偏向锁就会升级为轻量级锁； 

**1）加锁**

1.    在进入同步代码块前，JVM会在当前线程的栈帧中创建用于存储锁记录的空间，并将对象头中的MarkWord复制到锁记录中。
2. 然后线程尝试使用自旋将对象头中的MarkWord替换为指向锁记录的指针。
3. 如果成功，当前线程获得轻量级锁，执行同步代码块。
4. 如果失败，表示其他线程竞争锁，当前线程便尝试使用自旋来获取锁。当自旋次数达到一定次数时，锁就会升级为重量级锁，并阻塞线程。

**2）解锁**

​	解锁时，会使用自旋操作将锁记录替换回到对象头，相当于做一个对比。如果成功，表示没有竞争发生；如果失败，表示当前锁存在竞争，锁已经被升级为重量级锁，会释放锁并唤醒等待的线程。

![image-20200723223256861](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723223256861.png)

`因为自旋操作是依赖于CPU的，为了避免无用的自旋操作(获得锁的线程被阻塞住了)，轻量级锁一旦升级为重量级锁，就不会再恢复到轻量级锁。当锁处于重量级锁时，其他线程试图获取锁时，都会被阻塞住。当持有锁的线程释放锁之后会唤醒其他线程再次开始竞争锁。`

#####   重量级锁

​	重量级锁通过对象内部的监视器（monitor）实现，其中monitor的本质是依赖于底层操作系统的Mutex Lock实现，操作系统实现线程之间的切换需要从用户态到内核态的切换，切换成本非常高。 

​	切换成本高的原因在于，当系统检查到是重量级锁之后，会把等待想要获取锁的线程阻塞，被阻塞的线程不会消耗CPU，但是阻塞或者唤醒一个线程，都需要通过操作系统来实现，也就是相当于从用户态转化到内核态，而转化状态是需要消耗时间的 。

​	简单来说就是：竞争失败后，线程阻塞，释放锁后，唤醒阻塞的线程，不使用自旋锁，不会那么消耗CPU，所以重量级锁适合用在同步块执行时间长的情况下。

#####   锁的优缺点对比

| 锁       | 优点                                                         | 缺点                                                         | 使用场景                                         |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------ |
| 偏向锁   | 加锁和解锁会存在CAS，没有额外的性能消耗，和执行非同步方法相比，仅存在纳秒级的差距 | 如果线程间存在锁竞争，会带来额外的锁撤销的消耗               | 只有一个线程访问同步块或者同步方法的场景         |
| 轻量级锁 | 竞争的线程不会阻塞，提高程序响应速度                         | 若线程长时间抢不到锁，自旋会消耗CPU性能                      | 追求响应时间。同步代码块执行非常快               |
| 重量级锁 | 线程竞争不使用自旋，不消耗CPU                                | 线程阻塞，响应时间缓慢,在多线程下,频繁的获取释放锁，会带来巨大的性能消耗 | 追求吞吐量，同步块或者同步方法执行时间较长的场景 |

#####   小结

**偏向锁**：在不存在多线程竞争情况下，默认会开启偏向锁。

**偏向锁升级轻量级锁**：当一个对象持有偏向锁，一旦第二个线程访问这个对象，如果产生竞争，偏向锁升级为轻量级锁。

**轻量级锁升级重量级锁**：一般两个线程对于同一个锁的操作都会错开，或者说稍微等待一下（自旋），另一个线程就会释放锁。但是当自旋超过一定的次数，或者一个线程在持有锁，一个在自旋，又有第三个来访时，轻量级锁膨胀为重量级锁，重量级锁使除了拥有锁的线程以外的线程都阻塞，防止CPU空转。

##   死锁

###   什么是死锁

​	在多线程环境中，多个线程可以竞争有限数量的资源。当一个线程申请资源时，如果这时没有可用资源，那么这个线程进入等待状态。如果所申请的资源被其他等待线程占有，那么该等待线程有可能再也无法改变状态。这种情况称为**死锁**

​	在Java中使用多线程，就会**有可能导致死锁**问题。死锁会让程序一直卡住，不再程序往下执行。我们只能通过**中止并重启**的方式来让程序重新执行。

![image-20200723230905234](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723230905234.png)

###   造成死锁的原因

- 当前线程**拥有其他线程需要的**资源
- 当前线程**等待其他线程已拥有**的资源
- **都不放弃**自己拥有的资源

### 死锁演示

​	所谓死锁是指多个线程因竞争资源而造成的一种僵局（互相等待），若无外力作用，这些进程都将无法向前推进，两个或两个以上的线程在执行过程中，因争夺资源而造成的一种互相等待的现象，若无外力作用，它们都将无法推进下去。

```java
public class DeadLock {

    private static String value1 = "a";
    private static String value2 = "b";

    public static void main(String[] args) {
        new DeadLock().deadLock();
    }

    private void deadLock() {

        Thread t1 = new Thread(()->{
            try {
                System.out.println("t1 running");
                while (true){
                    synchronized (value1){
                        System.out.println("t1 lock value1");
                        Thread.sleep(3000);//获取obj1后先等一会儿，让Lock2有足够的时间锁住obj2
                        synchronized(value2){
                            System.out.println("t1 lock value2");
                        }
                    }
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        });

        Thread t2 = new Thread(()->{
            try {
                System.out.println("t2 running");
                while (true){
                    synchronized (value2){
                        System.out.println("t2 lock value2");
                        Thread.sleep(3000);//获取obj1后先等一会儿，让Lock2有足够的时间锁住obj2
                        synchronized(value1){
                            System.out.println("t2 lock value1");
                        }
                    }
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        });

        t1.start();
        t2.start();
    }
}
```

​	这段只是用于演示死锁的效果，在实际开发中你可能不会写出这样的代码，但是，在一些复杂场景下，稍有不慎就会出现这样的问题。比方说t1拿到锁后，因为一些异常情况没有释放锁（死循环）。又或者t1释放锁时出现异常，没有释放到。 这些情况下都有可能出现死锁的问题。

###  死锁排查

​	在java程序中，死锁的出现有时是你根本无法想到的，如果不了解排查死锁的方法，就会造成线上系统性能的大幅度下降。那对于死锁应该如何排查呢？

####  通过JDK工具jps+jstack

​	jps是jdk提供的一个工具，可以查看到正在运行的java进程

![image-20200723233955136](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723233955136.png)

​	jstack也是jdk提供的工具，可以查看java进程中线程堆栈信息。

![image-20200723234108779](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723234108779.png)

![image-20200723234122006](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723234122006.png)

从输出的堆栈信息中可以发现：Found one Java-level deadLock。表示在这个程序中发现了死锁，后面的详细描述中已经指出了在22行和39行出现死锁。 那就可以根据这些信息快速定位到问题点进行优化处理。

####   通过JDK工具jconsole

​	jconsole是JDK提供的一款可视化工具，可以更加方便的排查程序问题，如：内存溢出、死锁。其位于JDK的bin目录中

![image-20200723235323514](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723235323514.png)

在选择好对应程序，点击连接即可。

![image-20200723235421257](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723235421257.png)

在该页面那种展示了程序运行的相关详情信息。此时可以选择线程，来查看线程在堆栈中的详细信息。

![image-20200723235525526](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723235525526.png)

点击检测死锁，即可看到程序中的死锁信息

![image-20200723235604118](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723235604118.png)

####   通过JDK工具VisualVM

​	其也是JDK提供的一款非常强大的程序问题检测工具，可以监控程序性能、查看JVM配置信息、堆栈信息。位于JDK的bin目录中（jvisualvm.exe）。

![image-20200723235907826](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723235907826.png)

在左侧列表中，打开你当前要来查看的线程。

![image-20200723235953445](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200723235953445.png)

进入到线程选项卡，可以看到其已经提示发现死锁，接着点击线程DUMP按钮，即可查看线程堆栈信息。确定死锁位置。

![image-20200724000119109](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200724000119109.png)

![image-20200724000137854](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/1/assets/image-20200724000137854.png)

####   避免死锁的常见方法

1）避免一个线程同时获取多个锁。

2）避免一个线程在锁内同时占用多个资源，尽量保证每个锁只占用一个资源。

3）尝试使用定时锁，使用lock.tryLock(timeout)来替代使用内部锁机制。

