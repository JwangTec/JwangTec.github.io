---
title: 设计模式--python实现
tags:
  - python
top: 10
abbrlink: 2590054529
date: 2019-05-01 18:18:19
categories: 设计模式
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)

### python与设计模式

<!--more-->

#### 1.定义：

>设计模式是面对各种问题进行提炼和抽象而形成的解决方案。这些设计方案是前人不断试验，考虑了封装性、复用性、效率、可修改、可移植等各种因素的高度总结。它不限于一种特定的语言，它是一种解决问题的思想和方法。

#### 2.分类

设计模式可以分为三个大类：创建类设计模式、结构类设计模式、行为类设计模式。

创建类设计模式可以分为
>单例模式、工厂模式、抽象工厂模式、原型模式、建造者模式；

结构类设计模式可以分为
>装饰器模式、适配器模式、门面模式、组合模式、享元模式、桥梁模式；

行为类设计模式可以细分为
>策略模式、责任链模式、命令模式、中介者模式、模板模式、迭代器模式、访问者模式、观察者模式、解释器模式、备忘录模式、状态模式。

#### 3.设计模式与软件框架

设计模式和软件框架在软件设计中是两个不同的研究领域：

>A、设计模式如前边的定义所讲，它指的是针对一类问题的解决方法，一个设计模式可应用于不同的框架和被不同的语言所实现；而框架则是一个应用的体系结构，是一种或多种设计模式和代码的混合体；

>B、设计模式相较于框架更容易移植，并且可以用各种语言实现，而软件框架则受限于领域大环境。虽然设计模式和软件框架有很多不同，但在某些方面他们二者是统一的，即重视软件复用，提高开发效率。

#### 4.软件架构和设计模式

软件架构可以由不同的框架和不同的设计模式，再加上特定的构件组合来实现；

框架可以根据设计模式结合特定编程语言和环境来实现。

设计模式就是解决单一问题的设计思路和解决方法。


### python与设计模式--单例模式


#### 1.单例模式


>单例模式是所有设计模式中比较简单的一类，其定义如下：Ensure a class has only one instance, and provide a global point of access to it.（保证某一个类只有一个实例，而且在全局只有一个访问点）


#### 2.实例

1. 模块：

>Python 的模块就是天然的单例模式，因为模块在第一次导入时，会生成 .pyc 文件，当第二次导入时，就会直接加载 .pyc 
文件，而不会再次执行模块代码。因此，我们只需把相关的函数和数据定义在一个模块中，就可以获得一个单例对象了

```#mysingleton.py
class Singleton(object):
    def foo(self):
        pass
singleton = Singleton()

from a import singleton
```

2. 装饰器

```
def Singleton(cls):
    _instance = {}
    def _singleton(*args, **kargs):
        if cls not in _instance:
            _instance[cls] = cls(*args, **kargs)
        return _instance[cls]
    return _singleton

@Singleton
class A(object):
    a = 1
    def __init__(self, x=0):
        self.x = x

a1 = A(2)
a2 = A(3)

```

3. 类(多线程)

```
import time
import threading
class Singleton(object):
    _instance_lock = threading.Lock()

    def __init__(self):
        time.sleep(1)

    @classmethod
    def instance(cls, *args, **kwargs):
        if not hasattr(Singleton, "_instance"):
            with Singleton._instance_lock:
                if not hasattr(Singleton, "_instance"):
                    Singleton._instance = Singleton(*args, **kwargs)
        return Singleton._instance


def task(arg):
    obj = Singleton.instance()
    print(obj)
for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start()
time.sleep(20)
obj = Singleton.instance()
print(obj)

```

4. 基于__new__方法

>实例化一个对象时，是先执行了类的__new__方法，实例化对象；然后再执行类的__init__方法，对这个对象进行初始化，所有我们可以基于这个，实现单例模式

```
import threading
class Singleton(object):
    _instance_lock = threading.Lock()

    def __init__(self):
        pass


    def __new__(cls, *args, **kwargs):
        if not hasattr(Singleton, "_instance"):
            with Singleton._instance_lock:
                if not hasattr(Singleton, "_instance"):
                    Singleton._instance = object.__new__(cls)  
        return Singleton._instance

obj1 = Singleton()
obj2 = Singleton()
print(obj1,obj2)

def task(arg):
    obj = Singleton()
    print(obj)

for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start()

```

5. 元类metaclass


>1.类由type创建，创建类时，type的__init__方法自动执行，类() 
  执行type的 __call__方法(类的__new__方法,类的__init__方法)
  
>2.对象由类创建，创建对象时，类的__init__方法自动执行，对象()执行类的 __call__ 方法

```
import threading

class SingletonType(type):
    _instance_lock = threading.Lock()
    def __call__(cls, *args, **kwargs):
        if not hasattr(cls, "_instance"):
            with SingletonType._instance_lock:
                if not hasattr(cls, "_instance"):
                    cls._instance = super(SingletonType,cls).__call__(*args, **kwargs)
        return cls._instance

class Foo(metaclass=SingletonType):
    def __init__(self,name):
        self.name = name


obj1 = Foo('name')
obj2 = Foo('name')
print(obj1,obj2)

```

#### 3.单例模式的优点：
	
1、由于单例模式要求在全局内只有一个实例，因而可以节省比较多的内存空间；

2、全局只有一个接入点，可以更好地进行数据同步控制，避免多重占用；

3、单例可长驻内存，减少系统开销。

单例模式的应用举例：
	
	1、生成全局惟一的序列号；
	2、访问全局复用的惟一资源，如磁盘、总线等；
	3、单个对象占用的资源过多，如数据库等；
	4、系统全局统一管理，如Windows下的Task Manager；
	5、网站计数器。


### python设计模式--工厂模式

>通过一个指定的“工厂”获得需要的“产品”，在设计模式中主要用于抽象对象的创建过程，让用户可以指定自己想要的对象而不必关心对象的实例化过程。这样做的好处是用户只需通过固定的接口而不是直接去调用类的实例化方法来获得一个对象的实例，隐藏了实例创建过程的复杂度，解耦了生产实例和使用实例的代码，降低了维护的复杂性。

#### 1.简单工厂

```
#coding=utf-8
class Mercedes(object):
    """梅赛德斯
    """
    def __repr__(self):
        return "Mercedes-Benz"

class BMW(object):
    """宝马
    """
    def __repr__(self):
        return "BMW"
        
假设我们有两个“产品”分别是Mercedes和BMW的汽车，如果没有“工厂”来生产它们，
我们就要在代码中自己进行实例化，如：

mercedes = Mercedes()
bmw = BMW()
但现实中，你可能会面对很多汽车产品，而且每个产品的构造参数还不一样，这样在创
建实例时会遇到麻烦。这时就可以构造一个“简单工厂”把所有汽车实例化的过程封装在里面。

class SimpleCarFactory(object):
    """简单工厂
    """
    @staticmethod
    def product_car(name):
        if name == 'mb':
            return Mercedes()
        elif name == 'bmw':
            return BMW()
SimpleCarFactory类后，就可以通过向固定的接口传入参数获得想要的对象实例

c1 = SimpleCarFactory.product_car('mb')
c2 = SimpleCarFactory.product_car('bmw')
```

#### 2.工厂方法

>如果我们要新增一个“产品”，例如Audi的汽车，我们除了新增一个Audi类外还要修改SimpleCarFactory内的product_car方法。这样就违背了软件设计中的开闭原则[1]，即在扩展新的类时，尽量不要修改原有代码。所以我们在简单工厂的基础上把SimpleCarFactory抽象成不同的工厂，每个工厂对应生成自己的产品，这就是工厂方法。

```
#coding=utf-8
import abc

class AbstractFactory(object):
    """抽象工厂
    """
    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def product_car(self):
        pass

class MercedesFactory(AbstractFactory):
    """梅赛德斯工厂
    """
    def product_car(self):
        return Mercedes()

class BMWFactory(AbstractFactory):
    """宝马工厂
    """
    def product_car(self):
        return BMW()
我们把工厂抽象出来用abc模块[2]实现了一个抽象的基类AbstractFactory，
这样就可以通过特定的工厂来获得特定的产品实例了：

c1 = MercedesFactory().product_car()
c2 = BMWFactory().product_car()

每个工厂负责生产自己的产品也避免了我们在新增产品时需要修改工厂的代码，
而只要增加相应的工厂即可。如新增一个Audi产品，只需新增一个Audi类和AudiFactory类。
```

#### 3.抽象工厂


>如果我们要生产很多产品，就会发现我们同样需要写很多对应的工厂类。比如如果MercedesFactory和BMWFactory不仅生产小汽车，还要生产SUV，那我们用工厂方法就要再多构造两个生产SUV的工厂类。所以为了解决这个问题，我们就要再更进一步的抽象工厂类，让一个工厂可以生产同一类的多个产品，这就是抽象工厂

```#coding=utf-8
import abc

# 两种小汽车
class Mercedes_C63(object):
    """梅赛德斯 C63
    """
    def __repr__(self):
        return "Mercedes-Benz: C63"

class BMW_M3(object):
    """宝马 M3
    """
    def __repr__(self):
        return "BMW: M3"

#　两种SUV
class Mercedes_G63(object):
    """梅赛德斯 G63
    """
    def __repr__(self):
        return "Mercedes-Benz: G63"

class BMW_X5(object):
    """宝马 X5
    """
    def __repr__(self):
        return "BMW: X5"

class AbstractFactory(object):
    """抽象工厂
    可以生产小汽车外，还可以生产SUV
    """
    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def product_car(self):
        pass

    @abc.abstractmethod
    def product_suv(self):
        pass

class MercedesFactory(AbstractFactory):
    """梅赛德斯工厂
    """
    def product_car(self):
        return Mercedes_C63()

    def product_suv(self):
        return Mercedes_G63()

class BMWFactory(AbstractFactory):
    """宝马工厂
    """
    def product_car(self):
        return BMW_M3()

    def product_suv(self):
        return BMW_X5()

让基类AbstractFactory同时可以生产汽车和SUV，然后令MercedesFactory和BMWFactory
继承AbstractFactory并重写product_car和product_suv方法即可。

c1 = MercedesFactory().product_car()
s1 = MercedesFactory().product_suv()
print(c1, s1)
s2 = BMWFactory().product_suv()
c2 = BMWFactory().product_car()
print(c2, s2)
```


#### 4.抽象工厂模式与工厂方法模式区别


1. 抽象工厂中的一个工厂对象可以负责多个不同产品对象的创建 ，这样比工厂方法模式更为简单、有效率。


工厂模式、抽象工厂模式的优点：

>1、工厂模式巨有非常好的封装性，代码结构清晰；在抽象工厂模式中，其结构还可以随着需要进行更深或者更浅的抽象层级调整，非常灵活；

>2、屏蔽产品类，使产品的被使用业务场景和产品的功能细节可以分而开发进行，是比较典型的解耦框架。


2. 工厂模式、抽象工厂模式的使用场景：
	
	1、当系统实例要求比较灵活和可扩展时，可以考虑工厂模式或者抽象工厂模式实现。比如，
		
		在通信系统中，高层通信协议会很多样化，同时，上层协议依赖于下层协议，
		那么就可以对应建立对应层级的抽象工厂，根据不同的“产品需求”去生产定制的实例。


### python与设计模式--建造者模式


>建造者模式的定义如下：将一个复杂对象的构建与它的表示分离，使得同样的构建过程可以创建不同的表示。

>在建造者模式中，还可以加一个Director类，用以安排已有模块的构造步骤。对于在建造者中有比较严格的顺序要求时，该类会有比较大的用处。


#### 快餐例：

```
主餐
class Burger():
    name=""
    price=0.0
    def getPrice(self):
        return self.price
    def setPrice(self,price):
        self.price=price
    def getName(self):
        return self.name
class cheeseBurger(Burger):
    def __init__(self):
        self.name="cheese burger"
        self.price=10.0
class spicyChickenBurger(Burger):
    def __init__(self):
        self.name="spicy chicken burger"
        self.price=15.0
小食
class Snack():
    name = ""
    price = 0.0
    type = "SNACK"
    def getPrice(self):
        return self.price
    def setPrice(self, price):
        self.price = price
    def getName(self):
        return self.name


class chips(Snack):
    def __init__(self):
        self.name = "chips"
        self.price = 6.0


class chickenWings(Snack):
    def __init__(self):
        self.name = "chicken wings"
        self.price = 12.0
饮料
class Beverage():
    name = ""
    price = 0.0
    type = "BEVERAGE"
    def getPrice(self):
        return self.price
    def setPrice(self, price):
        self.price = price
    def getName(self):
        return self.name


class coke(Beverage):
    def __init__(self):
        self.name = "coke"
        self.price = 4.0


class milk(Beverage):
    def __init__(self):
        self.name = "milk"
        self.price = 5.0

一个订单类。假设，一个订单，包括一份主食，一份小食，一种饮料。（省去一些异常判断）

class order():
    burger=""
    snack=""
    beverage=""
    def __init__(self,orderBuilder):
        self.burger=orderBuilder.bBurger
        self.snack=orderBuilder.bSnack
        self.beverage=orderBuilder.bBeverage
    def show(self):
        print "Burger:%s"%self.burger.getName()
        print "Snack:%s"%self.snack.getName()
        print "Beverage:%s"%self.beverage.getName()

orderBuilder就是建造者模式中所谓的“建造者”了

class orderBuilder():
    bBurger=""
    bSnack=""
    bBeverage=""
    def addBurger(self,xBurger):
        self.bBurger=xBurger
    def addSnack(self,xSnack):
        self.bSnack=xSnack
    def addBeverage(self,xBeverage):
        self.bBeverage=xBeverage
    def build(self):
        return order(self)
        
订单生成

if  __name__=="__main__":
    order_builder=orderBuilder()
    order_builder.addBurger(spicyChickenBurger())
    order_builder.addSnack(chips())
    order_builder.addBeverage(milk())
    order_1=order_builder.build()
    order_1.show()
    
构造步骤

class orderDirector():
    order_builder=""
    def __init__(self,order_builder):
        self.order_builder=order_builder
    def createOrder(self,burger,snack,beverage):
        self.order_builder.addBurger(burger)
        self.order_builder.addSnack(snack)
        self.order_builder.addBeverage(beverage)
        return self.order_builder.build()

```

#### 3.优缺：
	
	1、封装性好，用户可以不知道对象的内部构造和细节，就可以直接建造对象；
	2、系统扩展容易；
	3、建造者模式易于使用，非常灵活。在构造性的场景中很容易实现“流水线”；
	4、便于控制细节。

使用场景：
	
>1、 目标对象由组件构成的场景中，很适合建造者模式。例如，在一款赛车游戏中，车辆生成时，需要根据级别、环境等，选择轮胎、悬挂、骨架等部件，构造一辆“赛车”；

>2、 在具体的场景中，对象内部接口需要根据不同的参数而调用顺序有所不同时，可以使用建造者模式。例如：一个植物养殖器系统，对于某些不同的植物，浇水、施加肥料的顺序要求可能会不同，因而可以在Director中维护一个类似于队列的结构，在实例化时作为参数代入到具体建造者中。


缺点：
	
	1、“加工工艺”对用户不透明。（封装的两面性）
	
	

### python设计模式--原型模式



#### 原型模式

原型模式定义如下：用原型实例指定创建对象的种类，并且通过复制这些原型创建新的对象。
需要注意一点的是，进行clone操作后，新对象的构造函数没有被二次执行，新对象的内容是从内存里直接拷贝的。

>用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。

![原型模式](http://ata2-img.cn-hangzhou.img-pub.aliyun-inc.com/56e6c262b1510b59beba7552f07522ae.png)

#### 实例

>从简历原型，生成新的简历
>
>简历类Resume提供的Clone()方法其实并不是真正的Clone，只是为已存在对象增加了一次引用。
>
>Python为对象提供的copy模块中的copy方法和deepcopy方法已经实现了原型模式，但由于例子的层次较浅，二者看不出区别。


```
import copy
class WorkExp:
    place=""
    year=0

class Resume:
    name = ''
    age = 0
    def __init__(self,n):
        self.name = n
    def SetAge(self,a):
        self.age = a
    def SetWorkExp(self,p,y):
        self.place = p
        self.year = y
    def Display(self):
        print self.age
        print self.place
        print self.year
    def Clone(self):
    #实际不是“克隆”，只是返回了自身
        return self

if __name__ == "__main__":
    a = Resume("a")
    b = a.Clone()
    c = copy.copy(a)
    d = copy.deepcopy(a)
    a.SetAge(7)
    b.SetAge(12)
    c.SetAge(15)
    d.SetAge(18)
    a.SetWorkExp("PrimarySchool",1996)
    b.SetWorkExp("MidSchool",2001)
    c.SetWorkExp("HighSchool",2004)
    d.SetWorkExp("University",2007)
    a.Display()
    b.Display()
    c.Display()
    d.Display()

```

#### 原型模式的优缺点和使用场景

1. 优点：
	
		1、性能极佳，直接拷贝比在内存里直接新建实例节省不少的资源；
		2、简化对象创建，同时避免了构造函数的约束，不受构造函数的限制直接复制对象，是优
		点，也有隐患，这一点还是需要多留意一些。

2. 使用场景：
	
		1、对象在修改过后，需要复制多份的场景。如本例和其它一些涉及到复制、粘贴的场景；
		2、需要优化资源的情况。如，需要在内存中创建非常多的实例，可以通过原型模式来减少
			资源消耗。此时，原型模式与工厂
			模式配合起来，不管在逻辑上还是结构上，都会达到不错的效果；
		3、某些重复性的复杂工作不需要多次进行。如对于一个设备的访问权限，多个对象不用各
			申请一遍权限，由一个设备申请后，通过原型模式将权限交给可信赖的对象，
			既可以提升效率，又可以节约资源。

3. 原型模式的缺点
		
		1、深拷贝和浅拷贝的使用需要事先考虑周到；
		2、某些编程语言中，拷贝会影响到静态变量和静态函数的使用。
		
		

### Python与设计模式--代理模式


代理模式是一种使用频率非常高的模式，在多个著名的开源软件和当前多个著名的互联网产品后台程序中都有所应用。下面我们用一个抽象化的简单例子，来说明代理模式。

>首先，构造一个网络服务器：

```
#该服务器接受如下格式数据，addr代表地址，content代表接收的信息内容
info_struct=dict()
info_struct["addr"]=10000
info_struct["content"]=""
class Server:
    content=""
    def recv(self,info):
        pass
    def send(self,info):
        pass
    def show(self):
        pass
class infoServer(Server):
    def recv(self,info):
        self.content=info
        return "recv OK!"
    def send(self,info):
        pass
    def show(self):
        print "SHOW:%s"%self.content
        
```

infoServer有接收和发送的功能，发送功能由于暂时用不到，保留。

另外新加一个接口show，用来展示服务器接收的内容。

接收的数据格式必须如info_struct所示，服务器仅接受info_struct的content字段。

那么，如何给这个服务器设置一个白名单，使得只有白名单里的地址可以访问服务器呢？

修改Server结构是个方法，但这显然不符合软件设计原则中的单一职责原则。

>在此基础之上，使用代理，是个不错的方法。代理配置如下：

```
class serverProxy:
    pass
class infoServerProxy(serverProxy):
    server=""
    def __init__(self,server):
        self.server=server
    def recv(self,info):
        return self.server.recv(info)
    def show(self):
        self.server.show()

class whiteInfoServerProxy(infoServerProxy):
    white_list=[]
    def recv(self,info):
        try:
            assert type(info)==dict
        except:
            return "info structure is not correct"
        addr=info.get("addr",0)
        if not addr in self.white_list:
            return "Your address is not in the white list."
        else:
            content=info.get("content","")
            return self.server.recv(content)
    def addWhite(self,addr):
        self.white_list.append(addr)
    def rmvWhite(self,addr):
        self.white_list.remove(addr)
    def clearWhite(self):
        self.white_list=[]

```

代理中有一个server字段，控制代理的服务器对象，infoServerProxy充当Server的直接接口代理，而whiteInfoServerProxy直接继承了infoServerProxy对象，同时加入了white_list和对白名单的操作。
>这样，在场景中通过对白名单代理的访问，就可以实现服务器的白名单访问了。

```
if  __name__=="__main__":
    info_struct = dict()
    info_struct["addr"] = 10010
    info_struct["content"] = "Hello World!"
    info_server = infoServer()
    info_server_proxy = whiteInfoServerProxy(info_server)
    print info_server_proxy.recv(info_struct)
    info_server_proxy.show()
    info_server_proxy.addWhite(10010)
    print info_server_proxy.recv(info_struct)
    info_server_proxy.show()
		
```

#### 代理模式

代理模式定义如下：为某对象提供一个代理，以控制对此对象的访问和控制。代理模式在使用过程中，应尽量对抽象主题类进行代理，而尽量不要对加过修饰和方法的子类代理。
	
	为其他对象提供一种代理以控制对这个对象的访问。
	
>如上例中，如果有一个xServer继承了Server，并新加了方法xMethod，xServer的代理应以Server为主题进行设计，而尽量不要以xServer为主题，以xServer为主题的代理可以从ServerProxy继承并添加对应的方法.
>

![代理模式](http://ata2-img.cn-hangzhou.img-pub.aliyun-inc.com/651b419d706989c57083ad35e71d1029.png)

>在JAVA中，讲到代理模式，不得不会提到动态代理。动态代理是实现AOP（面向切面编程）的重要实现手段。而在Python中，很少会提到动态代理，而AOP则会以另一种模式实现：装饰模式。有关AOP的相关内容，我们会在装饰模式这一节中进行说明。
>

#### 代理模式的优缺点和应用场景

1. 优点:
		
		1、职责清晰：非常符合单一职责原则，主题对象实现真实业务逻辑，而非本职责
			的事务，交由代理完成；
		2、扩展性强：面对主题对象可能会有的改变，代理模式在不改变对外接口的情况
			下，可以实现最大程度的扩展；
		3、保证主题对象的处理逻辑：代理可以通过检查参数的方式，保证主题对象的处
		理逻辑输入在理想范围内。

2. 应用场景：
		
		1、针对某特定对象进行功能和增强性扩展。如IP防火墙、远程访问代理等技术的应用；
		2、对主题对象进行保护。如大流量代理，安全代理等；
		3、减轻主题对象负载。如权限代理等。

3. 代理模式的缺点
		
		1、可能会降低整体业务的处理效率和速度。
		

#### 举例

同模式特点描述：

```
class Interface :
    def Request(self):
    return 0

class RealSubject(Interface): 
    def Request(self):
        print "Real request."

class Proxy(Interface):
    def Request(self):
        self.real = RealSubject()
        self.real.Request()

if __name__ == "__main__":
    p = Proxy()
    p.Request()

```


### python与设计模式--装饰器模式

#### 快餐点餐系统（3）

>又提到了那个快餐点餐系统，不过今天我们只以其中的一个类作为主角：饮料类。首先，回忆下饮料类：

```
class Beverage():
    name = ""
    price = 0.0
    type = "BEVERAGE"
    def getPrice(self):
        return self.price
    def setPrice(self, price):
        self.price = price
    def getName(self):
        return self.name


class coke(Beverage):
    def __init__(self):
        self.name = "coke"
        self.price = 4.0


class milk(Beverage):
    def __init__(self):
        self.name = "milk"
        self.price = 5.0
```
>除了基本配置，快餐店卖可乐时，可以选择加冰，如果加冰的话，要在原价上加0.3元；卖牛奶时，可以选择加糖，如果加糖的话，要原价上加0.5元。怎么解决这样的问题？可以选择装饰器模式来解决这一类的问题。首先，定义装饰器类：

```
class drinkDecorator():
    def getName(self):
        pass
    def getPrice(self):
        pass

class iceDecorator(drinkDecorator):
    def __init__(self,beverage):
        self.beverage=beverage
    def getName(self):
        return self.beverage.getName()+" +ice"
    def getPrice(self):
        return self.beverage.getPrice()+0.3
    
class sugarDecorator(drinkDecorator):
    def __init__(self,beverage):
        self.beverage=beverage
    def getName(self):
        return self.beverage.getName()+" +sugar"
    def getPrice(self):
        return self.beverage.getPrice()+0.5
```

>构建好装饰器后，在具体的业务场景中，就可以与饮料类进行关联。以可乐+冰为例，示例业务场景如下：

```
if  __name__=="__main__":
    coke_cola=coke()
    print "Name:%s"%coke_cola.getName()
    print "Price:%s"%coke_cola.getPrice()
    ice_coke=iceDecorator(coke_cola)
    print "Name:%s" % ice_coke.getName()
    print "Price:%s" % ice_coke.getPrice()
    
打印结果如下：
Name:coke
Price:4.0
Name:coke +ice
Price:4.3
```

#### 装饰器模式


装饰器模式定义如下：动态地给一个对象添加一些额外的职责。在增加功能方面，装饰器模式比生成子类更为灵活。

![装饰器模式](http://ata2-img.cn-hangzhou.img-pub.aliyun-inc.com/6c8cc57b36c5772c0bc489221c648819.png)


装饰器模式和上一节说到的代理模式非常相似，可以认为，装饰器模式就是代理模式的一个特殊应用，两者的共同点是都具有相同的接口，不同点是侧重对主题类的过程的控制，而装饰模式则侧重对类功能的加强或减弱。

>动态地为对象增加额外的职责


上一次说到，JAVA中的动态代理模式，是实现AOP的重要手段。而在Python中，AOP通过装饰器模式实现更为简洁和方便。

先来解释一下什么是AOP。AOP即Aspect Oriented Programming，中文翻译为面向切面的编程，它的含义可以解释为：如果几个或更多个逻辑过程中（这类逻辑过程可能位于不同的对象，不同的接口当中），有重复的操作行为，就可以将这些行为提取出来（即形成切面），进行统一管理和维护。举例子说，系统中需要在各个地方打印日志，就可以将打印日志这一操作提取出来，作为切面进行统一维护。


从编程思想的关系来看，可以认为AOP和OOP（面向对象的编程）是并列关系，二者是可以替换的，也可以结合起来用。

>实际上，在Python语言中，是天然支持装饰器的，如下例：

```
def log(func):
    def wrapper(*args, **kw):
        print 'call %s():' % func.__name__
        return func(*args, **kw)
    return wrapper

@log
def now():
    print '2016-12-04'
if  __name__=="__main__":
    now()
打印如下：
call now():
2016-12-04

```

>log接口就是装饰器的定义，而Python的@语法部分则直接支持装饰器的使用。
如果要在快餐点餐系统中打印日志，该如何进行AOP改造呢？可以借助类的静态方法或者类方法来实现：

```
class LogManager:
    @staticmethod
    def log(func):
        def wrapper(*args):
            print "Visit Func %s"%func.__name__
            return func(*args)
        return wrapper
在需要打印日志的地方直接@LogManager.log，即可打印出访问的日志信息。
如，在beverage类的函数前加上@LogManager.log，场景类保持不变，则打印结果如下：
Visit Func getName
Name:coke
Visit Func getPrice
Price:4.0
Visit Func getName
Name:coke +ice
Visit Func getPrice
Price:4.3
```
#### 装饰器模式的优点和应用场景

1. 优点：

		1、装饰器模式是继承方式的一个替代方案，可以轻量级的扩展被装饰对象的功能；
		2、Python的装饰器模式是实现AOP的一种方式，便于相同操作位于不同调用位置
			的统一管理。
2. 应用场景：

		1、需要扩展、增强或者减弱一个类的功能，如本例。

3. 装饰器模式的缺点
 		
 		1、多层装饰器的调试和维护有比较大的困难。
 		
 
#### 举例：展示一个人一件一件穿衣服的过程。

```
class Person:
    def __init__(self,tname):
        self.name = tname
    def Show(self):
       print "dressed %s" %(self.name)

class Finery(Person):
    componet = None
    def __init__(self):
        pass
    def Decorate(self,ct):
        self.componet = ct
    def Show(self):
    if(self.componet!=None):
        self.componet.Show()

class TShirts(Finery):
    def __init__(self):
        pass
    def Show(self):
        print "Big T-shirt "
        self.componet.Show()

class BigTrouser(Finery):
    def __init__(self):
        pass
    def Show(self):
        print "Big Trouser "
        self.componet.Show()

if __name__ == "__main__":
    p = Person("somebody")
    bt = BigTrouser()
    ts = TShirts()
    bt.Decorate(p)
    ts.Decorate(bt)
    ts.Show()

```



