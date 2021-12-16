---
title: Java重要知识积累03--String和StringBuilder和ArrayList
categories: Java知识积累
tags: [Java, Java数据类型, String]
top: 10
abbrlink: 3937920951
date: 2019-07-02 18:18:19
password:

---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/first_foots/01.jpeg" width="1000" height="300" align="middle" />

<!--more-->

## String类的常用方法

String 类代表字符串，Java 程序中的所有字符串文字（例如“abc”）都被实现为此类的实例。也就是说，Java 程序中所有的双引号字符串，都是 String 类的对象。String 类在 java.lang 包下，所以使用的时候不需要导包！



### String类的构造方法


- 常用的构造方法

| 方法名                      | 说明                                      |
| --------------------------- | ----------------------------------------- |
| public   String()           | 创建一个空白字符串对象，不含有任何内容    |
| public   String(char[] chs) | 根据字符数组的内容，来创建字符串对象      |
| public   String(byte[] bys) | 根据字节数组的内容，来创建字符串对象      |
| String s =   “abc”;         | 直接赋值的方式创建字符串对象，内容就是abc |


### 使用String类的构造方法

```java

/**
 * @Author：pengzhilin
 * @Date: 2020/9/9 8:44
 * 构造方法通过new来调用
 * 成员方法:
 *      非静态成员方法:通过对象名来调用
 *      静态成员方法:通过类名来调用
 * 方法:
 *      无返回值:直接调用
 *      有返回值:
 *          直接调用
 *          赋值调用
 *          输出调用
 */
public class Test {
    public static void main(String[] args) {
        /*
            public   String() 创建一个空白字符串对象，不含有任何内容
            public   String(char[] chs) 根据字符数组的内容，来创建字符串对象
            public   String(char[] value, int offset, int count) 根据指定字符数组范围的内容，来创建字符串对象
            public   String(byte[] bys) 根据字节数组的内容，来创建字符串对象
            public   String(byte[] bytes, int offset, int length)根据指定字节数组范围的内容，来创建字符串对象
            String s =   “abc”;直接赋值的方式创建字符串对象，内容就是abc
         */
        // 创建空白字符串对象
        String str1 = new String();// str1字符串内容: ""
        System.out.println("="+str1+"=");// ==

        // 根据字符数组的内容，来创建字符串对象
        char[] chs = {'a','b','c','d'};
        String str2 = new String(chs);// str2字符串内容:"abcd"
        System.out.println(str2);// abcd

        // 根据指定字符数组范围的内容，来创建字符串对象
        String str3 = new String(chs, 0, 3);// str3字符串内容:"abc"
        System.out.println(str3);// abc

        // 根据字节数组的内容，来创建字符串对象
        byte[] bys = {97,98,99,100,101,102};
        String str4 = new String(bys);// str4字符串内容:"abcdef"
        System.out.println(str4);// abcdef

        // 根据指定字节数组范围的内容，来创建字符串对象
        String str5 = new String(bys, 2, 3);// str5字符串内容:"cde"
        System.out.println(str5);// cde

        // 直接赋值的方式创建字符串对象
        String str6 = "abc";// str6字符串内容:"abc"
        System.out.println(str6);

    }
}

```

###  创建字符串对象两种方式的区别

#### 通过构造方法创建

- 通过 new 创建的字符串对象，每一次 new 都会申请一个内存空间，虽然字符串内容相同，但是地址值不同


```java
char[] chs = {'a','b','c'};
String s1 = new String(chs);// s1字符串的内容: abc
String s2 = new String(chs);// s2字符串的内容: abc
// 上面的代码中,JVM首先会先创建一个字符数组,然后每一次new的时候都会有一个新的地址,只不过s1和s2参考的字符串内容是相同的
```

#### 直接赋值方式创建

- 以“”方式给出的字符串，只要字符序列相同(顺序和大小写)，无论在程序代码中出现几次，JVM 都只会建立一个 String 对象，并在字符串池中维护  


```java
String s3 = "abc";
String s4 = "abc";
// 上面的代码中,针对第一行代码,JVM会建立一个String对象放在字符串池中,并给s3参考;第二行代码,则让s4直接参考字符串池中String对象,也就是说他们本质上是同一个对象
```

#### 绘制内存图

```java
public class Test {
    public static void main(String[] args) {
        char[] chs = {'a','b','c'};
        String s1 = new String(chs);// s1字符串的内容: abc
        String s2 = new String(chs);// s2字符串的内容: abc
        System.out.println(s1 == s2);// 比较s1和s2的地址值 false

        // 直接赋值方式创建
        String str1 = "abc";// str1字符串的内容: abc
        String str2 = "abc";// str2字符串的内容: abc
        System.out.println(str1 == str2);// 比较str1和str2的地址值 true

    }
}

```

![1582730449429](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/string/img/1582730449429.png)



![1584169790187](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/string/img/1584169790187.png)


- 通过new创建的字符串对象,每一次都会新开辟空间
- 通过""方式直接创建的字符串对象,是常量,在常量池中,只有一份

### String类的特点

- String类的字符串不可变，它们的值在创建后不能被更改

  ```java
  String s1 = "abc";
  s1 += "d";
  System.out.println(s1); // "abcd" 
  // 内存中有"abc"，"abcd","d",3个对象，s1从指向"abc"，改变指向，指向了"abcd"。
  ```

- 虽然 String 的值是不可变的，但是它们可以被共享

  ```java
  String s1 = "abc";
  String s2 = "abc";
  // 内存中只有一个"abc"对象被创建，同时被s1和s2共享。
  ```

- 字符串效果上相当于字符数组( char[] )

  ```java
  例如： 
  String str = "abc";
  
  相当于： 
  char[] data = {'a', 'b', 'c'};     
  String str = new String(data);
  // String底层是靠字符数组实现的,jdk9底层是字节数组。
  
  byte[] bys = {97,98,99};
  String str = new String(bys);
  ```


### 字符串的比较

- 比较字符串内容是否相等,区分大小写,需要使用String类的equals方法,**千万不要用 == 比较**
- 如果比较字符串内容是否相等,不区分大小写,需要使用String类的equalsIgnoreCase()方法


#### ==号的比较

- 比较基本数据类型：比较的是具体的值

```java
int num1 = 10;
int num2 = 20;
num1 == num2  ===> 10==20  结果:false
```

- 比较引用数据类型：比较的是对象地址值

```java
String str1 = new String("abc");
String str2 = new String("abc");
str1 == str2 ===> 
str1存储的对象地址值 == str2存储的对象地址值  
结果: false
```

```java
public class StringDemo02 {
  public static void main(String[] args) {
      //构造方法的方式得到对象
      char[] chs = {'a', 'b', 'c'};
      String s1 = new String(chs);
      String s2 = new String(chs);

      //直接赋值的方式得到对象
      String s3 = "abc";
      String s4 = "abc";

      //比较字符串对象地址是否相同
      System.out.println(s1 == s2);// 
      System.out.println(s1 == s3);// 
      System.out.println(s3 == s4);// 
      System.out.println("--------");
  }
}
```

#### equals方法的作用

- 字符串是对象,它比较内容是否相同,是通过一个方法来实现的,就是equals()方法

- 方法介绍

```java
public boolean equals(Object s)     
比较两个字符串内容是否相同、区分大小写
```

- ` public boolean equalsIgnoreCase (String anotherString)` ：将此字符串与指定对象进行比较，忽略大小写。




### String类获取功能的方法



- public int length () ：返回此字符串的长度。
- public String concat (String str) ：将指定的字符串连接到该字符串的末尾。拼接
- public char charAt (int index) ：返回指定索引处的 char值。
- public int indexOf (String str) ：返回指定子字符串第一次出现在该字符串内的索引。
- public int indexOf(String str, int fromIndex)  返回从指定索引位置查找,该子字符串第一次出现在该字符串内的索引。
- public int lastIndexOf(String str) 返回指定子字符串最后一次出现在该字符串内的索引。
- public int lastIndexOf(String str, int fromIndex) 返回从指定索引位置查找,,该子字符串最后一次出现在该字符串内的索引。
- public String substring (int beginIndex) ：返回一个子字符串，从beginIndex开始截取字符串到字符串结尾。
- public String substring (int beginIndex, int endIndex) ：返回一个子字符串，从beginIndex到endIndex截取字符串。含beginIndex，不含endIndex。



## StringBuilder类


### 字符串拼接问题

由于String类的对象内容不可改变，所以每当进行字符串拼接时，总是会在内存中创建一个新的对象。例如：

```java
public class StringDemo {
    public static void main(String[] args) {
        String s = "Hello";
        s += "World";// s = s + "World";
        System.out.println(s);// HelloWorld
    }
}
```

在API中对String类有这样的描述：字符串是常量，它们的值在创建后不能被更改。

根据这句话分析我们的代码，其实总共产生了三个字符串，即`"Hello"`、`"World"`和`"HelloWorld"`。引用变量s首先指向`Hello`对象，最终指向拼接出来的新字符串对象，即`HelloWord` 。

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/string/img/String拼接问题.bmp)

由此可知，如果对字符串进行拼接操作，每次拼接，都会构建一个新的String对象，**既耗时，又浪费空间**。为了解决这一问题，可以使用`java.lang.StringBuilder`类。


###  StringBuilder类概述以及与String类的区别

StringBuilder 是一个可变的字符串类，我们可以把它看成是一个容器，这里的可变指的是 StringBuilder 对象中的内容是可变的

#### StringBuilder类和String类的区别

- String类：内容是不可变的

- StringBuilder类：内容是可变的

![06-StringBuilder的原理](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/string/img/06-StringBuilder的原理.png)


###  StringBuilder类的构造方法


- 常用的构造方法

| 方法名                             | 说明                                       |
| ---------------------------------- | ------------------------------------------ |
| public StringBuilder()             | 创建一个空白可变字符串对象，不含有任何内容 |
| public StringBuilder(String   str) | 根据字符串的内容，来创建可变字符串对象     |

- 示例代码

```java
public class Test {
    public static void main(String[] args) {
        /*
            StringBuilder类的构造方法:
            public StringBuilder() 
            创建一个空白可变字符串对象，不含有任何内容
            public StringBuilder(String str) 
            根据字符串的内容，来创建可变字符串对象
         */
        // 创建空白可变字符串对象  ""
        StringBuilder sb1 = new StringBuilder();
        System.out.println("sb1:"+sb1+"=");// sb1:=
        System.out.println("sb1的长度:"+sb1.length());// 0

        // 把不可变字符串转换为可变字符串
        String str = "itheima";
        // 不可变的字符串
        StringBuilder sb2 = new StringBuilder(str);
        // 可变的字符串,字符串内容是:itheima
        System.out.println("sb2:"+sb2);// sb2:itheima
        System.out.println("sb2的长度:"+sb2.length());// 7

    }
}

```

### StringBuilder类拼接和反转方法


- 添加和反转方法

```java
public StringBuilder append(任意类型) 拼接数据，并返回对象本身
public StringBuilder insert(int offset, 任意类型) 在指定位置插入数据,并返回对象本身
public StringBuilder reverse()  反转字符串,并返回对象本身
```


### StringBuilder和String相互转换


#### String转换为StringBuilder

`public StringBuilder(String s)`：通过StringBuilder的构造方法就可以实现把 String 转换为 StringBuilder

#### StringBuilder转换为String

`public String toString()`：通过StringBuilder类中的 toString() 就可以实现把 StringBuilder 转换为 String



## ArrayList


- 集合: 是一个大小可变的容器,可以用来存储多个引用类型的数据
- 集合和数组的区别:
  - 数组大小是固定
  - 集合大小是可变

###  ArrayList类概述


- 概述: ArrayList类底层是一个大小可变的数组实现
- 使用ArrayList<E>类的时候,在E出现的位置使用引用数据类型替换,表示该集合可以存储哪种引用类型的元素

###  ArrayList类构造方法


- `ArrayList()`  构造一个初始容量为 10 的空列表。 

### ArrayList类添加元素方法

- ArrayList添加元素的方法

  -  public boolean add(E e)：将指定的元素追加到此集合的末尾
  -  public void add(int index,E element)：在此集合中的指定位置插入指定的元素


### 扩展--集合存储基本数据类型以及指定位置添加元素的注意事项

```java
public class Test {
    public static void main(String[] args) {
        // 创建ArrayList集合对象,限制集合中元素的类型为Integer类型
        ArrayList<Integer> list = new ArrayList<>();

        // 往集合中添加元素
        list.add(10);
        list.add(20);
        list.add(30);
        list.add(40);
        System.out.println("list:"+list);// list:[10, 20, 30, 40]

        // 思考一:指定索引为4的位置添加一个元素50,是否可以?---可以
        list.add(4,50);// 相当于list.add(50);
        System.out.println("list:"+list);// list:[10, 20, 30, 40, 50]

        // 思考二:指定索引为6的位置添加一个元素100,是否可以?----不可以
        //list.add(6,100);
        // 运行报异常,IndexOutOfBoundsException索引越界异常

    }
}

```



### ArrayList类常用方法


```java
public boolean   remove(Object o) 
删除指定的元素，返回删除是否成功
public E   remove(int   index) 
删除指定索引处的元素，返回被删除的元素
public E   set(int index, E  element) 
修改指定索引处的元素，返回被修改的元素
public E   get(int   index) 
返回指定索引处的元素
public int   size() 
返回集合中的元素的个数
```


- 注意事项

```java
public class Test2 {
  public static void main(String[] args) {
      //  public boolean remove(Object o) 
      删除指定的元素，返回删除是否成功
      //  public E   remove(int   index) 
      删除指定索引处的元素，返回被删除的元素
      // 1.创建ArrayList集合对象,限制集合中元素的类型为Integer
      ArrayList<Integer> list = new ArrayList<>();

      // 2.往集合中存储int类型的整数
      list.add(1);
      list.add(2);
      list.add(3);
      list.add(4);
      System.out.println(list);// [1, 2, 3, 4]

      list.remove(1);// 删除索引为1的元素
      System.out.println(list);// [1, 3, 4]

      // 删除1这个元素,需要传入1的Integer对象
      list.remove(new Integer(1));
      System.out.println(list);// [3, 4]
  }
}

```


