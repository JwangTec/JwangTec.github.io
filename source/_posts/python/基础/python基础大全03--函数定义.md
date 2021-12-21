---
title: python基础大全03--函数定义
categories: python基础
tags:
  - python
  - 基础知识
  - 函数
top: 7
abbrlink: 2679684480
date: 2019-04-18 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)


### 函数基本定义

<!--more-->

1. 申明 函数命名规则与变量一样
2. 函数需要调用后才会运行，并函数可重复调用
3. 函数内部申明的变量在外部无法使用，即函数作用域
4. 全局变量：在函数外部定义的变量，可以拿到函数内部使用，只需要在需要使用该变量的函数内部将该变量变为全局变量：global 变量名
5. 变量的传递：将需要传递的变量放入函数头（）中,传递多个参数时，用, 隔开，在调用函数时需要注意一一对应其变量值，即 参数：可随意改变的值
6. 函数返回值：return 返回变量 ，调用函数则会返回return的结果，，其函数中若没有return 会在结尾自动加一个，存在输出语句则也会输出
7. 自定义函数/内置函数
8. return: 返回的为函数时，会暂停运行并调用相关函数，直到返回值为确定值，则继续运行该函数
9. 递归函数：函数调用函数本身

### 题型


1.1 * 2 * 3 * 4 * 5 * 。。。n =

```
		步骤： 1. 停止条件：n = 1
			  2. 分解条件（规律）： 若 n = 5  （确认一个后面的数，往前推）
			  
			   5 * num_sum(4)
			   	        4   *  num_sum(3)
			   	        			 3     *  num_sum(2)
												   2 * num_sum(1) --> num_sum(1)==1
			   5  *     4   *         3     *      2 *   1		   	        								 
			   	        						    
```

```
def num_sum(n):
    if n == 1:            #添加停止条件
        return n
    else:
        return n * num_sum(n - 1)    #递归函数，分解条件

print(num_sum(5))

```
2.斐波拉契数：1 1 2 3 5 8 ...

```	
	步骤：
			
			1.停止条件：n = 1或者 n = 2 即 num_qq(1) = 1 num_qq(2) = 1 （即最小元子确认）
			2.循环条件：若 n = 5 ：  bile(n) + bile(n-1)
					 			bile(5) 
				    			/     \
						bile(4)  +   bile(3)
	       			/	  \	         
	   				bile(3)+ bile(2)  
	    			/     \    1        
	 			bile(2)+bile(1)
	 			  1       1

```

```
def num_qq(n):
    if n == 1 or n == 2:     #添加停止条件
        return 1
    else:
        return num_qq(n - 1) + num_qq(n - 2)   #递归函数分解条件，反推或者正推 数值太大会卡顿
```

3.汉诺塔

```
递归函数：解题思路，将n==1的写出来 即将底层的结果写出来，然后将自己知道的过程或者下一步写出来，将下一步的如2 当成n 


def is_equeue(n,start, mid, end):
    if n == 1:
        print("{} to {}".format(start,end))     #一个的时候移动步骤
    else:
        is_equeue(n -1,start,end,mid)           #两个时候的移动步骤，当成n     2-1
        is_equeue(1,start,mid,end)
        is_equeue(n-1,mid,start,end)

is_equeue(3,'a','b','c')

```

4.二分法查找

```
def find(i, l):
    num = len(l) // 2
    if len(l) == 0:
        print("0")
    elif i > l[num]:
        find(i,l[(num + 1): ]) #可以不再判断这个中间值 直接+1

    elif i < l[num]:
        find(i,l[ :num])

    else:
        print("1")

find(13,[1,2,3,4,5,6,7,8,9])
```

```
查找并定位

def find(l,num,start,end):
    mid_index = (end + start) // 2
    if start > end:
        print("列表中不存在%d"%num)
    else:
        if l[mid_index] > num:
            return find(l,num,1,mid_index -1)
        elif l[mid_index] < num:
            return find(l,num,mid_index + 1,end)
        elif l[mid_index] == num:
            print("%d 的位置为：%d"%(num,mid_index))

l = [1,2,3,4,5,6,7,8,9,12,23,45]
find_i = len(l)
find(l,3,0,find_i)

```
5.一等函数，和变量一样，可传递和赋值

```
def fun1():
    print(2112)
a = fun1   #当成变量进行赋值
b = a
b()     #此时才是运行函数
```

6.高阶函数  接受函数作为参数的函数 详见pysort.py

```
sorted  排序，
fruits = ['strawberry','fig','apple','cherry','raspberry','banana']
list2 = sorted(fruits,key=len)   #根据len产生的返回值进行排序
print(list2)

def first_num(list1):
    return list1[0]
list4 = sorted(fruits,key=first_num)
print(list4)
lamda  无法复用，简单结构可以使用

list5 = sorted(fruits,key=lambda list_1: list_1[0])

print(list5)

```