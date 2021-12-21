---
title: 构建型设计模式--抽象工厂模式 Abstract factory
categories: 设计模式
tags: [抽象工厂模式, 构建型模式]
top: 10
abbrlink: 1943064750
password:
---

## 抽象工厂模式

### 描述

提取公共的工厂接口，然后都实现该接口，调用者可以将实现的相关接口统一作为父类对象使用

<!--more-->

### 例子

比如水果工厂：

```java
#公共工厂接口
public interface IFactory {
    Fruit create();
}

#实现接口
public class AppleFactory implements IFactory {
    @Override
    public Fruit create(){
        return new Apple();
    }
}

#调用者
public class User {
    private void eat(){
        IFactory appleFactory = new AppleFactory();
        Fruit apple = appleFactory.create();
        IFactory pearFactory = new PearFactory();
        Fruit pear = pearFactory.create();
        apple.eat();
        pear.eat();
    }
}
```

- 可以看到，我们在创建时指定了具体的工厂类后，在使用时就无需再关心是哪个工厂类，只需要将此工厂当作抽象的 IFactory 接口使用即可。这种经过抽象的工厂方法模式被称作抽象工厂模式。

- 由于客户端只和 IFactory 打交道了，调用的是接口中的方法，使用时根本不需要知道是在哪个具体工厂中实现的这些方法，这就使得替换工厂变得非常容易。

```java
#吃苹果
public class User {
    private void eat(){
        IFactory factory = new AppleFactory();
        Fruit fruit = factory.create();
        fruit.eat();
    }
}

#吃橘子只修改一行代码
public class User {
    private void eat(){
        IFactory factory = new PearFactory();
        Fruit fruit = factory.create();
        fruit.eat();
    }
}
```

## 综述

- IFactory 中只有一个抽象方法时，或许还看不出抽象工厂模式的威力。实际上抽象工厂模式主要用于替换一系列方法。例如将程序中的 SQL Server 数据库整个替换为 Access 数据库，使用抽象方法模式的话，只需在 IFactory 接口中定义好增删改查四个方法，让 SQLFactory 和 AccessFactory 实现此接口，调用时直接使用 IFactory 中的抽象方法即可，调用者无需知道使用的什么数据库，我们就可以非常方便的整个替换程序的数据库，并且让客户端毫不知情。

- 抽象工厂模式很好的发挥了开闭原则、依赖倒置原则，但缺点是抽象工厂模式太重了，如果 IFactory 接口需要新增功能，则会影响到所有的具体工厂类。使用抽象工厂模式，替换具体工厂时只需更改一行代码，但要新增抽象方法则需要修改所有的具体工厂类。所以抽象工厂模式适用于增加同类工厂这样的横向扩展需求，不适合新增功能这样的纵向扩展。





 
 
 

