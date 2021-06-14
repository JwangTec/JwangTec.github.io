---
title: Spring源码- IOC- Bean的初始化-循环依赖的解决
categories: Java框架
tags:
  - Java框架
  - Spring
top: 11
abbrlink: 568164911
date: 2019-07-01 18:18:19
password:
---


<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/mybatis.jpeg" width="1000" height="300" align="middle" />



# 前言

在实际工作中，经常由于设计不佳或者各种因素，导致类之间相互依赖。这些类可能单独使用时不会出问题，但是在使用Spring进行管理的时候可能就会抛出BeanCurrentlyInCreationException等异常 。当抛出这种异常时表示Spring解决不了该循环依赖，本文将简要说明Spring对于循环依赖的解决方法。

<!--more-->

循环依赖的产生和解决的前提
循环依赖的产生可能有很多种情况，例如：

A的构造方法中依赖了B的实例对象，同时B的构造方法中依赖了A的实例对象
A的构造方法中依赖了B的实例对象，同时B的某个field或者setter需要A的实例对象，以及反之
A的某个field或者setter依赖了B的实例对象，同时B的某个field或者setter依赖了A的实例对象，以及反之
当然，Spring对于循环依赖的解决不是无条件的，首先前提条件是针对scope单例并且没有显式指明不需要解决循环依赖的对象，而且要求该对象没有被代理过。同时Spring解决循环依赖也不是万能，以上三种情况只能解决两种，第一种在构造方法中相互依赖的情况Spring也无力回天。结论先给在这，下面来看看Spring的解决方法，知道了解决方案就能明白为啥第一种情况无法解决了。

Spring对于循环依赖的解决
Spring循环依赖的理论依据其实是Java基于引用传递，当我们获取到对象的引用时，对象的field或者或属性是可以延后设置的。
Spring单例对象的初始化其实可以分为三步：

createBeanInstance， 实例化，实际上就是调用对应的构造方法构造对象，此时只是调用了构造方法，spring xml中指定的property并没有进行populate
populateBean，填充属性，这步对spring xml中指定的property进行populate
initializeBean，调用spring xml中指定的init方法，或者AfterPropertiesSet方法
会发生循环依赖的步骤集中在第一步和第二步。
三级缓存
对于单例对象来说，在Spring的整个容器的生命周期内，有且只存在一个对象，很容易想到这个对象应该存在Cache中，Spring大量运用了Cache的手段，在循环依赖问题的解决过程中甚至使用了“三级缓存”。

“三级缓存”主要是指
