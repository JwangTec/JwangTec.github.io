---
title: Java重要知识积累02--从数据结构到Java常用集合
categories: Java知识积累
tags:
  - Java集合 - 数据结构
top: 10
abbrlink: 3265662706
date: 2019-07-02 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/first_foots/01.jpeg)

# 从数据结构到Java常用集合


- 常用的数据结构可根据数据访问的特点分为**线性结构**和**非线性结构**。线性结构包括常见的链表、栈、队列等，非线性结构包括**树**、**图**等。数据结构种类繁多，本篇内容将通过图解的方式对常用的数据结构以及在java中的实现进行介绍

<!--more-->

**数据结构组织图**

![å¨è¿éæå¥å¾çæè¿°](https://img-blog.csdnimg.cn/20200526095818285.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2JlZXdvcmtzaG9w,size_16,color_FFFFFF,t_70) 

**Java集合组织图**

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20170918091025493-1734810124.png) 

# 数组 

​	数组可以说是最基本最常见的数据结构。数组一般用来存储相同类型的数据，可通过数组名和下标进行数据的访问和更新。数组中元素的存储是按照先后顺序进行的，同时，在内存中也是按照这个顺序进行连续存放。数组相邻元素之间的内存地址的间隔一般就是数组数据类型的大小。

![image-20200811092114529](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811092114529.png)

## ArrayList概述 

- ArrayList是可以动态增长和缩减的索引序列，它**是基于数组实现**的List类。

- 该类封装了一个动态再分配的Object[]数组，每一个类对象都有一个capacity属性，表示它们所封装的Object[]数组的长度，当向ArrayList中添加元素时，该属性值会自动增加。

- ArrayList的用法和Vector向类似，但是Vector是一个较老的集合，具有很多缺点，不建议使用。

 - 另外，ArrayList和Vector的区别是：ArrayList是线程不安全的，当多条线程访问同一个ArrayList集合时，程序需要手动保证该集合的同步性，而Vector则是线程安全的。

- ArrayList和Collection的关系：

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018145151287-1709338098.png)

## ArrayList的数据结构 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018145259474-886553593.png)

- 底层的数据结构就是数组，数组元素类型为Object类型，即可以存放所有类型数据。我们对ArrayList类的实例的所有的操作底层都是基于数组的。

## ArrayList源码分析 

### 继承结构和层次关系 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018145449709-655616177.png)

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018145519068-1615466435.png)



- 为什么要先继承AbstractList，而让AbstractList先实现List<E>？而不是让ArrayList直接实现List<E>？

	- 这里是有一个思想，接口中全都是抽象的方法，而抽象类中可以有抽象方法，还可以有具体的实现方法，正是利用了这一点，让AbstractList实现接口中一些通用的方法，而具体的类，如ArrayList就继承这个AbstractList类，拿到一些通用的方法，然后自己在实现一些自己特有的方法，这样一来，让代码更简洁，就继承结构最底层的类中通用的方法都抽取出来，先一起实现了，减少重复代码。所以一般看到一个类上面还有一个抽象类，应该就是这个作用。

### 类中的属性

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
{
    // 版本号
    private static final long serialVersionUID = 8683452581122892189L;
    // 缺省容量
    private static final int DEFAULT_CAPACITY = 10;
    // 空对象数组
    private static final Object[] EMPTY_ELEMENTDATA = {};
    // 缺省空对象数组
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
    // 元素数组
    transient Object[] elementData;
    // 实际元素大小，默认为0
    private int size;
    // 最大数组容量
    private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
}
```

### 构造方法 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018150642912-329826692.png)

#### 无参构造方法　　

```java
/*
*Constructs an empty list with an initial capacity of ten.　　
*这里就说明了默认会给10的大小，所以说一开始arrayList的容量是10.
*/
//ArrayList中储存数据的其实就是一个数组，这个数组就是elementData，
//在123行定义的 private transient Object[] elementData;
public ArrayList() {　　
    super();        
    //调用父类中的无参构造方法，父类中的是个空的构造方法
    this.elementData = EMPTY_ELEMENTDATA;
    //EMPTY_ELEMENTDATA：是个空的Object[]， 将elementData初始化，
    	 //elementData也是个Object[]类型。空的Object[]会给默认大小10
}
```


#### 有参构造函数一

```java
public ArrayList(int initialCapacity) {
    super(); //父类中空的构造方法
    if (initialCapacity < 0)    
    //判断如果自定义大小的容量小于0，则报下面这个非法数据异常
        throw new IllegalArgumentException("Illegal Capacity: "+
                                           initialCapacity);
    this.elementData = new Object[initialCapacity]; 
    //将自定义的容量大小当成初始化elementData的大小
}
```

- arrayList的构造方法就做一件事情，就是初始化一下储存数据的容器，其实本质上就是一个数组，在其中就叫elementData。

### 核心方法 

#### add()方法 

![img](https://images2017.cnblogs.com/blog/999804/201710/999804-20171018162356787-2047160796.png)

##### boolean add(E)；//默认直接在末尾添加元素

```java
/**
* 把元素添加到集合的末尾
*/
public boolean add(E e) {
    
    //确定数组容量是否足够，size是数据个数，所以+1. 
    ensureCapacityInternal(size + 1); 
    
    //在数组中正确的位置上添加元素e，并size++
    elementData[size++] = e;
    
    return true;
}
```

- **ensureCapacityInternal(xxx);**　确定内部容量的方法　　

```java
//用于确定数组容量
private void ensureCapacityInternal(int minCapacity) {
    
    //判断初始化elementdata是否为一个空数组
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        
        //如果是，相当于是空数组没有长度，则获取“默认的容量”和“传入参数”两者之间的最大值
        minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);

    }
    //确认实际的容量，判断是否需要进行扩容操作
    ensureExplicitCapacity(minCapacity);
}
```

- **ensureExplicitCapacity(xxx)；**

```java
//判断是否需要扩容
private void ensureExplicitCapacity(int minCapacity) {
    //记录修改次数
    modCount++;

    //如果最小大小 减 数组长度 大于0 -> 进行数组扩容
    if (minCapacity - elementData.length > 0)
        //实际进入扩容机制
        grow(minCapacity);
}
```

- **grow(xxx); arrayList核心的方法，能扩展数组大小的真正秘密。**

```java
/**
* ArrayList扩容的核心方法。
*/
private void grow(int minCapacity) {
     // oldCapacity为旧容量，newCapacity为新容量
    
    //将扩充前的elementData大小给oldCapacity
    int oldCapacity = elementData.length;
	
    //将oldCapacity 右移一位，其效果相当于oldCapacity/2
    //newCapacity就是1.5倍的oldCapacity
    int newCapacity = oldCapacity + (oldCapacity >> 1);

     //检查新容量是否大于最小需要容量，若小于最小需要容量，那么就把最小需要容量当作数组的新容量
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;

    /**
     * 检查新容量是否超出了ArrayList所定义的最大容量，
     * 若超出了，则调用hugeCapacity()来比较minCapacity和 MAX_ARRAY_SIZE，
     * 如果minCapacity大于MAX_ARRAY_SIZE，则新容量则为Interger.MAX_VALUE，否则，新容量大小则为 MAX_ARRAY_SIZE。
    */
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        //比较minCapacity和 MAX_ARRAY_SIZE
        newCapacity = hugeCapacity(minCapacity);
    
    //新的容量大小已经确定好了，就copy数组，改变容量大小
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```

- **hugeCapacity();**  

```java
//这个就是上面用到的方法，很简单，就是用来赋最大值。
private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    //如果minCapacity都大于MAX_ARRAY_SIZE，那么就Integer.MAX_VALUE返回，反之将MAX_ARRAY_SIZE返回
    return (minCapacity > MAX_ARRAY_SIZE) ？Integer.MAX_VALUE:MAX_ARRAY_SIZE;
}
```

##### void add(int，E)；在特定位置添加元素，也就是插入元素

```java
/**
* 在此列表中的指定位置插入指定的元素。 

*先调用 rangeCheckForAdd 对index进行界限检查；然后调用 ensureCapacityInternal 方法保证capacity足够大；

*再将从index开始之后的所有成员后移一个位置；将element插入index位置；最后size加1。
*/
public void add(int index, E element) {
    rangeCheckForAdd(index);

    ensureCapacityInternal(size + 1);  // Increments modCount!!
    
    //arraycopy()方法实现数组自己复制自己
    System.arraycopy(elementData, index, elementData, index + 1,size - index);
    elementData[index] = element;
    size++;
}
```

- rangeCheckForAdd(index)　　

```java
private void rangeCheckForAdd(int index) {
    if (index > size || index < 0)   
    //插入的位置肯定不能大于size 和小于0
	 //如果是，就报这个越界异常
    throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}
```

####  remove()方法 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018154558896-1270971770.png)![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018154624115-1149460965.png)

- 其中fastRemove(int)方法是private的，是提供给remove(Object)这个方法用的。

##### **remove(int)：**删除指定位置上的元素

```java
public E remove(int index) {
    rangeCheck(index);//检查index的合理性

    modCount++;//增加修改次数
    E oldValue = elementData(index);//通过索引直接找到该元素

    int numMoved = size - index - 1;//计算要移动的位数。
    if (numMoved > 0)
        //用来移动元素的。
        System.arraycopy(elementData, index+1, elementData, index,
                         numMoved);
    //将--size上的位置赋值为null，让gc(垃圾回收机制)更快的回收它。
    elementData[--size] = null; // clear to let GC do its work
    //返回删除的元素。
    return oldValue;
}
```

##### **remove(Object)：**这个方法可以看出来，arrayList是可以存放null值得。

```java
//通过元素来删除该元素，就依次遍历，如果有这个元素，就将该元素的索引传给fastRemobe(index)，使用这个方法来删除该元素，
//fastRemove(index)方法的内部跟remove(index)的实现几乎一样，这里最主要是知道arrayList可以存储null值
public boolean remove(Object o) {
    if (o == null) {
        for (int index = 0; index < size; index++)
            if (elementData[index] == null) {
                fastRemove(index);
                return true;
            }
    } else {
        for (int index = 0; index < size; index++)
            if (o.equals(elementData[index])) {
                fastRemove(index);
                return true;
            }
    }
    return false;
}
```

![image-20200811141939777](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811141939777.png)

##### clear()：**将elementData中每个元素都赋值为null，等待垃圾回收将这个给回收掉，所以叫clear**

```java
public void clear() {
    modCount++;

    // clear to let GC do its work
    for (int i = 0; i < size; i++)
        elementData[i] = null;

    size = 0;
}
```

​	  

#### set()方法 

```java
public E set(int index, E element) {
    // 检验索引是否合法
    rangeCheck(index);
    // 旧值
    E oldValue = elementData(index);
    // 赋新值
    elementData[index] = element;
    // 返回旧值
    return oldValue;
}
```

- 设定指定下标索引的元素值

#### indexOf()方法 

```java
// 从首开始查找数组里面是否存在指定元素
public int indexOf(Object o) {
    if (o == null) { // 查找的元素为空
        for (int i = 0; i < size; i++) 
        // 遍历数组，找到第一个为空的元素，返回下标
            if (elementData[i]==null)
                return i;
    } else { // 查找的元素不为空
        for (int i = 0; i < size; i++) 
        // 遍历数组，找到第一个和指定元素相等的元素，返回下标
            if (o.equals(elementData[i]))
                return i;
    } 
    // 没有找到，返回空
    return -1;
}
```

- 从头开始查找与指定元素相等的元素，注意，是可以查找null元素的，意味着ArrayList中可以存放null元素的。与此函数对应的lastIndexOf，表示从尾部开始查找。

#### get()方法 

```java
public E get(int index) {
    // 检验索引是否合法
    rangeCheck(index);

    return elementData(index);
}
```

- get函数会检查索引值是否合法（只检查是否大于size，而没有检查是否小于0），值得注意的是，在get函数中存在element函数，element函数用于返回具体的元素，具体函数如下：

```java
E elementData(int index) {
    return (E) elementData[index];
}
```

- 返回的值都经过了向下转型（Object -> E），这些是对我们应用程序屏蔽的小细节。

## 总结

- arrayList可以存放null。
- arrayList本质上就是一个elementData数组。
- arrayList区别于数组的地方在于能够自动扩展大小，其中关键的方法就是grow()方法。
- arrayList中removeAll(collection c)和clear()的区别就是removeAll可以删除批量指定的元素，而clear是全删除集合中的元素。
- arrayList由于本质是数组，所以它在数据的查询方面会很快，而在插入删除这些方面，性能下降很多，有移动很多数据才能达到应有的效果
- arrayList实现了RandomAccess，所以在遍历它的时候推荐使用for循环。

# 链表 


![image-20200811143924271](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811143924271.png)

## **链表类型**

### 单向链表：

- element：用来存放元素

- next：用来指向下一个节点元素

- 通过每个结点的指针指向下一个结点从而链接起来的结构，最后一个节点的next指向null。

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018163705615-546509635.png)

### 单向循环链表

- element、next 跟前面一样

- 在单向链表的最后一个节点的next会指向头节点，而不是指向null，这样存成一个环

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018163849318-946854643.png)

### 双向链表

- element：存放元素

- pre：用来指向前一个元素

- next：指向后一个元素

- 双向链表是包含两个指针的，pre指向前一个节点，next指向后一个节点，但是第一个节点head的pre指向null，最后一个节点的tail指向null。

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018164025990-1035906814.png)

### 双向循环链表

- element、pre、next 跟前面的一样

- 第一个节点的pre指向最后一个节点，最后一个节点的next指向第一个节点，也形成一个“环”。

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018164246521-25397602.png)

### **链表和数组对比**

- 单链表和数组的区别进行了对比和总结。

|              | 数组                                 | 链表                         |
| ------------ | ------------------------------------ | ---------------------------- |
| 内存地址     | 连续的内存空间                       | 非连续的内存空间             |
| 数据长度     | 长度固定，一般不可动态扩容           | 长度可动态变化               |
| 增删效率     | 低，需要移动被修改元素之后的所有元素 | 高，只需要修改指针指向       |
| 查询效率     | 高，可用过数组名和下标直接访问       | 低，只能通过遍历节点依次查询 |
| 数据访问方式 | 随机访问                             | 顺序访问                     |

## LinkedList 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018185451506-2136799134.png)

- 是一种可以在任何位置进行高效地插入和移除操作的**有序序列**，它是基于**双向链表**实现的。
- 是一个继承于AbstractSequentialList的双向链表。它也可以被当作堆栈、队列或双端队列进行操作。
- 实现 List 接口，能对它进行队列操作。
- 实现 Deque 接口，即能将LinkedList当作双端队列使用。
- 实现了Cloneable接口，即覆盖了函数clone()，能克隆。
- 实现java.io.Serializable接口，这意味着LinkedList支持序列化，能通过序列化去传输。
- 是非同步，线程不安全的。

### 数据结构  

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018164511396-1020210450.png)

- 如上图所示，LinkedList底层使用的双向链表结构，有一个头结点和一个尾结点，双向链表意味着我们可以从头开始正向遍历，或者是从尾开始逆向遍历，并且可以针对头部和尾部进行相应的操作。

### 特性 

- 异步，也就是非线程安全
- 双向链表。由于实现了list和Deque接口，能够当作队列来使用。
	- 链表：查询效率不高，但是插入和删除这种操作性能好。
- 是顺序存取结构

### 源码分析 

#### 类的属性 

```java
// 实际元素个数，链表长度
transient int size = 0;

// 头结点
transient Node<E> first;

// 尾结点
transient Node<E> last;
```

- LinkedList的属性非常简单，一个头结点、一个尾结点、一个表示链表中实际元素个数的变量。

#### 构造方法 

- 空参构造函数

```java
public LinkedList() { }
```

- 有参构造函数

```java
//将集合c中的各个元素构建成LinkedList链表。
public LinkedList(Collection<? extends E> c) {
    // 调用无参构造函数
    this();
    // 添加集合中所有的元素
    addAll(c);
}
```　

#### 内部类（Node） 

```java
private static class Node<E> {
    E item; // 数据域（当前节点的值）
    Node<E> next; // 后继（指向当前一个节点的后一个节点）
    Node<E> prev; // 前驱（指向当前节点的前一个节点）

    // 构造函数，赋值前驱后继
    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```

- 内部类Node就是实际的结点，用于存放实际元素的地方。　　　　　



#### add()方法  

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/999804-20171018180421865-139109156.png)

- add(E)

```java
public boolean add(E e) {
    // 添加到末尾
    linkLast(e);
    return true;
}
```

- LinkLast()

```java
/**
     * Links e as last element.
     */
void linkLast(E e) {
    final Node<E> l = last;    
    //临时节点l(L的小写)保存last，也就是l指向了最后一个节点
    final Node<E> newNode = new Node<>(l, e, null);
    //将e封装为节点，并且e.prev指向了最后一个节点
    last = newNode;
    //newNode成为了最后一个节点，所以last指向了它
    if (l == null)    
    //判断是不是一开始链表中就什么都没有，如果没有，则newNode就成为了第一个节点，first和last都要指向它
        first = newNode;
    else 
    //正常的在最后一个节点后追加，那么原先的最后一个节点的next就要指向现在真正的最后一个节点，原先的最后一个节点就变成了倒数第二个节点
        l.next = newNode;
    size++;//添加一个节点，size自增
    modCount++;
}
```

- 举例：

```java
List<Integer> lists = new LinkedList<Integer>();
lists.add("e1");
lists.add("e2");
```

- 一开始，first和last都为null，此时链表什么都没有，当第一次调用该方法后，first和last均指向了第一个新加的节点E1：

![image-20200811160819443](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811160819443.png)

- 第二次调用该方法，加入新节点E2。首先，将last引用赋值给l，接着new了一个新节点E2，并且E2的prve指向l，接着将新节点E2赋值为last

![image-20200811161146898](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811161146898.png)

- 接着判断l==null? 所以走的else语句，将l的next引用指向新节点E2

![image-20200811161204522](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811161204522.png)

- 最后，size+1，modCount+1，退出该方法，局部变量l销毁

![image-20200811161244413](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811161244413.png)



##### remove(Object o)  

```java
//首先通过看上面的注释，我们可以知道，如果我们要移除的值在链表中存在多个一样的值
//那么我们会移除index最小的那个，也就是最先找到的那个值，如果不存在这个值，那么什么也不做
public boolean remove(Object o) {
    //这里可以看到，linkedList也能存储null
    if (o == null) {
        //循环遍历链表，直到找到null值，然后使用unlink移除该值。下面的这个else中也一样
        for (Node<E> x = first; x != null; x = x.next) {
            if (x.item == null) {
                unlink(x);
                return true;
            }
        }
    } else {
        for (Node<E> x = first; x != null; x = x.next) {
            if (o.equals(x.item)) {
                unlink(x);
                return true;
            }
        }
    }
    return false;
}
```

- unlink(xxxx)

```java
/**
 * Unlinks non-null node x.
 */
//不能传一个null值过，注意，看之前要注意之前的next、prev这些都是谁。
E unlink(Node<E> x) {
    // assert x != null;
//拿到节点x的三个属性
    final E element = x.item;
    final Node<E> next = x.next;
    final Node<E> prev = x.prev;

//这里开始往下就进行移除该元素之后的操作，也就是把指向哪个节点搞定。
    if (prev == null) {
//说明移除的节点是头节点，则first头节点应该指向下一个节点
        first = next;
    } else {
//不是头节点，prev.next=next：有1、2、3，将1.next指向3
        prev.next = next;
//然后解除x节点的前指向。
        x.prev = null;
    }

    if (next == null) {
//说明移除的节点是尾节点
        last = prev;
    } else {
//不是尾节点，有1、2、3，将3.prev指向1. 然后将2.next=解除指向。
        next.prev = prev;
        x.next = null;
    }
//x的前后指向都为null了，也把item为null，让gc回收它
    x.item = null;
    size--;    //移除一个节点，size自减
    modCount++;
    return element;    //由于一开始已经保存了x的值到element，所以返回。
}
```

##### get(index) 

- get(index)查询元素的方法

```java
//这里没有什么，重点还是在node(index)中
public E get(int index) {
    checkElementIndex(index);
    return node(index).item;
}
```

- node(index)

```java
/**
 * Returns the (non-null) Node at the specified element index.
 */
//这里查询使用的是先从中间分一半查找
Node<E> node(int index) {
     // assert isElementIndex(index);
     //这个if中就是查询前半部分
     if (index < (size >> 1)) {
        Node<E> x = first;
        for (int i = 0; i < index; i++)
            x = x.next;
        return x;
    } else {
    //前半部分没找到，所以找后半部分
        Node<E> x = last;
        for (int i = size - 1; i > index; i--)
            x = x.prev;
        return x;
    }
}
```

##### indexOf(Object o)  

```java
//这个很简单，就是通过实体元素来查找到该元素在链表中的位置。跟remove中的代码类似，只是返回类型不一样。
public int indexOf(Object o) {
    int index = 0;
    if (o == null) {
        for (Node<E> x = first; x != null; x = x.next) {
            if (x.item == null)
                return index;
            index++;
        }
    } else {
        for (Node<E> x = first; x != null; x = x.next) {
            if (o.equals(x.item))
                return index;
            index++;
        }
    }
    return -1;
}
```

## 总结 

- linkedList本质上是一个**双向链表**，通过一个Node内部类实现的这种链表结构。
- 能存储null值
- 跟arrayList相比较，就真正的知道了，LinkedList在删除和增加等操作上性能好，而ArrayList在查询的性能上好
- 从源码中看，它不存在容量不足的情况
- linkedList不光能够向前迭代，还能像后迭代，并且在迭代的过程中，可以修改值、添加值、还能移除值。
- linkedList不光能当链表，还能当队列使用，这个就是因为实现了Deque接口。

# 栈  

## 概述

- 栈是一种比较简单的数据结构，常用一句话描述其特性，**先进后出**。栈本身是一个线性表，但是在这个表中只有一个口子允许数据的进出

- 栈的常用操作包括**入栈push**和**出栈pop**，对应于数据的压入和压出。还有访问栈顶数据、判断栈是否为空和判断栈的大小等。由于栈后进先出的特性，常可以作为数据操作的临时容器，对数据的顺序进行调控，与其它数据结构相结合可获得许多灵活的处理。

![在这里插入图片描述](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/20200526101351156.gif)

## Stack

- Stack是栈。它的特性是：先进后出(FILO, First In Last Out)。java工具包中的Stack是继承于Vector(矢量队列)的，由于Vector是通过数组实现的，这就意味着，Stack也是通过数组实现的，而非链表。当然，我们也可以将LinkedList当作栈来使用。Stack的继承关系

![image-20200620035809710](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200620035809710.png)

```java
package java.util;

public class Stack<E> extends Vector<E> {
    private static final long serialVersionUID = 1224463164541339165L;
// 构造函数
public Stack() {
}

// push函数：将元素存入栈顶
public E push(E item) {
    // 将元素存入栈顶。
    // addElement()的实现在Vector.java中
    addElement(item);
    return item;
}

// pop函数：返回栈顶元素，并将其从栈中删除
public synchronized E pop() {
    E   obj;
    int  len = size();
    obj = peek();
    // 删除栈顶元素，removeElementAt()的实现在Vector.java中
    removeElementAt(len - 1);
    return obj;
}

// peek函数：返回栈顶元素，不执行删除操作
public synchronized E peek() {
    int  len = size();
    if (len == 0)
        throw new EmptyStackException();
    // 返回栈顶元素，elementAt()具体实现在Vector.java中
    return elementAt(len - 1);
}

// 栈是否为空
public boolean empty() {
    return size() == 0;
}

// 查找“元素o”在栈中的位置：由栈底向栈顶方向数
public synchronized int search(Object o) {
    // 获取元素索引，elementAt()具体实现在Vector.java中
    int i = lastIndexOf(o);
    if (i >= 0) {
        return size() - i;
    }
    return -1;
}
}
```

# 队列 

- 队列是栈的兄弟结构，与栈的后进先出相对应，队列是一种先进先出的数据结构。顾名思义，队列的数据存储是如同排队一般，先存入的数据先被压出。常与栈一同配合，可发挥最大的实力。

![在这里插入图片描述](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/20200526101424265.gif)

# 树  

## 树的基本概念

- 树是数据结构中非常重要的一个存在。在Java中对树进行了大量的使用，如TreeMap、HashMap等。并且如MySQL、MongoDB也都使用到了树。

- 树是由N个节点组成的，每个节点中都会进行数据的存储。当N=0时，被称为空树。在任何一颗树中，有且只有一个根节点，在根节点下可以继续进行扩展，形成互不相交的集合。其中每个集合本身又可以理解为是一颗树，他们则被称为子树。

![image-20200811181101295](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811181101295.png)


| 节点     | 树中的元素                                             |
| -------- | ------------------------------------------------------ |
| 节点的度 | 节点拥有子树的个数，二叉树的度不能大于2                |
| 高度     | 叶子节点的高度为1，叶子节点的父节点高度为2，依次类推。 |
| 根节点   | 树的顶部节点。                                         |
| 子节点   | 父节点的下层节点。                                     |
| 叶子节点 | 没有子节点的节点，也被称为终端节点、度为0的节点。      |

- 树的种类也非常的多：二叉树、平衡二叉树、红黑树、B树、B+树、哈夫曼树、B*树等等。

## 二叉树

### 基本概念

- 二叉树的特点是树的每个节点最多只能有两个子节点。其中一棵树叫做根的左子树，另一颗叫根的右子树。

![image-20200811190601991](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811190601991.png)

- 如果节点数量超过两个，则不能叫做二叉树，而叫做多路树。

![image-20200811190425678](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811190425678.png)

###  特点

- 每个节点最多有两颗子树，所以二叉树中不存在度(该结点孩子的个数)大于2的节点。
- 左子树和右子树是有顺序的。
- 即使树中某节点只有一颗子树， 也要区分它是左子树还是右子树。

### 特殊的二叉树

####  满二叉树

- 在一棵二叉树中。如果所有分支结点都存在**左子树和右子树**，并且**所有叶子都在同一层上**，这样的二叉树称为满二叉树。其特点如下：

	- 假设深度为k，且含有2^k-1个结点的树。
	- 叶子只能出现在最下一层。出现在其它层就不可能达成平衡。
	- 非叶子结点的度一定是2。
	- 在同样深度的二叉树中，满二叉树的结点个数最多，叶子数最多。

![image-20200811192235886](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811192235886.png)

#### 完全二叉树

- 完全二叉树是一颗特殊的二叉树。假设一个二叉树的高度为h，如果说它是一颗完全二叉树的话，需要满足以下规则：

	- 叶子结点只能出现在最下层和次下层。
	
	- 最下层的叶子结点集中在树的左部。
	- 倒数第二层若存在叶子结点，一定在右部连续位置。
	- 如果结点度为1，则该结点只有左孩子，即没有右子树。

![image-20200811193944229](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811193944229.png)

####  斜树

- 所有的节点都之后左子树的二叉树叫做左斜树，同理还存在右斜树。一旦产生这种情况，相当于树结构退化为了链表，查找一个节点的时间复杂度为O(n)，查询效率严重降低。

![image-20200811230829771](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811230829771.png)

![image-20200811230952490](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811230952490.png)

### 存储结构

- 二叉树的顺序存储结构就是使用一维数组存储二叉树中的结点，并且结点的存储位置，就是数组的下标索引。

![image-20200811232239278](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811232239278.png)

- 当二叉树为完全二叉树时，结点数刚好填满数组。

![image-20200811232514640](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811232514640.png)

- 当不为完全二叉树时，采用顺序存储又是什么样子呢？

![image-20200811232851079](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811232851079.png)

- 其中，∧表示数组中此位置没有存储结点。此时可以发现，顺序存储结构中已经出现了空间浪费的情况。

在极端的右斜树极端情况对应的顺序存储结构。

![image-20200811233033805](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811233033805.png)

- 可以看出，对于这种右斜树极端情况，采用顺序存储的方式是十分浪费空间的。因此，顺序存储一般适用于完全二叉树。

###  二叉树遍历

####  定义

**二叉树的遍历**是指从二叉树的根结点出发，按照某种次序依次访问二叉树中的所有结点，使得每个结点被访问一次，且仅被访问一次。
二叉树的访问次序可以分为四种：

- 前序遍历
- 中序遍历
- 后序遍历
- 层序遍历

#### 前序遍历

- 从根结点出发，当**第一次**到达结点时就输出结点数据，按照**先向左再向右的方向**访问。简单理解就是：父节点->左子树->右子树

![image-20200811235242745](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200811235242745.png)


####  中序遍历

- 从根结点出发，当**第二次到达结点**时则输出结点数据，按照先向左再向右的方向访问。简单理解就是：左子树->父节点->右子树

![image-20200812000716284](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812000716284.png)

- 流程如下：

	- 从根节点触发，则第一次到达结点A，不输出A，继续向左访问，第一次到达结点B，不输出B，继续到达D、H，都不进行输出。
	
	- 到达H，H左子树为空，则返回到H，此时是第二次访问H，则输出H。


#### 后序遍历

​	从根结点出发，当第三次到达结点时则输出输出，按照先向左后向右的方式访问。简单理解就是：左子树 -> 右子树 ->父节点

![image-20200812001640297](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812001640297.png)


#### 层次遍历

- 按照树的层次自上而下的遍历二叉树。最终结果为：**ABCDEFGHIJ**

##  二叉搜索树

### 定义

- 二叉搜索树，也被称为二叉查找树、二叉排序树。对于基础二叉树来说，数据查找、数据变动的效率都是非常低效的。因此才产生了二叉搜索树。

- 其定义规则如下：

	- 若左子树不为空，则左子树上的各个结点的值，均**小于**它的父节点的值。
	- 若右子树不为空，则右子树上的各个结点的值，均**大于**它的父节点的值。
	- 没有值相等的结点。
	- 左右子树也分别为二叉搜索树。
	- 不一定是一颗完全二叉树，因此，二叉搜索树不能用数组来存储。

![image-20200812004718795](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812004718795.png)

![image-20200812004836213](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812004836213.png)

### 查找

- 流程：

	- （1）如果树是空的，则查找结束，无匹配。
	- （2）如果被查找的值和节点的值相等，查找成功。
	- （3）如果被查找的值小于节点的值，递归查找左子树。
	- （4）如果被查找的值大于节点的值，递归查找右子树。

### 插入

- 图解：

![image-20200812005834866](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812005834866.png)

------

![image-20200812005900285](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812005900285.png)

------

![image-20200812005932267](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812005932267.png)

------

![image-20200812010233539](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812010233539.png)

###  删除

####  删除节点为叶子节点

- 该方式最简单，只需找到对应节点，直接删除即可。

![image-20200812010738152](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812010738152.png)

####   删除的节点只有左子树

- 需要将节点的左子树替代被删除节点的位置。

 ![image-20200812010956148](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812010956148.png)

------

![image-20200812011121765](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812011121765.png)

####  删除的节点只有右子树

- 需要将右子树替代被删除节点的位置。与左子树思想一致。

####  删除的节点拥有左右子树

- 此情况操作起来最为复杂。操作流程如下：

	- （1）遍历待删除节点的左子树，找到其左子树中的最大节点。
	- （2）将最大节点代替被删除节点。
	- （3）删除左子树中的最大节点。

- 同理，也可以选取右子树中的最小值取代它并删除原结点。

##  平衡二叉树

###   定义

- 二叉搜索树一定程度上可以提高搜索效率，但是当有序序列为{1,2,3,4,5,6}时，此时构造的二叉搜索树为右斜树。可以发现二叉树已经退化为了单链表，搜索效率降低为O(n)。

![image-20200812121026874](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812121026874.png)

- 在此二叉搜索树中查找元素6需要查找6次。二叉搜索树的查找效率取决于树的高度，因此树的高度越低，其查询效率就会越高。同样的序列，更改存储方式，查找元素6时只需要比较三次，查询效率提升一倍。

![image-20200812121258289](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812121258289.png)

- 可以看出当节点数目一定，保持树的左右两端保持平衡，树的查找效率最高。这种**左右子树的高度相差不超过1的树为平衡二叉树**。 

![image-20200812121843134](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812121843134.png)

###  平衡因子

​	**定义：**某节点的左子树与右子树的高度(深度)差即为该节点的平衡因子（BF,Balance Factor），平衡二叉树中不存在平衡因子大于1的节点。在一棵平衡二叉树中，节点的平衡因子只能取-1、1或者0。

###  左旋与右旋

####  左旋

- 如图所示的平衡二叉树

![image-20200812144003778](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144003778.png)

- 如在此平衡二叉树插入节点62，树结构变为：

![image-20200812144025384](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144025384.png)


- 左旋流程：

![image-20200812144139196](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144139196.png)

------

![image-20200812144238932](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144238932.png)

------

![image-20200812144307930](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144307930.png)

------

![image-20200812144409076](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144409076.png)

####  右旋

- 右旋操作与左旋类似，操作流程为：
	- （1）原根节点的左孩子代表此节点
	- （2）原根节点的左孩子的右子树变为节点的左子树。
	- （3）原根节点作为左孩子节点的右子树。

- 过程如下：

![image-20200812144551327](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144551327.png)

------

![image-20200812144614420](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144614420.png)

------

![image-20200812144931963](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812144931963.png)

------

![image-20200812145020443](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812145020443.png)

### 插入

- 假设一颗 AVL 树的某个节点为A，有时会使 A 的左右子树高度差大于 1，从而破坏了原有 AVL 树的平衡性。平衡二叉树插入节点的情况分为以下2种：

####   **A的左孩子的左子树插入节点**

- 假设现在有这样的一颗平衡二叉树：

![image-20200812145217565](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812145217565.png)

- 节点A的左孩子为B，B的左子树为D，无论在节点D的左子树或者右子树中插入F均会导致节点A失衡。因此需要对节点A进行旋转操作。A的平衡因子为2，值为正，因此对A进行右旋操作。

过程如下：

![image-20200812145401573](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812145401573.png)

------

![image-20200812145421078](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812145421078.png)

------

![image-20200812145436943](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812145436943.png)

####   **A的右孩子的右子树插入节点**

- 插入节点F后，节点A的平衡因子为-2，对节点A进行左旋操作。


###  删除

- 平衡二叉树的节点删除与二叉搜索树删除方法一致，但是需要在节点删除后判断树是否仍然保持平衡，若出现失衡情况，需要进行调整。

## 红黑树

###  概述

- **红黑树**是树的数据结构中最为重要的一种。Java的容器TreeSet、TreeMap均使用红黑树实现。JDK1.8中HashMap中也加入了红黑树。每个节点都带有颜色属性，颜色为**红色**或**黑色**。除了二叉查找树一般要求以外，对于任何有效的红黑树还增加了如下的额外要求:

- 1）节点要么是黑色要么是红色。

- 2）根结点一定是黑色的。

- 3）每个叶子节点都带有两个空(NIL)的黑色节点。

- 4）每个红色节点的两个子节点一定是黑色，因此不会存在两个连续的红色节点，红色节点的父节点一定是黑色节点。

- 5）从任一节点到它所能到达的叶子节点的所有路径都包含相同数目的黑色节点。从而达到黑色平衡。（平衡二叉树是一个完美平衡的树，红黑树是非完美平衡树，但是一个完美的黑色平衡二叉查找树）。

![image-20200812152853784](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812152853784.png)

###  节点名称

	**父节点——P(Parent)**
	**祖父节点——G(GrandParent)**
	**叔叔节点——U(Uncle)**
	**当前节点——C(Current)**
	**兄弟节点——B(Brother)**
	**左孩子——L(Left)**
	**右孩子——R(Right)**

##  B树

- 大部分数据库的索引都采用树的结构存储，这是因为树的查询效率相对较高，且保持有序。 
​- 对于二叉搜索树的时间复杂度是**O(logN)**，在算法以及逻辑上来分析，二叉搜索树的查找速度以及数据比较次数都是较小的。但是我们不得不考虑一个新的问题。数据量是远大于内存大小的，那我们在查找数据时并不能将全部数据同时加载至内存。既然不能全部加载至内存中就只能逐步的去加载磁盘中某个页，简而言之就是逐一的去加载磁盘，加数据分块的加载至内存进行查找与比较。

- 如图所示，在树中查找10，树的每个节点代表一个磁盘页，相当于每次访问一个新节点代表一次磁盘IO。


- 通过查找过程可以看出，磁盘IO次数与树的高度相关，在最坏情况下，磁盘IO次数等于树的高度。由于磁盘IO过程是相对耗时效率较低的，因此，在设计数据存储结构时需要降低树的高度，即将一棵“瘦高”的树变得“矮胖”。
- 当数据数目相同，在保持有序前提下，降低树高度，只需将节点中存储的key值增加，即二叉搜索树中每个节点只有一个数据元素，而在**B树中每个节点可以有多个数据元素**。

###  定义

- B树也成B-树。它是一颗多路平衡查找树（所有的叶子节点拥有相同的高度）。当描述一颗B树时需要指定它的**阶数**，阶数表示一个节点最多有多少个孩子节点，一般用字母m表示。当m取2时，就是一颗二叉查找树。

- 要定义一颗m阶的B树，需要遵循以下五条原则：

	- 1）根节点最少可以只有一个元素，且至少要有两个子节点。
	
	- 2）每个节点最多有m-1个元素。
	
	- 3）非根节点至少有(m/2)-1个元素。m/2要进行向上取整，如m/2=1.5=2。
	
	- 4）每个结点中的元素都按照从小到大的顺序排列，每个元素的左子树中的所有元素都小于它，而右子树中的所有元素都大于它。
	
	- 5）所有叶子节点都位于同一层，相当于根节点到每个叶子节点的长度相同。

###  操作

- B树的查找其实是对二叉搜索树查找的扩展， 与二叉搜索树不同的地方是，B-树中每个节点有不止一棵子树。在B-树中查找某个结点时，需要先判断要查找的结点在哪棵子树上，然后在结点中逐个查找目标结点。B树的查找过程相对简单，与二叉搜索树类似，因此不再赘述。

####  插入

- B树的插入操作是指在树种插入一条新记录，即（key, value）的键值对。如果B树中已存在需要插入的键值对，则用需要插入的value替换旧的value。若B树不存在这个key，则一定是在叶子结点中进行插入操作。

- 插入流程如下：
	
	- 1）根据要插入的key的值，对B树执行查找操作，查找到待插入数据的当前节点位置。
	
	- 2）判断**当前节点key的个数是否小于等于m-1**，若满足，则直接插入数据。
	
	- 3）若不满足，以**节点中间的key**为中心分裂成**左右两部分**，然后将这个**中间的key插入到父节点中**，这个key的左子树指向分裂后的左半部分，这个key的右子树指向分裂后的右半部分，然后将当前节点指向父节点，继续执行第三步。



- 下面以5阶B树为例，介绍B树的插入操作，在5阶B树中，结点最多有4个key，最少有2个key。

1：**插入38，此时为空树，直接插入，并作为根节点。继续插入22、76、40，符合情形（2），直接插入。**

![image-20200812193205493](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812193205493.png)

2：**插入51，符合情形（3），执行分裂。**

![image-20200812193415970](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812193415970.png)

3：**按照相同的步骤继续插入13、21**

![image-20200812193649389](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812193649389.png)

4：**插入39，符合情形（3），导致节点分裂。选择中值22作为父节点，并将22节点上移，与40节点进行合并。**

![image-20200812193754228](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812193754228.png)

5：**按照同样的插入规则，继续向树中插入key为30、27、33、36、35、34、24、29的数据。**

![image-20200812210944524](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812210944524.png)

6：**继续插入key为26的数据，插入之后需要执行节点分裂。**

![image-20200812211108009](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812211108009.png)

7：**将key为27的数据节点上移至父节点**

![image-20200812211157198](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812211157198.png)

8：**此时父节点已经有4个key，插入key27的数据后需要执行节点分裂，树的高度加1。**

![image-20200812211227694](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812211227694.png)

9：**再依次插入14，23，28，29，31，32。**

![image-20200812211332462](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812211332462.png)

####  删除


1：**首先删除21，符合情形（2）直接删除。**

![image-20200812212450909](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812212450909.png)

2：**继续删除27，符合情形（1），使用后继节点28替代27，并删除28。**

![image-20200812212701762](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812212701762.png)

3：**删除28后，节点中只有29一个key，因此需要按照情形（3）调整。29左兄弟节点有三个节点，将28下移，兄弟节点中26上移。**

![image-20200812213149187](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812213149187.png)

4：**继续删除32。**

![image-20200812213457870](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812213457870.png)

5：**删除32后，需要按照情形（3）进行调整。**

![image-20200812213606267](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812213606267.png)

6：**当前节点的兄弟节点只有2个key，则将父节点下移，将当前节点与一个兄弟节点合并，调整完毕。**

![image-20200812213719819](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812213719819.png)

7：**继续删除39节点。**

![image-20200812213922242](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812213922242.png)

8：**删除39节点后，需要按照情形（4）进行调整。**

![image-20200812213959770](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812213959770.png)

9：**调整过后，当前节点变为只有key40的节点，需要按照情形（3）进行调整。执行节点合并，合并操作包含根节点，导致合并之后，树的高度减1。**

![image-20200812214145220](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812214145220.png)


##  B+树

- **B+树**是在B树基础进一步优化得到的一种数据结构。B+树相比于B树具有更高的查询效率。

### 定义

- 1）B+树包含2种类型的结点：内部结点（也称索引结点）和叶子结点。

- 2）根结点本身即可以是内部结点，也可以是叶子结点。根结点的关键字个数最少可以只有1个。

- 3）B+树与B树最大的不同是内部结点不保存数据，只用于索引，所有数据（或者说记录）都保存在叶子结点中。

- 4） m阶B+树表示了**内部结点最多有m-1个关键字**，阶数m同时限制了**叶子结点最多存储m-1个数据**。

- 5）内部结点中的key都按照从小到大的顺序排列，对于内部结点中的一个key，左树中的所有key都小于它，右子树中的key都大于等于它。叶子结点中的数据也按照key的大小排列。

- 6）**每个叶子结点都存有相邻叶子结点的指针**，叶子结点本身依关键字的大小自小而大顺序链接。



- 如图所示的B+树中，灰色节点代表索引节点，索引节点中只有key，而不含数据data。橙色节点代表叶子节点，叶子节点中既有key值又有数据data。叶子节点采用单链表的方式链接。

![image-20200812215025439](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/image-20200812215025439.png)

### 特点

- 1）索引节点的key值均会出现在叶子节点中。

- 2）索引节点中的key值在叶子节点中或者为最大值或者为最小值。

- 3）叶子节点使用单链表的形式链接起来。

###  性能分析

- **查找性能**
	- 1）在相同数量的待查数据下，B+树查找过程中需要调用的磁盘IO操作要少于普通B-树。由于B+树所在的磁盘存储背景下，因此B+树的查找性能要好于B-树。 
	- 2）B+树的查找效率更加稳定，因为所有叶子结点都处于同一层中，而且查找所有关键字都必须走完从根结点到叶子结点的全部历程。因此同一颗B+树中，任何关键字的查找比较次数都是一样的。而B树的查找是不稳定的。 
 
- **插入性能**
	- B+树的插入过程与B树类似，性能也基本一致。
- **删除性能**
	- 删除性能与B树也基本一致。

##  相关问题

### hashmap为什么使用红黑树而不用别的树

​	红黑树是一个比较特殊的树，跟他能产生对比的是平衡二叉树。但是平衡二叉树的严格平衡牺牲了插入、删除操作的性能，来保证了查询的高效。 而红黑树则采用了折中策略，即不牺牲太大的插入删除性能，同时又保证稳定高效的查找效率。

###   为什么MongoDB索引使用B树，而MySQL使用B+树

​	MongoDB是一个非关系型数据库，对于遍历数据的需求很低，更多的是在做一些单一记录查询。而对于MySQL这种关系型数据库来说，进行遍历关联查询的需求就会很高。

​	结合B树与B+树的特点来说，B树的查询效率不固定，最好的情况是O（1），所以在做单一数据查询时，B树的平均性能会更好。但如果要对B树进行遍历的话，由于各个节点间没有指针相连，所以性能会很低。

​	而B+树最大的特点是数据只会出现在叶子节点，因此对于单条数据查询，其一定会进入到叶子节点上，因此平均性能没有B树好。但B+树的叶子节点有指针相连，在进行遍历时，其效率会明显优于B树。

#  堆 

​- 堆通常是一个可以被看做一棵树的数组对象。堆的具体实现一般不通过指针域，而是通过构建一个一维数组与二叉树的父子结点进行对应，因此堆总是一颗完全二叉树。

- 对于任意一个父节点的序号n来说（这里n从0算），它的子节点的序号一定是2n+1，2n+2，因此可以直接用数组来表示一个堆。

- 不仅如此，堆还有一个性质：堆中某个节点的值总是不大于或不小于其父节点的值。将根节点最大的堆叫做最大堆或**大根堆**，根节点最小的堆叫做最小堆或**小根堆**。

![在这里插入图片描述](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/database/assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2JlZXdvcmtzaG9w,size_16,color_FFFFFF,t_7015)

- 堆常用来实现优先队列，与排序有关，比如堆排序、topK问题等。由于堆的根节点是序列中最大或者最小值，因而可以在建堆以及重建堆的过程中，筛选出数据序列中的极值，从而达到排序或者挑选topK值的目的。

## 案例PriorityBlockingQueue中二叉堆的使用 

### put过程 

````java
public void put(E e) {
        offer(e); // never need to block
    }


 public boolean offer(E e) {
        if (e == null)
            throw new NullPointerException();
        final ReentrantLock lock = this.lock;
        lock.lock();//加锁
        int n, cap;
        Object[] array;
     	//如果元素个数大于等于数组长度，开始扩容
        while ((n = size) >= (cap = (array = queue).length))
            tryGrow(array, cap);
        try {
            //一开始构建队列的时候传入comparator
            Comparator<? super E> cmp = comparator;
            if (cmp == null)
                //使用元素自带的comparator进行比较，并排序
                siftUpComparable(n, e, array);
            else
                //使用comparator进行比较，并排序
                siftUpUsingComparator(n, e, array, cmp);
            size = n + 1;//增加元素个数
            notEmpty.signal();//唤醒take线程
        } finally {
            lock.unlock();//解锁
        }
        return true;
    }

//新元素堆内上浮实现
    private static <T> void siftUpComparable(int k, T x, Object[] array) {
        //尝试转化插入对象为Comparable实例
        Comparable<? super T> key = (Comparable<? super T>) x; 
        while (k > 0) {
            // 新元素x的数组下标为k，对应的父节点的下标为(k-1)/2
            int parent = (k - 1) >>> 1; 
            Object e = array[parent];
            //如果子节点已经比父节点还要大，不需要再跟上层节点比较，新元素上浮结束
            if (key.compareTo((T) e) >= 0) 
                break;
            //如果子节点已经比父节点小，父节点下沉，新元素上浮一次
            array[k] = e; 
            k = parent; //新元素上浮后继续与新的父节点比较大小，直到k=0或者新的父节点小于新元素
        }
        array[k] = key;//新元素在堆中插入正确的位置。
    }

 private void tryGrow(Object[] array, int oldCap) {
     	//扩容期间需要解锁，能够让其他线程继续执行
        lock.unlock(); // must release and then re-acquire main lock
        Object[] newArray = null;//新数组
     	//cas标识，如果为0，表示当前没有线程对数组扩容
        if (allocationSpinLock == 0 &&
            //cas方式设置值0->1
            UNSAFE.compareAndSwapInt(this, allocationSpinLockOffset,
                                     0, 1)) {
            try {
                //开始扩容
                //计算新的数组长度
                int newCap = oldCap + ((oldCap < 64) ?
                                       (oldCap + 2) : // grow faster if small
                                       (oldCap >> 1));
                //计算容量不能超过最大大小
                if (newCap - MAX_ARRAY_SIZE > 0) {    // possible overflow
                    int minCap = oldCap + 1;
                    if (minCap < 0 || minCap > MAX_ARRAY_SIZE)
                        throw new OutOfMemoryError();
                    newCap = MAX_ARRAY_SIZE;
                }
                if (newCap > oldCap && queue == array)
                    newArray = new Object[newCap];//创建新的数组用来保存元素
            } finally {
                allocationSpinLock = 0;//重置标识，表示扩容完毕
            }
        }
        if (newArray == null) // back off if another thread is allocating
            Thread.yield();
        lock.lock();//重新加锁
     	//如果数组还是原来的数组
        if (newArray != null && queue == array) {
            queue = newArray;//设置为新数组
            System.arraycopy(array, 0, newArray, 0, oldCap);//转移元素到新数组
        }
    }
````

### take过程 

````java
 public E take() throws InterruptedException {
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();//加锁
        E result;
        try {
            while ( (result = dequeue()) == null)
                notEmpty.await();
        } finally {
            lock.unlock();
        }
        return result;
    }

private E dequeue() {
        int n = size - 1;
        if (n < 0)
            return null;//队列为空
        else {
            Object[] array = queue;
            E result = (E) array[0];//取出第一个,二叉堆中第一个最小
            E x = (E) array[n];
            array[n] = null;//设置为空
            Comparator<? super E> cmp = comparator;
            if (cmp == null)
                siftDownComparable(0, x, array, n);
            else
                siftDownUsingComparator(0, x, array, n, cmp);
            size = n;
            return result;
        }
    }

//空元素堆内下沉实现
    private static <T> void siftDownComparable(int k, T x, Object[] array, int n) {
        if (n > 0) {
            Comparable<? super T> key = (Comparable<? super T>) x;
            int half = n >>> 1; // loop while a non-leaf  half最后一个有子节点的父节点下标
            while (k < half) { 
                int child = (k << 1) + 1; // assume left child is least
                Object c = array[child];
                int right = child + 1;
                if (right < n
                        && ((Comparable<? super T>) c)
                                .compareTo((T) array[right]) > 0)
                    c = array[child = right];  //比较出左右子节点更小的那个子节点
                if (key.compareTo((T) c) <= 0) //如果左右子节点的最小值大于数组末尾的值，那么数组末尾的值直接放到父节点，空节点下沉结束
                    break;
                array[k] = c; // 如果子节点最小值小于数据末尾的值，子节点上浮到父空节点
                k = child; //空节点下滑到最小子节点的位置
            }
            array[k] = key; // 最后空节点填充数组最后的值
        }
    }
````






