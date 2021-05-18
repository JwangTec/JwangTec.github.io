---
title: Java重要知识积累01--面相对象
categories: Java知识积累
tags:
  - 面相对象
top: 10
abbrlink: 1572511114
date: 2019-07-01 18:18:19
password:
---



<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/first_foots/02.jpeg" width="1000" height="300" align="middle" />

## 类和对象

<!--more-->

### 面向对象和面向过程编程思想


#### 面向过程编程思想

- **强调的是过程,必须清楚每一个步骤,然后按照步骤一步一步去实现**

#### 面向对象编程思想

- **强调的是对象, 通过调用对象的行为来实现功能，而不是自己一步一步的去操作实现。**

#### 举例对比2种编程思想
  
- java程序:  需求:打印数组中所有的元素,打印格式为: [元素1，元素2，元素3，元素，...，元素n]


```java
  private static void method01() {
      // 1.面向过程来实现该需求
      // 1.1 定义一个数组,并且初始化数组中的元素
      int[] arr = {10, 20, 30, 40, 50};
  
      // 1.2 按照指定格式去打印
      // 1.2.1 先打印一个左中括号 "["
      System.out.print("[");
  
      // 1.2.2 循环遍历元素
      for (int i = 0; i < arr.length; i++) {
          // 1.2.3 判断遍历的元素是否是最后一个元素
          int e = arr[i];
          if (i == arr.length - 1) {
              // 1.2.5 如果是最后一个元素,那么打印格式就是 "元素]"
              System.out.print(e+"]");
          } else {
              // 1.2.4 如果不是最后一个元素,那么打印格式就是 "元素, "
              System.out.print(e+", ");
          }
      }
  
  
      // 2.面向对象来实现该需求
      // Arrays数组的工具类,toString()方法,可以帮助我们按照该指定格式打印数组
      System.out.println(Arrays.toString(arr));// [10, 20, 30, 40, 50]
  }

```


### 类的概述

- 类是用来描述一类具有**共同属性和行为事物的统称**。所以其实类在客观世界里是不存在的，**是抽象的**，只是用来描述数据信息的。

#### 类的组成

- 属性：就是该事物的状态信息。
- 行为：就是该事物能够做什么。

##### 举例

- 手机类
  - 属性：品牌、价格----成员变量
  - 行为：打电话、发短信----成员方法


### 对象的概述

- 对象是类的一个实例，**具体存在的，看得见摸得着的**，并且具备该类事物的属性和行为
  - 对象的属性:对象的属性具有特定的值
  - 对象的行为:对象可以操作的行为
- 手机类: 描述手机
  - 对象:袁芳老师的手机


### 类和对象的关系

![1584029135069](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/1_类和对象的关系.png)


### 类的定义【应用】


类的组成是由属性和行为两部分组成

* 属性：该类事物的状态信息,在类中通过成员变量来体现（类中方法外的变量）
* 行为：该类事物有什么功能,在类中通过成员方法来体现（和前面的方法相比去掉static关键字即可）

#### 类的定义格式

```java
public class 类名 {// 定义一个类
	// 类里面:属性(成员变量),行为(成员方法)
    // 定义成员变量
    数据类型 变量名1;
    数据类型 变量名2;
    ...
        
    // 定义成员方法
    方法;  去掉static
}
```
  

### 对象的创建和使用


#### 对象的创建

* 创建对象的格式：
  * `类名 对象名 = new 类名();`
  * 类其实就是对象的数据类型,类是引用数据类型
     * 例: Phone p1 = new Phone ();   创建了一个手机对象(Phone类的对象)

#### 对象的使用

* 调用成员的格式：
  * 访问成员变量
     * 获取成员变量的值: 对象名.成员变量名
     * 给成员变量赋值: 对象名.成员变量名=值;
  * 访问成员方法
     * 对象名.成员方法名(实参);

#### 成员变量是有默认值

```java
整数类型    默认值         0
小数类型    默认值         0.0
字符类型    默认值         不可见字符 '\u0000'
布尔类型    默认值         false
引用数据类型 默认值        null
```


### 对象内存图相关使用的测试类


```java
public class Student {
    // 属性: 姓名,年龄
    String name;// 姓名
    int age;// 年龄

    // 行为:学习功能
    public void study(){
        System.out.println("正在努力学Java...");
    }
}

```

### 单个对象内存图

- 只要创建对象,就会在堆区开辟一块空间
- 只要调用方法,就会在栈区开辟一块空间,用来执行该方法


![1584072556325](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/2_单个对象的内存图.png)


### 多个对象内存图 


![image-20200607105906300](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/image-20200607105906300.png)


- 多个对象在堆内存中，都有不同的内存划分，成员变量存储在各自的内存区域中，成员方法多个对象共用的一份
- 凡是new就会重新在堆区开辟一块新空间
- 对象和对象之间的关系是相互独立的

### 多个变量指向相同对象内存图 


![1584081535183](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/4_多个变量指向相同对象内存图.png)


- 当多个对象的引用指向同一个内存空间（变量所记录的地址值是一样的）
- 只要有任何一个对象修改了内存中的数据，随后，无论使用哪一个对象进行数据获取，都是修改后的数据。



### 成员变量和局部变量的区别 


![1582716017361](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/1582716017361.png)

* 类中位置不同：成员变量（类中方法外）局部变量（方法内部或方法声明上）
* 内存中位置不同：成员变量（堆内存）局部变量（栈内存）
* 生命周期不同：成员变量（随着对象的存在而存在，随着对象的消失而消失）局部变量（随着方法的调用而存在，随着方法的调用完毕而消失）
* 初始化值不同：成员变量（有默认初始化值）局部变量（没有默认初始化值，必须先定义，赋值才能使用）


![1584082793302](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/5_成员变量和局部变量的区别.png)


## 封装

### private关键字

- 概述: private是一个权限修饰符，代表最小权限。
- 特点:
  - 可以修饰成员变量和成员方法。
  - 被private修饰后的成员变量和成员方法，只在本类中才能访问。

#### private的使用格式

```java
// private关键字修饰成员变量
private 数据类型 变量名 ；

// private关键字修饰成员方法
private 返回值类型 方法名(参数列表){
    代码
}
```

#### 案例 

```java
public class Student {
    // 成员变量
    String name;// 姓名
    private int age;// 年龄

    public void show(){
        System.out.println(name);
        System.out.println(age);// 可以访问
        study();// 可以访问
    }

    private void study(){
        System.out.println("正在努力学Java");
    }

}
public class Test {
    public static void main(String[] args) {
        Student stu = new Student();
        System.out.println(stu.name);
        //System.out.println(stu.age);// 编译报错,没有访问权限

        //stu.study();// 编译报错,没有访问权限

        // 间接访问
        stu.show();
    }
}

```

### 对属性封装的步骤

#### 为什么要对属性进行封装

- 通过对象名直接访问成员变量的方式来对属性赋值,会存在数据安全隐患,应该怎么解决呢?
- 解决方式: 不让外界直接访问成员变量(也就是要对属性进行封装)

#### 对属性封装的步骤

1. 使用private修饰成员变量

```java
public class Student {
   // 类的属性 ---> 成员变量
   // 姓名(name)
   private String name;

   // 年龄(age)
   private int age;

   // 类的行为 ---> 成员方法
   public void show(){
       System.out.println("姓名:"+name+",年龄:"+age);
   }
}
```

2. 对需要访问的成员变量,提供对应的`getXxx`方法(获取属性的值) 、`setXxx` 方法(给属性赋值)。

### set和get方法


- 由于属性使用了private关键字修饰,在其他类中无法直接访问,所以得提供公共的访问方法,我们把这张方法叫做set和get方法

  * get方法:  提供“get变量名()”方法，用于获取成员变量的值，方法用public修饰

  - set方法: 提供“set变量名(参数)”方法，用于设置成员变量的值，方法用public修饰


#### set和get方法的书写

```java
public class Student {

  private int age;

  public void setAge(int a) {
    age = a;
  }

  public int getAge() {
    return age;
  }
}
```


```java
set方法的书写规律:
    1.set方法一定是一个公共的方法(public)
        2.set方法一定没有返回值(void)
        3.set方法的方法名一定是set+属性名,并且属性名首字母大写
        4.set方法一定有参数
        5.set方法一定会给属性赋值

get方法的书写规律:
    1.get方法一定是一个公共的方法(public)
        2.get方法一定有返回值,并且返回值类型与获取的属性类型一致
        3.get方法的方法名一定是get+属性名,并且属性名首字母大写
        4.get方法一定没有参数
        5.get方法一定会返回属性的值
```



### this关键字

- `setXxx` 方法中的形参名字并不符合见名知意的规定，那么如果修改与成员变量名一致，是否就见名知意了呢？


- 经过修改和测试，我们发现新的问题，成员变量赋值失败了。也就是说，在修改了`setXxx()` 的形参变量名后，方法并没有给成员变量赋值！这是由于形参变量名与成员变量名重名，导致成员变量名被隐藏，方法中的变量名，无法访问到成员变量，从而赋值失败。所以，我们只能使用this关键字，来解决这个重名问题。

![1584082793302](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/5_成员变量和局部变量同名问题分析.png)



#### this的含义和使用

- this含义: this代表当前调用方法的引用，哪个对象调用this所在的方法，this就代表哪一个对象

- this关键字其主要作用是区分同名的局部变量和成员变量

  - 方法的形参如果与成员变量同名，不带this修饰的变量指的是形参，而不是成员变量
  - 方法的形参没有与成员变量同名，不带this修饰的变量指的是成员变量

- this的使用格式:

  ```java
  this.成员变量名
  ```

- 使用 `this` 修饰方法中的变量，解决成员变量被隐藏的问题
  

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/6_this%E5%85%B3%E9%94%AE%E5%AD%97.png)

 > 小贴士：方法中只有一个变量名时，默认也是使用 `this` 修饰，可以省略不写。

### this内存原理

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/OA/img/image-20200601121319604.png)

### 封装概述

- 是面向对象三大特征之一（封装，继承，多态）
- 是面向对象编程语言对客观世界的模拟，客观世界里成员变量都是**隐藏**在对象内部的，外界是无法直接操作的

#### 封装原则

- 将类的某些信息隐藏在类内部，不允许外部程序直接访问，而是通过该类提供的方法来实现对隐藏信息的操作和访问
- 例如:成员变量使用private修饰，提供对应的getXxx()/setXxx()方法

#### 封装好处

- 通过方法来控制成员变量的操作，提高了代码的安全性
- 把代码用方法进行封装，提高了代码的复用性


## 构造方法

### 构造方法概述

- 构造方法是一种特殊的方法,主要是完成对象的创建和对象数据的初始化

#### 构造方法的定义

- 格式

  ```java
  // 空参构造方法
  修饰符 类名(){
      
  }
  
  // 有参构造方法
  修饰符 类名(参数列表){
  	// 方法体
  }
  
  
  ```

- 特点:

  - 构造方法的写法上，方法名与它所在的类名相同
  - 构造方法没有返回值，所以不需要返回值类型，甚至不需要void

- 示例代码：

```java
public class Student {
    // 属性
    String name;
    int age;

    // 构造方法:
    // 空参构造方法
    // 创建对象,属性为默认值
    public Student(){//空参构造
        System.out.println("空参构造方法执行了...");
    }

    // 有参构造方法
    public Student(String name,int age){// 满参构造方法
        // 给属性赋值
        this.name = name;
        this.age = age;
    }

    public Student(String name){// 有参构造方法
        // 给属性赋值
        this.name = name;
    }

    // 方法
    public void show(){
        System.out.println("姓名:"+name+",年龄:"+age);
    }

}

/*
    测试类
 */
public class Demo1Student {
    public static void main(String[] args) {
        // 使用构造方法
        // 创建Student对象:  类名 对象名 = new 类名();
        // 调用空参构造方法创建对象,对象的属性为默认值
        Student stu1 = new Student();// 等于号的右边其实就是调用空参构造方法
        stu1.show();// 姓名:null,年龄:0

        // 调用满参构造方法创建对象,对象的属性会被赋值
        Student stu2 = new Student("冰冰",18);
        stu2.show();// 姓名:冰冰,年龄:18

        // 调用有参构造方法创建对象,对象的部分属性会被赋值
        Student stu3 = new Student("小泽老师");
        stu3.show();// // 姓名:小泽老师,年龄:0

    }
}
```

### 构造方法的注意事项


* 构造方法的创建
  * 如果没有定义构造方法，系统将给出一个默认的无参数构造方法
  * 如果定义了构造方法，系统将不再提供默认的构造方法

* 构造方法可以重载，既可以定义参数，也可以不定义参数。

* 示例代码

```java
/*
    学生类
 */
class Student {
    private String name;
    private int age;

    public Student() {}

    public Student(String name) {
        this.name = name;
    }

    public Student(int age) {
        this.age = age;
    }

    public Student(String name,int age) {
        this.name = name;
        this.age = age;
    }

    public void show() {
        System.out.println(name + "," + age);
    }
}
/*
    测试类
 */
public class StudentDemo {
    public static void main(String[] args) {
        //创建对象
        Student s1 = new Student();
        s1.show();

        //public Student(String name)
        Student s2 = new Student("林青霞");
        s2.show();

        //public Student(int age)
        Student s3 = new Student(30);
        s3.show();

        //public Student(String name,int age)
        Student s4 = new Student("林青霞",30);
        s4.show();
    }
}
```


### 标准类制作


#### 标准类的组成

`JavaBean` 是 Java语言编写类的一种标准规范。符合`JavaBean` 的类，要求类必须是公共的，属性使用private修饰,并且具有无参数的构造方法，提供用来操作成员变量的`set` 和`get` 方法。


```java
public class ClassName{
  //成员变量  private
  //构造方法
  //无参构造方法【必须】
  //满参构造方法【建议】
  //getXxx()
  //setXxx()
  //成员方法	
}
```

## API

- 什么是API

  ​	API (Application Programming Interface) ：应用程序编程接口。Java API是一本程序员的`字典` ，是JDK中提供给我们使用的类的**说明文档**。这些类将底层的代码实现封装了起来，我们不需要关心这些类是如何实现的，只需要学习这些类如何使用即可。所以我们可以通过查询API的方式，来学习Java提供的类，并得知如何使用它们。

  - API其实就是jdk中核心类库的说明文档
  - 对于jdk中的核心类库只需要知道如何使用,无须关心他是如何实现的

### API的使用步骤

1. 打开API帮助文档。
2. 点击显示，找到索引，看到输入框。
3. 你要找谁？在输入框里输入，然后回车。
4. 看包。java.lang下的类不需要导包，其他需要。  
5. 看类的解释和说明。
6. 看构造方法。
7. 看成员方法。


