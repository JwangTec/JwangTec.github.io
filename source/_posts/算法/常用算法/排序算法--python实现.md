---
title: 排序算法--python实现
categories: 算法
tags:
  - 常用算法
  - python
top: 6
abbrlink: 1419621532
date: 2019-04-23 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)

### 资料博客：

[十大金典排序](https://www.jianshu.com/p/47170b1ced23)

<!--more-->

#### 1. 鸡尾酒排序 左右同时进行冒泡排序


```
def cocktaisort(list2):
    left = 0
    right = len(list2) - 1
    while left < right:
        for i in range(left, right, 1):
            if(list2[i] > list2[i + 1]):
                temp1 = list2[i+1]
                list2[i+1] = list2[i]          #交换python可以直接使用：list2[i],list2[i+1] = list2[i+1], list2[i]
                list2[i] = temp1
        right -= 1
        for i in range(right,left,-1):
            if(list2[i] < list2[i - 1]):
                temp1 = list2[i]
                list2[i] = list2[i -1]
                list2[i - 1] = temp1
        left+=1
        return list2

```

#### 2. 冒泡排序  顺序比较  两两比较，依次后移        性能较低

```
def sort(list1):
    num = len(list1)
    if num == 0:
        return list1
    for i in range(0,num,1):
        iswap = False
        for j in range(0,num - 1 - i,1):
            if list1[j + 1] < list1[j]:
                temp = list1[j + 1]
                list1[j + 1] = list1[j]
                list1[j] = temp
                iswap = True
        if (not iswap):
            break
    return  list1
```

#### 3. 简化冒泡排序     

```
def sort_bubble(list1):
    for i in range(len(list1)):
        j = 0
        while j < (len(list1) - 1 - i):
            if list1[j] > list1[j + 1]:
                temp = list1[j]
                list1[j] = list1[j+1]
                list1[j+1] = temp
            j += 1
    return list1
```

#### 4. 简单选择排序

```
def simpesort(list1):
    num = len(list1)
    if num == 0:
        return list1
    for i in range(0,num):
        min = i                       #最小值下标
        for j in range(i,num):         #i开始后推
            if list1[j] < list1[min]:   # 最小值与该值比较，符合则交换下标
                min = j
        temp = list1[min]              #下标对应值交换
        list1[min] = list1[i]
        list1[i] = temp
    return list1
```

#### 5. 直接插入排序:取出i + 1的元素 与前面排好序的元素从后向前比较，小于等于则将i+1元素插入到该位置（有一定序的时候效率最高）

```
def insert_sort(list1):
    length = len(list1)
    if len(list1) == 0:
        return list1
    for i in range(1,length,1):
        temp = list1[i]
        preindex = i - 1
        while preindex >= 0 and temp < list1[preindex]:
            list1[preindex + 1] = list1[preindex]
            preindex -= 1
        list1[preindex + 1] = temp
    return list1
```

#### 6. 二分插入排序  排好序的为一个数组，未排好序的为另一个

```
def Binaryinsertsort(list1):
    if len(list1) == 0:
        return list1
    for i in range(1,len(list1)):
        left = 0
        right = i - 1   #有序边界
        temp = list1[i]
        while left <= right:
            mid = left + (right - left) // 2
            if list1[mid] > temp:
                right = mid - 1
            else:
                left = mid + 1
        for j in range(i - 1,left,-1):
            list1[j+1] = list1[j]
        list1[left] = temp
    return list1
```

#### 7.归并排序 空间换时间，多了一个tmp列表占用内存，但时间减少为n*logn

```
def merge_sort(list1):
    if len(list1) < 2:
        return list1
    else:                               #递归函数分解列表
        mid = len(list1) // 2
        list1_left = merge_sort(list1[:mid])
        list1_right = merge_sort(list1[mid:])


        tmp = list()                   #tmp 为新列表 存放排好序的元素
        i = 0
        j = 0
        k = 0
        while i < len(list1_left) or j < len(list1_right):     #循环条件
            if i < len(list1_left) and j < len(list1_right):   #两个有序列表相比较，开始为一个元素，直接累积为两个有序列表
                if list1_left[i] < list1_right[j]:             #判断两个列表中元素的大小，小的放入tmp列表
                    tmp.append(list1_left[i])
                    i+=1
                else:
                    tmp.append(list1_right[j])
                    j += 1
            elif i >= len(list1_left):                        #分别判断是否超出左右列表最大下标，则只需要把左右列表合并到tmp里 反之一样
                tmp.append(list1_right[j])
                j += 1
            else:
                tmp.append(list1_left[i])
                i += 1
        return tmp
```

### 调用所有排序

```
def random_sort(sort_name):
    import random
    list1 = list()
    for i in range(10):
        list1.append(random.randint(0,100))

    print("使用%s排序结是%s"%(sort_name.__name__,sort_name(list1)))

list2 = [cocktaisort,sort,sort_bubble,simpesort,Binaryinsertsort,merge_sort]

for xx in list2:
    random_sort(xx)

```

### 使用装饰器计算程序运行时间

```
def dec(fun):             #装饰器：计算运行时间
    def res(*args,**kwarges):
        print('--------%s 算法-------------' % (fun.__name__))
        start = time.perf_counter()
        a = fun(*args,**kwarges)
        print('消耗的时间为 %s' %(time.perf_counter() - start))
        print('******************')
        return a
    return res
    
在需要计算时间的函数前加上 @dec 即可（详见test19.py）

```