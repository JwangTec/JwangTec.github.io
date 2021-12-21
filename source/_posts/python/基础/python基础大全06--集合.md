---
title: python基础大全06--集合
categories: python基础
tags:
  - python
  - 基础知识
  - 集合
top: 7
abbrlink: 1512853071
date: 2019-04-24 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)

#### 字典: 键值对 key - value

<!--more-->

1.申明

```
dict1 = {'a':1,'b':2,'c':3}   #其中的每一个键值对都与下标无关，即与位置无关
dict2 = {'b':2,'a':1,'c':3}
print(dict1)
print(dict1['a'])
```

2.dict内置方法

```
dict3 = {'b':2,'a':1,'c':3,'d':dict1}
print(dict3.keys())        #打印所有的键

print(list(dict3.keys()))

print(list(dict3.values())) #打印所有的值

print(list(dict3.items()))  #打印所有的键和值

print(dict3.get('a','aa'))  #判断其是否存在该键值,有则返回对应的值，（键，值）

print(dict3.setdefault('hello','w')) #不存在该键值则更新字典，将其加入
print(dict3)

dict4 = {'f':134}
dict4.update(dict2)    #把dict2中的键值对更新到dict4中
print(dict4)

dict1.pop('a')         #将dict1中的键'a'对应的键值对删除
print(dict1)
del dict1['b']         #删除该键值对
print(dict1)

dict11 = dict.fromkeys(dict1)  #新建一个与dict1有相同键的字典，其值为none
print(dict11)

#键值对添加修改
dict2['world'] = 'e'    #无则添加该键值
print(dict2)
dict2['c'] = 'f'    #有则修改该键对应的值
print(dict2)

```

3.优化斐波拉契
 
 ```
 dict1 = {}
 def fib(n):
     if n == 1 or n == 2:
         return 1
     else:
         if dict1.get(n-1,''):
             x1 = dict1.get(n-1)
         else:
             x1 = fib(n-1)
             dict1[n-1] = x1
         if dict1.get(n-2,''):
             x2 = dict1.get(n-2)
         else:
             x2 = fib(n-2)
             dict1[n-2] = x2
         return x1 + x2
 print(fib(5))
 
 ```

#### tuple:元祖  不可修改的列表

```
可拆包
不可变 （针对某些元素）
用于轻量级数据中

 tup1 = ('asdf','s')
 tup4 = ('d',) #但元素加，
 tup2,tup3 = ('aa','bb')  #可以拆包
 print(tup3)
 print(tup2)

```

1.tuple取值：

```
1,下标取值
2。拆包

d = {'a':1,'b':2,'c':3}
for tup1,tup2 in d.items():     #若不需要tup1则可以写成 _ , tup2
    print(tup2)
for _,v in d.items():
    print(v)
l2 = [(k,v) for k,v in d.items()] #变成列表

```


#### set:集合  

```
元素不重合
可做集合运算 &（交集） |（并集） -（差集）

s = set('2235462346')
s1 = ({1,2,3,3,4,5,2,3,4})    #自动去掉重复的元素，不能嵌套list,dict.
#里面的元素必须是可hash的
print(s)
print(s1)
list1 = [1,2,3,4,5,2,3,4,2,2]

```

#### 浅复制

```
 a = [1,2,3,4,5]
 b = a[:]       #此时b重新指向另一个地址 但如果其中内嵌容器，则只会对数值改变，容器仍指向原地址

 l1 = [1,[22,33],(11,22,[33,44])]

 l2 = list(l1)     #新的列表创建。但内嵌列表和元祖的指向地址未改变

 l3 = l1[:]        #新列表创建，内嵌容器仍指向原地址
 print(l1 == l2)
 print(l1 is l2)

 l1[1].append(1111111)
 l1[2][2].append(2333)  #改变的为元祖中的内嵌列表，其仍可进行添加

 l1[0] = 9          #改变的是列表中的数值，其L1发生改变，对L2和L3无影响

 print(l1)
 print(l2)
 print(l3)


l1 = [2,[44,55],(44,55,[3,1])]
l2 = list(l1)
l1.append(100)
l1[1].remove(44)
l2[1] += [11,22]
l2[2] += (2,3)     #生成新的tuple但其内嵌的列表地址未改变，相当于浅复制

```