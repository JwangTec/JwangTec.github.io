---
title: LinkedList源码解析
categories: 源码分析
tags:
  - Collection
  - LinkedList
top: 5
abbrlink: 800868230
date: 2021-11-30 09:56:23
password:
---


	LinkedList将做为双链表来实现，它本身实现了List接口和Deque接口，
	并且实现了所有可选的列表操作，并且允许包含所有元素（包括null）。

<!--more-->


## 前瞻

### UML

![UML](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/LinkedListMain.jpg)

```java
public class LinkedList<E>
extends AbstractSequentialList<E>
implements List<E>, Deque<E>, Cloneable, java.io.Serializable
```

- AbstractSequentialList: 在遍历LinkedList的时候，官方更推荐使用顺序访问，也就是使用我们的迭代器。（因为LinkedList底层是通过一个链表来实现的）（虽然LinkedList也提供了get（int index）方法，但是底层的实现是：每次调用get（int index）方法的时候，都需要从链表的头部或者尾部进行遍历，每一的遍历时间复杂度是O(index)，而相对比ArrayList的底层实现，每次遍历的时间复杂度都是O(1)。所以不推荐通过get（int index）遍历LinkedList。至于上面的说从链表的头部后尾部进行遍历：官方源码对遍历进行了优化：通过判断索引index更靠近链表的头部还是尾部来选择遍历的方向）（所以这里遍历LinkedList推荐使用迭代器）。
- List：提供List接口中所有方法的实现
- Cloneable：它支持克隆（浅拷贝），底层实现：LinkedList节点并没有被克隆，只是通过Object的clone（）方法得到的Object对象强制转化为了LinkedList,然后把它内部的实例域都置空，然后把被拷贝的LinkedList节点中的每一个值都拷贝到clone中
- Deque：实现所有相关操作，标识其符合队列的形式

### Node数据结构

```java
private static class Node<E> {
    E item;
    Node<E> next;
    Node<E> prev;

    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```

- Node 类是LinkedList中的私有内部类，LinkedList中就是通过Node来存储集合中的元素。
- E ：节点的值。
- Node next：当前节点的后一个节点的引用（可以理解为指向当前节点的后一个节点的指针）
- Node prev:当前节点的前一个节点的引用（可以理解为指向当前节点的前一个节点的指针）

## 属性

![feild](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/LinkedListField.jpg)

```java
transient int size = 0; //用来记录LinkedList的大小

/**
 * Pointer to first node.
 * Invariant: (first == null && last == null) ||
 *            (first.prev == null && first.item != null)
 */
transient Node<E> first;  //用来表示LinkedList的头节点。

/**
 * Pointer to last node.
 * Invariant: (first == null && last == null) ||
 *            (last.next == null && last.item != null)
 */
transient Node<E> last; //用来表示LinkedList的尾节点。
```

## 构造函数

![构造函数](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/LinkedListConstroller.jpg)

- LinkedList提供了两个构造器，ArrayList比它多提供了一个通过设置初始化容量来初始化类。- 
- LinkedList不提供该方法的原因：因为LinkedList底层是通过链表实现的，每当有新元素添加进来的时候，都是通过链接新的节点实现的，也就是说它的容量是随着元素的个数的变化而动态变化的。而ArrayList底层是通过数组来存储新添加的元素的，所以我们可以为ArrayList设置初始容量（实际设置的数组的大小）。


- 首先调用一下空的构造器。
- 然后调用addAll(c)方法。

```java
public LinkedList(Collection<? extends E> c) {
    this();
    addAll(c);
}
```

- 通过调用addAll(int index, Collection<? extends E> c) 完成集合的添加。

```java
public boolean addAll(Collection<? extends E> c) {
    return addAll(size, c);
}

```


```java
public boolean addAll(int index, Collection<? extends E> c) {
    checkPositionIndex(index);

    Object[] a = c.toArray();
    int numNew = a.length;
    if (numNew == 0)
        return false;

    Node<E> pred, succ; //指代待添加节点的位置。指代待添加节点的前一个节点。
    if (index == size) {
    //新添加的元素的位置位于LinkedList最后一个元素的后面。
        succ = null;
        pred = last;
    } else {
    //新添加的元素的位置位于LinkedList中。
        succ = node(index);
        pred = succ.prev;
    }

    for (Object o : a) {
        @SuppressWarnings("unchecked") E e = (E) o;
        Node<E> newNode = new Node<>(pred, e, null);
        if (pred == null)
            first = newNode;
        else
            pred.next = newNode;
        pred = newNode;
    }

    if (succ == null) {
    //新添加的节点位于LinkedList集合的最后一个元素的后面
        last = pred;
    } else {
    //当不为空的时候，表明在LinkedList集合中添加的元素，
    	 //需要把pred的next指向succ上,succ的prev指向pred。
        pred.next = succ;
        succ.prev = pred;
    }

    size += numNew;
    modCount++;
    return true;
}

```

- 判断传进来的参数是否合法
- 先把集合转化为数组，然后为该数组添加一个新的引用（Objext[] a）
- 新建一个变量存储数组的长度。
- 如果待添加的集合为空，直接返回，无需进行后面的步骤。后面都是用来把集合中的元素添加到LinkedList中。
- 依据新添加的元素的位置分为两个分支
- 接着遍历数组中的每个元素。在每次遍历的时候，都新建一个节点，该节点的值存储数组a中遍历的值，该节点的prev用来存储pred节点，next设置为空。接着判断一下该节点的前一个节点是否为空，如果为空的话，则把当前节点设置为头节点。否则的话就把当前节点的前一个节点的next值设置为当前节点。最后把pred指向当前节点，以便后续新节点的添加。
- 最后把集合的大小设置为新的大小。

```java

private void checkPositionIndex(int index) {
    if (!isPositionIndex(index))
        throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}

private boolean isPositionIndex(int index) {
    return index >= 0 && index <= size;
}
```

## 辅助方法

### 把参数中的元素作为链表的第一个元素

- 因为我们需要把该元素设置为头节点，所以需要新建一个变量把头节点存储起来。
- 然后新建一个节点，把next指向f，然后自身设置为头结点。
- 再判断一下f是否为空，如果为空的话，说明原来的LinkedList为空，所以同时也需要把新节点设
- 置为尾节点。否则就把f的prev设置为newNode。
- size和modCount自增。

```java
private void linkFirst(E e) {
    final Node<E> f = first;
    final Node<E> newNode = new Node<>(null, e, f);
    first = newNode;
    if (f == null)
        last = newNode;
    else
        f.prev = newNode;
    size++;
    modCount++;
}
```

### 把参数中的元素作为链表的最后一个元素

- 因为我们需要把该元素设置为尾节点，所以需要新建一个变量把尾节点存储起来。
- 然后新建一个节点，把last指向l，然后自身设置为尾结点。
- 再判断一下l是否为空，如果为空的话，说明原来的LinkedList为空，所以同时也需要把新节点设
- 置为头节点。否则就把l的next设置为newNode。
- size和modCount自增。

```java
void linkLast(E e) {
    final Node<E> l = last;
    final Node<E> newNode = new Node<>(l, e, null);
    last = newNode;
    if (l == null)
        first = newNode;
    else
        l.next = newNode;
    size++;
    modCount++;
}
```

### 在非空节点succ之前插入元素e


- 首先我们需要新建一个变量指向succ节点的前一个节点，因为我们要在succ前面插入一个节点。
- 接着新建一个节点，它的prev设置为我们刚才新建的变量，后置节点设置为succ。
- 然后修改succ的prev为新节点。
- 接着判断一个succ的前一个节点是否为空，如果为空的话，需要把新节点设置为为头结点。
- 如果不为空，则把succ的前一个节点的next设置为新节点。

```java
void linkBefore(E e, Node<E> succ) {
     // assert succ != null;
    final Node<E> pred = succ.prev;
    final Node<E> newNode = new Node<>(pred, e, succ);
    succ.prev = newNode;
    if (pred == null)
        first = newNode;
    else
        pred.next = newNode;
    size++;
    modCount++;
}
```

### 删除LinkedList中第一个节点

- 使用该方法的前提是参数f是头节点，而且f不能为空。(并且是私有方法)


- 定义一个变量element指向待删除节点的值，接着定义一个变量next指向待删除节点的下一个节点。（因为我们需要设置f节点的下一个节点为头结点，而且需要把f节点的值设置为空）
- 把f的值和它的next设置为空，把它的下一个节点设置为头节点。
- 判断一个它的下一个节点是否为空，如果为空的话，则需要把last设置为空。否则的话，需要把next的prev设置为空，因为next现在指代头节点。
  
  
```java
private E unlinkFirst(Node<E> f) {
    // assert f == first && f != null;
    final E element = f.item;
    final Node<E> next = f.next;
    f.item = null;
    f.next = null; // help GC
    first = next;
    if (next == null)
        last = null;
    else
        next.prev = null;
    size--;
    modCount++;
    return element;
}
```

### 删除LinkedList的最后一个节点

- 该节点不为空, 并且返回删除节点对应的值	。和unlinkFirst（）方法思路差不多。

```java
private E unlinkLast(Node<E> l) {
    // assert l == last && l != null;
    final E element = l.item;
    final Node<E> prev = l.prev;
    l.item = null;
    l.prev = null; // help GC
    last = prev;
    if (prev == null)
        first = null;
    else
        prev.next = null;
    size--;
    modCount++;
    return element;
}
```

### 删除一个节点（该节点不为空）

```java
E unlink(Node<E> x) {
    // assert x != null;
    final E element = x.item;
    final Node<E> next = x.next;
    final Node<E> prev = x.prev;

    if (prev == null) {
        first = next;
    } else {
        prev.next = next;
        x.prev = null;
    }

    if (next == null) {
        last = prev;
    } else {
        next.prev = prev;
        x.next = null;
    }

    x.item = null;
    size--;
    modCount++;
    return element;
}
```

### 计算指定索引上的节点（返回Node）

- 先比较一下index更靠近链表（LinkedList）的头节点还是尾节点。然后进行遍历，获取相应的节点。

```java
Node<E> node(int index) {
    // assert isElementIndex(index);

    if (index < (size >> 1)) {
        Node<E> x = first;
        for (int i = 0; i < index; i++)
            x = x.next;
        return x;
    } else {
        Node<E> x = last;
        for (int i = size - 1; i > index; i--)
            x = x.prev;
        return x;
    }
}

```

## 通用方法

![方法](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/SourceCode/LinkedListMethod.jpg)

### 可使用的删除头结点，并返回删除的值

```java
public E removeFirst() {
    final Node<E> f = first;
    if (f == null)
        throw new NoSuchElementException();
    return unlinkFirst(f);
}
```

### 删除链表中的最后一个节点，并返回被删除节点的值。


```java
public E removeLast() {
    final Node<E> l = last;
    if (l == null)
        throw new NoSuchElementException();
    return unlinkLast(l);
}
```
 
### LinkedList头部添加一个新的元素、尾部添加一个新元素。

```java
public void addFirst(E e) {
linkFirst(e);
}
public void addLast(E e) {
linkLast(e);
}
```

### 判断LinkedList是否包含某一个元素

```java
public boolean contains(Object o) {
    return indexOf(o) != -1;
}
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

### 添加一个新元素

```java
public boolean add(E e) {
    linkLast(e);
    return true;
}
```

### 从LinkedList中删除指定元素。

- 只删除第一次出现的指定的元素
- 如果指定的元素在集合中不存在，则返回false，否则返回true

```java
public boolean remove(Object o) {
    if (o == null) {
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

### 清空LinkedList中的所有元素

- 直接遍历整个LinkedList，然后把每个节点都置空。最后要把头节点和尾节点设置为空，size也设置为空，但是modCount仍然自增

```java
public void clear() {
    // Clearing all of the links between nodes is "unnecessary", but:
    // - helps a generational GC if the discarded nodes inhabit
    //   more than one generation
    // - is sure to free memory even if there is a reachable Iterator
    for (Node<E> x = first; x != null; ) {
        Node<E> next = x.next;
        x.item = null;
        x.next = null;
        x.prev = null;
        x = next;
    }
    first = last = null;
    size = 0;
    modCount++;
}
```

### 获取对应index的节点的值。

```java
public E get(int index) {
    checkElementIndex(index);
    return node(index).item;
}
```

### 设置对应index的节点的值

```java
public E set(int index, E element) {
    checkElementIndex(index);
    Node<E> x = node(index);
    E oldVal = x.item;
    x.item = element;
    return oldVal;
}
```

### 在指定的位置上添加新的元素

```java
public void add(int index, E element) {
    checkPositionIndex(index);

    if (index == size)
        linkLast(element);
    else
        linkBefore(element, node(index));
}
```

### 移除指定位置上的元素

```java
public E remove(int index) {
    checkElementIndex(index);
    return unlink(node(index));
}
```

### 在LinkedList中查找object在LinkedList中最后出现的位置。

- 从后向前遍历，只返回第一出现的元素的索引，如果没找到，则返回-1

```java
public int lastIndexOf(Object o) {
    int index = size;
    if (o == null) {
        for (Node<E> x = last; x != null; x = x.prev) {
            index--;
            if (x.item == null)
                return index;
        }
    } else {
        for (Node<E> x = last; x != null; x = x.prev) {
            index--;
            if (o.equals(x.item))
                return index;
        }
    }
    return -1;
}
```

- 顺序遍历，只返回第一出现的元素的索引，如果没找到，则返回-1

```java
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

## 实现双端队列的方法

### 返回头结点的值

```java
//空直接返回
public E peek() {
    final Node<E> f = first;
    return (f == null) ? null : f.item;
}

//空会抛出异常
public E element() {
    return getFirst();
}
```

### 移除头结点，并返回移除的头结点的值

```java

//空直接返回
public E poll() {
    final Node<E> f = first;
    return (f == null) ? null : unlinkFirst(f);
}

//空抛出异常
public E remove() {
        return removeFirst();
    }
public E removeFirst() {
    final Node<E> f = first;
    if (f == null)
        throw new NoSuchElementException();
    return unlinkFirst(f);
}
```

### 链表添加元素

```java
//尾部添加
public boolean offer(E e) {
    return add(e);
}

//头部添加   
public boolean offerFirst(E e) {
    addFirst(e);
    return true;
}

//尾部添加
public boolean offerLast(E e) {
    addLast(e);
    return true;
}
```

### 弹出元素

```java

//弹出链表的头结点的元素，如果为空，则返回null
public E peekFirst() {
    final Node<E> f = first;
    return (f == null) ? null : f.item;
 }

//弹出链表的尾结点的元素，如果为空，则返回null
public E peekLast() {
final Node<E> l = last;
return (l == null) ? null : l.item;
}
```

### 去除链表两端元素，并删除节点

```java
//取出链表头节点的值，并删除该头节点。如果头结点为空，则返回null
public E pollFirst() {
    final Node<E> f = first;
    return (f == null) ? null : unlinkFirst(f);
}
 
//取出链表尾节点的值，并删除该尾节点。如果头结点为空，则返回null   
public E pollLast() {
    final Node<E> l = last;
    return (l == null) ? null : unlinkLast(l);
}
```

### 队列操作-增加、删除元素

```java
//增加一个新的元素：（新添加的元素位于LinkedList的头结点。）
public void push(E e) {
    addFirst(e);
}
//弹出头结点的元素。（删除头结点的值，并返回删除的值）（都是队列中才有的操作。）   
public E pop() {
    return removeFirst();
}
```

### 移除第一次或最后一次出现的元素。（遍历集合）

```java
//从前向后
public boolean removeFirstOccurrence(Object o) {
    return remove(o);
}
//从后向前
public boolean removeLastOccurrence(Object o) {
    if (o == null) {
        for (Node<E> x = last; x != null; x = x.prev) {
            if (x.item == null) {
                unlink(x);
                return true;
            }
        }
    } else {
        for (Node<E> x = last; x != null; x = x.prev) {
            if (o.equals(x.item)) {
                unlink(x);
                return true;
            }
        }
    }
    return false;
}
```

### 克隆

- 直接调用超类的clone（）方法，然后把得到的Object对象转换为LinkedList类型。
Object的clone（）方法是本地方法（通过native修饰）

- 首先获取从辅助方法返回的LinkedList对象，接着把该对象的所有域都设置为初始值。
然后把LinkedList中所有的内容复制到返回的对象中

```java

@SuppressWarnings("unchecked")
private LinkedList<E> superClone() {
    try {
        return (LinkedList<E>) super.clone();
    } catch (CloneNotSupportedException e) {
        throw new InternalError(e);
    }
}

public Object clone() {
    LinkedList<E> clone = superClone();

    // Put clone into "virgin" state
    clone.first = clone.last = null;
    clone.size = 0;
    clone.modCount = 0;

    // Initialize clone with our elements
    for (Node<E> x = first; x != null; x = x.next)
        clone.add(x.item);

    return clone;
}
```

### 转化为数组

```java
public Object[] toArray() {
    Object[] result = new Object[size];
    int i = 0;
    for (Node<E> x = first; x != null; x = x.next)
        result[i++] = x.item;
    return result;
}

 * 泛型方法
 * 在方法内部，如果a的长度小于集合的大小的话，
 * 通过反射创建一个和集合同样大小的数组，
 * 接着把集合中的所有元素添加到数组中。
 * 如果数组的元素的个数大于集合中元素的个数，则把a[size]设置
 * 为空。
 * 我估计代码设计者这样设计代码的目的是为了能够通过返回值观察到
 * LinkedList集合中原来的元素有哪些。通过null把集合中的元素凸显出来。
 * ArrayList中也有同样的考虑和设计。
 
@SuppressWarnings("unchecked")
public <T> T[] toArray(T[] a) {
    if (a.length < size)
        a = (T[])java.lang.reflect.Array.newInstance(
                            a.getClass().getComponentType(), size);
    int i = 0;
    Object[] result = a;
    for (Node<E> x = first; x != null; x = x.next)
        result[i++] = x.item;

    if (a.length > size)
        a[size] = null;

    return a;
}
```

### 序列化和反序列化

```java
//将LinkedList写入到流中。（也就是把LinkedList状态保存到流中）
private void writeObject(java.io.ObjectOutputStream s)
    throws java.io.IOException {
    // Write out any hidden serialization magic
    s.defaultWriteObject();

    // Write out size
    s.writeInt(size);

    // Write out all elements in the proper order.
    for (Node<E> x = first; x != null; x = x.next)
        s.writeObject(x.item);
}
//从流中把LinkedList读取出来（读取流，拼装成LinkedList）（反序列化）
@SuppressWarnings("unchecked")
private void readObject(java.io.ObjectInputStream s)
    throws java.io.IOException, ClassNotFoundException {
    // Read in any hidden serialization magic
    s.defaultReadObject();

    // Read in size
    int size = s.readInt();

    // Read in all elements in the proper order.
    for (int i = 0; i < size; i++)
        linkLast((E)s.readObject());
}
```

### 迭代器

```java
//List的专有迭代器ListIterator。
public ListIterator<E> listIterator(int index) {
    checkPositionIndex(index);
    return new ListItr(index);
}

//向后遍历的Iterator
public Iterator<E> descendingIterator() {
    return new DescendingIterator();
}
```

## 总结

- LinkedList底层是一个双链表。是一个直线型的链表结构。
- LinkedList内部实现了6种主要的辅助方法：void linkFirst(E e)、void linkLast(E e)、linkBefore(E e, Node<E> succ)、E unlinkFirst(Node<E> f)、E unlinkLast(Node<E> l)、E unlink(Node<E> x)。它们都是private修饰的方法或者没有修饰符，表明这里都只是为LinkedList的其他方法提供服务，或者同一个包中的类提供服务。在LinkedList内部，绝大部分方法的实现都是依靠上面的6种辅助方法实现的


