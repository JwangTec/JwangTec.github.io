---
title: Java重要知识积累04--常用API
categories: Java知识积累
tags:
  - 权限修饰符
  - BigInteger
  - BigDecimal
top: 10
abbrlink: 3250697702
date: 2019-07-03 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/first_foots/01.jpeg" width="1000" height="300" align="middle" />

<!--more-->


##  权限修饰符

###   概述

在Java中提供了四种访问权限，使用不同的访问权限修饰符修饰时，被修饰的内容会有不同的访问权限，

- public：公共的
- protected：受保护的
- (空的)：默认的
- private：私有的

### 不同权限的访问能力

|                        | public | protected | （空的） | private |
| ---------------------- | ------ | --------- | -------- | ------- |
| 同一类中               | √      | √         | √        | √       |
| 同一包中(子类与无关类) | √      | √         | √        |         |
| 不同包的子类           | √      | √         |          |         |
| 不同包中的无关类       | √      |           |          |         



可见，public具有最大权限。private则是最小权限。

编写代码时，如果没有特殊的考虑，建议这样使用权限：

- 成员变量使用`private` ，隐藏细节。

- 构造方法使用` public` ，方便创建对象。

- 成员方法使用`public` ，方便调用方法。


##  代码块



### 构造代码块

```java
格式: {}
位置: 类中,方法外
执行: 每次在调用构造方法的时候,就会执行
使用场景: 统计创建了多少个该类对象

例如:
public class Person{
    {
        构造代码块执行了
    }
}

public class Test {
    public static void main(String[] args) {
        /*
            构造代码块:
                格式: {}
                位置: 类中,方法外
                执行: 每次执行构造方法之前都会执行一次
                使用场景: 例如统计对象的个数 也就是每次执行构造方法之前要执行的代码就可以放在构造代码块中
         */
        Person p1 = new Person();
        Person p2 = new Person();
    }
}
```

###  静态代码块

格式：

```java
格式:static{}
位置: 类中,方法外
执行: 当类被加载的时候执行,并只执行一次
使用场景: 例如加载驱动,这种只需要执行一次的代码就可以放在静态代码块中         

package com.itheima.demo3_代码块.demo2_静态代码块;

/**
 * @Author：pengzhilin
 * @Date: 2020/9/10 9:46
 */
public class Person {
    static {
        System.out.println("Person 静态代码块");
    }

    {
        System.out.println("Person 构造代码块");
    }

    public Person(){
        System.out.println("Person 构造方法");
    }
}

public class Test {
    /*
         静态代码块:
            格式: static{}
            位置: 类中,方法外
            执行: 随着类的加载而执行,并且只执行一次
            使用场景: 例如读取配置文件中的数据,加载驱动,也就是说程序中只需要执行一次的代码就可以放在静态代码块中

            执行优先级:  静态代码块 >  构造代码块  >  构造方法
     */
    public static void main(String[] args) {
        Person p1 = new Person();
        Person p2 = new Person();

    }
}

```

### 局部代码块

```java
格式:{}
位置: 方法中
执行: 调用方法,执行到局部代码块的时候就执行
使用场景: 节省内存空间,没有多大的意义
例如:
public class Test {
    public static void main(String[] args) {
        /*
            局部代码块:
                格式: {}
                位置: 方法中
                执行: 调用方法,执行到了局部代码块的时候执行
                使用场景: 节省内存空间,没有太多意义
         */
        System.out.println("开始");
        {
            int num1 = 10;
            System.out.println("局部代码块");
        }// 把局部代码块中的变量占用的空间会释放

        System.out.println("结束");
    }
}

```



## Object类


- `java.lang.Object`类是Java语言中的根类，即所有类的父类。

  如果一个类没有特别指定父类，	那么默认则继承自Object类。例如：

```java
public class MyClass /*extends Object*/ {
	// ...
}
public class Fu{
  
}
public class Zi extends Fu{
  // 间接继承Object类: Zi继承Fu,Fu继承Object类
}
```

- Object类是java中的根类
- java中所有的类都是直接或者间接继承Object类,也就意味着,java中所有的类都拥有Object类中的那11个方法

### toString方法


- `public String toString()`：返回该对象的字符串表示，其实该字符串内容就是：对象的类型名+@+内存地址值。

由于toString方法返回的结果是内存地址，而在开发中，经常需要按照对象的属性得到相应的字符串表现形式，因此也需要重写它。

#### 重写toString方法

如果不希望使用toString方法的默认行为，则可以对它进行覆盖重写。例如自定义的Person类：

在IntelliJ IDEA中，可以点击`Code`菜单中的`Generate...`，也可以使用快捷键`alt+insert`，点击`toString()`选项。选择需要包含的成员变量并确定。

> 小贴士： 在我们直接使用输出语句输出对象名的时候,其实通过该对象调用了其toString()方法。


- toString方法默认返回的字符串内容格式: 对象的类型+@+十六进制数的地址值
- 特点:打印对象的时候,其实就是打印该对象调用toString方法返回的字符串内容
- 如果打印对象的时候不希望打印的是地址值的形式,那么就可以去重写toString方法,指定返回的字符串内容格式  ---->一般开发中,重写toString方法---alt+insert--->toString() 回车

###  equals方法

- `public boolean equals(Object obj)`：指示其他某个对象是否与此对象“相等”。

#### equals方法的使用


- Object类的equals()方法默认实心是==比较,也就是比较2个对象的地址值,对于我们来说没有用

##### 对象内容比较

如果希望进行对象的内容比较，即所有或指定的部分成员变量相同就判定两个对象相同，则可以覆盖重写equals方法。例如：



## Objects类


在**JDK7**添加了一个Objects工具类，它提供了一些方法来操作对象，它由一些静态的实用方法组成，这些方法是null-save（空指针安全的）或null-tolerant（容忍空指针的），用于计算对象的hashCode、返回对象的字符串表示形式、比较两个对象。

在比较两个对象的时候，Object的equals方法容易抛出空指针异常，而Objects类中的equals方法就优化了这个问题。方法如下：

- `public static boolean equals(Object a, Object b)`:判断两个对象是否相等。

我们可以查看一下源码，学习一下：

```java
public static boolean equals(Object a, Object b) {  
    return (a == b) || (a != null && a.equals(b));  
}
```

```java

public class Test {
    public static void main(String[] args) {
        /*
            Objects类: 避免空指针异常(容忍空指针)
                public static boolean equals(Object a, Object b):判断两个对象是否相等。
                源码:
                     public static boolean equals(Object a, Object b) {
                        return (a == b) || (a != null && a.equals(b));
                    }
         */
        String name1 = "张三";
        String name2 = new String("张三");
        String name3 = null;
        System.out.println(name1);// 张三
        System.out.println(name2);// 张三

        // 比较name1和name2字符串内容是否相同
        //System.out.println(name1.equals(name2));// true
        //System.out.println(name3.equals(name1));// 空指针异常NullPointerException,因为null不能调用方法

        System.out.println(Objects.equals(name1, name2));// true
        System.out.println(Objects.equals(name3, name1));// false
    }
}

```

## native方法


在Object类的源码中定义了 **native** 修饰的方法， native 修饰的方法称为本地方法。这种方法是没有方法体的

- 本地方法的作用： 就是当Java调用非[Java](https://baike.baidu.com/item/Java/85979)代码的接口。方法的实现由非Java语言实现，比如C或C++。 

> Object类源码(部分)：

```java
package java.lang;
public class Object {
	//本地方法
    private static native void registerNatives();
    //静态代码块
    static {
        registerNatives();
    }
    ......
    ......
}
```

## Date类


` java.util.Date`类 表示一个日期和时间，内部精确到毫秒。

### Date类中的构造方法


- `public Date()`：从运行程序的此时此刻到时间原点经历的毫秒值,转换成Date对象，分配Date对象并初始化此对象，以表示分配它的时间（精确到毫秒）。
- `public Date(long date)`：将指定参数的毫秒值date,转换成Date对象，分配Date对象并初始化此对象，以表示自从标准基准时间（称为“历元（epoch）”，即1970年1月1日00:00:00 GMT）以来的指定毫秒数。

> tips: 由于中国处于东八区（GMT+08:00）是比世界协调时间/格林尼治时间（GMT）快8小时的时区，当格林尼治标准时间为0:00时，东八区的标准时间为08:00。

简单来说：使用无参构造，可以自动设置当前系统时间的毫秒时刻；指定long类型的构造参数，可以自定义毫秒时刻。例如：


> tips:在使用println方法时，会自动调用Date类中的toString方法。Date类对Object类中的toString方法进行了覆盖重写，所以结果为指定格式的字符串。

### Date类中的常用方法

Date类中的多数方法已经过时，常用的方法有：

```java
public long getTime() 
获取当前日期对象距离标准基准时间的毫秒值。
public void setTime(long time) 
设置当前日期对象距离标准基准时间的毫秒值.也就意味着改变了当前日期对象
public boolean after(Date when) 
测试此日期是否在指定日期之后。
public boolean before(Date when) 
测试此日期是否在指定日期之前。
```


## DateFormat类


`java.text.DateFormat` 是日期/时间格式化子类的抽象类，我们通过这个类可以帮我们完成日期和文本之间的转换,也就是可以在Date对象与String对象之间进行来回转换。

- **格式化**：按照指定的格式，把Date对象转换为String对象。
- **解析**：按照指定的格式，把String对象转换为Date对象。

由于DateFormat为抽象类，不能直接使用，所以需要常用的子类`java.text.SimpleDateFormat`。这个类需要一个模式（格式）来指定格式化或解析的标准。构造方法为：

- `public SimpleDateFormat(String pattern)`：用给定的模式和默认语言环境的日期格式符号构造SimpleDateFormat。参数pattern是一个字符串，代表日期时间的自定义格式。

### 格式规则


| 标识字母（区分大小写） | 含义 |
| ---------------------- | ---- |
| y                      | 年   |
| M                      | 月   |
| d                      | 日   |
| H                      | 时   |
| m                      | 分   |
| s                      | 秒   |

> 备注：更详细的格式规则，可以参考SimpleDateFormat类的API文档。

### 常用方法

DateFormat类的常用方法有：

- `public String format(Date date)`：将Date对象格式化为字符串。

- `public Date parse(String source)`：将字符串解析为Date对象。


## Calendar类



- java.util.Calendar类表示一个“日历类”，可以进行日期运算。它是一个抽象类，不能创建对象，我们可以使用它的子类：java.util.GregorianCalendar类。
- 有两种方式可以获取GregorianCalendar对象：
  - 直接创建GregorianCalendar对象；
  - 通过Calendar的静态方法getInstance()方法获取



### Calendar类的常用方法

- `public static Calendar getInstance()` 获取当前日期的日历对象
- `public int get(int field)` 获取某个字段的值。
  - 参数field:表示获取哪个字段的值,可以使用Calender中定义的常量来表示
  - Calendar.YEAR : 年<br />Calendar.MONTH ：月<br />Calendar.DAY_OF_MONTH：月中的日期<br />Calendar.HOUR：小时<br />Calendar.MINUTE：分钟<br />Calendar.SECOND：秒<br />Calendar.DAY_OF_WEEK：星期
- `public void set(int field,int value) `设置某个字段的值
- `public void add(int field,int amount)`为某个字段增加/减少指定的值
- 额外扩展2个方法:
  - `void setTime(Date date)`  使用给定的 Date 设置此 Calendar 的时间。
  - `boolean before(Object when) `判断此 Calendar 表示的时间是否在指定 Object 表示的时间之前，返回判断结果。
    - 调用before方法的日历对象是否在参数时间对象之前,
      -  如果在之前就返回true     例如: 2017年11月11日   2019年12月18日   true
      - 如果不在之前就返回false  例如: 2019年12月18日    2017年11月11日  false


### 注意

- 1.中国人:一个星期的第一天是星期一,外国人:一个星期的第一天是星期天
- 2.日历对象中的月份是: 0-11



## BigInteger类


java.math.BigInteger 类，不可变的任意精度的整数。如果运算中，数据的范围超过了long类型后，可以使用
BigInteger类实现，该类的计算整数是不限制长度的。

### BigInteger类的构造方法

- BigInteger(String value) 将 BigInteger 的十进制字符串表示形式转换为 BigInteger。超过long类型的范围，已经不能称为数字了，因此构造方法中采用字符串的形式来表示超大整数，将超大整数封装成BigInteger对象。

### BigInteger类成员方法

BigInteger类提供了对很大的整数进行加add、减subtract、乘multiply、除divide的方法，注意：都是与另一个BigInteger对象进行运算。

| 方法声明                   | 描述                                                         |
| -------------------------- | ------------------------------------------------------------ |
| add(BigInteger value)      | 返回其值为 (this + val) 的 BigInteger，超大整数加法运算      |
| subtract(BigInteger value) | 返回其值为 (this - val) 的 BigInteger，超大整数减法运算      |
| multiply(BigInteger value) | 返回其值为 (this * val) 的 BigInteger，超大整数乘法运算      |
| divide(BigInteger value)   | 返回其值为 (this / val) 的 BigInteger，超大整数除法运算，除不尽取整数部分 |


## BigDecimal类


### BigDecimal类的概述

使用基本类型做浮点数运算精度问题；

看程序说结果：

```java
public static void main(String[] args) {
    System.out.println(0.09 + 0.01);
    System.out.println(1.0 - 0.32);
    System.out.println(1.015 * 100);
    System.out.println(1.301 / 100);
}
```

- **对于浮点运算，不要使用基本类型，而使用"BigDecimal类"类型**

- **java.math.BigDecimal(类):提供了更加精准的数据计算方式。** 

###  BigDecimal类构造方法

| 构造方法名             | 描述                                            |
| ---------------------- | ----------------------------------------------- |
| BigDecimal(double val) | 将double类型的数据封装为BigDecimal对象          |
| BigDecimal(String val) | 将 BigDecimal 的字符串表示形式转换为 BigDecimal |

注意：推荐使用第二种方式，第一种存在精度问题；

###  BigDecimal类常用方法

BigDecimal类中使用最多的还是提供的进行四则运算的方法，如下：

| 方法声明                                     | 描述     |
| -------------------------------------------- | -------- |
| public BigDecimal add(BigDecimal value)      | 加法运算 |
| public BigDecimal subtract(BigDecimal value) | 减法运算 |
| public BigDecimal multiply(BigDecimal value) | 乘法运算 |
| public BigDecimal divide(BigDecimal value)   | 除法运算 |

注意：对于divide方法来说，如果除不尽的话，就会出现java.lang.ArithmeticException异常。此时可以使用divide方法的另一个重载方法；

> BigDecimal divide(BigDecimal divisor, int scale, RoundingMode roundingMode): divisor：除数对应的BigDecimal对象；scale:精确的位数；roundingMode取舍模式

RoundingMode枚举: RoundingMode.HALF_UP 四舍五入 


## Arrays类


java.util.Arrays类：该类包含用于操作数组的各种方法（如排序和搜索）

### Arrays类常用方法

- public static void sort(int[] a)：按照数字顺序排列指定的数组

- public static String toString(int[] a)：返回指定数组的内容的字符串表示形式


## 包装类



Java提供了两个类型系统，基本类型与引用类型，使用基本类型在于效率，然而很多情况，会创建对象使用，因为对象可以做更多的功能，如果想要我们的基本类型像对象一样操作，就可以使用基本类型对应的包装类，如下：

| 基本类型 | 对应的包装类（位于java.lang包中） |
| -------- | --------------------------------- |
| byte     | Byte                              |
| short    | Short                             |
| int      | **Integer**                       |
| long     | Long                              |
| float    | Float                             |
| double   | Double                            |
| char     | **Character**                     |
| boolean  | Boolean                           |



### Integer类


包装一个对象中的原始类型 int 的值

#### Integer类构造方法及静态方法

| 方法名                                  | 说明                                   |
| --------------------------------------- | -------------------------------------- |
| public Integer(int   value)             | 根据 int 值创建 Integer 对象(过时)     |
| public Integer(String s)                | 根据 String 值创建 Integer 对象(过时)  |
| public static Integer valueOf(int i)    | 返回表示指定的 int 值的 Integer   实例 |
| public static Integer valueOf(String s) | 返回保存指定String值的 Integer 对象    |


###  装箱与拆箱


基本类型与对应的包装类对象之间，来回转换的过程称为”装箱“与”拆箱“：

- **装箱**：从基本类型转换为对应的包装类对象。
- **拆箱**：从包装类对象转换为对应的基本类型。

#### 自动装箱与自动拆箱

由于我们经常要做基本类型与包装类之间的转换，从Java 5（JDK 1.5）开始，基本类型与包装类的装箱、拆箱动作可以自动完成。例如：

```java
public class Test {
public static void main(String[] args) {
    // 装箱
    // int--->Integer
    Integer i1 = new Integer(10);
    // i1对象表示的整数就是10
    Integer i2 = Integer.valueOf(10);
    //    i2对象表示的整数就是10

    // 拆箱
    // Integer--->int
    int num1 = i1.intValue();
    int num2 = i2.intValue();

    System.out.println("==========================");

    // 自动装箱
    Integer i3 = 10;

    // 自动拆箱
    int num3 = i3;

}
}

```


## 基本类型与字符串之间的转换

### 基本类型转换为String

- 转换方式
- 方式一：直接在数字后加一个空字符串
- 方式二：通过String类静态方法valueOf()
- 示例代码

```java
public class IntegerDemo {
    public static void main(String[] args) {
        //int --- String
        int number = 100;
        //方式1
        String s1 = number + "";
        System.out.println(s1);
        //方式2
        //public static String valueOf(int i)
        String s2 = String.valueOf(number);
        System.out.println(s2);
        System.out.println("--------");
    }
}
```

### String转换成基本类型 

除了Character类之外，**其他所有包装类都具有parseXxx静态方法可以将字符串参数转换为对应的基本类型**：

- `public static byte parseByte(String s)`：将字符串参数转换为对应的byte基本类型。
- `public static short parseShort(String s)`：将字符串参数转换为对应的short基本类型。
- **`public static int parseInt(String s)`：将字符串参数转换为对应的int基本类型。**
- **`public static long parseLong(String s)`：将字符串参数转换为对应的long基本类型。**
- `public static float parseFloat(String s)`：将字符串参数转换为对应的float基本类型。
- `public static double parseDouble(String s)`：将字符串参数转换为对应的double基本类型。
- `public static boolean parseBoolean(String s)`：将字符串参数转换为对应的boolean基本类型。


```java
public class IntegerDemo {
    public static void main(String[] args) {
         // 基本类型--->字符串:
        String str1 = 100 + "";
        // str1字符串的内容:"100"
        String str2 = String.valueOf(100);
        // str2字符串的内容: "100"

        // 字符串--->基本类型:
        int num1 = Integer.parseInt(str1);
        int num2 = Integer.parseInt(str2);
        System.out.println(num1+num2);// 200
    }
}
```

> 注意:如果字符串参数的内容无法正确转换为对应的基本类型，则会抛出`java.lang.NumberFormatException`异常。
