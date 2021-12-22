---
title: web开发介绍及tomcat
categories: 前端知识集
tags: [前端服务器, tomcat]
top: 7
abbrlink: 3951566323
date: 2019-05-11 18:18:19
password:
---

#  WEB开发介绍

## WEB资源分类 

WEB，在英语中web即表示网页的意思，它用于**表示Internet主机(服务器)上供外界访问的资源**

<!--more-->

### 静态资源

- web页面中供人们浏览的数据始终是不变 (eg: html,css,js、音视频)

### 动态资源

- 指web页面中供人们浏览的数据是由程序产生的，不同的用户或者不同时间点访问web页面看到的内容各不相同。(eg: servlet,jsp)


##  软件架构 

### C/S架构

​	Client / Server,客户端和服务器端，**用户需要安装专门客户端程序。**

### B/S架构

​	Browser / Server,浏览器和服务器端，**不需要安装专门客户端程序，浏览器是操作系统内置。**

### B/S 和C/S交互模型的比较

+ 相同点

  ​	都是基于请求-响应交互模型:即浏览器（客户端) 向 服务器发送 一个 请求。服务器 向 浏览器（客户端）回送 一个 响应 。

  ​	必须先有请求 再有响应

  ​	请求和响应成对出现

+ 不同点

  ​	实现C/S模型需要用户在自己的操作系统安装各种客户端软件（百度网盘、腾讯QQ等）；实现B/S模型，只需要用户在操作系统中安装浏览器即可。

>  注：B/S模型可以理解为一种特殊C/S模型。

##  web通信 


![image-20191208091344175](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/image-20191208091344175.png)



#  服务器 

processon的画图软件的注册地址:

https://www.processon.com/i/5f0440b81e085326375eb062

##  服务器介绍

服务器就是一个软件，任何电脑只需要安装上了服务器软件， 我们的电脑就可以当做一台服务器了. 

​	服务器: 硬件(电脑)+软件(mysql, tomcat,nginx)

## 常见web服务器

+ WebLogic

  ​	Oracle公司的产品，是目前应用比较多的Web服务器，支持J2EE规范。WebLogic是用于开发、集成、部署和管理大型分布式Web应用、网络应用和数据库应用的Java应用服务器。

  ![1555895183498](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555895183498.png) 

+ WebSphere

  ​       IBM公司的WebSphere，支持JavaEE规范。WebSphere 是随需应变的电子商务时代的最主要的软件平台，可用于企业开发、部署和整合新一代的电子商务应用。

  ![1555895215122](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555895215122.png) 

+ Glass Fish 

  ​      最早是Sun公司的产品，后来被Oracle收购，开源免费，中型服务器。

+ JBoss

  ​      JBoss公司产品，开源，支持JavaEE规范，占用内存、硬盘小，安全性和性能高。

  ![1555895293155](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555895293155.png) 

+ Tomcat

  ​    中小型的应用系统，免费,开源,效率特别高, 适合扩展(搭集群)支持JSP和Servlet. 
  
  ![1555895400407](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1555895400407.png) 

    

##  tomcat介绍、安装和使用


​	Tomcat服务器是一个免费的开放源代码的Web应用服务器。

​	Tomcat是Apache软件基金会（Apache Software Foundation）的Jakarta项目中的一个核心项目，由Apache、Sun和其他一些公司及个人共同开发而成。由于有了Sun的参与和支持，最新的Servlet 和JSP规范总是能在Tomcat中得到体现。

​	因为Tomcat技术先进、性能稳定，而且免费，因而深受Java爱好者的喜爱并得到了部分软件开发商的认可，是目前比较流行的Web应用服务器。

### tomcat的下载

强调: 我们使用的软件版本，要和老师用的版本一致

目前阶段:

​				jdk8、mysql5、tomcat8

1. **先去官网下载：http://tomcat.apache.org/，选择tomcat8版本(资料已提供)（红框所示）**：

   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/01.png)

2. 选择要下载的文件（红框所示）：

   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/02.png)

    tar.gz 文件 是linux操作系统下的安装版本

    exe文件是window操作系统下的安装版本

    zip文件是window操作系统下压缩版本（我们选择zip文件）

   

3. **下载完成**：

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/03.png)

### tomcat服务器软件安装

1. 直接解压当前这个tomcat压缩包：(**不要有中文,不要有空格**)

2. 配置环境变量：

   tomcat运行依赖于java环境：
   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/05.png)		

### tomcat的目录结构

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_5.png)

### 启动与关闭tomcat服务器

1. 启动tomcat服务器

   查找tomcat目录下bin目录，查找其中的startup.bat命令，双击启动服务器：
   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/06.png)

   启动效果：
   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/07.png)

   

   

2. 测试访问tomcat服务器

   打开浏览器在，在浏览器的地址栏中输入：

   http://127.0.0.1:8080或者http://localhost:8080

   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/08.png)

   注： Localhost相当于127.0.0.1

3. 关闭tomcat服务器

   查找tomcat目录下bin目录，查找其中的shutdown.bat命令，双击关闭服务器：
   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/09.png)



### 常见问题 

####  安装注意点

+ 解压到一个==没有中文和空格==目录下
+ 使用之前, 配置java_home和path(jdk环境变量)
  + java_home 不要配到bin目录,配到jdk的安装目录
  + path 才是配到bin目录



####   端口号冲突  

​	报如下异常: java.net.BindException: Address already in use: JVM_Bind   8080

​	解决办法:

​	第一种:修改Tomcat的端口号   

​	![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_100.png)

​		修改conf/server.xml ,  第70行左右

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_3.png)

第二种:查询出来哪一个进程把8080占用了, 结束掉占用8080端口后的程序

​		打开命令行输入:  netstat -ano

​		找到占用了8080 端口的 进程的id

​		去任务管理器kill掉这个id对应的程序

​		![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/tu_4.png)

​		

####  JAVA_HOME没有配置

+ 会出现闪退  (如果java_home配置了还是闪退  忽略它了, 后面在IDEA里面进行启动, 就没有这个问题)



## 运用Tomcat服务器部署WEB项目


```
  WebAPP(文件夹,项目)  
   		|---静态资源: html,css,js,图片(它们可以以文件存在,也可以以文件夹存在)  
   		|---WEB-INF 固定写法。此目录下的文件不能被外部(浏览器)直接访问
   			|---lib:jar包存放的目录
   			|---web.xml:当前项目的配置文件(3.0规范之后可以省略)
   			|---classes:java类编译后生成class文件存放的路径
```



### 发布项目到tomcat

#### 方式一:直接发布

​	只要将准备好的web资源直接复制到tomcat/webapps文件夹下，就可以通过浏览器使用http协议访问获取

#### 方式二: 虚拟路径的方式发布项目

1. 第一步：在tomcat/conf目录下新建一个Catalina目录（如果已经存在无需创建）

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/26.png)

2. 第二步：在Catalina目录下创建localhost目录（如果已经存在无需创建）

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/27.png)

3. 第三步：在localhost中创建xml配置文件，名称为：随便写，比如叫做second.xml（注：这个名称是浏览器访问路径）

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/28.png)

4. 第四步：添加second.xml文件的内容为：  docBase就是你需要作为虚拟路径的项目的路径

   ```
   <?xml version = "1.0" encoding = "utf-8"?>
   <Context docBase="C:\JavaEE_Relation\JavaEE101\itheima101_staticWeb\day24_html" />
   ```
   ![1537667265350](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/HTS/img/1537667265350.png)

5. 第五步：直接访问(通过写配置文件的路径来访问):

   http://localhost:8080/second/a.html (second就是配置文件的名字, 映射成了myApp)


