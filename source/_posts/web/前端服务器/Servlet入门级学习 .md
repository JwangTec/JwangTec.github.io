---
title: Servlet入门级学习
categories: 前端知识集
tags:
  - servlet
  - 前端服务器
top: 11
abbrlink: 1391573724
date: 2019-05-11 18:18:19
password:
---


# Servlet入门 

## 使用IDEA创建web工程配置tomcat

<!--more-->

### 配置tomcat

我们要将idea和tomcat集成到一起，可以通过idea就控制tomcat的启动和关闭：

 ![1555838575577](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555838575577.png)

 ![1555838600225](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555838600225.png)



![1555838669879](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555838669879.png) 



![1555838727262](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555838727262.png)



### 创建JavaWeb工程

#### web工程创建

![1555838784099](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/200.png)

![1555902807303](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555902807303.png)

![1555902832195](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555902832195.png)



![1555902959035](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555902959035.png)

####  发布

+ 情况一: 已经关联成功的情况(因为我创建项目的时候, 已经选择了tomcat)

![1555903047439](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555903047439.png) 

![1555903115979](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555903115979.png)

+ 情况二:  如果之前没有选择tomcat, 现在就需要自己关联发布

![1555903217846](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555903217846.png)

![1555903238067](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555903238067.png)


## Servlet概述

​	Servlet **运行在服务端(tomcat)**的Java小程序(对象)，是sun公司提供一套规范. 就是动态资源

### Servlet作用

​	用来接收、处理客户端请求、响应给浏览器的动态资源。

​	但servlet的实质就是java代码，通过java的API动态的向客户端输出内容

### servlet与普通的java程序的区别

1. 必须实现servlet接口
2. 必须在servlet容器（服务器 tomcat）中运行
3. servlet程序可以接收用户请求参数以及向浏览器输出数据

##  Servlet入门案例

### 配置文件方式实现

1. 创建web工程
2. 创建一个类实现Servlet接口
3. 在web.xml配置servlet的映射路径



### 注解方式实现  

1. 创建web工程
2. 创建一个类实现Servlet接口
3. 在这个类上面添加@WebServlet("访问的路径")

## 实现  

### 配置文件方式实现  

+ 在com.itheima.web包下创建一个类实现Servlet接口

```java
package com.itheima.web;


import javax.servlet.*;
import java.io.IOException;
public class ServletDemo01 implements Servlet {

    @Override
    //服务方法: 处理请求的
    public void service(ServletRequest request, ServletResponse response) throws ServletException, IOException {
        System.out.println("hello world...");
    }


    @Override
    public void init(ServletConfig servletConfig) throws ServletException {

    }

    @Override
    public ServletConfig getServletConfig() {
        return null;
    }



    @Override
    public String getServletInfo() {
        return null;
    }

    @Override
    public void destroy() {

    }
}

```



+ web.xml配置（该文件在web/WEB-INF 文件夹下）：

```java
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
		  http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
           version="2.5">

    <!--配置Servlet-->
    <servlet>
        <!--servlet-name: 名字 随便取; 一般就是类名-->
        <servlet-name>ServletDemo01</servlet-name>
        <!--servlet-class:Servlet这个类的全限定名-->
        <servlet-class>com.itheima.web.ServletDemo01</servlet-class>
    </servlet>
    <servlet-mapping>
        <!--servlet-name: 必须和servlet标签里面的servlet-name一样-->
        <servlet-name>ServletDemo01</servlet-name>
        <!--url-pattern: 配置访问的路径-->
        <url-pattern>/demo01</url-pattern>
    </servlet-mapping>

</web-app>

```



### 注解方式实现

+ 在com.itheima.web包下创建一个类实现Servlet接口, 添加注解

```java
package com.itheima.web;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
@WebServlet("/demo02")
public class ServletDemo02 implements Servlet{

    @Override
    public void service(ServletRequest servletRequest, ServletResponse servletResponse) throws ServletException, IOException {
        System.out.println("hello world...");
    }


    @Override
    public void init(ServletConfig servletConfig) throws ServletException {

    }

    @Override
    public ServletConfig getServletConfig() {
        return null;
    }



    @Override
    public String getServletInfo() {
        return null;
    }

    @Override
    public void destroy() {

    }
}

```

浏览器地址栏输入：http://localhost:8080/day27_servlet/demo02



### 如果出现实现Servlet报错

+ 检查当前的工程是否依赖了Tomcat

![1555904633352](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555904633352.png)

+ 如果没有依赖, 依赖tomcat

![1555905478996](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555905478996.png)

![1555905493524](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555905493524.png) 

### 配置文件方式与注解方式比较

​	注解方式简化的javaweb代码开发，可以省略web.xml配置文件. 

​	但是配置文件方式必须掌握的(后面在框架或者大项目里面会使用到的)  


##  入门案例原理和路径


### Servlet执行原理



![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_31.png)



通过上述流程图我们重点需要掌握如下几个点：

- Servlet对象是由服务器创建(反射)
- request与response对象也是由tomcat服务器创建
- service()方法也是服务器调用的


### Servlet路径的配置url-pattern  

url-pattern配置方式共有三种: 

- 完全路径匹配: **以 / 开始**.      注: 访问的路径不能多一个字母也不能少一个

```
例如: 配置了/demo01  请求的时候必须是: /demo01  
```

- 目录匹配"**以 / 开始需要以 * 结束**.    注: Servlet里面用的 不多, 但是过滤器里面通常就使用目录匹配 

```
例如:  配置/* 访问/a, /aa, /aaa; 配置 /aa/*  访问 /aa/b , /aa/cc
```

- 扩展名匹配**不能以 / 开始, 以 * 开始的 .**

```
例如:  *.action;  访问: aa.action, bb.action, c.action;   错误写法: /*.do, 不可以写*.jsp,*.html
```

注意的地方:

- 一个路径只能对应一个servlet, 但是一个servlet可以有多个路径 


- tomcat获得匹配路径时，优先级顺序：完全路径匹配> 目录匹配 > 扩展名匹配 


# Servlet进阶

##  Servlet的生命周期

### 生命周期概述

​	一个对象从创建到销毁的过程

### Servlet生命周期方法

​	servlet从创建到销毁的过程

​	出生：（初始化）用户第一次访问时执行。

​	活着：（服务）应用活着。每次访问都会执行。

​	死亡：（销毁）应用卸载。

​	serrvlet生命周期方法:

​		init(ServletConfig config)

​		service(ServletRequest req, ServletResponse res)

​		destroy()

### Servlet生命周期描述  

1. 常规【重点】

   ​	默认情况下, 来了第一次请求, 会调用init()方法进行初始化【调用一次】

   ​	任何一次请求 都会调用service()方法处理这个请求

   ​	服务器正常关闭或者项目从服务器移除, 调用destory()方法进行销毁【调用一次】

2. 扩展

   ​	servlet是单例多线程的, 尽量不要在servlet里面使用值可变的全局(成员)变量,可能会导致线程不安全

   ​	单例: 只有一个对象(init()调用一次, 创建一次)

   ​	多线程: 服务器会针对每次请求, 开启一个线程调用service()方法处理这个请求




### ServletConfig 

​	Servlet的配置对象, 可以使用用ServletConfig来获得Servlet的初始化参数,**在SpringMVC里面会遇到**

+ 先在配置文件里面配置初始化参数

![1537837644263](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1537837644263.png)

+ 可以通过akey获得aaa

![1537837616004](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1537837616004.png)

### 启动项

​	Servlet默认情况下什么是创建? 默认情况下是第一次请求的时候.   

​	如果我想让Servlet提前创建(服务器启动的时候), 这个时候就可以使用启动项  **在SpringMVC里面会遇到**

![1555981767256](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555981767256.png)   ​	




## Servlet体系结构 


![https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_30-1571447571193.png)



- Servlet接口

  ​	前面我们已经学会创建一个类实现sevlet接口的方式开发Servlet程序，实现Servlet接口的时候，我们必须实现接口的所有方法。但是，在servlet中，真正执行程序逻辑的是service，对于servlet的初始化和销毁，由服务器调用执行，开发者本身不需要关心。因此，有没有一种更加简洁的方式来开发servlet程序呢？

我们先来查阅API回顾Servlet接口：
![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_32-1571447571193.png)

​	由上图可知在servlet接口规范下，官方推荐使用继承的方式，继承GenericServlet 或者HttpServlet来实现接口，那么我们接下来再去查看一下这两个类的API：

- GenericServlet 类

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_33-1571447571193.png)

​	阅读上图API可知，GenericServlet 是一个类，它简化了servlet的开发，已经提供好了一些servlet接口所需的方法，我们开发者只需要重写service方法即可

我们来使用GenericServlet 创建servlet：

1. 创建一个类
2. 继承GenericServlet
3. 重写service方法

```java
package cn.itcast.web;

import javax.servlet.GenericServlet;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet(name = "GenericDemoServlet",urlPatterns = "/generic")
public class GenericDemoServlet extends GenericServlet {
    @Override
    public void service(ServletRequest servletRequest, ServletResponse servletResponse) throws ServletException, IOException {
        System.out.println("GenericDemoServlet执行.......");
    }
}
```

​	虽然，GenericServlet已经简化了servlet开发，但是我们平时开发程序需要按照一种互联网传输数据的协议来开发程序——http协议，因此，sun公司又专门提供了HttpServlet，来适配这种协议下的开发。

- HttpServlet

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_34-1571447571193.png)

阅读上图的API可知，继承HttpServlet，我们需要重写doGet、doPost等方法中一个即可，根据Http不同的请求，我们需要实现相应的方法。

我们来使用HttpServlet创建servlet：	

1. 创建一个类
2. 继承HttpServlet
3. 重写doGet方法和doPost方法

```java
/**
 * 包名:com.itheima.servlet
 *
 * @author Leevi
 * 日期2020-07-11  15:39
 * Servlet的常用的编写方法:
 * 1. 写一个类继承HttpServlet，重写doGet和doPost方法
 *    1.1 doGet()方法，是处理来自客户端的get请求
 *    1.2 doPost()方法，是处理来自客户端的post请求
 *
 *    通常情况下:服务器端针对同一个请求(不同的请求方式)不会做不同的处理,所以我们会选择在doGet中调用doPost
 * 2. 配置servlet的映射路径
 */
@WebServlet("/demo02")
public class ServletDemo02 extends HttpServlet{
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req,resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("编写很多代码处理这次post请求");
    }
}
```

​	通过以上两个API阅读，同学们注意一个细节HttpServlet是GenericServlet的子类，它增强了GenericServlet一些功能，因此，在后期使用的时候，我们都是选择继承HttpServlet来开发servlet程序。




### 扩展(Servlet体系源码)

1. 看HttpServlet的service()方法

![image-20191208151858364](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/image-20191208151858364.png) 



# 第六章-ServletContext

## 知识点-ServletContext概述

### 1.目标

+ 知道什么是ServletContext, 以及作用

### 2.讲解

#### 2.1 servletContext概述

​	ServletContext: 是一个全局对象, 上下文对象. 

​	服务器为每一个应用(项目)都创建了一个ServletContext对象。 ServletContext属于整个应用(项目)的，不局限于某个Servlet。并且整个项目有且只会有一个ServletContext对象

#### 2.2 ServletContext作用

​	作为域对象存取数据,让Servlet共享(掌握)

​	获得文件MIME类型（文件下载）(了解)  

​	获得全局初始化参数(了解)

​	获取web资源路径  ，可以将Web资源转换成字节输入流(掌握)

### 3.小结



## 知识点-ServletContext的功能

### 1.目标

+ 掌握ServletContext的作用

### 2.路径

+ 作为域对象存取数据
+ 获得文件mini类型（文件下载）
+ 获得全局初始化参数
+ 获取web资源路径

### 3.讲解

#### 3.1作为域对象存取值【重点】



![image-20191208154333086](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/image-20191208154333086.png)  

1. API

   + getAttribute(String name) ;向ServletContext对象的map取数据
   + setAttribute(String name, Object object) ;从ServletContext对象的map中添加数据
   + removeAttribute(String name) ;根据name去移除数据

2. 代码

   + ServletDemo01
```java
   package com.itheima.servlet;
   
   import javax.servlet.ServletContext;
   import javax.servlet.ServletException;
   import javax.servlet.annotation.WebServlet;
   import javax.servlet.http.HttpServlet;
   import javax.servlet.http.HttpServletRequest;
   import javax.servlet.http.HttpServletResponse;
   import java.io.IOException;
   
   /**
   - 包名:${PACKAGE_NAME}
   *
   - @author Leevi
     - 日期2020-07-11  16:11
     - 目标: 在ServletDemo02中获取servletDemo01中的一个变量的值
     - 1. 获取ServletContext对象:
     - getServletContext()
   */
   @WebServlet("/demo01")
   public class ServletDemo01 extends HttpServlet {
       @Override
       protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
           doGet(request, response);
       }
       @Override
      protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
           String name = "周杰棍";
           //1. 获取ServletContext对象
           ServletContext servletContext = getServletContext();
           //2. 往容器ServletContext中存值
           servletContext.setAttribute("name",name);
       }
   }
```

   + ServletDemo02

   ```java
   package com.itheima.servlet;
   
   import javax.servlet.ServletContext;
   import javax.servlet.ServletException;
   import javax.servlet.annotation.WebServlet;
   import javax.servlet.http.HttpServlet;
   import javax.servlet.http.HttpServletRequest;
   import javax.servlet.http.HttpServletResponse;
   import java.io.IOException;
   /**
   
   - 包名:${PACKAGE_NAME}
   *
   - @author Leevi
   - 日期2020-07-11  16:11
   */
   @WebServlet("/demo02")
   public class ServletDemo02 extends HttpServlet {
       @Override
       protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
           doGet(request, response);
       }
       @Override
       protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
           //1. 获取那个容器ServletContext
           ServletContext servletContext = getServletContext();
           //2. 从容器ServletContext中获取数据
           String name = (String) servletContext.getAttribute("name");
   
           System.out.println("在ServletDemo02中获取的name是:" + name);
       }
   }  
   ```

#### 3.2 获得文件mime-type(了解) 

1. getMimeType(String file) 
2. 代码

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//根据文件名获得文件的mini类型
//1.获得ServletContext
//2.调用getMimeType()方法
String file01 = "a.mp3";
String file02 = "b.png";
String mimeType01 = getServletContext().getMimeType(file01);
String mimeType02 = getServletContext().getMimeType(file02);

response.getWriter().print("ServletDemo05..."+mimeType01+":"+mimeType02);

}
```



#### 3.3.获得全局初始化参数(了解)

- String getInitParameter(String name) ; //根据配置文件中的key得到value; 

在web.xml配置

![1537841534534](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1537841534534.png)

通过ServletContext来获得

 ![1537841552654](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1537841552654.png)

#### 3.4 获取web资源路径

1. API
   + String  getRealPath(String path);根据资源名称得到资源的绝对路径.
   + getResourceAsStream(String path) ;返回制定路径文件的流

>  注意: filepath:直接从项目的根目录开始写

2. 代码

```java
/**
 * 包名:${PACKAGE_NAME}
 * @author Leevi
 * 日期2020-07-11  16:41
 * 使用ServletContext获取web里面的资源文件的真实路径
 * 目标: 使用字节输入流，读取mm.jpg这张图片
 *     方法1: FileInputStream
 *     方法2: ClassLoader
 *     方法3: 使用ServletContext
 *
 * 在web项目中，将文件转换成流，有两种方式
 * 1. 如果文件在resources里面，使用类加载器
 * 2. 如果文件在web里面，使用ServletContext
 */
@WebServlet("/demo04")
public class ServletDemo04 extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //方法1: 使用FileInputStream,此时使用磁盘路径
        //InputStream is = new FileInputStream("C:/JavaEE_Relation/JavaEE98/itheima98_web/day24_servletcontext_03/web/mm.jpg");
        //方法2: 使用ClassLoader将文件转换成流
        //InputStream is = ServletDemo04.class.getClassLoader().getResourceAsStream("../../mm.jpg");

        //方法3: 使用ServletContext可以获取web里面的资源的真实路径
        ServletContext servletContext = getServletContext();
        //String realPath = servletContext.getRealPath("mm.jpg");

        InputStream is = servletContext.getResourceAsStream("mm.jpg");
        System.out.println(is);
    }
}
```



### 4.小结

1. 作为域对象存取数据【共享】
  
   + setAttribute(String name,Object value)  存
   + getAttribute(String name)  取
   + removeAttribute(String name) 移除
   
2. 获得文件的Mime类型

   + getMineType(String fileName);

   

3. 获得全局初始化参数

   + 在web.xml配置
   + getInitParameter(String name);

   

4. 获得web资源路径【已经在web目录了】

   + getRealPath(String file);   获得文件的绝对路径
   + getReSourceAsStream(String file);   获得文件流

   

   





## 案例-统计网站被访问的总次数

### 1.需求

![https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_3.gif)

- 在页面中显示您是第x位访问的用户.

### 2.思路分析

![image-20191208160926430](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/count.jpg) 

### 3.代码实现 

+ CountServlet

```java
package com.itheima.servlet;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 包名:${PACKAGE_NAME}
 *
 * @author Leevi
 * 日期2020-07-11  17:04
 * 每次接收到请求，则往容器中的计数器上面+1
 */
@WebServlet("/count")
public class CountServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //1. 获取容器中计数器原本的次数
        ServletContext servletContext = getServletContext();
        Object count = servletContext.getAttribute("count");

        //判断ServletContext中是否有计数器
        if (count == null) {
            //说明当前是第一次访问
            //就往ServletContext中添加一个计数器
            servletContext.setAttribute("count",1);
        }else {
            //说明我不是第一次访问，那么就要对原来的计数器+1，再存进去
            int number = ((int) count) + 1;
            servletContext.setAttribute("count",number);
        }
        //2. 向客户端响应WelCome
        response.getWriter().write("WelCome!!!");
    }
}
```

+ ShowServlet

```java
package com.itheima.servlet;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 包名:${PACKAGE_NAME}
 *
 * @author Leevi
 * 日期2020-07-11  17:04
 */
@WebServlet("/show")
public class ShowServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //从容器中获取计数器的值
        ServletContext servletContext = getServletContext();

        int count = (int) servletContext.getAttribute("count");

        //将count响应给客户端
        response.getWriter().print("access count is:"+count);
    }
}
```

### 4.小结