---
title: python基础大全09--模块操作
categories: python
tags:
  - python模块操作
top: 1
abbrlink: 1559717923
date: 2019-04-26 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)

### 模块的引用与创建

<!--more-->

```
test1.py

小技巧，程序自动识别当前执行的python文件名   __file__

def a_test():
    return 'a.py'
def test():     #return 为空 调用会多一个返回值空，以及执行该函数打印出aaaa
    print("aaaaa")
if __name__ == "__main__":   #该命令下的不会被引用执行
    print("不可被引用的命令test1")
print('可以被调用的test1')
```

```
test2.py
from module.test1 import a_test,test  #引用来自module包下test1.py中的a_test函数，
module包必须含有_init_.py文件

def b_test():
    return 'b.py'

print(a_test())   #输出test1中的a_test函数运行结果
print(test())
```

```
test3.py

import module.test1    #引用目标文件名 -- 会先执行import下的文件
import module.a_test
print(module.test1.a_test())  #直接调用该文件下的为a_test的函数，并打印输出  
若有其它文件调用该文件下函数，会执行该文件下的命令，解决方案见test1.py
print(module.test1.test())    #会先执行module下test1中的所有，
再执行函数test若无return会返回空
print(module.a_test.get_path())  #调用的执行目标文件所在路径，
而不是该命令所在文件的路径

```


### 引用内置库

```
import os    #引进os模块，详见a_test.py
import time

time.sleep(2) #程序暂停2秒
time.time()#时间戳
datetime.time() #运行时间

import random
random.randint(0,10)  #伪随机
random.random()  #随机浮点数

```
### 引用第三方库

```
安装外部库：pycharm -- preferences -- project interpreter -- + -- '选择库' -- install
相当于执行了：pip3 install requests(浏览网页)
import requests

r = requests.get('https://www.baidu.com')
print(r.text)

```

### 建立自己的库：在需要的文件夹下建立一个__init__.py文件,或者系统自动生成，该文件夹会成为一个库


```
from module import test1
test1.test()
```

### 文件读取

```
r w a -->读 写（会覆盖文件中的内容） 追加写（末尾添加）读写文件性能会很低，因为文件存在磁盘，需要转到CPU运行

 w = open('open.txt','r')  #每次都只能操作一个方法
 w.write('测试写')
 w.close()          #文件操作后需要关闭，文件描述符有关

r.readlines():一行一行读

 r = open('open.txt','r')  #读取文档中所有内容（字节读取）
 read_txt = ''
 while True:
     x = r.read(1)      #一个字节一个字节读取
     if len(x) == 0:
         break
     read_txt += x
 r.close()
 print(read_txt)


 r = open('open.txt','r')  #读取文档中的所有内容（行读取）
 read_txt = ''
 while True:
     x = r.readlines()
     if len(x) == 0:
         break
     print(x)
 r.close()

#无需关闭文件的方法：
 with open('open.txt','r') as r:  #在其中的文件操作代码运行后会自动关掉
     read_txt = ''
     while True:
         x = r.readlines()
         if len(x) == 0:
             break
         print(x)
         
```