---
title: spring百科全书-SpringIOC：循环依赖
top: 200
categories: Java_spring
tags:
  - Java
  - Spring
abbrlink: 1426955188
date: 2021-12-23 11:15:21
password:
---



<!--more-->

## 循环依赖的形成

循环依赖是指三个对象互相依赖 , 当通过 getBean 去获取依赖的 Bean 时 , 就形成了循环依赖

```java
// 这里先使用 Scope 尝试使用 prototype 模式 
@Component
@Scope(value = "prototype")
public class BeanCService{}

// 当 BeanA , BeanB , BeanC 相互依赖时 , 结果是这样的 :
 The dependencies of some of the beans in the application context form a cycle:
   beanStartService (field private com.gang.BeanAService com.gang.BeanStartService.beanAService)
┌─────┐
|  beanAService (field private com.gang.BeanBService com.gang.BeanAService.beanBService)
↑     ↓
|  beanBService (field private com.gang.BeanCService com.gang.BeanBService.beanCService)
↑     ↓
|  beanCService (field private com.gang.BeanAService com.gang.study.BeanCService.beanAService)
└─────┘
```

去掉 @Scope(value = "prototype") 后 , 一切正常

循环依赖是在 单例模式中处理完成的

## 源码分析

可以从源码的角度分析，Spring IOC的单例是怎么控制循环依赖的


