---
title: spring百科全书：目录快查
categories: 通用文章
tags:
  - links
  - 目录文章
  - Spring
top: 200
abbrlink: 1120991051
date: 2021-12-23 10:23:54
password:
---



spring中有很多的知识需要去细心梳理，这个系列就是分析并记录这些核心知识，以及运用到实际项目中
	
	文章目的

- 梳理主流程，并且提供相关UML图便于理解
- 实际操作中的运用

<!--more-->

## IOC 整体流程

![请保存查看！！！](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/IOC.webp)

- Spring IOC梳理：Resource及Document体系
- Spring IOC梳理：ApplicationContext一览
- Spring IOC梳理：Bean创建-initializingBean
- Spring IOC梳理：Bean创建-属性注入
- Spring IOC梳理：Bean创建-主流程

### 主要知识梳理

#### IOC

- 盘点Spring IOC：循环依赖

![请保存查看！！！](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/iocCyli.webp)

#### AOP

- AOP的初始化

![请保存查看！！！](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/AOPinit.webp)

- AOP代理类的创建

![请保存查看！！！](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/AOPproxy.webp)

- AOP的拦截对象的创建

![请保存查看！！！](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/AOPintercepet.webp)

- AOP的拦截与方法调用

![请保存查看！！！](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/AOPincemethod.webp)

## SpringMVC

SpringMVC：MVC主流程

### 注解扫描及请求拦截

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/mvcrequest.webp)

### 方法映射

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/mvcmethod.webp)

### 属性转换

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/mvcinvert.webp)


## SpringBoot

- SpringBoot知识梳理 : 自动装配
- SpringBoot知识梳理 : Factories 处理流程
- SpringBoot知识梳理 : Application 主流程
- SpringBoot知识梳理 : Listener
- SpringBoot知识梳理 : Application配置的读取流程


## 深入理解Spring各节点

- BeanDefinition 的定制处理
- BeanFactory 的定制处理
- FactoryBean 的定制处理
- BeanPostProcessor 深度使用
- BeanAware 能干什么
- 自定义Spring 容器
- Spring 启动时能做什么
- InitializingBean 流程
- DisposableBean 流程



