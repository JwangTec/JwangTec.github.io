​---
title: Java并发编程08--Fork/Join分解合并框架
categories: Java并发编程
tags:
	- Fork
	- Join
top: 10
date: 2019-08-03 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc3.jpeg)

<!--more-->

##   什么是fork/join

​	Fork/Join框架是JDK1.7提供的一个用于并行执行任务的框架，开发者可以在不去了解如Thread、Runnable等相关知识的情况下，只要遵循fork/join开发模式，就完成写出很好的多线程并发任务。

​	同时其按照**分而治之**的思想，可以把一个大任务分割成若干个小任务，最终汇总每个小任务结果后得到大任务结果的框架。

​	对于Fork/Join框架的理解可以认为其由两部分组成，Fork就是把一个大任务切分为若干个子任务并行执行。Join就是合并这些子任务的执行结果，最后得到这个大任务的结果。

![image-20200730151437185](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730151437185.png)

##   工作窃取算法

​	即当前线程的 Task 已经全被执行完毕，则自动取到其他线程的 Task 池中取出 Task 继续执行。ForkJoinPool 中维护着多个线程（一般为 CPU 核数）在不断地执行 Task，每个线程除了执行自己任务列表内的 Task 之外，还会根据自己工作线程的闲置情况去获取其他繁忙的工作线程的 Task，如此一来就能能够减少线程阻塞或是闲置的时间，提高 CPU 利用率。

![image-20200730153133010](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730153133010.png)

##   Fork/Join的使用

###  基本概念

​	要使用Fork/Join的话，首先需要有一个Pool。通过它可以来执行任务。 而每一个任务叫做ForkJoinTask，其内部提供了fork和join的操作机制。通常情况下开发者不需要直接继承ForkJoinTask，而是继承它的子类。分别为：

- **RecursiveAction**：返回没有结果的任务。

- **RecursiveTask<T>**：返回有结果的任务。

![image-20200730155948459](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/3/assets/image-20200730155948459.png)

1）新建ForkJoinPool；

2）新建ForkJoinTask(RecursiveAction || RecursiveTask);

3）在任务中的compute方法，会根据自定义条件进行任务拆分，如果条件满足则执行任务，如果条件不满足则继续拆分任务。当所有任务都执行完，进行最终结果的汇总。

4）最终通过get或join获取数据结果。

###  同步有结果值返回

需求：统计整型数组中所有元素的和。

```java
//生成随机数组
public class GenArray {

    //数组长度
    public static final int ARRAY_LENGTH=400000;

    public static int[] genArray(){

        Random random = new Random();
        int[] result = new int[ARRAY_LENGTH];
        for (int i = 0; i < ARRAY_LENGTH; i++) {
            //随机数填充数组
            result[i]= random.nextInt(ARRAY_LENGTH*3);
        }
        return result;
    }
}
```

```java
//普通循环累加
public class SumNormal {

    public static void main(String[] args) {

        int count = 0;
        int[] src = GenArray.genArray();

        long start = System.currentTimeMillis();

        for (int i = 0; i < src.length; i++) {
            count+=src[i];
        }

        System.out.println("spend time: "+(System.currentTimeMillis()-start));
    }
}
```

```java
//forkJoin累加
public class SumForkJoin{

    //自定义任务
    private static class SumTask extends RecursiveTask<Integer> {

        private final static int THRESHOLD=GenArray.ARRAY_LENGTH/10;
        private int[] src;
        private int fromIndex;
        private int endIndex;

        public SumTask(int[] src, int fromIndex, int endIndex) {
            this.src = src;
            this.fromIndex = fromIndex;
            this.endIndex = endIndex;
        }

        @Override
        protected Integer compute() {

            //判断是否符合任务大小
            if (endIndex-fromIndex<THRESHOLD){
                //符合条件
                int count = 0;
                for (int i = fromIndex; i <= endIndex; i++) {
                    count+=src[i];
                }
                return count;
            }else {
                //继续拆分任务
                //基于二分查找对任务进行拆分
                int mid = (fromIndex+endIndex)/2;
                SumTask left = new SumTask(src,fromIndex,mid);
                SumTask right = new SumTask(src,mid+1,endIndex);
                invokeAll(left,right);
                return left.join()+right.join();
            }
        }
    }

    public static void main(String[] args) {

        ForkJoinPool pool = new ForkJoinPool();

        int[] src = GenArray.genArray();
        SumTask sumTask = new SumTask(src,0,src.length-1);

        long start = System.currentTimeMillis();
        pool.invoke(sumTask);
        System.out.println("spend time: "+(System.currentTimeMillis()-start));
    }
}
```

​	根据执行结果可以看到，如果数据量较小的情况下，使用普通循环的效率更高，因为其内部是以总线的形式进行相加。而forkjoin的话，要利用当前可用的CPU核数结合线程的上下文切换，所以存在一定的性能消耗。

​	但是如果数据量较大的话，可以看到使用forkjoin的效率会明显高于普通for循环。

###   异步无结果值返回

需求：遍历目录（包含子目录）寻找txt类型文件。

```java
public class FindFile extends RecursiveAction {

    private File path;

    public FindFile(File path) {
        this.path = path;
    }

    @Override
    protected void compute() {
        List<FindFile> takes = new ArrayList<>();

        //获取指定路径下的所有文件
        File[] files = path.listFiles();

        if (files != null){
            for (File file : files) {
                //是否为文件夹
                if (file.isDirectory()){
                    //递归调用
                    takes.add(new FindFile(file));
                }else {
                    //不是文件夹。执行检查
                    if (file.getAbsolutePath().endsWith("txt")){
                        System.out.println(file.getAbsolutePath());
                    }
                }
            }

            //调度所有子任务执行
            if (!takes.isEmpty()){
                for (FindFile task : invokeAll(takes)){
                    //阻塞当前线程并等待获取结果
                    task.join();
                }
            }
        }
    }

    public static void main(String[] args) {

        ForkJoinPool pool = new ForkJoinPool();

        FindFile task = new FindFile(new File("F://"));

        pool.submit(task);

        //主线程join，等待子任务执行完毕。
        task.join();

        System.out.println("task end");
    }
}
```



