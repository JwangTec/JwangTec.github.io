---
title: Java快速开发指南
categories: Java
tags:
  - 开发指南
  - Java编程
  - 项目实战
top: 800
abbrlink: 2522846927
date: 2021-12-07 10:39:54
password:
---


## Java原生技术

### 函数编程

#### 先创建List再赋值

- 标准方式，先创建集合对象，然后逐个调用add方法初始化。用起来比较繁琐，不方便

```java
List<Integer> list = new ArrayList<>();
list.add(1);
list.add(2);
list.add(3);
```

#### 使用{{}}双大括号初始化

- 使用匿名内部类完成初始化，外层{}定义了一个ArrayList的匿名内部类，内层{}定义一个实例化初始化代码。**有内存泄漏的风险**

```java
List<Integer> list = new ArrayList<Integer>(){
        {
            add(1);
            add(2);
            add(3);
        }
};
```

#### 使用Arrays.asList

- 使用Arrays的静态方法asList初始化，**返回的list集合是不可变的**

```java
List<Integer> list = Arrays.asList(1,2,3);
```

#### 使用Stream

- 使用JDK8引入的Stream的of方法生成一个stream对象，调用collect方法进行收集，形成一个List集合

```java
List<Integer> list = Stream.of(1,2,3).collect(Collectors.toList());
```

#### 使用Google Guava工具集Lists（需引入Guava工具包）

```java
List<Integer> list = Lists.newArrayList(1,2,3);
```

#### 使用Lists（JDK9以上）

```java
List<Integer> list = Lists.of(1,2,3);
```

#### Lambda表达式的形式

- 没有参数

```java
()-> System.out.println("hello");
```

- 只有一个参数

```java
name -> System.out.println(
        "hello" + name
);
```

- 没有参数，逻辑复杂

```java
{} -> {
    System.out.println("1");
    System.out.println("2");
}
```

- 包含两个参数的方法

```java
BinaryOperator<Long> functionAdd = (x,y) -> x+y;
Long result = functionAdd.apply(1L, 2L);
```

- 对参数显示声明

```java
BinaryOperator<Long> functionAdd = (Long x, Long y) -> x+y;
Long result = functionAdd.apply(1L, 2L);
```


![函数编程](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/function.png)

### 流编程

![流编程](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/stream.png)

### 线程池

![线程池](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/threadPool.png)

### 资源关闭

![资源关闭](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/source.png)

## 优秀开源框架

### 工具集

![工具集](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/utils.png)

### 验证框架

![验证框架](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/auth.png)

### 实用工具

![实用工具](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/util.png)

## 开发常用工具

![开发常用工具](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/quit/itutil.png)