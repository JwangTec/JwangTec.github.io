---
title: 构建型设计模式--工厂模式 Factory
categories: 设计模式
tags:
  - 设计模式
  - 工厂模式 Factory
  - 简单工厂模式
top: 90
abbrlink: 655849358
password:
---

## 概述
 
 平时构建对象最常用方法是new一个对象，这属于一种硬编码。每当new一个对象，调用者就会多知道一个类，类与类之间的耦合度增加。我们可以把构建过程封装起来，工厂模式就是用于封装对象的设计模式
 
 <!--more-->
 
## 简单工厂模式
 
 - 通常我们new一个对象我们需要某一个具体的对象的构造方法，相当于我们需要一个苹果，需要知道苹果的构造方法，需要栗子，就需要知道栗子的构造方法。
 - 更好的实现方法是有一个水果工厂，我们只需要告知需要什么具体的水果，水果工厂将需要的水果制造出来给我们就可以。整个过程只用和水果工厂打交道。
 
 ```java
 
 #水果工厂
 public class FruitFactory {
    public Fruit create(String type){
        switch (type){
            case "苹果": return new Apple();
            case "梨子": return new Pear();
            default: throw new IllegalArgumentException("暂时没有这种水果");
        }
    }
}

 #调用者
public class User {
    private void eat(){
        FruitFactory fruitFactory = new FruitFactory();
        Fruit apple = fruitFactory.create("苹果");
        Fruit pear = fruitFactory.create("梨子");
        apple.eat();
        pear.eat();
    }
}
```
 
 - 事实上，将构建过程封装的好处不仅可以降低耦合，如果某个产品构造方法相当复杂，使用工厂模式可以大大减少代码重复。比如，如果生产一个苹果需要苹果种子、阳光、水分，将工厂修改如下：

```java
public class FruitFactory {
    public Fruit create(String type) {
        switch (type) {
            case "苹果":
                AppleSeed appleSeed = new AppleSeed();
                Sunlight sunlight = new Sunlight();
                Water water = new Water();
                return new Apple(appleSeed, sunlight, water);
            case "梨子":
                return new Pear();
            default:
                throw new IllegalArgumentException("暂时没有这种水果");
        }
    }
}

```

- 调用者的代码则完全不需要变化，而且调用者不需要在每次需要苹果时，自己去构建苹果种子、阳光、水分以获得苹果。苹果的生产过程再复杂，也只是工厂的事。这就是封装的好处，假如某天科学家发明了让苹果更香甜的肥料，要加入苹果的生产过程中的话，也只需要在工厂中修改，调用者完全不用关心。

- 工厂模式一共有三种：

		简单工厂模式
		工厂方法模式
		抽象工厂模式
		注：在 GoF 所著的《设计模式》一书中，简单工厂模式被划分为工厂方法模式的一种特例，没有单独被列出来。


总而言之，简单工厂模式就是让一个工厂类承担构建所有对象的职责。调用者需要什么产品，让工厂生产出来即可。它的弊端也显而易见：

- 一是如果需要生产的产品过多，此模式会导致工厂类过于庞大，承担过多的职责，变成超级类。当苹果生产过程需要修改时，要来修改此工厂。梨子生产过程需要修改时，也要来修改此工厂。也就是说这个类不止一个引起修改的原因。违背了单一职责原则。
- 二是当要生产新的产品时，必须在工厂类中添加新的分支。而开闭原则告诉我们：类应该对修改封闭。我们希望在添加新功能时，只需增加新的类，而不是修改既有的类，所以这就违背了开闭原则。

## 工厂方法模式
 
 为了解决简单工厂模式的这两个弊端-单一职责原则和开闭原则，工厂方法模式应运而生，它规定每个产品都有一个专属工厂。比如苹果有专属的苹果工厂，梨子有专属的梨子工厂。
 
 ```java
 #苹果工厂
 public class AppleFactory {
    public Fruit create(){
        return new Apple();
    }
}

#橘子工厂
public class PearFactory {
    public Fruit create(){
        return new Pear();
    }
}

#调用者
public class User {
    private void eat(){
        AppleFactory appleFactory = new AppleFactory();
        Fruit apple = appleFactory.create();
        PearFactory pearFactory = new PearFactory();
        Fruit pear = pearFactory.create();
        apple.eat();
        pear.eat();
    }
}
 ```
 
 用简单工厂模式，我们只需要知道 FruitFactory，无需知道 Apple 、Pear 类，很容易看出耦合度降低了。但用工厂方法模式，调用者虽然不需要和 Apple 、Pear 类打交道了，但却需要和 AppleFactory、PearFactory 类打交道。有几种水果就需要知道几个工厂类，耦合度完全没有下降啊，甚至还增加了代码量！

仔细想一想，工厂模式的第二个优点在工厂方法模式中还是存在的。当构建过程相当复杂时，工厂将构建过程封装起来，调用者可以很方便的直接使用，同样以苹果生产为例：

```java
public class AppleFactory {
    public Fruit create(){
        AppleSeed appleSeed = new AppleSeed();
        Sunlight sunlight = new Sunlight();
        Water water = new Water();
        return new Apple(appleSeed, sunlight, water);
    }
}
```

调用者无需知道苹果的生产细节，当生产过程需要修改时也无需更改调用端。同时，工厂方法模式解决了简单工厂模式的两个弊端。

当生产的产品种类越来越多时，工厂类不会变成超级类。工厂类会越来越多，保持灵活。不会越来越大、变得臃肿。如果苹果的生产过程需要修改时，只需修改苹果工厂。梨子的生产过程需要修改时，只需修改梨子工厂。符合单一职责原则。
当需要生产新的产品时，无需更改既有的工厂，只需要添加新的工厂即可。保持了面向对象的可扩展性，符合开闭原则。

## 完整例子

```java
#口罩超类
abstract class Mask {
}


public class SurgicalMask extends Mask {
    @NonNull
    @Override
    public String toString() {
        return "这是医用口罩";
    }
}


public class N95Mask extends Mask {
    @NonNull
    @Override
    public String toString() {
        return "这是 N95 口罩";
    }
}
```

```java
#简单工厂模式
public class MaskFactory {
    public Mask create(String type){
        // 使用简单工厂模式实现此处的逻辑
        switch (type){
            case "Surgical":
                return new SurgicalMask();
            case "N95":
                return new N95Mask();
            default:
                throw new IllegalArgumentException("Unsupported mask type");
        }
    }
}


# 工厂模式
public class SurgicalMaskFactory{

    public Mask create() {
        return new SurgicalMask();
    }
}


public class N95MaskFactory {
    public Mask create() {
        return new N95Mask();
    }
}
```


 
 
 

