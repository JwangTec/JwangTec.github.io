---
title: Java并发编程12--ThreadPoolExecutor线程池
categories: Java并发编程
tags:
  - ThreadPoolExecutor线程池
top: 10
abbrlink: 2407816807
password:
---



<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc3.jpeg" width="1000" height="300" align="middle" />



##  为什么使用线程池

<!--more-->

​	对于线程的创建和切换代价都是比较大的，为了能够更好的使用线程，所以就产生了线程池的概念。Java中的线程池是运用场景最多的并发框架，几乎所有需要异步或并发执行任务的程序都可以使用线程池。其带来的好处如下：

- 降低资源消耗。通过重复利用已创建的线程降低线程创建和销毁造成的消耗。

- 提高响应速度。当任务到达时，任务可以不需要等到线程创建就能立即执行。

- 提高线程的可管理性。线程是稀缺资源，要合理利用分配，通过线程池可以进行统一分配、调优和监控。

##   线程池状态

![image-20200801165159637](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200801165159637.png)

线程池存在五种状态：RUNNING、 SHUTDOWN,、STOP、TIDYING、TERMINATED。

* **RUNNING**：处于RUNNING状态的线程池能够接受新任务，以及对新添加的任务进行处理。
* **SHUTDOWN**：处于SHUTDOWN状态的线程池不可以接受新任务，但是可以对已添加的任务进行处理。
* **STOP**：处于STOP状态的线程池不接收新任务，不处理已添加的任务，并且会中断正在处理的任务。
* **TIDYING**：当所有的任务已终止，线程池会变为TIDYING状态。当线程池变为TIDYING状态时，会执行钩子函数terminated()。terminated()在ThreadPoolExecutor类中是空的，若用户想在线程池变为TIDYING时，进行相应的处理；可以通过重载terminated()函数来实现。
* **TERMINATED**：线程池彻底终止的状态。

![image-20200801165350954](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200801165350954.png)

## 线程池创建的各个参数含义

![image-20200801165625614](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200801165625614.png)

**corePoolSize：**

​	核心线程数(线程池基本大小)，在没有任务需要执行的时候的线程池大小。当提交一个任务时，线程池创建一个新线程执行任务，直到线程数等于该参数。 如果当前线程数为该参数，后续提交的任务被保存到阻塞队列中，等待被执行。

**maximumPoolSize：**

​	线程池中允许的最大线程数，线程池中的当前线程数目不会超过该值。如果当前阻塞队列满了，且继续提交任务，如果当前的线程数小于maximumPoolSize，则会新建线程来执行任务。

**keepAliveTime：**

​	线程池空闲时的存活时间，即当线程池没有任务执行时，继续存活的时间。默认情况下，该参数只在线程数大于corePoolSize时才有用。

**workQueue：**

​	其必须是BolckingQueue有界阻塞队列，用于实现线程池的阻塞功能。当线程池中的线程数超过它的corePoolSize时，线程会进入阻塞队列进行阻塞等待。

**threadFactory**：

​	用于设置创建线程的工厂。ThreadFactory的作用就是提供创建线程的功能的线程工厂。他是通过newThread()方法提供创建线程的功能，newThread()方法创建的线程都是“非守护线程”而且“线程优先级都是默认优先级”。

**handler：**

​	线程池拒绝策略。当阻塞队列满了，且没有空闲的工作线程，如果继续提交任务，则必须采取一种策略处理该任务。

AbortPolicy：默认策略，直接抛出异常。

CallerRunsPolicy：用调用者所在的线程执行任务。

DiscardOldestPolicy：丢去阻塞队列的头部任务，并执行当前任务。

DiscardPolicy：直接丢弃任务。

##   线程池工作机制

1. 如果当前运行的线程少于corePoolSize，则创建新线程来执行任务（执行这一步前，需要获取全局锁）。
2. 如果运行的线程等于或多于corePoolSize，则将任务加入BlockingQueue。
3. 如果无法将任务加入BlockingQueue，则创建新线程处理任务。
4. 如果创建的新线程使当前运行的线程超出maximumPoolSize，任务将被拒绝。

##   自定义线程池

```java
public class ThreadPoolDemo {

    public static void main(String[] args) {

        //创建阻塞队列
        LinkedBlockingQueue<Runnable> queue = new LinkedBlockingQueue<>(100);

        //创建工厂
        ThreadFactory threadFactory = new ThreadFactory() {

            AtomicInteger atomicInteger = new AtomicInteger(1);
            @Override
            public Thread newThread(Runnable r) {

                //创建线程把任务传递进去
                Thread thread = new Thread(r);
                //设置线程名称
                thread.setName("MyThread: "+atomicInteger.getAndIncrement());
                return thread;
            }
        };

        ThreadPoolExecutor pool  = new ThreadPoolExecutor(10,
                                                          10,
                                                          1,
                                                          TimeUnit.SECONDS,
                                                          queue,
                                                          threadFactory);

        for (int i = 0; i < 100; i++) {

            pool.execute(new Runnable() {
                @Override
                public void run() {
                    //执行业务
                    System.out.println(Thread.currentThread().getName()+" 进来了");
                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println(Thread.currentThread().getName()+"出去了");
                }
            });
        }
    }
}
```

##  五种预定义线程池

​	我们除了可以使用ThreadPoolExecutor自己根据实际情况创建线程池以外，Executor框架也提供了四种线程池，他们都可以通过工具类Executors来创建。

​	还有一种线程池ScheduledThreadPoolExecutor，它相当于提供了“延迟”和“周期执行”功能的ThreadPoolExecutor。

###   FixedThreadPool

​	创建使用固定线程数的线程池。适用于为了满足资源管理而需要限制当前线程数量的场景。同时也适用于负载较重的服务器。其定义如下：

```java
public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                  0L, TimeUnit.MILLISECONDS,
                                      new LinkedBlockingQueue<Runnable>());
}
```

**nThreads**：

​	FixedThreadPool 的 corePoolSize 和 maximumPoolSize 都被设置为创建FixedThreadPool 时指定的参数 nThreads。

**keepAliveTime**：

​	此处设置为了0L，代表多于的空闲线程会被立即终止。

**LinkedBlockingQueue**：

FixedThreadPool 使用有界队列 LinkedBlockingQueue 作为线程池的工作队列（队列的容量为 Integer.MAX_VALUE）。

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/2018120835002.png)

```java
public class FixedThreadPoolCase {

    static class Demo implements Runnable {
        @Override
        public void run() {
            String name = Thread.currentThread().getName();
            for (int i = 0; i < 2; i++) {
                System.out.println(name + ":" + i);
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        ExecutorService exec = Executors.newFixedThreadPool(3);

        for (int i = 0; i < 5; i++) {
            exec.execute(new Demo());
            Thread.sleep(10);
        }
        exec.shutdown();
    }


}
```

### SingleThreadExecutor

​	只会使用单个工作线程来执行一个无边界的队列。适用于保证顺序地执行各个人物，并且在任意时间点，不会有多个线程存在活动的应用场景。

```java
public static ExecutorService newSingleThreadExecutor() {
    return new FinalizableDelegatedExecutorService
        (new ThreadPoolExecutor(1, 1,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>()));
}
```

​	corePoolSize 和 maximumPoolSize 被设置为 1。其他参数与 FixedThreadPool相同。SingleThreadExecutor 使用有界队列 LinkedBlockingQueue 作为线程池的工作队列（队列的容量为 Integer.MAX_VALUE）。

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/2018120835006.png)

```java
public class SingleThreadPoolCase {
    
    static int count = 0;

    public static void main(String[] args) throws InterruptedException {
        
        ExecutorService exec = Executors.newSingleThreadExecutor();
        
        for (int i = 0; i < 10; i++) {
            exec.execute(new Demo());
            Thread.sleep(5);
        }
        exec.shutdown();
    }

    static class Demo implements Runnable {
        @Override
        public void run() {
            String name = Thread.currentThread().getName();
            for (int i = 0; i < 2; i++) {
                count++;
                System.out.println(name + ":" + count);
            }
        }
    }
}
```

###  CachedThreadPool

​	其是一个大小无界的线程池，会根据需要创建新线程。适用于执行很多的短期异步任务的小程序或者是负载较轻的服务器。

```java
public static ExecutorService newCachedThreadPool() {
    return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                  60L, TimeUnit.SECONDS,
                                  new SynchronousQueue<Runnable>());
}
```

​	corePoolSize 被设置为 0，即 corePool 为空；maximumPoolSize 被设置为Integer.MAX_VALUE。这里把 keepAliveTime 设置为 60L，意味着 CachedThreadPool中的空闲线程等待新任务的最长时间为60秒，空闲线程超过60秒后将会被终止。

​	FixedThreadPool 和 SingleThreadExecutor 使用有界队列 LinkedBlockingQueue作为线程池的工作队列。CachedThreadPool 使用没有容量的 SynchronousQueue作为线程池的工作队列，但 CachedThreadPool 的 maximumPool 是无界的。这意味着，如果主线程提交任务的速度高于 maximumPool 中线程处理任务的速度时，
CachedThreadPool 会不断创建新线程。极端情况下，CachedThreadPool 会因为创建过多线程而耗尽 CPU 和内存资源。

![image-20200801182645368](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200801182645368.png)

```java
public class Demo9CachedThreadPoolCase {
    public static void main(String[] args) throws InterruptedException {
        ExecutorService exec = Executors.newCachedThreadPool();
        for (int i = 0; i < 10; i++) {
            exec.execute(new Demo());
            Thread.sleep(1);
        }
        exec.shutdown();
    }

    static class Demo implements Runnable {
        @Override
        public void run() {
            String name = Thread.currentThread().getName();
            try {
                //修改睡眠时间，模拟线程执行需要花费的时间
                Thread.sleep(1);

                System.out.println(name + "执行完了");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
```

###  ScheduledThreadPoolExecutor

​	ScheduledThreadPoolExecutor，继承ThreadPoolExecutor且实现了ScheduledExecutorService接口，它就相当于提供了“延迟”和“周期执行”功能的ThreadPoolExecutor。它可另行安排在给定的延迟后运行命令，或者定期执行命令。它适用于为了满足资源管理的需求而需要限制后台线程数量的场景同时可以保证多任务的顺序执行。

```java
    public ScheduledThreadPoolExecutor(int corePoolSize) {
        super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
                new DelayedWorkQueue());
    }

    public ScheduledThreadPoolExecutor(int corePoolSize,
                                       ThreadFactory threadFactory) {
        super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
                new DelayedWorkQueue(), threadFactory);
    }

    public ScheduledThreadPoolExecutor(int corePoolSize,
                                       RejectedExecutionHandler handler) {
        super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
                new DelayedWorkQueue(), handler);
    }


    public ScheduledThreadPoolExecutor(int corePoolSize,
                                       ThreadFactory threadFactory,
                                       RejectedExecutionHandler handler) {
        super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
                new DelayedWorkQueue(), threadFactory, handler);
    }
```

​	在ScheduledThreadPoolExecutor的构造函数中，我们发现它都是利用ThreadLocalExecutor来构造的，唯一变动的地方就在于它所使用的阻塞队列变成了DelayedWorkQueue。

​	DelayedWorkQueue为ScheduledThreadPoolExecutor中的内部类，类似于延时队列和优先级队列。在执行定时任务的时候，每个任务的执行时间都不同，所以DelayedWorkQueue的工作就是按照执行时间的升序来排列，执行时间距离当前时间越近的任务在队列的前面，这样就可以保证每次出队的任务都是当前队列中执行时间最靠前的。

```java
public class Demo9ScheduledThreadPool {

    public static void main(String[] args) throws InterruptedException {
        ScheduledExecutorService scheduledThreadPool = Executors.newScheduledThreadPool(2);
        System.out.println("程序开始：" + new Date());
        // 第二个参数是延迟多久执行
        scheduledThreadPool.schedule(new Task(), 0, TimeUnit.SECONDS);
        scheduledThreadPool.schedule(new Task(), 1, TimeUnit.SECONDS);
        scheduledThreadPool.schedule(new Task(), 5, TimeUnit.SECONDS);

        Thread.sleep(5000);

        // 关闭线程池
        scheduledThreadPool.shutdown();
    }

    static class Task implements Runnable {
        @Override
        public void run() {
            try {
                String name = Thread.currentThread().getName();

                System.out.println(name + ", 开始：" + new Date());
                Thread.sleep(1000);
                System.out.println(name + ", 结束：" + new Date());

            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
```



###  WorkStealingPool

​	其是JDK1.8中新增的线程池，利用所有运行的CPU来创建一个工作窃取的线程池，是对ForkJoinPool的扩展，适用于非常耗时的操作。

```java
public class WorkStealingPoolDemo {

    public static void main(String[] args) throws IOException {

        //获取当前可用CPU核数
        System.out.println(Runtime.getRuntime().availableProcessors());

        //创建线程池
        ExecutorService stealingPool = Executors.newWorkStealingPool();
        stealingPool.execute(new MyThread(1000));

        /**
         * 我现在CPU是8个，开启了9个线程，第一个线程一秒执行完，其他的都是两秒
         * 此时会有一个线程进行等待，当第一个执行完毕后，会偷取第九个线程执行
         */
        for (int i = 0; i < Runtime.getRuntime().availableProcessors(); i++) {
            stealingPool.execute(new MyThread(2000));
        }

        // 因为work stealing 是deamon线程
        // 所以当main方法结束时, 此方法虽然还在后台运行,但是无输出
        // 可以通过对主线程阻塞解决
        System.in.read();

    }

    static class MyThread implements Runnable{

        int time;

        public MyThread(int time) {
            this.time = time;
        }

        @Override
        public void run() {
            try {
                TimeUnit.MILLISECONDS.sleep(time);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName()+" : "+time);
        }
    }
}
```

![image-20200801184347585](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200801184347585.png)
