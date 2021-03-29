---
title: python基础大全11--面相对象
categories: python
tags:
  - python面向对象
top: 1
abbrlink: 1278160075
date: 2019-04-27 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)


###  面向对象


<!--more-->

```
面向对象：先有类（抽象）才有对象（具体）
class:
可继承  class Mylist(list):  括号里为其它的对象等   ：可多继承，层层继承，本次继承拥有被继承以及上面所有
继承父类的init时，需要使用supper().__init__()
可重写：可以在继承的类中重写其中的方法或功能（多态）
可扩展：继承中可以增加新的方法或功能

```

```
import random
#类的申明方式
class Car:  #在这个下面可以有无数函数  命名：首字母必须大写

    def __init__(self):        
    #面向对象中的所有东西可共享（通过self挂载，再通过self调用，只用于类）init中为确定的功能
        self.coloer = 'red'
        self.ppai = 'jili'
        self.kuandu = 1900
        print('对象初始化')
        self.x = random.randint(0,100)

    def test(self):
        print(self.coloer)
        self.laba()
        return self.ppai

    def laba(self):
        self.changd = 8000

    def de_self(self):
        print(self.x)     #挂载在self上，每次调用地址不同
        print(id(self.x))
        xx = random.randint(0,100)  #依附于class上，相当于函数变量，每次调用地址相同
        print(xx)
        print(id(xx))

    def de1_self(self):
        self.de_self()


# car1 = Car()         
类的实例化(对象) 会直接调用类中的__init__（初始化）函数 (魔法函数都以__名称__为命名格式)初始化
# car2 = Car()         
可实例化多次
# # print(car1.test())   
调用功能函数
# # print(car1.coloer)    
调用self的属性
# car1.laba()             
属于类里除__init__函数之外的self需要先运行其类中对应的函数，才能挂载在self上，对象才能继续调用
# print(car1.changdu)
```


###  self


```
self：相当于挂载器，可以将类中的各个属性通过其挂载，再使用，属于对象，可以在类中互相传递
每个self都有一个独立的空间

car1 = Car()
car1.de_self()
car1.de1_self()
'''

# import random
# class Student:
#     def __init__(self):
#         self.cla_num = random.randint(1,5)
#         self.cla_stunum = random.randint(1,50)
#
#
#     def cla_girls(self):
#         stunum = self.cla_stunum
#         self.girls = random.randint(1,stunum)
#         print("女生人数：%d"%self.girls)
#
#     def cla_boysnum(self):
#         cla_boyssnum = self.cla_stunum - self.girls
#         print("男生人数：%d"%cla_boyssnum)
# student1 = Student
# student1.cla_girls()
# student1.cla_boysnum()


```


###  私有属性

```
class Room:
    def __init__(self,name_num):  #初始化时，可以加入参数
        self.__password = 111   #在前面+__后 该属性变成私有，只能在内部调用
        self.__card = 111111
        self.n = name_num

    def card_get(self):      #可以通过函数传出，但可以修改成其它值
        return self.__card / 2

    def get_password(self):
        return '12365'

xx = Room('aaaa')  #参数值传入并初始化

print(xx.card_get())
print(xx.get_password())


#每一个类中都存在默认函数：如__str__(魔法函数，会自动调用)

```

### 内置函数调用装饰器

```
class Person:

    def __init__(self,name,age,id):
        self.__age = age       #私有属性：进行运行时无法查看（被保护）,可隐藏真实数据
        self.__name = name
        self.id = id


    def age(self):
        return self.__age//2

    def set_age(self,age):  #判断输入的参数是否符合规则，符合就修改该参数
        if age < 50:
            self.__age = age
        else:
            self.__age = 50

        return self.__age


    @property  # 可以直接使用函数名调用的内置装饰器
    def name(self):
        return self.__name

    def id_c(self):
        print(self.id)


p = Person('xxx',50,12)

print(p.age())  #只能通过函数调用该属性，并且函数能改原数据

print(p.name)   #不需要加（）即可调用该函数

p.id = 14    #可修改类中的参数。
p.id_c()

p.set_age(30)   #判断参数规则并修改该参数
print(p.age())


```

###  __slots__

```
class DataBaset:
    #在设置属性时会直接调用，控制其对象只能存在的属性
    __slots__ = ('__password','__database_name','__name')

    def __init__(self):
        self.__name = ''
        self.__password = ''
        self.__database_name = ''

    def name(self):
        return self.__name
    @property   #将函数变成属性  若有相关联的setting则需要对setting中的语句再执行该变量
    def password(self):
        return "{}".format('*' * len(self.__password))

    def set_name(self,name):
        iswasp = True
        while iswasp == True:
            if type(len(name)) == str:
                print("非字符串")
                iswasp = False
            elif len(name) < 6:
                print('账户名错误')
                iswasp = False
            elif 48 <= ord(name[0])<= 57:
                print("首字母为数字")
                iswasp = False
            else:
                self.__name = name
                break
    @password.setter   #在变成属性的函数赋值时会调用此setting函数
    def password(self,password):
        if type(password) != str:
            print('错误')
            return
        if len(password) < 8:
            print('长度不够')
            return
        self.__password = password


mysql = DataBaset()


```

###  注意点

```
# mysql.name = 'aaaaaa'  #未修改类中的任何，只是单纯定义（直接在类中设置控制函数就可）

'''
在使用property后 如果需要直接使用赋值语法修改被保护的，可在相关判断条件下使用  
@判断名(需要与函数名一样).setter
'''
mysql.password = 'aaa'
print(mysql.password)

```