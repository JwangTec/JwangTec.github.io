---
title: python基础大全12--正则表达式
categories: python
tags:
  - python正则
top: 1
abbrlink: 1992162868
date: 2019-04-29 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)


#### 参考地址：[正则表达式运用](https://www.cnblogs.com/huxi/archive/2010/07/04/1771073.html)

<!--more-->

```
基础函数运用：


import re
pattern = re.compile(r'\d+')
print(pattern.split('one1two2three')) 
#以此分隔并返回分开后的形式
print(pattern.match('0one1two2three'))  
#返回一个对象
print(pattern.findall('one111two211three')) 
#返回所有能匹配的对象
print(pattern.finditer('one1two2three'))   
#返回为迭代器
pattern1 = re.compile(r'(\d\w+) (\d\w+)')  
#相互交换位置
print(pattern1.sub(r'\2 \1','1one 2two'))

```


####  正则表达式：邮箱等规则字符串可用   re函数

```
模糊查询：判断主题是字符串
特殊字符：
\d:数字（一个数字（开始为数字则正确））
\D:非数字
\w:单词字符
\W:非单词字符
\s:空白字符
[1-9]: 1到9数字
[a-z|A-Z]:

转义符：\
\\d:\d
\.:.
.:任意字符

|：左右满足任何一个即可

正则表达式的数量：
*:0个或多个
+：1个或多个
？：0个或1个  贪婪模式下:取消贪婪模式
注意：+ ？ * 匹配的是前一个字符
贪婪模式：*?  +?  ??  {1,4}?
^:以xxx开头
$:以XXX结尾
\A:相当于：^\w
\Z:相当于:\w$
{0,5}：格式重复次数0到5次
r:转译符，r'  '

```
#### re函数

```
match:尽量不匹配，找到一个马上返回
search：
findall:尽量匹配

import re


# pa = '\d'   #规则 --->正则表达式
# str1 = 'qaqsqdq12313'
#
# x = re.findall(pa,str1)
# print(x)

# def is_num(string1):
#     pattern = '\w+@\w+\.com'
#     x = re.findall(pattern,string1)
#     print(x)
#     return x
#
# while True:
#     str1 = input('输入邮箱： ')
#     res = is_num(str1)
#     if len(res) == 0:
#         print('xxxx')
#     else:
#         print('oooooo')
#         break

# def is_num(string1):
#     pattern = r"^((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.){3}(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])$"
#     # pattern = r'1\d\d|25[0-5]|2[0-4]\d'
#     x = re.findall(pattern, string1)
#     print(x)
#     return x
#
#
# while True:
#     str1 = input('输入号码： ')
#     res = is_num(str1)
#     if len(res) != 1:
#         print('xxxx')
#     else:
#         print('oooooo')
#         break
# content = 'Hello 12345 World'
# result = re.match('^Hello\s(\d+)\sWorld', content)
# print(result.group())

```

```
贪婪模式
# content = 'http://weibo.com/comment/kEraCNdsfgkdsfgjkldsjkl'
# result1 = re.match('http.*?comment/(.*?)', content)
# result2 = re.match('http.*?comment/(.*)', content)
# print('result1', result1.group(1))  # 结果 result1
# print('result2', result2.group(1))  # 结果 result2 kEraCN

# content = 'Hello 1234567 World_This is a Regex Demo'
# result = re.match('^He.*?(\d+).*Demo$', content)
# print(result.group(1))  # 结果
# result = re.match('^He.*(\d+).*Demo$', content)
# print(result.group(1))  # 结果 7

```