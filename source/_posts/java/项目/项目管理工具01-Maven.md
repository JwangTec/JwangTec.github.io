---
title: 项目管理工具01-Maven
categories: 项目管理工具
tags: [Maven介绍, Maven安装及常用命令, IDEA上使用Maven, 私服, Lombok, Maven]
top: 12
abbrlink: 3720442140
date: 2019-09-01 18:18:19
password:
---


# 第一章-Maven相关的概念

##  Maven介绍

<!--more-->

###  目标

+ 能够了解Maven的作用

###  路径

+ 什么是Maven
+ Maven的作用
+ Maven的好处

###  讲解

####  什么是Maven

​	Maven是项目进行模型抽象，充分运用的面向对象的思想，Maven可以通过一小段描述信息来管理项目的构建，报告和文档的软件项目管理工具。Maven 除了以程序构建能力为特色之外，还提供高级项目管理工具。由于 Maven 的缺省构建规则有较高的可重用性，所以常常用两三行 Maven 构建脚本就可以构建简单的项目。

​	说白了: **Maven是由Apache开发的一个工具**。用来管理java项目(依赖(jar)管理, 项目构建, 分模块开发 ，管理项目的生命周期).

####  Maven的作用

- 依赖管理: maven对项目的第三方构件（jar包）进行统一管理。向工程中加入jar包不要手工从其它地方拷贝，通过maven定义jar包的坐标，自动从maven仓库中去下载到工程中。  


- 项目构建: maven提供一套对项目生命周期管理的标准，开发人员、和测试人员统一使用maven进行项目构建。项目生命周期管理：编译、测试、打包、部署、运行。
- maven对工程分模块构建，提高开发效率。 (后面Maven高级会涉及)

####   Maven的好处

+ 使用普通方式构建项目

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/tu_2.png)

+ 使用Maven构建项目

  ![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/tu_3.png)



## 知识点-Maven仓库和坐标 

###  目标

+ 能够理解Maven仓库的作用

### 路径

1. Maven的仓库
2. Maven的坐标

###  讲解

#### Maven的仓库

| 仓库名称 | 作用                                                         |
| -------- | ------------------------------------------------------------ |
| 本地仓库 | 相当于缓存，工程第一次会从远程仓库（互联网）去下载jar 包，将jar包存在本地仓库（在程序员的电脑上）。第二次不需要从远程仓库去下载。先从本地仓库找，如果找不到才会去远程仓库找。 |
| 中央仓库 | 仓库中jar由专业团队（maven团队）统一维护。中央仓库的地址：https://repo1.maven.org/maven2/ |
| 远程仓库 | 在公司内部架设一台私服，其它公司架设一台仓库，对外公开。     |

####  Maven的坐标

​	Maven的一个核心的作用就是管理项目的依赖，引入我们所需的各种jar包等。为了能自动化的解析任何一个Java构件，Maven必须将这些Jar包或者其他资源进行唯一标识，这是管理项目的依赖的基础，也就是我们要说的坐标。包括我们自己开发的项目，也是要通过坐标进行唯一标识的，这样才能才其它项目中进行依赖引用。坐标的定义元素如下：

- groupId:项目组织唯一的标识符，实际对应JAVA的包的结构 (一般写公司的组织名称 eg:com.jwang,com.alibaba)  
- artifactId: 项目的名称
- version：定义项目的当前版本 

例如：要引入druid，只需要在pom.xml配置文件中配置引入druid的坐标即可：

```xml
<dependecies>
	<!--druid连接池-->
	<dependency>
  		<groupId>com.alibaba</groupId>
  		<artifactId>druid</artifactId>    
  		<version>1.0.9</version>  
	</dependency>
    <dependency>
    	<groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.6</version>
    </dependency>
</dependecies>

```

###  小结

1. 仓库(本地仓库,中央仓库,远程仓库(私服))
   + 先从本地仓库找
     + 如果有, 就直接获得使用
     + 如果没有, 从中央仓库找, 自动的下载到本地仓库
2. 通过坐标从仓库里面找到对应的jar使用

```xml
<dependency>
  <groupId>com.alibaba</groupId>
  <artifactId>druid</artifactId>    
  <version>1.0.9</version>  
</dependency>
```

3. maven坐标搜索网站的地址: https://mvnrepository.com/ 
4. 以后工作中maven坐标是直接拷贝

# 第二章-Maven的安装

##  Maven的安装

###  目标

+ 能够掌握Maven的安装

###  路径

1. 下载Maven
2. 安装Maven
3. Maven目录介绍
4. 配置环境变量  
5. 配置本地仓库
6. 测试Maven是否安装成功

###  讲解

####  下载Maven

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/2.png)

  http://maven.apache.org/

####   安装Maven

将Maven压缩包解压，即安装完毕

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/4.png)

####   Maven目录介绍

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/43.png)

####  配置环境变量

+ 进入环境变量

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/tu_5.png)

+ 配置MAVEN_HOME和Path

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/tu_6.png)

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/tu_7.png)

####   配置本地仓库

#####   将软件文件夹中的repository解压

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/5.png)

#####  配置本地仓库

在maven的安装目录中conf/ settings.xml文件，在这里配置本地仓库

![1535072726716](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535072726716.png)

+ 示例代码

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <!-- localRepository
   | The path to the local repository maven will use to store artifacts.
   |
   | Default: ${user.home}/.m2/repository
  <localRepository>/path/to/local/repo</localRepository>
  -->
 <localRepository>E:/source/04_Maven/repository_pinyougou</localRepository>
```

####    测试Maven安装成功

打开cmd本地控制台，输入mvn -version

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/6.png)

###  小结

1. 注意事项
   + `Maven安装包` 和`仓库` 都需要解压到一个==没有中文和空格==的目录下(建议解压到不同的目录)
   + 配置
     + MAVEN_HOME 配置到Maven的解压目录
     + Path 配置到bin目录
   + 在`apache-maven-3.3.9\conf\settings.xml`配置本地仓库

## 知识点-IDEA集成Maven 

###  目标

+ 能够掌握IDEA配置本地Maven

###  路径

1. 在IDEA配置Maven
2. 配置默认的Maven环境

###  讲解

####  配置Maven

+ 配置Maven

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/7.png)

+ 配置参数(解决创建慢的问题)  -DarchetypeCatalog=internal

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/tu_8.png)



* 然后新创建project，一定不要使用原来的project，要求各位第一次使用maven创建项目的时候，一定要联网

### 小结

+ 配置默认Maven环境 目的: 为了下次创建的时候 不需要再选择Maven了, 使用的就是这个默认环境的

+ 配置三块

  + maven_home
  + Maven的配置文件
  + 本地仓库的路径

  

# 第三章-使用IDEA创建Maven工程

##  创建javase工程

###  目标

+ 能够使用IDEA创建javase的Maven工程

###  路径

1. 创建java工程
2. java工程目录结构
3. 编写Hello World！

###  讲解

#### 创建java工程

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/8.png)



![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/9.png)

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/10.png)

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/11.png)

####   java工程目录结构

+ 需要main/java文件夹变成 源码的目录(存放java源码)

![1535073660314](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535073660314.png)



+ 需要test/java文件夹变成 测试源码的目录(存放单元测试)

![1535073720297](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535073720297.png)

+ 创建resources目录, 变成资源的目录

  ![1535073892837](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535073892837.png)

+ 整体结构

  ![1535073980263](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535073980263.png)

####  编写Hello World！

![](img\13.png)

![](img\14.png)

###  小结

1. JavaSe工程的骨架

![image-20191224102043184](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191224102043184.png) 

2. 项目的结构

![image-20191224102316809](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191224102316809.png) 



## 实操-创建javaweb工程

###  目标

+ 能够使用IDEA创建javaweb的Maven工程

### 路径

1. 创建javaweb工程
2. 发布javaweb工程
3. 浏览器访问效果

###  讲解

####  创建javaweb工程

- 创建javaweb工程与创建javase工程类似，但在选择Maven骨架时，选择maven-archetype-webapp即可：

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/15.png)

- 创建好的javaweb工程如下：

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/16.png)

- 所以，要手动创建一个java目录用于编写java代码：

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/17.png)

- 还要将java目录添加为Source Root：

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/18.png)

####   发布javaweb工程

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/37.png)

####  浏览器访问效果

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/21.png)

###  小结

1. 选择骨架选择webapp 

![image-20191224105135578](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191224105135578.png) 

2. pom.xml

![image-20191224105159688](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191224105159688.png) 



3. web工程结构 

![image-20191224105359670](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191224105359670.png) 





## 实操-不使用骨架创建工程  

### 目标

​	上面是使用骨架来创建工程的，如果不使用骨架，怎样创建工程呢?

### 路径

1. 不使用骨架创建javase项目
2. 不使用骨架创建javaweb项目

###  讲解

####  不使用骨架创建javase项目

- 第一步

![1535183606179](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535183606179.png)

- 第二步

![1535183637210](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535183637210.png)

- 第三步

![1535183659568](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535183659568.png)

- 第四步

![1535183718460](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535183718460.png)

#### 不使用骨架创建javaweb项目

* 安装一个插件(JBLJavaToWeb)

- 第一步

![1535183799998](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535183799998.png)

- 第二步

![1535183825097](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535183825097.png)

- 第三步

![1535183856928](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535183856928.png)



- 第四步

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1111.jpg)

###  小结

我们可以使用JBLJavaToWeb插件，轻松地将没有使用骨架创建的java项目转换成javaweb项目



# 第四章-Maven的常用命令

##  Maven的常用命令管理项目的生命周期

### 目标

+ 掌握Maven的常用命令

###  路径

1. clean命令
2. compile命令
3. test命令
4. package命令  
5. install命令

###  讲解

####  clean命令

**清除编译产生的target文件夹内容**，可以配合相应命令一起使用，如mvn clean package， mvn clean test

![1535077199437](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535077199437.png)



![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/22.png)

####  compile命令

该命令可以对src/main/java目录的下的代码进行编译

![1535077363500](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535077363500.png)



![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/32.png)

####  test命令

**测试命令,先将src/main/java以及src/test/java中的类都进行编译，然后再执行src/test/java/下所有junit的测试用例**

![1535077528168](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535077528168.png)

- 在src/test/java下创建测试类DemoTest

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/33.png)

- 执行test命令测试

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/34.png)

- 控制台显示测试结果

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/35.png)

####   package命令

mvn package，打包项目

先编译，再执行测试，然后再打包(只会将main/java里面的代码打到包)

+ 如果是JavaSe的项目,打包成jar包
+ 如果是JavaWeb的项目,打包成war包

![1535077767079](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535077767079.png)



![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/25.png)

打包后的项目会在target目录下找到

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/26.png)





####  install命令

mvn install，打包后将其安装在本地仓库

![1535078133186](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1535078133186.png)

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/23.png)

安装完毕后，在本地仓库中可以找到jwang_javase_demo的信息

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/24.png)



###  小结

1. 命令作用

   + clean 用来清除编译后的文件(target文件夹里面的)**【一般清缓存】**
   + compile  编译只会编译main里面的内容
   + test       执行单元测试，先将main、test中的内容进行编译，然后执行test中的测试方法
   + package  打包 (**javaSe-->jar, javaweb-->war**)，其实执行打包之前先执行test，然后对项目进行打包
   + install  把项目打包之后**安装到本地仓库**，其实执行install之前先执行了打包，然后对项目进行安装到本地仓库

2. 生命周期

     当我们执行了install 也会执行compile  test  package

     

# 第五章-依赖管理和插件

## 依赖管理(引入依赖)

###  目标

+ 能够掌握依赖引入的配置方式

###  路径

1. 导入依赖
2. 导入依赖练习
3. 依赖范围

### 讲解

####  导入依赖

​	导入依赖坐标，无需手动导入jar包就可以引入jar。在pom.xml中使用<dependency>标签引入依赖。

​	做项目/工作里面 都有整套的依赖的, 不需要背诵的. 

​	去Maven官网找, 赋值,粘贴.  `http://mvnrepository.com/`

##### 导入junit的依赖

- 导入junit坐标依赖

```xml
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.12</version>
    <scope>test</scope>
</dependency>
```

- 进行单元测试

```java
import org.junit.Test;

public class DemoTest {
    @Test
    public void test1(){
        System.out.println("test running...");
    }
}
```

#####   导入servlet的依赖

- 创建Servlet，但是发现报错，原因是没有导入Servlet的坐标依赖

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/38.png)

- 导入Servlet的坐标依赖

```xml
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>3.1.0</version>
    <scope>provided</scope>
</dependency>
```

- 原有报错的Servlet恢复正常

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/39.png)

####  依赖范围

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/27.png)





- compile 编译、测试、运行，A在编译时依赖B，并且在测试和运行时也依赖

  例如：strus-core、spring-beans, C3P0,Druid。打到war包或jar包


- **provided 编译、和测试有效**，A在编译和测试时需要B

   例如：servlet-api就是编译和测试有用，在运行时不用（tomcat容器已提供）

   不会打到war

- runtime：测试运行有效, 

   例如：jdbc驱动包 ，在开发代码中针对java的jdbc接口开发，编译不用

   在运行和测试时需要通过jdbc驱动包（mysql驱动）连接数据库，需要的

   会打到war

- test：只是测试有效，只在单元测试类中用

   例如：junit

   不会打到war

- 按照依赖强度，由强到弱来排序：(理解)

  compile> provided> runtime> test

###  小结

1. 坐标不需要背, 做项目时候/工作开发 都有整套的坐标. 如果是导入一些特定, 可以查阅网站,直接拷贝

2. 作用范围
  
   + compile    编译、测试、打包运行部署 有效  【默认】
   + **provided   编译, 测试 有效.  打包运行部署 无效**
   + runtime    测试、打包运行部署 有效  编译无效
   + test           只是测试有效，只在单元测试类中用
   
3.  Servlet,JSP 这类jar  需要加上provided ,  因为部署到Tomcat里面. tomcat里面有, 如果没有加上provided , 可能会导致jar 冲突

     单元测试的 建议加上test           
    
     

## 知识点-Maven插件 

###  目标

​	Maven是一个核心引擎，提供了基本的项目处理能力和建设过程的管理，以及一系列的插件是用来执行实际建设任务。maven插件可以完成一些特定的功能。例如，集成jdk插件可以方便的修改项目的编译环境；集成tomcat插件后，无需安装tomcat服务器就可以运行tomcat进行项目的发布与测试。在pom.xml中通过plugin标签引入maven的功能插件。

###  路径

1.  JDK编译版本的插件
2. Tomcat的插件

###  讲解

####  JDK编译版本的插件   

```xml
<!--jdk编译插件-->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.2</version>
    <configuration>
        <source>1.8</source>
        <target>1.8</target>
        <encoding>utf-8</encoding>
    </configuration>
</plugin>
```

####  Tomcat7服务端的插件(部署项目)  

- 添加tomcat7插件    

```xml
<plugins>
    <plugin>
        <groupId>org.apache.tomcat.maven</groupId>
        <artifactId>tomcat7-maven-plugin</artifactId>
        <configuration>
            <!-- 指定端口 -->
            <port>82</port>
            <!-- 请求路径 -->
            <path>/</path>
        </configuration>
    </plugin>
</plugins>
```

> 注意: Maven的中央仓库中只有Tomcat7.X版本的插件，而之前我们使用的是8.X的版本，如果想使Tomcat8.X的插件可以去其他第三方仓库进行寻找，或者使用IDEA集成外部Tomcat8极其以上版本，进行项目的发布。

###  小结

```xml
<build>
	<plugins>
		   <plugin></plugin> 
    	   <plugin></plugin> 
    </plugins>
</build>
```



# 补充内容: 修改maven的配置

## 一、修改不使用骨架创建maven项目的默认编译版本

1. 不使用骨架创建的maven项目的默认编译版本是1.5或者1.4版本

   ```
   <profile>   
           <id>jdk1.8</id>
           <activation>   
               <activeByDefault>true</activeByDefault>
               <jdk>1.8</jdk>   
           </activation>
           <properties>
               <maven.compiler.source>1.8</maven.compiler.source>
               <maven.compiler.target>1.8</maven.compiler.target>
               <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
               <encoding>UTF-8</encoding>
           </properties>   
   </profile>
   将上述标签内容添加到settings文件的<profiles>标签中
   ```


## 二、彻底解决引入依赖的时候卡、报错

修改settings.xml文件，添加如下代码

```xml
<mirrors>
      <mirror>
          <id>alimaven</id>
          <name>aliyun maven</name>
          <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
          <mirrorOf>central</mirrorOf>
      </mirror>
      <mirror>
          <id>uk</id>
          <mirrorOf>central</mirrorOf>
          <name>Human Readable Name for this Mirror.</name>
          <url>http://uk.maven.org/maven2/</url>
      </mirror>

      <mirror>
          <id>CN</id>
          <name>OSChina Central</name>
          <url>http://maven.oschina.net/content/groups/public/</url>
          <mirrorOf>central</mirrorOf>
      </mirror>

      <mirror>
          <id>nexus</id>
          <name>internal nexus repository</name>
          <url>http://repo.maven.apache.org/maven2</url>
          <mirrorOf>central</mirrorOf>
      </mirror>
  </mirrors>
```

### 三、注意点

1. 引入依赖之后，要检查依赖是否引入成功

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/222.png)

2. 如果dependencies中大块报红

   1. 先使用cleanLastUpdated文件，进行清理。清完之后刷新
   2. 检查自己的maven配置是否正确

   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/333.png)

   3. 检查settings.xml中的本地仓库路径配置是否正确

   ![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/444.png)

   4. 将所有的依赖删除，接着一个一个依赖添加，添加一个就刷新一下，看是否添加成功，如果发现了哪个依赖报错，很有可能是因为你的本地仓库中没有该版本，所以我们可以尝试切换版本

# 第六章 maven 私服  

##   私服搭建

###  目标

- [ ] 了解Maven私服搭建

###  路径

1. Maven私服概述
2. 搭建私服环境 

###  讲解

####  Maven私服概述

​	**公司在自己的局域网内搭建自己的远程仓库服务器，称为私服**， 私服服务器即是公司内部的 maven 远程仓库， 每个员工的电脑上安装 maven 软件并且连接私服服务器，员工将自己开发的项目打成 jar 并发布到私服服务器，其它项目组从私服服务器下载所依赖的构件（jar）。私服还充当一个代理服务器，当私服上没有 jar 包会从互联网中央仓库自动下载，如下
图 :

![1536500069718](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500069718.png)

####  搭建私服环境 

#####   下载 nexus 

​	Nexus 是 Maven 仓库管理器， 通过 nexus 可以搭建 maven 仓库，同时 nexus 还提供强大的仓库管理功能，构件搜索功能等。
​	 下载地址： http://www.sonatype.org/nexus/archived/ 

​	下载： nexus-2.12.0-01-bundle.zip 

![1536500146465](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500146465.png)

#####  安装 nexus 

解压 nexus-2.12.0-01-bundle.zip，进入 bin 目录： 

![1536500225057](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500225057.png)

以管理员权限运行命令行,进入 bin 目录，执行 nexus.bat install 

![1536500276373](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500276373.png)

安装成功在服务中查看有 nexus 服务： 

![1536500298930](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500298930.png)

#####  卸载nexus 

cmd 进入 nexus 的 bin 目录，执行： nexus.bat uninstall 

![1536500348981](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500348981.png)

##### 启动 nexus 

+ 方式一

  cmd 进入 bin 目录，执行 nexus.bat start 

+ 方式二

  直接启动 nexus 服务 

  ![1536500419782](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500419782.png)

  

##### 登录

+ 访问: http://localhost:8081/nexus/ 

  > 查看 nexus 的配置文件 conf/nexus.properties ,里面有端口号

![1536500498947](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500498947.png)

+ 点击右上角的 Log in，输入账号和密码 登陆 (账号admin,密码admin123 )

![1536500542616](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500542616.png)

+ 登录成功

![1536500555932](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500555932.png)

#####  仓库类型 

![1536500594312](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500594312.png)

nexus 的仓库有 4 种类型： 

![1536500615935](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500615935.png)

1. hosted，宿主仓库， 部署自己的 jar 到这个类型的仓库，包括 releases 和 snapshot 两部
   分， Releases 公司内部发布版本仓库、 Snapshots 公司内部测试版本仓库
2. proxy，代理仓库， 用于代理远程的公共仓库，如 maven 中央仓库，用户连接私服，私
   服自动去中央仓库下载 jar 包或者插件。
3. group，仓库组，用来合并多个 hosted/proxy 仓库，通常我们配置自己的 maven 连接仓
   库组。
4. virtual(虚拟)：兼容 Maven1 版本的 jar 或者插件 

###  小结

1. 对着文档搭建一下就OK

2. 安装的时候需要以`管理员` 身份
3. 路径不要有中文



##  Maven私服的使用

###  目标

- [ ] 了解Maven私服的使用

###  路径

1. 将项目发布到私服 
2. 从私服下载 jar 包 

### 讲解

####  将项目发布到私服 

##### 需求

​	企业中多个团队协作开发通常会将一些公用的组件、开发模块等发布到私服供其它团队或模块开发人员使用。
​	本例子假设多团队分别开发 .  某个团队开发完在common_utils, 将 common_utils发布到私服供 其它团队使用.

#####  配置

​	第一步： 需要在客户端即部署common_utils工程的电脑上配置 maven环境，并修改 settings.xml文件(Maven配置文件)， 配置连接私服的用户和密码 。此用户名和密码用于私服校验，因为私服需要知道上传的账号和密码是否和私服中的账号和密码一致 (配置到<servers>标签下)

```xml
<server>
    <id>releases</id>
    <username>admin</username>
    <password>admin123</password>
</server>
<server>
    <id>snapshots</id>
    <username>admin</username>
    <password>admin123</password>
</server>
```

releases: 连接发布版本项目仓库
snapshots: 连接测试版本项目仓库 

![1536500938592](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536500938592.png)

​	

​	第二步： 在需要发布配置项目 pom.xml . 配置私服仓库的地址，本公司的自己的 jar 包会上传到私服的宿主仓库，根据工程的版本号决定上传到哪个宿主仓库，如果版本为 release 则上传到私服的 release 仓库，如果版本为snapshot 则上传到私服的 snapshot 仓库 .

```xml
<distributionManagement>
    <repository>
        <id>releases</id>
        <url>http://localhost:8081/nexus/content/repositories/releases/</url>
    </repository>
    <snapshotRepository>
        <id>snapshots</id>
        <url>http://localhost:8081/nexus/content/repositories/snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```

+ 注意： pom.xml 这里<id> 和 settings.xml 配置 <id> 对应！ 

#####  测试

1、 首先启动 nexus
2、 对 common_utils工程执行 deploy 命令 

​	根据本项目pom.xml中version定义决定发布到哪个仓库，如果version定义为snapshot，执行 deploy后查看 nexus 的 snapshot仓库， 如果 version定义为 release则项目将发布到 nexus的 release 仓库，本项目将发布到 snapshot 仓库： 

![image-20191222211914094](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191222211914094.png)

####  从私服下载 jar 包 

#####  需求

​	没有配置 nexus 之前，如果本地仓库没有，去中央仓库下载，通常在企业中会在局域网内部署一台私服服务器， 有了私服本地项目首先去本地仓库找 jar，如果没有找到则连接私服从私服下载 jar 包，如果私服没有 jar 包私服同时作为代理服务器从中央仓库下载 jar 包，这样做的好处是一方面由私服对公司项目的依赖 jar 包统一管理，一方面提高下载速度， 项目连接私服下载 jar 包的速度要比项目连接中央仓库的速度快的多。 

本例子测试从私服下载 commons-utils工程 jar 包。 

##### 在 settings.xml 中配置仓库 

​	在客户端的 settings.xml 中配置私服的仓库，由于 setting.xml 中没有 repositories 的配置标签需要使用 profile 定义仓库。(**配置在`<profiles>`标签下**)

```xml
<profile>
    <!--profile 的 id-->
    <id>dev</id>
    <repositories>
        <repository>
        <!--仓库 id， repositories 可以配置多个仓库，保证 id 不重复-->
        <id>nexus</id>
        <!--仓库地址，即 nexus 仓库组的地址-->
        <url>http://localhost:8081/nexus/content/groups/public/</url>
        <!--是否下载 releases 构件-->
        <releases>
            <enabled>true</enabled>
        </releases>
        <!--是否下载 snapshots 构件-->
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
    </repository>
    </repositories>
    <pluginRepositories>
        <!-- 插件仓库， maven 的运行依赖插件，也需要从私服下载插件 -->
        <pluginRepository>
            <!-- 插件仓库的 id 不允许重复，如果重复后边配置会覆盖前边 -->
            <id>public</id>
            <name>Public Repositories</name>
            <url>http://localhost:8081/nexus/content/groups/public/</url>
        </pluginRepository>
    </pluginRepositories>
</profile>
```

使用 profile 定义仓库需要激活才可生效。 

```xml
<activeProfiles>
	<activeProfile>dev</activeProfile>
</activeProfiles>
```



##### 测试从私服下载 jar 包

+ 删掉本地仓库的day01_javase_02


+ 编译依赖day01_javase_02的工程

![image-20191222212314528](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191222212314528.png) 

+ 出现如下日志

![image-20191222212255624](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191222212255624.png)

###  小结

1. 对着文档操作

 

##  把第三方 jar 包放入本地仓库和私服 

### 目标

- [ ] 掌握把第三方 jar 包放入本地仓库和私服 

### 路径

1. 导入本地库 
2. 导入私服 
3. 参数说明 

###  讲解

####  导入本地库(掌握) 

+ 随便找一个 jar 包测试， 可以先 CMD进入到 jar 包所在位置，运行

```
mvn install:install-file -DgroupId=com.jwang -DartifactId=nbutil -Dversion=1.1.37 -Dfile=nbutil-1.1.37.jar -Dpackaging=jar
```

![1536502172637](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536502172637.png)

![1536502183383](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536502183383.png)

####  导入私服 

需要在 maven 软件的核心配置文件 settings.xml 中配置第三方仓库的 server 信息 

```xml
<server>
    <id>thirdparty</id>
    <username>admin</username>
    <password>admin123</password>
</server>
```

才能执行一下命令 

```
mvn deploy:deploy-file -DgroupId=com.jwang -DartifactId=nbutil -Dversion=1.1.37 -Dpackaging=jar -Dfile=nbutil-1.1.37.jar -Durl=http://localhost:8081/nexus/content/repositories/thirdparty/ -DrepositoryId=thirdparty
```

![1536502272558](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536502272558.png)

![1536502293709](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/1536502293709.png)

####  参数说明 

DgroupId 和 DartifactId 构成了该 jar 包在 pom.xml 的坐标，项目就是依靠这两个属性定位。自己起名字也行。

Dfile 表示需要上传的 jar 包的绝对路径。

Durl 私服上仓库的位置，打开 nexus——>repositories 菜单，可以看到该路径。

DrepositoryId 服务器的表示 id，在 nexus 的 configuration 可以看到。

Dversion 表示版本信息。

关于 jar 包准确的版本：

​	包的名字上一般会带版本号，如果没有那可以解压该包，会发现一个叫 MANIFEST.MF 的文件 

​	这个文件就有描述该包的版本信息。

​	比如 Specification-Version: 2.2 可以知道该包的版本了。

​	上传成功后，在 nexus 界面点击 3rd party 仓库可以看到这包。 

###  小结

1. 有些jar中央仓库没有(eg:oracle驱动), 从官网/网络上下载下来, 安装到本地仓库. 我们的Maven项目就可以使用了
2. 具体操作参考文档



# 第七章 - LomboK

##  LomboK介绍和配置

###  目标

- [ ] 掌握LomboK的配置

###  路径

1. 什么是LomboK
2. LomboK的作用
3. LomboK的配置

###  讲解

####  什么是LomboK

​	 Lombok是一个Java库，能自动插入编辑器并构建工具，简化Java开发。

​	官网: https://www.projectlombok.org/ 

####  Lombok的作用

​	通过**添加注解**的方式，Lombok能以简单的注解形式来简化java代码，提高开发人员的开发效率。

​	例如开发中经常需要写的javabean，都需要花时间去添加相应的getter/setter，也许还要去写构造器、equals等方法，而且需要维护，当属性多时会出现大量的getter/setter方法，这些显得很冗长也没有太多技术含量，一旦修改属性，就容易出现忘记修改对应方法的失误,使代码看起来更简洁些。

####  Lombok的配置

+ 添加maven依赖

```xml
<dependency>
	<groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
	<version>1.18.8</version>
	<scope>provided</scope>
</dependency>
```



+ 安装插件

  ​	使用Lombok还需要插件的配合，我使用开发工具为idea. 打开idea的设置，点击Plugins，点击Browse repositories，在弹出的窗口中搜索lombok，然后安装即可

  ![image-20191121092349714](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191121092349714.png) 

+ 解决编译时出错问题

  ​	编译时出错，可能是没有enable注解处理器。Annotation Processors > Enable annotation processing。设置完成之后程序正常运行。

  ![image-20191121092543928](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/maven/img/image-20191121092543928.png)

###  小结

1. Lombox: 就是一个工具, 简化java代码开发
2. Lombok环境
   + 添加坐标
   + 添加插件



##  Lombok的常用注解

###  目标

- [ ] 掌握Lombox的常用注解

###  路径

1. @Data
2. @Getter/@Setter
3. @ToString
4. @NoArgsConstructor, @AllArgsConstructor

###  讲解

####  @Data

​	 @Data注解在类上，会为类的所有属性自动生成setter/getter、equals、canEqual、hashCode、toString方法，如为final属性，则不会为该属性生成setter方法。 

```java
@Data
public class User implements Serializable{
    private Integer id;
    private String username;
    private String password;
    private String address;
    private String nickname;
    private String gender;
    private String email;
    private String status;
}

```

####  @Getter/@Setter

​	 如果觉得@Data太过残暴不够精细，可以使用@Getter/@Setter注解，此注解在属性上，可以为相应的属性自动生成Getter/Setter方法.

```java
public class User implements Serializable{
    @Setter
    @Getter
    private Integer id;
    private String username;
    private String password;
    private String address;
    private String nickname;
    private String gender;
    private String email;
    private String status;
}
```



####  @ToString

​	 类使用@ToString注解，Lombok会生成一个toString()方法，默认情况下，会输出类名、所有属性（会按照属性定义顺序），用逗号来分割。 通过exclude属性指定忽略字段不输出,

```
@ToString(exclude = {"id"}) 
public class User implements Serializable{
    private Integer id;
    private String username;
    private String password;
    private String address;
    private String nickname;
    private String gender;
    private String email;
    private String status;
}

```



####  @xxxConstructor

+ @NoArgsConstructor: 无参构造器 

```java
@NoArgsConstructor
public class User implements Serializable{
    private Integer id;
    private String username;
    private String password;
    private String address;
    private String nickname;
    private String gender;
    private String email;
    private String status;
}
```

+ @AllArgsConstructor: 全参构造器 

```java
@AllArgsConstructor
public class User implements Serializable{
    private Integer id;
    private String username;
    private String password;
    private String address;
    private String nickname;
    private String gender;
    private String email;
    private String status;
}
```

###  小结

####  注解

+ @Data 
  
  + 用在类上面的 , 生成set,get, toString, hashCode,canEqual、toString方法
+ @Getter
  
+ 用在字段, 生成get方法
  
+ @Setter

  + 用在字段, 生成set方法

    

+ @ToString

  + 用在类上面的   生成toString方法

+ @xxxConstructor
  
  + 用在类上面的 生成构造方法 (只能生成无参和全参的构造方法)

####   优缺点

**优点：**

1. 能通过注解的形式自动生成构造器、getter/setter、equals、hashcode、toString等方法，提高了一定的开发效率
2. 让代码变得简洁，不用过多的去关注相应的方法
3. 属性做修改时，也简化了维护为这些属性所生成的getter/setter方法等

**缺点：**

1. 不支持多种参数构造器的重载
