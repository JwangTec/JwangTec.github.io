---
title: 构建型设计模式--原型模式 Prototype
categories: 设计模式
tags: [构建型模式, 原型模式]
top: 10
abbrlink: 1933872641
password:
---


## 原型模式

用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。

定义看起来有点绕口，实际上在 Java 中，Object 的 clone() 方法就属于原型模式，不妨简单的理解为：原型模式就是用来克隆对象的。

<!--more-->

## 运用

举个例子，比如有一天，周杰伦到奶茶店点了一份不加冰的原味奶茶，你说我是周杰伦的忠实粉，我也要一份跟周杰伦一样的。用程序表示如下：

- 奶茶类：

```java
public class MilkTea {
    public String type;
    public boolean ice;
}
```

- 下单

```java
private void order(){
    MilkTea milkTeaOfJay = new MilkTea();
    milkTeaOfJay.type = "原味";
    milkTeaOfJay.ice = false;
    
    MilkTea yourMilkTea = milkTeaOfJay;
}

```


好像没什么问题，将周杰伦的奶茶直接赋值到你的奶茶上就行了，看起来我们并不需要 clone 方法。但是这样真的是复制了一份奶茶吗？

当然不是，Java 的赋值只是引用传递，而不是值传递。这样赋值之后，yourMilkTea 仍然指向的周杰伦的奶茶，并不会多一份一样的奶茶。

那么我们要怎么做才能点一份一样的奶茶呢？将程序修改如下就可以了：


```java

private void order(){
    MilkTea milkTeaOfJay = new MilkTea();
    milkTeaOfJay.type = "原味";
    milkTeaOfJay.ice = false;
    
    MilkTea yourMilkTea = new MilkTea();
    yourMilkTea.type = "原味";
    yourMilkTea.ice = false;
}

```

只有这样，yourMilkTea 才是 new 出来的一份全新的奶茶。我们设想一下，如果有一千个粉丝都需要点和周杰伦一样的奶茶的话，按照现在的写法就需要 new 一千次，并为每一个新的对象赋值一千次，造成大量的重复。

更糟糕的是，如果周杰伦临时决定加个冰，那么粉丝们的奶茶配置也要跟着修改：

```java
private void order(){
    MilkTea milkTeaOfJay = new MilkTea();
    milkTeaOfJay.type = "原味";
    milkTeaOfJay.ice = true;
    
    MilkTea yourMilkTea = new MilkTea();
    yourMilkTea.type = "原味";
    yourMilkTea.ice = true;
    
    // 将一千个粉丝的 ice 都修改为 true
    ...
}

```

大批量的修改无疑是非常丑陋的做法，这就是我们需要 clone 方法的理由！

## 修正

- 运用原型模式，在 MilkTea 中新增 clone 方法：

```java
public class MilkTea{
    public String type;
    public boolean ice;

    public MilkTea clone(){
        MilkTea milkTea = new MilkTea();
        milkTea.type = this.type;
        milkTea.ice = this.ice;
        return milkTea;
    }
}


```

- 下单

```java
private void order(){
    MilkTea milkTeaOfJay = new MilkTea();
    milkTeaOfJay.type = "原味";
    milkTeaOfJay.ice = false;
    
    MilkTea yourMilkTea = milkTeaOfJay.clone();
    
    // 一千位粉丝都调用 milkTeaOfJay 的 clone 方法即可
    ...
}

```

这就是原型模式，Java 中有一个语法糖，让我们并不需要手写 clone 方法。这个语法糖就是 Cloneable 接口，我们只要让需要拷贝的类实现此接口即可。

```java
public class MilkTea implements Cloneable{
    public String type;
    public boolean ice;

    @NonNull
    @Override
    protected MilkTea clone() throws CloneNotSupportedException {
        return (MilkTea) super.clone();
    }
}

```
## 注意

值得注意的是，Java 自带的 clone 方法是浅拷贝的。也就是说调用此对象的 clone 方法，只有基本类型的参数会被拷贝一份，非基本类型的对象不会被拷贝一份，而是继续使用传递引用的方式。如果需要实现深拷贝，必须要自己手动修改 clone 方法才行。