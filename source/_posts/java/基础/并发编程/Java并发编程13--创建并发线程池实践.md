---
title: Java并发编程13--创建并发线程池实践
categories: Java并发编程
tags: [线程池创建, 并发编程]
top: 10
abbrlink: 1546721459
password:
---

## 传统创建线程池弊端

### Executors的创建线程池的方法

创建出来的线程池都实现了ExecutorService接口。常用方法有以下几个：

<!--more-->

- newFiexedThreadPool(int Threads)：创建固定数目线程的线程池。

- newCachedThreadPool()：创建一个可缓存的线程池，调用execute 将重用以前构造的线程（如果线程可用）。如果没有可用的线程，则创建一个新线程并添加到池中。终止并从缓存中移除那些已有 60 秒钟未被使用的线程。

- newSingleThreadExecutor()创建一个单线程化的Executor。

- newScheduledThreadPool(int corePoolSize)创建一个支持定时及周期性的任务执行的线程池，多数情况下可用来替代Timer类。

### Executors存在问题

在阿里巴巴Java开发手册中提到，使用Executors创建线程池可能会导致OOM(OutOfMemory ,内存溢出)

- 模拟一下使用Executors导致OOM

```java
public class ExecutorsDemo {
    private static ExecutorService executor = Executors.newFixedThreadPool(15);//根本原因
    public static void main(String[] args) {
        for (int i = 0; i < Integer.MAX_VALUE; i++) {
            executor.execute(new SubThread());//出现问题
        }
    }
}
 
class SubThread implements Runnable {
    @Override
    public void run() {
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            //do nothing
        }
    }
}

通过指定JVM参数：-Xmx8m -Xms8m 运行以上代码，会抛出OOM:
Exception in thread "main" java.lang.OutOfMemoryError: GC overhead limit exceeded
    at java.util.concurrent.LinkedBlockingQueue.offer(LinkedBlockingQueue.java:416)
    at java.util.concurrent.ThreadPoolExecutor.execute(ThreadPoolExecutor.java:1371)
    at com.hollis.ExecutorsDemo.main(ExecutorsDemo.java:16)
```

- 导致OOM的原因-LinkedBlockingQueue.offer方法

```java
//底层实现
public static ExecutorService newFixedThreadPool(int nThreads) {
        return new ThreadPoolExecutor(nThreads, nThreads,
                                      0L, TimeUnit.MILLISECONDS,
                                      new LinkedBlockingQueue<Runnable>());
```

#### 阻塞队列

Java中的BlockingQueue主要有两种实现，分别是ArrayBlockingQueue 和 LinkedBlockingQueue。

- ArrayBlockingQueue是一个用数组实现的有界阻塞队列，必须设置容量。

- LinkedBlockingQueue是一个用链表实现的有界阻塞队列，容量可以选择进行设置，**不设置的话，将是一个无边界的阻塞队列，最大长度为Integer.MAX_VALUE。**

### 弊端总结

newFixedThreadPool中创建LinkedBlockingQueue时，并未指定容量。此时，LinkedBlockingQueue就是一个无边界队列，对于一个无边界队列来说，是可以不断的向队列中加入任务的，这种情况下就有可能因为任务过多而导致内存溢出问题。

上面提到的问题主要体现在newFixedThreadPool和newSingleThreadExecutor两个工厂方法上，并不是说newCachedThreadPool和newScheduledThreadPool这两个方法就安全了，这两种方式创建的最大线程数可能是Integer.MAX_VALUE，而创建这么多线程，必然就有可能导致OOM。

```java
    3. 【强制】线程资源必须通过线程池提供，不允许在应用中自行显式创建线程。
    说明：使用线程池的好处是减少在创建和销毁线程上所花的时间以及系统资源的开销，解决资
    源不足的问题。如果不使用线程池，有可能造成系统创建大量同类线程而导致消耗完内存或者
    “过度切换”的问题。
    4. 【强制】线程池不允许使用 Executors 去创建，而是通过 ThreadPoolExecutor 的方式，这样
    的处理方式让写的同学更加明确线程池的运行规则，规避资源耗尽的风险。
    说明： Executors 返回的线程池对象的弊端如下：
    1） FixedThreadPool 和 SingleThreadPool :
    允许的请求队列长度为 Integer.MAX_VALUE ，可能会堆积大量的请求，从而导致 OOM 。
    2） CachedThreadPool 和 ScheduledThreadPool :
    允许的创建线程数量为 Integer.MAX_VALUE ，可能会创建大量的线程，从而导致 OOM 。

```

## 如何创建线程池

避免使用Executors创建线程池，主要是避免使用其中的默认实现，那么我们可以自己直接调用ThreadPoolExecutor的构造函数来自己创建线程池。在创建的同时，给BlockQueue指定容量就可以了。

```java
private static ExecutorService executor = new ThreadPoolExecutor(10, 10,
        60L, TimeUnit.SECONDS,
        new ArrayBlockingQueue(10));
```

- 这种情况下，一旦提交的线程数超过当前可用线程数时，就会抛出java.util.concurrent.RejectedExecutionException，这是因为当前线程池使用的队列是有边界队列，队列已经满了便无法继续处理新的请求。但是异常（Exception）总比发生错误（Error）要好。


### guava提供的ThreadFactoryBuilder来创建线程池

```java
public class ExecutorsDemo {

    private static ThreadFactory namedThreadFactory = new ThreadFactoryBuilder()
        .setNameFormat("demo-pool-%d").build();

    private static ExecutorService pool = new ThreadPoolExecutor(5, 200,
        0L, TimeUnit.MILLISECONDS,
        new LinkedBlockingQueue<Runnable>(1024), namedThreadFactory, new ThreadPoolExecutor.AbortPolicy());

    public static void main(String[] args) {

        for (int i = 0; i < Integer.MAX_VALUE; i++) {
            pool.execute(new SubThread());
        }
    }
}
```
通过上述方式创建线程时，不仅可以避免OOM的问题，还可以自定义线程名称，更加方便的出错的时候溯源。

### apache提供的BasicThreadFactory来创建线程池

```
import org.apache.commons.lang3.concurrent.BasicThreadFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.*;

public class AsyncProcessor {
    static final Logger LOGGER = LoggerFactory.getLogger(AsyncProcessor.class);

    /**
     * 默认最大并发数<br>
     */
    private static final int DEFAULT_MAX_CONCURRENT = Runtime.getRuntime().availableProcessors() * 2;

    /**
     * 线程池名称格式
     */
    private static final String THREAD_POOL_NAME = "ExternalConvertProcessPool-%d";

    /**
     * 线程工厂名称
     */
    private static final ThreadFactory FACTORY = new BasicThreadFactory.Builder().namingPattern(THREAD_POOL_NAME)
            .daemon(true).build();

    /**
     * 默认队列大小
     */
    private static final int DEFAULT_SIZE = 1000;

    /**
     * 默认线程存活时间
     */
    private static final long DEFAULT_KEEP_ALIVE = 60L;

    /**NewEntryServiceImpl.java:689
     * Executor
     */
    private static ExecutorService executor;

    /**
     * 执行队列
     */
    private static BlockingQueue<Runnable> executeQueue = new ArrayBlockingQueue<>(DEFAULT_SIZE);

    static {
        // 创建 Executor
        // 此处默认最大值改为处理器数量的 4 倍
        try {
            executor = new ThreadPoolExecutor(DEFAULT_MAX_CONCURRENT, DEFAULT_MAX_CONCURRENT * 4, DEFAULT_KEEP_ALIVE,
                    TimeUnit.SECONDS, executeQueue, FACTORY);

            // 关闭事件的挂钩
            Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

                @Override
                public void run() {
                    AsyncProcessor.LOGGER.info("AsyncProcessor shutting down.");

                    executor.shutdown();

                    try {

                        // 等待1秒执行关闭
                        if (!executor.awaitTermination(1, TimeUnit.SECONDS)) {
                            AsyncProcessor.LOGGER.error("AsyncProcessor shutdown immediately due to wait timeout.");
                            executor.shutdownNow();
                        }
                    } catch (InterruptedException e) {
                        AsyncProcessor.LOGGER.error("AsyncProcessor shutdown interrupted.");
                        executor.shutdownNow();
                    }

                    AsyncProcessor.LOGGER.info("AsyncProcessor shutdown complete.");
                }
            }));
        } catch (Exception e) {
            LOGGER.error("AsyncProcessor init error.", e);
            throw new ExceptionInInitializerError(e);
        }
    }

    /**
     * 此类型无法实例化
     */
    private AsyncProcessor() {
    }

    /**
     * 执行任务，不管是否成功<br>
     * 其实也就是包装以后的 {@link Executer} 方法
     *
     * @param task
     * @return
     */
    public static boolean executeTask(Runnable task) {

        try {
            executor.execute(task);
        } catch (RejectedExecutionException e) {
            LOGGER.error("Task executing was rejected.", e);
            return false;
        }

        return true;
    }

    /**
     * 提交任务，并可以在稍后获取其执行情况<br>
     * 当提交失败时，会抛出 {@link }
     *
     * @param task
     * @return
     */
    public static <T> Future<T> submitTask(Callable<T> task) {

        try {
            return executor.submit(task);
        } catch (RejectedExecutionException e) {
            LOGGER.error("Task executing was rejected.", e);
            throw new UnsupportedOperationException("Unable to submit the task, rejected.", e);
        }
    }
}

```

- 使用-异步执行任务

```java
import lombok.extern.slf4j.Slf4j;
import java.util.concurrent.FutureTask;
import java.util.function.Supplier;


/**
 * 任务执行管理
 */
@Slf4j
public class TaskManager {

    private TaskManager() {
    }

    /**
     * 异步执行任务
     * @param task  任务
     * @param title 标题
     */
    public static void doTask(final ITask task, String title) {
        try {
            AsyncProcessor.executeTask(() -> SpeedTimeLogSuit.wrap((Supplier<Void>) () -> {
                try {
                    task.doTask();
                } catch (Exception e) {
                    log.error("TaskManager doTask execute error.", e);
                }
                return null;
            }, title));
        } catch (Exception e) {
            log.error("thread pool get thread error.");
        }
    }
}
```











​	