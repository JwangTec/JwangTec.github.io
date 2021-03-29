---
title: python基础大全02--helloword
categories: python
tags:
  - 数据类型
  - python入门
top: 1
abbrlink: 3728702410
date: 2019-03-28 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)


# python常识

<!--more-->


1. 编译器：编译器就是将“一种语言（通常为高级语言）”翻译为“另一种语言（通常为低级语言）”的程序。一个现代编译器的主要工作流程：源代码 (source code) → 预处理器 (preprocessor) → 编译器 (compiler) → 目标代码 (object code) → 链接器 (Linker) → 可执行程序 (executables)
2. python编译器：pythonc
3. pyhton领域：数据分析、人工智能、爬虫
4. python缺点：运行速度慢，属于解释性语言

# 数据类型

1. int: 整型 
		
		注意：print("12345") 与 print(12345), 前者是字符串存储，其占40个bit 后者为整型，占14个bit.
			 前者是ascill码保存，后者直接转化为二进制
2. float：单精度型 
3. 两者区别：前者直接可以转化为二进制，后者需要遵循IEEE协议进行编码（指数E）

# 入门命令

1. print("hello world")
2. print(123456)
3. bin(589): 将十进制转化为二进制
