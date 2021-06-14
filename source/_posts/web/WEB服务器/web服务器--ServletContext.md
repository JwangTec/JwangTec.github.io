---
title: web服务器--ServletContext
categories: web
tags:
  - ServletContext
top: 7
abbrlink: 2195976482
date: 2019-05-11 18:18:19
password:
---


## ServletContext概述

### servletContext概述

​	ServletContext: 是一个全局对象, 上下文对象. 

​	服务器为每一个应用(项目)都创建了一个ServletContext对象。 ServletContext属于整个应用(项目)的，不局限于某个Servlet。并且整个项目有且只会有一个ServletContext对象


<!--more-->

###  ServletContext作用

​	作为域对象存取数据,让Servlet共享(掌握)

​	获得文件MIME类型（文件下载）(了解)  

​	获得全局初始化参数(了解)

​	获取web资源路径  ，可以将Web资源转换成字节输入流(掌握)

## ServletContext的功能



### 作为域对象存取值 



![image-20191208154333086](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/image-20191208154333086.png)  

1. API

   + getAttribute(String name) ;向ServletContext对象的map取数据
   + setAttribute(String name, Object object) ;从ServletContext对象的map中添加数据
   + removeAttribute(String name) ;根据name去移除数据

2. 代码

   + ServletDemo01
   
```java
   package com.jwang.servlet;
   
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
   package com.jwang.servlet;
   
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

### 获得文件mime-type 

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



### 获得全局初始化参数 

- String getInitParameter(String name) ; //根据配置文件中的key得到value; 

在web.xml配置

![1537841534534](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1537841534534.png)

通过ServletContext来获得

 ![1537841552654](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1537841552654.png)

### 获取web资源路径

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
        //InputStream is = new FileInputStream("C:/JavaEE_Relation/JavaEE98/jwang98_web/day24_servletcontext_03/web/mm.jpg");
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



##  统计网站被访问的总次数

###  需求

![https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_3.gif)

- 在页面中显示您是第x位访问的用户.

### 思路分析

![image-20191208160926430](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/count.jpg) 

###  代码实现 

+ CountServlet

```java
package com.jwang.servlet;

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
package com.jwang.servlet;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

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
