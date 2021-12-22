---
title: SpringMVC框架积累02-文件上传、拦截器及异常处理
categories: Java_SpringMVC
tags:
  - Java
  - Spring MVC
top: 16
abbrlink: 1962926894
date: 2019-07-01 18:18:19
password:
---



# 第一章 - SpringMVC 实现文件上传


## 文件上传概述以及使用场景

​	就是把客户端(浏览器)的文件保存一份到服务器 说白了就是文件的拷贝

​    常见的使用场景:上传头像、上传各种照片、上传word、Excel等等文件

<!--more-->

## 文件上传要求

### 浏览器端要求(通用浏览器的要求)

- 表单提交方式 post      
- 提供文件上传框(组件)  input type="file"
- 表单的entype属性必须为 `multipart/form-data`(没有这个属性值的话, 文件的内容是提交不过去的)

###  服务器端要求

1.  获取客户端上传的文件

 	2. 准备一个目录存储客户端上传的文件
 	3. 将客户端上传的文件写入到准备好的目录中

**注意:**

+ 若表单使用了 multipart/form-data ,使用原生request.getParameter()去获取参数的时候都为null

> 我们做文件上传一般会借助第三方组件(jar, 框架 SpringMVC)实现文件上传.

### 常见的文件上传jar包和框架

​	serlvet3.0(原生的文件上传的API) 

​	commons-fileupload :  apache出品的一款专门处理文件上传的工具包 （我们肯定不会直接使用）

​	struts2(底层封装了:commons-fileupload)   

​	SpringMVC(底层封装了:commons-fileupload)   



## 案例-springmvc 传统方式文件上传 


+ 创建Maven工程,添加依赖

```html
<dependencies>
    <!--文件上传组件的依赖-->
    <dependency>
        <groupId>commons-fileupload</groupId>
        <artifactId>commons-fileupload</artifactId>
        <version>1.3.1</version>
    </dependency>
    <!--springmvc的依赖-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-webmvc</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>

    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>servlet-api</artifactId>
        <version>2.5</version>
        <scope>provided</scope>
    </dependency>

    <dependency>
        <groupId>javax.servlet.jsp</groupId>
        <artifactId>jsp-api</artifactId>
        <version>2.0</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

+ 创建前端页面

```html
<h1>一,springmvc传统方式文件上传</h1>
<form action="/file/upload" method="post" enctype="multipart/form-data">
    图片： <input type="file" name="upload"/><br/>
    图片描述:<input type="text" name="pdesc"/>
    <input type="submit" value="上传"/>
</form>
```

+ 控制器

```java
package com.jwang.controller;

import org.apache.commons.io.IOUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * 包名:com.jwang.controller
 * @author Leevi
 * 日期2020-11-15  08:58
 * 服务器端获取客户端上传的文件:
 * 1. 在springmvc的配置文件中配置文件解析器，将字节输入流解析成MultipartFile对象
 * 2. 在控制器方法中添加MultipartFile类型的参数
 */
@RestController
@RequestMapping("/file")
public class FileController {
    @RequestMapping("/upload")
    public String upload(MultipartFile upload, String pdesc, HttpSession session) throws IOException {
        System.out.println(pdesc);
        InputStream is = null;
        FileOutputStream out = null;
        try {
            ServletContext servletContext = session.getServletContext();
            // 在部署的项目路径下准备一个upload目录
            String realPath = servletContext.getRealPath("upload");
            File file = new File(realPath);
            if (!file.exists()) {
                file.mkdirs();
            }
            //获取文件名
            String originalFilename = upload.getOriginalFilename();
            // 使用文件输出流将客户端上传的文件输出到指定目录
            out = new FileOutputStream(new File(file, originalFilename));

            //客户端上传文件的输入流
            is = upload.getInputStream();

            IOUtils.copy(is, out);
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        } finally {
            is.close();
            out.close();
        }
    }
}
```

+ 在springmvc.xml配置文件解析器 

  注意：文件上传的解析器**id 是固定的，不能起别的名称**，否则无法实现请求参数的绑定。（不光是文件，其他字段也将无法绑定） 

```xml
<!--配置文件上传解析器-->
<bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
    <!-- 设置上传文件的最大尺寸为 5MB --> 
    <property name="maxUploadSize" value="5242880"></property>
</bean>
```



## 案例-springmvc 跨服务器方式的文件上传  



### 分服务器的目的 

在实际开发中，我们会有很多处理不同功能的服务器(注意：此处说的不是服务器集群)。 例如：

​	应用服务器：负责部署我们的应用 
​	数据库服务器：运行我们的数据库
​	缓存和消息服务器：负责处理高并发访问的缓存和消息
​	文件服务器：负责存储用户上传文件的服务器。 

分服务器处理的目的是让服务器各司其职，从而提高我们项目的运行效率。 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/springMVC/s2/img/tu_2.png)

### 跨服务器方式的文件上传图解

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/springMVC/s2/img/tu_3.png)

+ 准备两个服务器(默认情况下，tomcat是不允许其他服务器往它里面写入数据的), 修改tomcat的的conf目录下的web.xml， 添加readonly参数为false

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/springMVC/s2/img/tu_4.png)

### 实现

+ 添jersey依赖 (跨服务器上传图片的代码)

```xml
<dependencies>
    <!--引入文件上传的依赖-->
    <!--文件上传组件的依赖-->
    <dependency>
        <groupId>commons-fileupload</groupId>
        <artifactId>commons-fileupload</artifactId>
        <version>1.3.1</version>
    </dependency>
    <!--springmvc的依赖-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-webmvc</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>

    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>servlet-api</artifactId>
        <version>2.5</version>
        <scope>provided</scope>
    </dependency>

    <dependency>
        <groupId>javax.servlet.jsp</groupId>
        <artifactId>jsp-api</artifactId>
        <version>2.0</version>
        <scope>provided</scope>
    </dependency>

    <!--跨服务器上传的文件的依赖-->
    <dependency>
        <groupId>com.sun.jersey</groupId>
        <artifactId>jersey-core</artifactId>
        <version>1.18.1</version>
    </dependency>
    <dependency>
        <groupId>com.sun.jersey</groupId>
        <artifactId>jersey-client</artifactId>
        <version>1.18.1</version>
    </dependency>
</dependencies>
```

+ 前端页面

```html
<h1>二,springmvc 跨服务器方式的文件上传</h1>
<form action="/file/upload" method="post" enctype="multipart/form-data">
    图片： <input type="file" name="upload"/><br/>
    图片描述:<input type="text" name="pdesc"/>
    <input type="submit" value="上传"/>
</form>
```

+ 控制器

```java
package com.jwang.controller;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

/**
 * 包名:com.jwang.controller
 * @author Leevi
 * 日期2020-11-15  08:58
 * 跨服务器文件上传：
 * 1. 使用springmvc的方式获取客户端上传的文件
 * 2. 使用跨服务器上传文件的API，将图片上传到文件服务器
 */
@RestController
@RequestMapping("/file")
public class FileController {

    /**
     * 改成跨服务器文件上传
     * @param upload
     * @param pdesc
     * @return
     * @throws IOException
     */
    @RequestMapping("/upload")
    public String upload(MultipartFile upload, String pdesc) throws IOException {
        System.out.println(pdesc);
        try {
            //获取文件名
            String originalFilename = upload.getOriginalFilename();
            //上传文件的路径
            String uploadPath = "http://localhost:8899/upload/"+originalFilename;

            //创建一个文件上传的客户端
            Client client = Client.create();
            //建立与服务器的连接
            WebResource resource = client.resource(uploadPath);
            //将文件上传给服务器
            resource.put(upload.getBytes());
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }
}
```


# 第二章-SpringMVC 中的异常处理  


​	系统中异常包括两类：编译时异常和运行时异常RuntimeException，前者通过捕获异常从而获取异常信息，后者主要通过规范代码开发、测试通过手段减少运行时异常的发生。

       系统的dao、service、controller出现都通过throws Exception向上抛出，最后由springmvc前端控制器交由异常处理器进行异常处理，如下图：

​	![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/springMVC/s2/img/tu_5.png)

​	springmvc在处理请求过程中出现异常信息交由异常处理器进行处理，自定义异常处理器可以实现一个系统的异常处理逻辑。




### 自定义异常处理器

```java
package com.jwang.handler;

import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 包名:com.jwang.handler
 * @author Leevi
 * 日期2020-11-15  10:17
 * 全局异常处理器：
 *     作用: 处理整个项目中所有的controller抛出的异常
 *     步骤: 1. 编写一个类实现HandlerExceptionResolver接口
 *          2. 重写resolveException方法
 *          3. 在springmvc的配置文件中，配置异常解析器
 */
public class GlobalExceptionHandler implements HandlerExceptionResolver {

    @Override
    public ModelAndView resolveException(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        //ex表示这次的异常信息,使用它可以收集异常信息
        ex.printStackTrace();//这句代码仅仅是在控制台打印文件

        //返回ModelAndView对象就必然要走视图解析器
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("error");
        return modelAndView;
    }
}
```

### 配置异常处理器 

+ 在springmvc.xml配置

```xml
<bean id="sysExceptionResolver" class="com.jwang.handler.GlobalExceptionHandler"></bean>
```




# 第三章-SpringMVC 中的拦截器  


## 拦截器概述 

​	Spring MVC 的处理器拦截器类似于 Servlet 开发中的过滤器 Filter，用于对处理器(自己编写的Controller)进行预处理和后处理。用户可以自己定义一些拦截器来实现特定的功能。谈到拦截器，还要向大家提一个词——拦截器链（Interceptor Chain）。拦截器链就是将拦截器按一定的顺序联结成一条链。在访问被拦截的方法或字段时，拦截器链中的拦截器就会按其之前定义的顺序被调用。说到这里，可能大家脑海中有了一个疑问，这不是我们之前学的过滤器吗？是的它和过滤器是有几分相似，但
是也有区别，接下来我们就来说说他们的区别： 

| 类别   | 使用范围      | 拦截范围                            |
| ------ | ------------- | ----------------------------------- |
| 拦截器 | SpringMVC项目 | 只会拦截访问的控制器方法的请求      |
| 过滤器 | 任何web项目   | 任何资源(servlet,控制器,jsp,html等) |

​	我们要想自定义拦截器， 要求必须实现： HandlerInterceptor 接口。 

## 自定义拦截器入门

+ 编写一个普通类实现 HandlerInterceptor 接口 

```java
package com.jwang.interceptor;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 包名:com.jwang.interceptor
 * @author Leevi
 * 日期2020-11-15  10:47
 * 拦截器:
 *    作用: 在执行controller的方法之前做预处理，以及执行controller的方法之后做后处理
 *    步骤:
 *       1. 写一个类实现HandlerInterceptor接口
 *       2. 选择实现其中的方法:
 *          1. preHandle() 在处理器方法之前执行
 *          2. postHandle() 在处理器方法之后、视图渲染之前执行
 *          3. afterCompletion() 在视图渲染之后执行，官方建议可以在该方法中做一些资源清理操作
 *       3. 在springmvc配置文件中进行拦截器的配置(配置拦截器的拦截路径)
 */
public class PermissionInterceptor implements HandlerInterceptor{
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        System.out.println("PermissionInterceptor的preHandle方法执行了...");
        //返回值为true就是放行
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        System.out.println("PermissionInterceptor的postHandle方法执行了...");
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        System.out.println("PermissionInterceptor的afterCompletion方法执行了...");
    }
}
```

+ 在springmvc.xml配置拦截器 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       http://www.springframework.org/schema/mvc
       http://www.springframework.org/schema/mvc/spring-mvc.xsd">
    <context:component-scan base-package="com.jwang"/>

    <!--配置拦截器-->
    <mvc:interceptors>
        <!--
            里面可以配置多个拦截器,每一个interceptor就是一个拦截器
        -->
        <mvc:interceptor>
            <!--
                mapping表示这个拦截器的拦截范围
            -->
            <mvc:mapping path="/**" />
            <!--
                exclude-mapping
            -->
            <mvc:exclude-mapping path="/hello/sayHaha.do"/>
            <!--
                bean标签表示对我们要进行配置的拦截器做IOC
            -->
            <bean id="permissionInterceptor" class="com.jwang.interceptor.PermissionInterceptor">	</bean>
        </mvc:interceptor>
    </mvc:interceptors>
</beans>
```




##  自定义拦截器进阶


### 拦截器的放行

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/springMVC/s2/img/tu_6.png)

###  拦截器的路径

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       http://www.springframework.org/schema/mvc
       http://www.springframework.org/schema/mvc/spring-mvc.xsd">
    <context:component-scan base-package="com.jwang"/>

    <!--配置拦截器-->
    <mvc:interceptors>
        <!--
            里面可以配置多个拦截器,每一个interceptor就是一个拦截器
        -->
        <mvc:interceptor>
            <!--
                mapping表示这个拦截器的拦截范围
			    /**表示拦截所有控制器方法
            -->
            <mvc:mapping path="/**" />
            <!--
                exclude-mapping
            -->
            <mvc:exclude-mapping path="/hello/sayHaha.do"/>
            <!--
                bean标签表示对我们要进行配置的拦截器做IOC
            -->
            <bean id="permissionInterceptor" class="com.jwang.interceptor.PermissionInterceptor">	</bean>
        </mvc:interceptor>
    </mvc:interceptors>
</beans>
```



### 拦截器的其它方法

+ afterCompletion  在目标方法完成视图层渲染后执行。
+ postHandle  在目标方法执行完毕获得了返回值后执行。
+ preHandle 被拦截的目标方法执行之前执行。

```java
package com.jwang.interceptor;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 包名:com.jwang.interceptor
 * @author Leevi
 * 日期2020-11-15  10:47
 * 拦截器:
 *    作用: 在执行controller的方法之前做预处理，以及执行controller的方法之后做后处理
 *    步骤:
 *       1. 写一个类实现HandlerInterceptor接口
 *       2. 选择实现其中的方法:
 *          1. preHandle() 在处理器方法之前执行
 *          2. postHandle() 在处理器方法之后、视图渲染之前执行
 *          3. afterCompletion() 在视图渲染之后执行，官方建议可以在该方法中做一些资源清理操作
 *       3. 在springmvc配置文件中进行拦截器的配置(配置拦截器的拦截路径)
 */
public class PermissionInterceptor implements HandlerInterceptor{
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        System.out.println("PermissionInterceptor的preHandle方法执行了...");
        //返回值为true就是放行
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        System.out.println("PermissionInterceptor的postHandle方法执行了...");
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        System.out.println("PermissionInterceptor的afterCompletion方法执行了...");
    }
}
```



###  多个拦截器执行顺序

​	回想多个过滤器的执行顺序:

1. 如果采用配置文件方式配置过滤器，那么就按照过滤器的配置先后顺序执行

    		2. 如果采用注解方式配置过滤器，那么就按照类名的排序执行

​	我们可以配置多个拦截器, 所以就存在一个优先级问题了.多个拦截器的优先级是按照配置的顺序决定的。 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/springMVC/s2/img/tu_9.jpg)

+ 配置顺序

```xml
<!--配置拦截器-->
<mvc:interceptors>
    <!--
            里面可以配置多个拦截器,每一个interceptor就是一个拦截器
        -->
    <mvc:interceptor>
        <!--
                mapping表示这个拦截器的拦截范围
            -->
        <mvc:mapping path="/**" />
        <!--
                exclude-mapping
            -->
        <mvc:exclude-mapping path="/hello/sayHaha.do"/>
        <!--
                bean标签表示对我们要进行配置的拦截器做IOC
            -->
        <bean id="permissionInterceptor" class="com.jwang.interceptor.PermissionInterceptor">	</bean>
    </mvc:interceptor>

    <mvc:interceptor>
        <!--
                mapping表示这个拦截器的拦截范围
            -->
        <mvc:mapping path="/**" />
        <!--
                bean标签表示对我们要进行配置的拦截器做IOC
            -->
        <bean id="secondInterceptor" class="com.jwang.interceptor.SecondInterceptor">	</bean>
    </mvc:interceptor>
</mvc:interceptors>
```


# 第四章-项目改成SSM

## 第一步-引入依赖

1. 并且去掉heima_mvc的依赖，并且删除web.xml中相关配置,并且删除掉自己项目中的解决乱码的过滤器
2. spring相关依赖
   1. spring-webmvc
   2. spring-jdbc
   3. aop依赖
3. mybatis整合spring的依赖
4. log相关依赖
5. jackson相关的依赖
6. druid连接池依赖
7. 文件上传的依赖

```xml
<properties> 
    <spring.version>5.0.2.RELEASE</spring.version>  
    <!--日志打印框架-->  
    <slf4j.version>1.6.6</slf4j.version>  
    <log4j.version>1.2.12</log4j.version>   
</properties>  
<dependencies>
	<dependency> 
      <groupId>org.springframework</groupId>  
      <artifactId>spring-webmvc</artifactId>  
      <version>${spring.version}</version> 
    </dependency>  
    <dependency> 
      <groupId>org.springframework</groupId>  
      <artifactId>spring-jdbc</artifactId>  
      <version>${spring.version}</version> 
    </dependency> 
    <dependency> 
      <groupId>com.fasterxml.jackson.core</groupId>  
      <artifactId>jackson-databind</artifactId>  
      <version>2.9.0</version> 
    </dependency>  
    <dependency> 
      <groupId>com.fasterxml.jackson.core</groupId>  
      <artifactId>jackson-core</artifactId>  
      <version>2.9.0</version> 
    </dependency>  
    <dependency> 
      <groupId>com.fasterxml.jackson.core</groupId>  
      <artifactId>jackson-annotations</artifactId>  
      <version>2.9.0</version> 
    </dependency>
    <!--
           关键: mybatis整合spring的依赖
        -->  
    <dependency> 
      <groupId>org.mybatis</groupId>  
      <artifactId>mybatis-spring</artifactId>  
      <version>1.3.0</version> 
    </dependency>
    <!--druid-->  
    <dependency> 
      <groupId>com.alibaba</groupId>  
      <artifactId>druid</artifactId>  
      <version>1.1.5</version> 
    </dependency>  
    <!--SpringAOP相关的坐标-->  
    <dependency> 
      <groupId>org.aspectj</groupId>  
      <artifactId>aspectjweaver</artifactId>  
      <version>1.8.7</version> 
    </dependency> 
</dependencies>
```

## 第二步-修改mybatis的核心配置文件

## 第三步-编写spring整合mybatis的配置文件

1. 整合mybatis

## 第四步-编写声明式事务的配置文件

1. 配置事务管理者
2. 加载事务注解驱动
3. 导入spring-mybatis.xml

## 第五步-编写spring的主配置文件

1. 包扫描
2. 加载mvc注解驱动
3. 导入导入spring-tx.xml

## 第六步-修改web.xml配置

1. 将heimaMVC中的DispatcherServlet的配置改成SpringMVC中的DispatcherServlet的配置
2. 将解决乱码的过滤器的配置改成SpringMVC中的解决乱码的过滤器配置
3. 删除项目中自己定义的解决乱码的过滤器

## 第七步-修改各个controller的代码

1. 将原本heimaMvc的Controller注解改成springMvc中的RestController注解
2. 使用Autowired注解注入Service对象
3. 在各个Controller类上添加RequestMapping注解
4. 将Controller类的各个方法上的RequestMapping注解改成SpringMVC中的RequestMapping注解，并且修改路径
5. 将各个方法的获取请求参数的方式改成SpringMVC中的获取请求参数
6. 将各个方法的响应数据给客户端的方式改成SpringMVC的响应数据方式

## 第八步-修改各个Service的代码

1. 将所有的Service的实现类改名成"XXXImpl"
2. 给各个实现类添加接口，然后Controller中一定要以接口类型接收Service的对象
3. 各个Service的实现类商添加Service注解进行IOC
4. 使用Autowired注解注入Dao对象
5. 将方法中所有涉及到SqlSession的代码全部删掉，直接就能使用Dao对象
6. 要进行事务控制的类或者方法上添加Transactional注解

## 第九步-修改文件上传的代码

1. 将原来的获取上传文件的代码改成SpringMVC的文件上传代码
2. 在创建spring文件上传的配置文件，配置文件解析器










