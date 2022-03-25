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


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc0.png)

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

### 单例Bean的加载流程

####  起点： AbstractBeanFactory 


```java
C- AbstractBeanFactory 
    M- doGetBean :
        - Object sharedInstance = getSingleton(beanName) : 从缓存中获取Bean
```

- 创建第一个 BeanA 时 , 进入 DefaultSingletonBeanRegistry

```java
// 继续深入 DefaultSingletonBeanRegistry , 其中有以下的参数
C180- DefaultSingletonBeanRegistry
    F01- private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);
        ?- 单例对象的缓存:bean到bean实例的名称
        
    F02- private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);
        ?- 单例工厂的缓存:ObjectFactory的bean名
        
    F03- private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);
        ?- 早期单例对象的缓存:bean到bean实例的名称
        
    F04- private final Set<String> registeredSingletons = new LinkedHashSet<>(256);
        ?- 一组已注册的单例，按注册顺序包含bean名称
        
    F05- private final Set<String> singletonsCurrentlyInCreation =Collections.newSetFromMap(new ConcurrentHashMap<>(16));
        ?- 当前正在创建的bean的名称
        
    F06- private final Set<String> inCreationCheckExclusions =Collections.newSetFromMap(new ConcurrentHashMap<>(16));
        ?- 当前在创建检查中被排除的bean的名称
        
    F07- private Set<Exception> suppressedExceptions;
        ?- 异常列表
        
    F08- private boolean singletonsCurrentlyInDestruction = false;
        ?- 标志是否正在销毁单例
        
    F09- private final Map<String, Object> disposableBeans = new LinkedHashMap<>();
        ?- 一次性bean实例:从bean名称到一次性实例
        
    F10- private final Map<String, Set<String>> containedBeanMap = new ConcurrentHashMap<>(16);
        ?- 包含bean名称之间的映射:bean名称到bean所包含的一组bean名称
        
    F11- private final Map<String, Set<String>> dependentBeanMap = new ConcurrentHashMap<>(64);
        ?- 依赖bean名称之间的映射:bean名称到一组依赖bean名称
        
    F12- private final Map<String, Set<String>> dependenciesForBeanMap = new ConcurrentHashMap<>(64);
        ?- 依赖bean名称之间的映射:bean名称到bean依赖项的一组bean名称
```

#### 创建一个单例Bean

```java
// 当我们创建一个单例Bean 时
C180- DefaultSingletonBeanRegistry      
    M180_01- getSingleton(String beanName, boolean allowEarlyReference)
        - 首先从 Map<String, Object> singletonObjects  中获取
        - 如果没有 , 且正在创建 (->M180_02) , 则继续从 earlySingletonObjects 中获取
        - 如果还是没有 , 且需要创建早期引用 , 则继续从 this.singletonFactories 中获取
        -如果 singletonFactories 获取到了  , 将当前 bean 放入 singletonObjects 且从 singletonFactories 移除
    M180_02- isSingletonCurrentlyInCreation
        ?- 判断当前 Bean 是否已经在注册
        - singletonsCurrentlyInCreation.contains(beanName)
    
    
// M180_01 代码 : 分别从三个 ConcurrentHashMap 中获取对应的 Bean
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
        synchronized (this.singletonObjects) {
            singletonObject = this.earlySingletonObjects.get(beanName);
            if (singletonObject == null && allowEarlyReference) {
                ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                if (singletonFactory != null) {
                    singletonObject = singletonFactory.getObject();
                    this.earlySingletonObjects.put(beanName, singletonObject);
                    this.singletonFactories.remove(beanName);
                }
            }
        }
    }
    return singletonObject;
}
```

- 整体流程来看，最主要的就是从三个 CurrentHashMap 本地缓存中获取 Bean 实例
- 当第一个Bean 创建时 , 就已经在缓存中存在了 , 哪怕他还没有完全加载完成

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc1.jpg)

```java
// 着重下上面几个对象
 
singletonsCurrentlyInCreation : 当前正在创建的 Bean 名称集合
singletonObjects : 单例对象的缓存
earlySingletonObjects : 早期单例对象的缓存
singletonFactories : 单例工厂的缓存

```

### singletonsCurrentlyInCreation

#### singletonsCurrentlyInCreation 插入的地方

```java
C180- DefaultSingletonBeanRegistry      
    M180_03- beforeSingletonCreation
    	?- this.singletonsCurrentlyInCreation.add(beanName) : 添加当前 BeanName
    M180_04- afterSingletonCreation
    	?- this.singletonsCurrentlyInCreation.remove(beanName) : 移除当前 BeanName
    
// 这里大概就清楚了 插入的方式
// PS : 以下方法中都会调用 beforeSingletonCreation 方法  , 三个方法处理完成后 , 就会移除
C- AbstractAutowireCapableBeanFactory
    M- getSingletonFactoryBeanForTypeCheck 
C- DefaultSingletonBeanRegistry
    M- getSingleton :  单例Bean 创建的位置
C- FactoryBeanRegistrySupport
    M- getObjectFromFactoryBean   
```

### singletonObjects 的存储

#### singletonObjects 存入的位置

```java
M180_05- addSingleton
    - this.singletonObjects.put(beanName, singletonObject)
        ?- 也就是说每添加一个 单例 ,都会往其中添加一个对象
    M- getSingletonMutex : 这是唯一一个有可能放入数据的地方了
        - return this.singletonObjects;

// 打断点跟踪后发现以下类中进行了调用: 
C- FactoryBeanRegistrySupport
    M- getObjectFromFactoryBean : 只是作为一个锁对象
C- AbstractApplicationEventMulticaster
    M- setBeanFactory 
        - this.retrievalMutex = this.beanFactory.getSingletonMutex() : 将对象进行了引用
        ?- 其中也大部分作为锁对象 , 没有进行操作
```

- 使用该对象作为 synchronized 的监视对象可以有效保证唯一性
- 这里的唯一应该是业务流程上的唯一 ,例如我这里要删除 , 你那里就不能进行添加 , 等我做完了 , 你才能继续

#### singletonObjects 删除的地方

```java

C180- DefaultSingletonBeanRegistry  
    M180_07- clearSingletonCache
        - 这里不止一个集合 , 是把所有的集合都清空了
        ?- 看了一下 , 主要是再 destroySingletons 流程中调用
    M180_08- removeSingleton
        - 移除单个单例时 ,此时时 remove
```

- 销毁单例时 , 该数据会被清空或者移除

```java
// M180_07 代码
protected void clearSingletonCache() {
    synchronized (this.singletonObjects) {
        this.singletonObjects.clear();
        this.singletonFactories.clear();
        this.earlySingletonObjects.clear();
        this.registeredSingletons.clear();
        this.singletonsCurrentlyInDestruction = false;
    }
}
```

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc2.jpg)

### earlySingletonObjects

#### earlySingletonObjects 保存的地方

```java
C180- DefaultSingletonBeanRegistry  
    M180_01- getSingleton(String beanName, boolean allowEarlyReference)
    	?- 还是之前获取的位置 , 可以看到 , 这里有一个参数是 allowEarlyReference
    	- this.earlySingletonObjects.put(beanName, singletonObject)
```

- 这个的位置为 初始类 BeanA 加载时 , 此时未注入依赖 , 只是第一次构建

- earlySingletonObjects 是一个中间缓存 , 在Single Bean 添加完成后 , 这个中间缓存就会被清除

#### earlySingletonObjects 清除的地方

```java
C180- DefaultSingletonBeanRegistry     
    M180_09- addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) : 清除单个
    M180_07- clearSingletonCache : 清空所有
    M180_05- addSingleton : 清除单个
```

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc3.jpg)

### singletonFactories

```java
// 还是先看下
C180- DefaultSingletonBeanRegistry      
    M180_07- addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory)
    	IF- 如果 singletonObjects (F01)包含 当前 BeanName
            TRUE- singletonFactories (F02) 添加当前 Bean 和 singletonFactory
                ?- this.singletonFactories.put(beanName, singletonFactory);

// PS : 单例工厂是哪个环节被调用的
首先 , getSingle 中 , 实际上接的是一个 lambda 表达式
C180- DefaultSingletonBeanRegistry      
    M180_01- getSingleton(String beanName, boolean allowEarlyReference)    
        - ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
        - singletonObject = singletonFactory.getObject();

// 该对象是在 AbstractAutowireCapableBeanFactory # doCreateBean 中生成的
addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));

// 其中传入了一个 getEarlyBeanReference 方法 , 该方法会在 getObject 回调
() -> getEarlyBeanReference(beanName, mbd, bean) --- singletonFactory.getObject() 
// 最终会通过 SmartInstantiationAwareBeanPostProcessor 来处理生成
SmartInstantiationAwareBeanPostProcessor ibp = (SmartInstantiationAwareBeanPostProcessor) bp;
exposedObject = ibp.getEarlyBeanReference(exposedObject, beanName);    

// 最终会生成一个空的对象 , 放进去
```

- 该对象会在后续中被 getSingleton 获取继续处理

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc7.jpg)

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc5.awebp)

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc6.awebp)

## 为什么 prototype 不可行

### prototype 的加载过程

- prototype 的创建是在 AbstractBeanFactory 中完成

```java
C171- AbstractBeanFactory 
    M171_02- doGetBean( String name, Class<T> requiredType,Object[] args, boolean typeCheckOnly)
        - 如果是 Singleton , 则 getSingleton
            ?- 走了缓存集合
        - 如果是 Prototype , 则 createBean
            ?- 这里是没有缓存类来处理的
    
// M171_02 伪代码
if (mbd.isSingleton()) {
    //.....
} else if (mbd.isPrototype()) {
    Object prototypeInstance = null;
    try {
        beforePrototypeCreation(beanName);
        prototypeInstance = createBean(beanName, mbd, args);
    }finally {
        afterPrototypeCreation(beanName);
    }
    bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
}
```
![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc8.jpg)

### SingletonBeanRegistry 体系

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/index/ioc9.awebp)



