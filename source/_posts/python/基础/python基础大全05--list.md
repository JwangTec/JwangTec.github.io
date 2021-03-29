---
title: python基础大全05--list
categories: python
tags:
  - python集合
top: 1
abbrlink: 2660417926
date: 2019-04-20 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)


### list 列表


<!--more-->


```
数据结构：组织并存取数据
list:有序的集合，列表 ，是一种数据结构
创建方式
取值方式

```

1.申明方式

	list1 = ['a',2,3,[1,2,3,4,[1,2,3]],'abcde']

2.将字符串转化为列表

	list2 = list("a,b")
	print(list2)

3.下标取值,下标取首不取尾,与数组相似取值方式

	print(list1[3][4][1])
	print(list1[0:3])

4.最后一个元素取法

	print(list1[-1])
	print(list1[len(list1)-1])    #列表不能为空

5.使用的len语句是计算的该列表中有多少个元素

	print(len(list1[3]))

6.元素更改

```
print(list1[1])
list1[1] = "b"         #元素修改
print(list1[1])
list1.append('f')      #尾部增加元素   其内置函数中没有return 所以print(list1.append())返回值为none
list1.insert(1,'b')    #在下标1处添加元素 返回值为none
print(list1.insert(1,'3'))
x = list1.pop(1)       #删除下标所在位置的元素，若无下标，则将尾部元素删除，返回值为删除的元素
list1.remove('a')        #找到该元素并移除 返回为none
range(start_num,end_num,间隔)：有序的一组数字
```

```
list2 = [1,'hello', 'world','c','d',[1,2,3,[1,2],5]]   #打印输出列表所有元素
for i in list2:                                  #for循环会将列表中存在的字符串也分开打印，例如'asd',for后为 'a','s','d'
    if not type(i) == list:                     #判断类别
        print(i)
    else:
        for j in i:
            print(j)
def for_list(list1):                 #使用函数打印所有列表中的元素
    for i in list1:
        if type(i) == list:
            for_list(i)
        else:
            print(i)
for_list([1,2,3,[1,2,[1,2,[12,34,['aasas','asadadf']]]]])  
```

7.列表切分

	list3 = [1,2,3,4,5]
	print(list3[1:3])   #切分1-2下标元素 长度为下标差

8.容器序列（容器）和编排序列（真正的数据）

```
list1 --> 容器(列表，元祖等） [1,2,3,4,5],[True,False] --> 编排序列

传统生成方式
list1 = []
for i in range(10):
    list1.append(i)

列表生成式：将一个编排序列放入列表中
list1 = [i for i in range(10)]       #性能更高
list2 = [i for i in 'asdfghjk']

print(list1)
print(list2)

list3 = [(i, j) for i in list1 for j in list2]   #注意：(i,j)
print(list3)

l1 = ['spades', 'diamonda','clubs','hearts']
l2 = ['A',2,3,4,5,6,7,8,9,'j','q','k',10]
list4 = [((i,j)) for i in l2 for j in l1]    #注意循环次序

i  = 0
l2 = list()
while i < (len(list4)):
    if "k" in list4[i]:
        l2 += list4[i:i+1]
    i += 1

print(l2)

```
9.切片  取左不取右 前闭后开

```

list1= [i for i in range(1,11,1)]
print(list1)
xx = list1[2:4]   #2,3  便于计算切片的数量：4-2
yy = list1[1:]    #list1[1:len(list1)]
zz = list1[:3]    #不包括3之前的
print(xx)

l1 = list1[-1]
l2 = list1[-1:]
print(l1)
print(l2)     #两者区分，一个取值一个切片仍是列表

# print(id(list1))
# print(id(list1[2:5]))
# print(id(list1[3:4]))
# print(id(xx))
# print(id(yy))

```

10.引用规则：python中变量是引用而不是赋值

```
a = [1,2,3]
b = a              #直接将a的地址给了b，未重新开空间 对两个变量进行操作时，都是对同一个地址中存储的数据操作
a.append(4)
print(a)
print(id(a))
print(b)
print(id(b))
```