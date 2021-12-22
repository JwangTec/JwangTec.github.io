---
title: Java并发编程05--atomic原子操作类
categories: Java并发编程
tags:
  - atomic
  - 并发编程
  - Java
top: 18
abbrlink: 673356023
date: 2019-08-02 18:18:19
password:
---


<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/juc.jpeg" width="1000" height="200" align="middle" />



​	在JDK1.5开始提供了`java.util.concurrent.atomic`工具包，这个包下的所有类都基于CAS思想实现，提供了简单、高效、安全的更新**一个**变量的方式。
​
​<!--more-->

​	为了适配变量类型，在Atomic包中一共提供了12个类，分属于4种类型的原子更新方式，分别为**原子更新基本类型**、**原子更新数据**、**原子更新引用**和**原子更新属性**。其内部基本都是用Unsafe实现的包装类。

![image-20200728175255463](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200728175255463.png)

##  原子更新基本类型

​	以原子方式更新基本类型，Atomic提供了三个类。分别为**AtomicInteger**、**AtomicBoolean**、**AtomicLong**。这三个类的方法基本相同，此处以AtomicInteger为例。

​	![image-20200728181644489](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200728181644489.png)

1）**int addAndGet()**：以原子的方式将输入的数字与AtomicInteger里的值相加，并返回结果。

```java
public class AtomicIntegerTest {

    private static AtomicInteger atomicInteger = new AtomicInteger(0);

    public static Integer addAndGetDemo(int value){
        return atomicInteger.addAndGet(value);
    }

    public static void main(String[] args) {

        for (int i = 0; i < 10; i++) {
            Integer result = addAndGetDemo(i);
            System.out.println(result);
        }
    }
}
```

2）**boolean compareAndSet(int expect, int update)**：如果输入的数值等于预期值，则以原子方式将该值设置为输入的值

```java
public static boolean compareAndSetDemo(int expect,int update){
    return atomicInteger.compareAndSet(expect, update);
}

 /*System.out.println(compareAndSetDemo(1,1));*/
```

3）**int incrementAndGet()**：对原值+1，并返回操作后的值。类似与redis中的increment命令。相反的还有**decrementAndGet()**

```java
public static int incrementAndGetDemo(){
    return atomicInteger.incrementAndGet();
}
```

4）**int getAndAdd(int delta)**：原值加上指定值，并返回修改前的值。

```java
public static int getAndAddDemo(int value){
    return atomicInteger.getAndAdd(value);
}

/*System.out.println(incrementAndGetDemo());*/
```

5）**int getAndSet(int newValue)**：将原值修改为新值，并返回修改前的值。

```java
public static int getAndSetDemo(int newValue){
    return atomicInteger.getAndSet(newValue);
}

/*System.out.println(getAndAddDemo(5));
System.out.println(atomicInteger.get());*/
```

6）**int getAndIncrement()**：原值加1，返回修改前的值。对应的还有getAndDecrement()

```java
public static int getAndIncrementDemo(){
    return atomicInteger.getAndIncrement();
}

/* System.out.println(getAndIncrementDemo());
System.out.println(atomicInteger.get());*/
```

##  原子更新数组

​	通过原子方式更新数组里的某个元素，Atomic包中提供了三个类，分别为**AtomicIntegerArray**、**AtomicLongArray**、**AtomicReferenceArray**。

​	以上几个类中的方法几乎一样，只是操作的数据类型不同，以AtomicIntegerArray中的API为例。

```java
//执行加法，第一个参数为数组的下标，第二个参数为增加的数量，返回增加后的结果
int addAndGet(int i, int delta)

//对比修改，参1数组下标，参2原始值，参3修改目标值，成功返回true否则false
boolean compareAndSet(int i, int expect, int update)

//参数为数组下标，将数组对应数字减少1，返回减少后的数据
int decrementAndGet(int i)
    
// 参数为数组下标，将数组对应数字增加1，返回增加后的数据
int incrementAndGet(int i)

//和addAndGet类似，区别是返回值是变化前的数据
int getAndAdd(int i, int delta)
    
//和decrementAndGet类似，区别是返回变化前的数据
int getAndDecrement(int i)
    
//和incrementAndGet类似，区别是返回变化前的数据
int getAndIncrement(int i)
    
// 将对应下标的数字设置为指定值，第一个参数数组下标，第二个参数为设置的值，返回是变化前的数据 
getAndSet(int i, int newValue)
```

```java
public class AtomicIntegerArrayDemo {

    static int[] value = new int[]{1,2,3};

    static AtomicIntegerArray ai = new AtomicIntegerArray(value);

    public static void main(String[] args) {

        System.out.println(ai.getAndSet(2,6));
        System.out.println(ai.get(2));
        System.out.println(value[2]);
    }
}
```

​	**此时可以看到从AtomicIntegerArray获取的值与原传入数组的值不同。这是因为数组是通过构造方法传递，然后AtomicIntegerArray会将当前传入数组复制一份。因此当AtomicIntegerArray对内部数组元素进行修改时，不会影响原数组。**

##  原子更新引用类型

​	之前提到的通过CAS只能保证一个共享变量的原子操作，当多个的话，就需要使用到锁。对于这个问题，在Atomic包中也进行了解决。如果要更新多个变量，就需要使用Atomic包中的三个类，分别为：**AtomicReference**(用于原子更新引用类型)、**AtomicMarkableReference**(用于原子更新带有标记位的引用类型)、**AtomicStampedReference**(用于原子更新带有版本号的引用类型)。

```java
public class AtomicReferenceTest {

    static class User{
        private String name;
        private int age;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getAge() {
            return age;
        }

        public void setAge(int age) {
            this.age = age;
        }

        public User(String name, int age) {
            this.name = name;
            this.age = age;
        }
    }

    public static AtomicReference<User> atomicReference = new AtomicReference<>();

    public static void main(String[] args) {

        User u1 = new User("张三",18);
        User u2 = new User("李四",19);

        atomicReference.set(u1);

        atomicReference.compareAndSet(u1,u2);
        System.out.println(atomicReference.get().getName());
        System.out.println(atomicReference.get().getAge());
    }
}
```

​	**AtomicMarkableReference**可以用于解决CAS中的ABA的问题。使用演示如下：

```java
public class AtomicMarkableReferenceDemo {

    static class User{
        private String name;
        private int age;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getAge() {
            return age;
        }

        public void setAge(int age) {
            this.age = age;
        }

        public User(String name, int age) {
            this.name = name;
            this.age = age;
        }
    }

    public static void main(String[] args) throws InterruptedException {
        User u1 = new User("张三", 22);
        User u2 = new User("李四", 33);

        //只有true和false两种状态。相当于未修改和已修改
        //构造函数出传入初始化引用和初始化修改标识
        AtomicMarkableReference<User> amr = new AtomicMarkableReference<>(u1,false);
        //在进行比对时，不仅比对对象，同时还会比对修改标识
        //第一个参数为期望值
        //第二个参数为新值
        //第三个参数为期望的mark值
        //第四个参数为新的mark值
        System.out.println(amr.compareAndSet(u1,u2,false,true));

        System.out.println(amr.getReference().getName());
    }
}
```

​	**AtomicStampedReference**会基于版本号思想解决ABA问题，根据源码可知，其内部维护了一个Pair对象，**Pair**对象记录了对象引用和时间戳信息，实际使用的时候，要保证时间戳唯一，如果时间戳如果重复，还会出现**ABA**的问题。

​	AtomicStampedReference中的每一个引用变量都带上了pair.stamp这个时间戳，这样就可以解决CAS中的ABA的问题。

![image-20200728233410970](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200728233410970.png)

​	使用实例如下：

```java
public class AtomicStampedReferenceDemo {

    private static final Integer INIT_NUM = 1000;
    private static final Integer UPDATE_NUM = 100;
    private static final Integer TEM_NUM = 200;

    private static AtomicStampedReference atomicStampedReference = new AtomicStampedReference(INIT_NUM, 1);

    public static void main(String[] args) {
        new Thread(() -> {

            int value = (int) atomicStampedReference.getReference();
            int stamp = atomicStampedReference.getStamp();

            System.out.println(Thread.currentThread().getName() + " : 当前值为：" + value + " 版本号为：" + stamp);

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            if(atomicStampedReference.compareAndSet(value, UPDATE_NUM, stamp, stamp + 1)){
                System.out.println(Thread.currentThread().getName() + " : 当前值为：" + atomicStampedReference.getReference() + " 版本号为：" + atomicStampedReference.getStamp());
            }else{
                System.out.println("版本号不同，更新失败！");
            }

        }, "线程A").start();

        new Thread(() -> {
            // 确保线程A先执行
            Thread.yield();

            int value = (int) atomicStampedReference.getReference();
            int stamp = atomicStampedReference.getStamp();
            System.out.println(Thread.currentThread().getName() + " : 当前值为：" + value + " 版本号为：" + stamp);

            System.out.println(Thread.currentThread().getName() +" : "+atomicStampedReference.compareAndSet(atomicStampedReference.getReference(), TEM_NUM, stamp, stamp + 1));
            System.out.println(Thread.currentThread().getName() + " : 当前值为：" + atomicStampedReference.getReference() + " 版本号为：" + atomicStampedReference.getStamp());

            System.out.println(Thread.currentThread().getName() +" : "+atomicStampedReference.compareAndSet(atomicStampedReference.getReference(), INIT_NUM, stamp, stamp + 1));
            System.out.println(Thread.currentThread().getName() + " : 当前值为：" + atomicStampedReference.getReference() + " 版本号为：" + atomicStampedReference.getStamp());
        }, "线程B").start();
    }
}
```

```
线程A : 当前值为：1000 版本号为：1
线程B : 当前值为：1000 版本号为：1
线程B : true
线程B : 当前值为：200 版本号为：2
线程B : false
线程B : 当前值为：200 版本号为：2
版本号不同，更新失败！
```

##  原子更新字段类

​	当需要原子更新某个类里的某个字段时，就需要使用原子更新字段类。Atomic包下提供了3个类**AtomicIntegerFieldUpdater**(原子更新整型字段)、**AtomicLongFieldUpdater**(原子更新长整型字段)、**AtomicReferenceFieldUpdater**(原子更新引用类型字段)

​	原子更新字段类都是抽象类，每次使用都时候必须使用静态方法newUpdater创建一个更新器。原子更新类的字段的必须使用public volatile修饰符。

​	以AtomicIntegerFieldUpdater为例

```java
public class AtomicIntegerFieldUpdaterTest {

    static class User{
        private String name;
        public volatile int age;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getAge() {
            return age;
        }

        public void setAge(int age) {
            this.age = age;
        }

        public User(String name, int age) {
            this.name = name;
            this.age = age;
        }
    }

    private static AtomicIntegerFieldUpdater<User> fieldUpdater = 	AtomicIntegerFieldUpdater.newUpdater(User.class,"age");

    public static void main(String[] args) {

        User user = new User("zhangsan",18);
        System.out.println(fieldUpdater.getAndIncrement(user));
        System.out.println(fieldUpdater.get(user));
    }
}
```

##   JDK1.8新增原子类

> LongAdder：长整型原子类
> DoubleAdder：双浮点型原子类
> LongAccumulator：类似LongAdder，但要更加灵活(要传入一个函数式接口)
> DoubleAccumulator：类似DoubleAdder，但要更加灵活(要传入一个函数式接口)

​	以LongAdder为例，其内部提供的API基本上可以替换原先的AtomicLong。

​	LongAdder类似于AtomicLong是原子性递增或者递减类，AtomicLong已经通过CAS提供了非阻塞的原子性操作，相比使用阻塞算法的同步器来说性能已经很好了，但是JDK开发组并不满足，因为在非常高的并发请求下AtomicLong的性能不能让他们接受，虽然AtomicLong使用CAS但是CAS失败后还是通过无限循环的自旋锁不断尝试。

​	在高并发下N多线程同时去操作一个变量会造成大量线程CAS失败然后处于自旋状态，这大大浪费了cpu资源，降低了并发性。那么既然AtomicLong性能由于过多线程同时去竞争一个变量的更新而降低的，那么如果把一个变量分解为多个变量，让同样多的线程去竞争多个资源那么性能问题不就解决了？是的，JDK8提供的LongAdder就是这个思路。

![image-20200729002844239](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/image-20200729002844239.png)

​	一段LongAdder和Atomic的对比测试代码：

```java
public class Demo9Compare {

    public static void main(String[] args) {
        AtomicLong atomicLong = new AtomicLong(0L);
        LongAdder longAdder = new LongAdder();

        long start = System.currentTimeMillis();
        for (int i = 0; i < 100; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    for (int j = 0; j < 10000; j++) {
                        //atomicLong.incrementAndGet();
                        longAdder.increment();
                    }
                }
            }).start();
        }

        while (Thread.activeCount() > 2) {
        }

        System.out.println(atomicLong.get());
        System.out.println(longAdder.longValue());

        System.out.println("耗时：" + (System.currentTimeMillis() - start));

    }
}
```

​	根据测试结论，使用longAdder相对比atomicLong可以进行大幅度的性能优化。当然不同计算机因为CPU、内存等硬件不一样，所以测试的数值也不一样，但是得到的结论都是一样的。

测试结果：

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/juc/2/assets/20170903201405380)

​	从上结果图可以看出，在并发比较低的时候，LongAdder和AtomicLong的效果非常接近。但是当并发较高时，两者的差距会越来越大。
​
​
