---
title: python基础大全04--控制语句
categories: python基础
tags:
  - python
  - 基础知识
  - 控制语句
top: 7
abbrlink: 3540061980
date: 2019-04-22 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)

## 控制语句：

<!--more-->

### 1 if 判断语句，

只接受True/False，只运行判断为真的语句快。

语句快中pass会不执行这一块语句

可以在判断语句中先赋值，再在语句外调用该值

if   else:

if elif else: 满足其中一个条件则执行该条件后直接跳出语句块

#### 1.1 基础判断举例
 	
1. 该成员是否是会员
 	
```
is_plus = True #是否是会员    # 基础判断
if is_plus:
    print("恭喜你，会员大大 ")
elif not is_plus:
    print("垃圾小号")
else:
    print("请充钱")
print("用薪创造快乐")
```

2. 折扣计算

```
buy_sum = float(input("购买后金额为："))     #折扣计算
if buy_sum < 0:
    print("非法操作")
else:
    if buy_sum > 400:
        buy_sum = buy_sum * 0.85
    else:
        buy_sum = buy_sum * 0.95
    print("实际支付金额：%.2f" % buy_sum)
```

3. 分数等级判断

```
score = float(input("分数： "))     #输入分数并判断其等级
if score > 100 or score < 0:
    print("无法判断")
elif score >= 90:
    print("等级为： A")
else:
    print("等级为： F")
```

## 循环语句：

### while：

若判断条件为真，循环运行其中的语句块，若为假，运行语句块外语句  注意：每次循环都会执行一次while进行判断

break：停止循环

continu：结束本次循环继续下一次循环

### while循环举例



成绩录入


```
num = 1
score = 0
while True:
    n = input("请输入第{}科成绩: ".format(num))
    n = int(n)
    if n > 100 or n < 0:
        n = input("输入错误，请重新输入第{0}科成绩".format(num))     #print（"输入错误，请重新输入"） continue
        n = int(n)                                               #使用continu可以结束本次循环
    score = score + n
    if num >=5:
        print("总成绩为：{0},平均成绩为：{1}".format(score, score/num))
        break

    num += 1
    
```

九九乘法表

利用while循环进行，声明变量需要清晰表达所表达的内容

```
倒九九乘法表

i = 1

while i <= 9:
    j = 9
    xx =""
    while j >= i:
        xx += ("{0:d} * {1:d} = {2:2d}  |  ".format(i,j,i * j))
        j -= 1
    print(xx)
    i += 1
```

图形数字输出

在做类似多个循环嵌套时，可以将循环拆分开一步一步分拆成单个变量循环，最后嵌套在一起。对于本题，整个：先输出空格，再输出数字

	
	    1
	   2 3 
	  4 5 6
	 7 8 9 0
	  
```
space_num = n - 1
i = 1
n = 4
while space_num >= 0:
    string = (" "*space_num)
    j = 0
    while (n - space_num) > j:
        string += str(i % 10) + " "
        i += 1
        j += 1
    print(string)
    space_num -= 1
```

		
		     *
		    **
		   ***
		  ****
		 *****

```

lines = 6
start_num = 6
j = lines
while j > 0:
    space_num = lines - start_num

    print(" " * space_num + "*" * start_num)
    start_num -= 1
    j -= 1
```


		    *
		   ***
		  *****
		 *******
		  *****
		   ***
		    *
		
		分析： 
		（1）先确认行数：n                          n = 7 
		（2）再判断图形组成元素即对象数量，并确认命名    两个对象： 空格（space_num） *号 (star_num)
		（3）发现每个对象的循环规律，最好与循环或已知变量关联   space_num = abs(中间行数mid - 循环1.2.3...)
						        规律： 等差数列             star_num = (mid - space_num)* 2 - 1			 
		（4）确认循环结束条件： n > 0 n递减  i递增               
		（5）编写 测试

```
代码：
n = 7
mid = n // 2 + 1 #中间那一排
i = 1
while n > 0:
    space_num = abs(mid-i) #3
    base_num = mid-space_num #1
    star_num = base_num*2-1
    print(' '*space_num + "*"*star_num)
    i += 1
    n -= 1
    
```

```
  *****
   ***
    *
   ***
  *****
```

```    
n = 5                          # 中间一行的行数
a = n                          #3
j = 2 * n + 1                  #7 一共7行
while j > 0:                   #循环7次
    space_num = n - abs(a)     # 初始化
    j -= 1                     #j控制循环
    line_num = abs(2 * a) + 1  #  *  数
    a -= 1                     #  a递减 3 2 1 0 -1 -2 -3
    print(" "* (space_num) + "*" *line_num )
    
```
输入一个整数n，输出所有0~n之间的质数

```

def is_peime(num):           #判断是否为质数
    i = 2
    flag = True
    while num > i:           #循环条件
        if not num % i:      #质数判断，若为真（不是质数）则执行判断语句
            flag = False
            break            #符合该条件则直接跳出循环
        i += 1
    return flag

num1 = int(input("请输入一个大于1的整数： "))    #输出所有符合条件的质数
while num1 > 0:
    if is_peime(num1):      #调用质数函数
        print(num1)
    num1 -= 1
```

当比较大小时，需要注意比较值的初始化，最好与初始值输入值一样，不定义成0

```
# 1、从键盘输入10个数，求出最大数

num = 1
max_num = int(input("请依次输入第{}个数：".format(num)))    #初始化最大值，防止输入的数为负数，若比较大小都需要初始化比较值。

while num < 10:
    num += 1
    num1 = int(input("请依次输入第{}个数：".format(num)))
    if num1 > max_num:                           #若max_num=0，出现负数比较则直接会使max_num=0
        max_num = num1
print(max_num)
```