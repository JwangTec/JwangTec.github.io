---
title: Java源码-Collection-ArrayList
categories: 源码
tags:
  - Java源码
  - list
  - ArrayList
top: 404
abbrlink: 2569105826
date: 2021-11-30 09:56:23
password:
---


## 源码分析步骤

- 看继承结构：看这个类的层次结构，处于一个什么位置，可以在自己心里有个大概的了解。
- 看构造方法：在构造方法中，看做了哪些事情，跟踪方法中里面的方法。
- 看常用的方法：跟构造方法一样，这个方法实现功能是如何实现的

<!--more-->


## 关系依赖

![主体关系](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/ArrayList1.jpg)

## 类继承及实现接口

```java
public class ArrayList<E> 
extends AbstractList<E>
implements List<E>, RandomAccess, Cloneable, java.io.Serializable
```

- AbstractList: 该类提供了List接口的骨架实现，以最小化实现这个由“随机访问”数据存储(如数组)支持的接口所需的工作。对于顺序访问数据(比如链表)，应该优先使用AbstractSequentialList而不是这个类。要实现不可修改的列表，程序员只需要扩展这个类并提供get(int)和size()方法的实现。要实现一个可修改的列表，程序员还必须重写set(int, E)方法(否则将抛出UnsupportedOperationException)。如果列表是可变大小的，程序员还必须重写add(int, E)和remove(int)方法。与其他抽象集合实现不同，程序员不需要提供迭代器实现;迭代器和列表迭代器由这个类实现,按照collection接口规范中的建议，程序员通常应该提供一个void(没有参数)和集合构造函数。

- List：List类的顶层父类，所有相关list有序集合都会实现该类，除了在Collection接口中指定的规定之外，List接口对迭代器（在调用者不知道实现的情况下，对列表中的元素进行迭代通常比对其进行索引要好。）、add、remove、equals和hashCode方法进行了额外的规定

- RandomAccess：表明它们支持快速(通常是常量时间)随机访问

- Clonewable：一个类实现了Cloneable接口来指示Object.clone()方法，该方法对该类的实例进行字段对字段的复制是合法的。在一个没有实现Cloneable接口的实例上调用Object的克隆方法会导致抛出CloneNotSupportedException异常。

## 属性

![feild](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/ArrayListFiled.jpg)

```java
private static final int DEFAULT_CAPACITY = 10; 默认初始化容量
private static final Object[] EMPTY_ELEMENTDATA = {}; 空数组实例
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
 默认大小的空数组实例，便于确认添加第一个元素时扩大容量
transient Object[] elementData; 

数组缓冲区，数组列表元素会存储在其中，elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA
的空ArrayList在第一次添加元素时会扩展为EMPTY_ELEMENTDATA

private int size; 大小
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8; 
能分配的最大数组大小，有些虚拟机保留了标题字


protected transient int modCount = 0;
结构上修改此列表的次数。结构修改是指改变列表的大小，或者以一种扰乱列表的方式，使在进行中的迭代可能产生不正确的结果。
```

## 构造函数

![构造函数](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/ArrayListConstructors.jpg)

- `ArrayList(int initialCapacity)`：
 构造一个有指定初始化容量的空集合 initialCapacity = 0 ？elementData=EMPTY_ELEMENTDATA：new Object[initialCapacity]

- `ArrayList()`：构造一个初始化容量为10的空list，elementData=DEFAULTCAPACITY_EMPTY_ELEMENTDATA

- `ArrayList(Collection<? extends E> c)` ：构造一个包含指定集合元素的列表，按照集合迭代器返回元素的顺序。c不能为null，使用elementData = c.toArray().length!=0?Arrays.copyOf():EMPTY_ELEMENTDATA


## 方法

![method](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/ArrayListMethod.jpg)

### 增加元素的方法

```java
arrayList.add( E element);
arrayList.add(int index, E element);
arrayList.addAll(Collection<? extends E> c);
```

```java
public boolean add(E e) {
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        elementData[size++] = e;
        return true;
}

```
 
```java
private void ensureCapacityInternal(int minCapacity) {
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
            minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
        }
 
        ensureExplicitCapacity(minCapacity);
}

```

- 判断当前是否是使用默认的构造函数初始化，如果是设置最小的容量为默认容量10，即默认的elementData的大小为10（这里是有一个容器的概念，当前容器的大小一般是大于当前ArrayList的元素个数大小的）

 
```
private void ensureExplicitCapacity(int minCapacity) {
        modCount++;
 
        // overflow-conscious code
        if (minCapacity - elementData.length > 0)
            grow(minCapacity);
}

```

- modCount字段是用来记录修改过扩容的次数，调用ensureExplicitCapacity()方法意味着确定修改容器的大小，即确认扩容

```java
private void grow(int minCapacity) {
        // overflow-conscious code
        int oldCapacity = elementData.length;
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity);
}

private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :
            MAX_ARRAY_SIZE;
}
 
Integer. MAX_VALUE = 0x7fffffff;
MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8

```

- 一般默认是扩容1.5倍，当时当发现还是不能满足的话，则使用size+1之后的元素个数，如果发现扩容之后的值大于我们规定的最大值，则判断size+1的值是否大于MAX_ARRAY_SIZE的值，大于则取值MAX_VALUE，反之则MAX_ARRAY_SIZE，也就数说容器最大的数量为MAX_VALUE


```java
public void add(int index, E element) {
        if (index > size || index < 0)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
 
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        System.arraycopy(elementData, index, elementData, index + 1,
                         size - index); //将数组elementData从index开始的数据向后移动一位
        elementData[index] = element;
        size++;
}
```


### 删除元素的方法

```java
arrayList.remove(Object o);
arrayList.remove(int index)
arrayList.removeAll(Collection<?> c)
```

```java
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
 
private void fastRemove(int index) {
        modCount++;
        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; 
        // clear to let GC do its work 置空原尾部数据 不再强引用， 可以GC掉。
}
```

```java
public E remove(int index) {
        if (index >= size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
 
        modCount++;
        E oldValue = (E) elementData[index];
 
        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // clear to let GC do its work
 
        return oldValue;
}
```

```java
public boolean removeAll(Collection<?> c) {
        Objects.requireNonNull(c);
        return batchRemove(c, false);
}
 
public static <T> T requireNonNull(T obj) {
        if (obj == null)
            throw new NullPointerException();
        return obj;
}

对传入集合c进行判空处理

```

```
 
private boolean batchRemove(Collection<?> c, boolean complement) {
        final Object[] elementData = this.elementData;
        int r = 0, w = 0;
        boolean modified = false;
        try {
            for (; r < size; r++)
                if (c.contains(elementData[r]) == complement)
                    elementData[w++] = elementData[r];
        } finally {
            // Preserve behavioral compatibility with AbstractCollection,
            // even if c.contains() throws.
            if (r != size) {
                System.arraycopy(elementData, r,
                                 elementData, w,
                                 size - r);
                w += size - r;
            }
            if (w != size) {
                // clear to let GC do its work
                for (int i = w; i < size; i++)
                    elementData[i] = null;
                modCount += size - w;
                size = w;
                modified = true;
            }
        }
        return modified;
    }
```

- 定义局部变量elementData、r、w、modified 　　elementData用来重新指向成员变量elementData，用来存储最终过滤后的元素，w用来纪录过滤之后集合中元素的个数，modified用来返回这次是否有修改集合中的元素

- for循环遍历原有的elementData数组，发现如果不是要移除的元素，则重新存储在elementData，且w自增

- 如果出现异常，则会导致 r !=size , 则将出现异常处后面的数据全部复制覆盖到数组里。

- 判断如果w!=size，则表明原先elementData数组中有元素被移除了，然后将数组尾端size-w个元素置空，等待gc回收。再修改modCount的值，在修改当前数组大小size的值


### 修改元素的方法

```java
arrayList.set(int index, E element)

public E set(int index, E element) {
        if (index >= size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
 
        E oldValue = (E) elementData[index];
        elementData[index] = element;
        return oldValue;
}
```

### 查询元素的方法

```java
arrayList.get(int index);

public E get(int index) {
        if (index >= size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
 
        return (E) elementData[index];
}
```

### 判断是否存在某个元素

```java
arrayList.contains(Object o);
arrayList.lastIndexOf(Object o);
```

```java
public boolean contains(Object o) {
        return indexOf(o) >= 0;
}
 
public int indexOf(Object o) {
        if (o == null) {
            for (int i = 0; i < size; i++)
                if (elementData[i]==null)
                    return i;
        } else {
            for (int i = 0; i < size; i++)
                if (o.equals(elementData[i]))
                    return i;
        }
        return -1;
}
 
public int lastIndexOf(Object o) {
        if (o == null) {
            for (int i = size-1; i >= 0; i--)
                if (elementData[i]==null)
                    return i;
        } else {
            for (int i = size-1; i >= 0; i--)
                if (o.equals(elementData[i]))
                    return i;
        }
        return -1;
    }
```

- 不管是contains方法还是lastIndexOf方法，其实就是进行for循环，如果找到该元素则记录下当前元素下标，如果没找到则返回-1


## 总结

- arrayList可以存放null。
- arrayList本质上就是一个elementData数组。
- arrayList区别于数组的地方在于能够自动扩展大小，其中关键的方法就是gorw()方法。
- arrayList中removeAll(collection c)和clear()的区别就是removeAll可以删除批量指定的元素，而clear是全是删除集合中的元素。
- arrayList由于本质是数组，所以它在数据的查询方面会很快，而在插入删除这些方面，性能下降很多，有移动很多数据才能达到应有的效果
- arrayList实现了RandomAccess，所以在遍历它的时候推荐使用for循环。









