---
title: Spring03-AOP运用及JdbcTemplate和Spring事务
categories: Java框架
tags:
  - Java框架
  - Spring
  - AOP运用 - Spring事务 - JdbcTemplate
top: 11
abbrlink: 3027323732
date: 2019-07-01 18:18:19
password:
---


# 第一章-Spring中的AOP

##  基于XML的AOP配置 

<!--more-->

需求: 在service的增删改查方法调用之前进行权限的校验

- 导入坐标

```xml
<dependencies>
    <!--Spring核心容器-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--SpringAOP相关的坐标-->
    <dependency>
        <groupId>org.aspectj</groupId>
        <artifactId>aspectjweaver</artifactId>
        <version>1.8.7</version>
    </dependency>

    <!--Spring整合单元测试-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-test</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--单元测试-->
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

- 导入约束

  ```java
  <?xml version="1.0" encoding="UTF-8"?>
  <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:aop="http://www.springframework.org/schema/aop"
         xsi:schemaLocation="http://www.springframework.org/schema/beans
         http://www.springframework.org/schema/beans/spring-beans.xsd
         http://www.springframework.org/schema/aop
         http://www.springframework.org/schema/aop/spring-aop.xsd">
  </beans>
  ```

- 定义被增强的业务逻辑类和切面类(增强的)

  ```java
  package com.jwang.service.impl;
  
  import com.jwang.service.UserService;
  import org.springframework.stereotype.Service;
  
  /**
   * 包名:com.jwang.service.impl
   *
   * @author Leevi
   * 日期2020-11-12  08:35
   * 目标1: 在执行service的所有方法之前加入权限校验
   * 目标2: 在执行完所有的方法之后都获取方法的返回值，并且进行日志打印 "方法执行完毕...，返回值为:", 如果方法出现异常，则不会执行后置通知
   * 目标3: 在执行所有方法出现异常之后,将异常信息写入到本地文件中
   * 目标4: 在执行所有方法之后，无论是否出现异常，均执行 "资源回收的操作......"
   * 目标5: 在执行query()方法的过程中，统计执行时间
   *       环绕通知还能修改切入点方法的返回值
   */
  @Service
  public class UserServiceImpl implements UserService {
      @Override
      public void add() {
          System.out.println("执行添加...");
          int number = 10/0;
      }
  
      @Override
      public void deleteById(int id) {
          //删除了id为
          System.out.println("执行删除..."+id);
      }
  
      @Override
      public void update() {
          System.out.println("执行修改...");
      }
  
      @Override
      public String query() {
          try {
              Thread.sleep(3000);
              System.out.println("执行查询...");
              return "张三";
          } catch (InterruptedException e) {
              e.printStackTrace();
              throw new RuntimeException(e.getMessage());
          }
      }
  }
  
  ```
  
  
  ```java
  package com.jwang.aspect;
  
  import org.aspectj.lang.ProceedingJoinPoint;
  import org.springframework.stereotype.Component;
  
  /**
   * 包名:com.jwang.aspect
   * @author Leevi
   * 日期2020-11-12  08:37
   */
    @Component
    public class MyAspect {
      public void checkPermission(){
          System.out.println("进行权限校验....");
      }
  
      public void printResult(String returnValue){
          //1. 获取被增强方法的返回值,就是returnValue
          //2. 打印
          System.out.println("执行完毕，方法的返回值为:"+returnValue);
      }
  
      public void printError(Throwable errorMsg){
          errorMsg.printStackTrace();
          //使用流将字符串(异常信息)，写入到本地磁盘文件中
          System.out.println("使用FileOutputStream将" + errorMsg.getStackTrace() + "写入到磁盘...");
      }
  
      public void close(){
          System.out.println("执行资源回收的操作...");
      }
  
      public Object totalTime(ProceedingJoinPoint joinPoint){
          try {
              //1. 获取当前时间
              long startTime = System.currentTimeMillis();
              //2. 执行切入点
              Object obj = joinPoint.proceed();
              //3. 获取执行完切入点之后的时间
              long endTime = System.currentTimeMillis();
              System.out.println("方法的总执行时间是:" + (endTime - startTime));
              return "hello:"+obj;
          } catch (Throwable throwable) {
              throwable.printStackTrace();
              throw new RuntimeException(throwable.getMessage());
          }
      }
    }
  ```
  
  
  
- spring-aop.xml配置文件中进行aop配置

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:context="http://www.springframework.org/schema/context"
         xmlns:aop="http://www.springframework.org/schema/aop"
         xsi:schemaLocation="http://www.springframework.org/schema/beans
         http://www.springframework.org/schema/beans/spring-beans.xsd
         http://www.springframework.org/schema/context
         http://www.springframework.org/schema/context/spring-context.xsd
         http://www.springframework.org/schema/aop
         http://www.springframework.org/schema/aop/spring-aop.xsd">
      <!--1. 包扫描-->
      <!--将UserServiceImpl、MyAspect进行IOC-->
      <context:component-scan base-package="com.jwang"/>
  
      <!--
          进行aop配置
              目标1: 在执行增删改查方法之前，都加入权限校验
                    1. 切入点是: UserServiceImpl中的所有方法
                    2. 通知是: MyAspect中的checkPermission方法
                    3. 通知的类型是: 前置通知
                    4. 切面是: MyAspect类的对象
             目标2: 在执行完所有的方法之后都获取方法的返回值，并且进行日志打印 "方法执行完毕...，返回值为:"
                   1. 切入点是: UserServiceImpl中的所有方法
                   2. 通知是: MyAspect中的printResult方法
                   3. 通知的类型是: 后置通知
                   4. 切面是: MyAspect类的对象
             目标3: 在执行所有方法出现异常之后,将异常信息写入到本地文件中
                   1. 切入点是: UserServiceImpl中的所有方法
                   2. 通知是: MyAspect中的printError方法
                   3. 通知的类型是: 异常通知
                   4. 切面是: MyAspect类的对象
             目标4: 在执行所有方法之后，无论是否出现异常，均执行 "资源回收的操作......"
                  1.切入点是: UserServiceImpl中的所有方法
                  2. 通知是:  MyAspect中的close方法
                  3. 通知的类型是: 最终通知
                  4. 切面是: MyAspect类的对象
             目标5: 在执行query()方法的过程中，统计执行时间
                  1. 切入点是: UserServiceImpl中的query方法
                  2. 通知是:  MyAspect中的totalTime方法
                  3. 通知的类型是: 环绕通知
                  4. 切面是: MyAspect类的对象
      -->
      <aop:config>
          <!--
              expression是切入点表达式，它的作用是用一个表达式描述切入点
          -->
          <aop:pointcut id="pt1" expression="execution(* com.jwang.service.impl.UserServiceImpl.*(..))"/>
  
          <aop:pointcut id="pt2" expression="execution(String com.jwang.service.impl.UserServiceImpl.query())"/>
  
          <!--
              配置一个切面
          -->
          <aop:aspect id="ap1" ref="myAspect">
              <!--
                  配置通知去增强切入点
              -->
              <aop:before method="checkPermission" pointcut-ref="pt1"></aop:before>
              <!--
                  配置后置通知, 后置通知有一个特殊的属性returning用于指定将切入点的返回值赋值给通知中的哪个参数
              -->
              <aop:after-returning returning="returnValue" method="printResult" pointcut-ref="pt1"></aop:after-returning>
  
              <!--
                  配置异常通知
              -->
              <aop:after-throwing throwing="errorMsg" method="printError" pointcut-ref="pt1"></aop:after-throwing>
  
              <!--
                  配置最终通知
              -->
              <aop:after method="close" pointcut-ref="pt1"></aop:after>
              <!--
                  配置环绕通知
              -->
              <aop:around method="totalTime" pointcut-ref="pt2"></aop:around>
          </aop:aspect>
      </aop:config>
  </beans>
  ```

  

##  基于注解的AOP配置


###   步骤

1. 创建工程, 导入坐标
2. 创建Dao和增强的类, 注册
3. 开启AOP的注解支持
4. 在增强类上面添加@Aspect
5. 在增强类的增强方法上面添加
   + @Before()
   + @AfterReturning()
   + @Around()
   + @AfterThrowing()
   + @After()




+ 添加坐标

```xml
<dependencies>
    <!--Spring核心容器-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--SpringAOP相关的坐标-->
    <dependency>
        <groupId>org.aspectj</groupId>
        <artifactId>aspectjweaver</artifactId>
        <version>1.8.7</version>
    </dependency>

    <!--Spring整合单元测试-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-test</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--单元测试-->
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

- 定义被增强的业务逻辑类

  ```java
  package com.jwang.service.impl;
  
  import com.jwang.service.UserService;
  import org.springframework.stereotype.Service;
  
  /**
   * 包名:com.jwang.service.impl
   * @author Leevi
   * 日期2020-09-23  08:34
   * 目标1: 在执行所有方法之前，先进行权限校验
   *      切入点: UserServiceImpl类的所有方法
   *      前置通知: checkPermission()方法
   *      切面: MyAspect
   * 目标2: 在执行完所有方法之后，进行日志打印 "方法执行完毕...", 如果方法出现异常，则不会执行后置通知
   *      切入点：UserServiceImpl类的所有方法
   *      后置通知: printLog()方法
   *      切面: MyAspect
   * 目标3: 在执行所有方法出现异常之后,输出"方法出现异常，请稍后再试"
   *      切入点: UserServiceImpl类的所有方法
   *      异常通知: printException()
   *      切面: MyAspect
   * 目标4: 在执行所有方法之后，无论是否出现异常，均执行 "hello world...."
   *      切入点: UserServiceImpl类的所有方法
   *      最终通知: printHello()
   *      切面: MyAspect
   * 目标5: 在执行query()方法的过程中，统计执行时间
   *      切入点: query()方法
   *      环绕通知: total()
   *      切面: MyAspect
   */
  @Service
  public class UserServiceImpl implements UserService{
      @Override
      public void add() {
          System.out.println("执行添加...");
          int num = 10/0;
      }
  
      @Override
      public void delete() {
          System.out.println("执行删除...");
      }
  
      @Override
      public void update() {
          System.out.println("执行修改...");
      }
  
      @Override
      public void query() {
          try {
              Thread.sleep(3000);
              System.out.println("执行查询...");
          } catch (InterruptedException e) {
              e.printStackTrace();
          }
      }
  }
  ```


- 定义切面类,在切面增强类上面使用注解 @Aspect并且在切面类中定义切入点方法

  ```java
  package com.jwang.aspect;
  
  import org.aspectj.lang.ProceedingJoinPoint;
  import org.aspectj.lang.annotation.*;
  import org.springframework.stereotype.Component;
  
  /**
   * 包名:com.jwang.aspect
   * @author Leevi
   * 日期2020-09-23  08:36
   * 注解AOP配置:
   * 1. 给切面加上Aspect注解
   * 2. 在切面中，创建方法，配置切入点
   *    Pointcut注解
   * 3. 配置各种通知
   *    Before
   *    AfterReturning
   *    AfterThrowing
   *    After
   *    Around
   */
  @Component
  @Aspect
  public class MyAspect {
      @Pointcut("execution(* com.jwang.service.impl.UserServiceImpl.*(..))")
      public void pt1(){
      }
      @Pointcut("execution(void com.jwang.service.impl.UserServiceImpl.query())")
      public void pt2(){
      }
  
      @Before("pt1()")
      public void checkPermission(){
          System.out.println("进行权限校验....");
      }
  
      @AfterReturning("pt1()")
      public void printLog(){
          System.out.println("方法执行完毕.....");
      }
      @AfterThrowing("pt1()")
      public void printException(){
          System.out.println("方法出现异常，请稍后再试...");
      }
      @After("pt1()")
      public void printHello(){
          System.out.println("hello world");
      }
  
      @Around("pt2()")
      public void total(ProceedingJoinPoint joinPoint){
          //1. 获取开始时间
          long startMillis = System.currentTimeMillis();
          //2. 执行切入点的方法
          try {
              joinPoint.proceed();
          } catch (Throwable throwable) {
              throwable.printStackTrace();
          }
          //3. 获取结束时间
          long endMillis = System.currentTimeMillis();
          //4. 计算执行时间并打印
          System.out.println(endMillis - startMillis);
      }
  }
  ```
  
- 创建配置文件

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:context="http://www.springframework.org/schema/context"
         xmlns:aop="http://www.springframework.org/schema/aop"
         xsi:schemaLocation="http://www.springframework.org/schema/beans
          http://www.springframework.org/schema/beans/spring-beans.xsd
          http://www.springframework.org/schema/context
          http://www.springframework.org/schema/context/spring-context.xsd
          http://www.springframework.org/schema/aop
          http://www.springframework.org/schema/aop/spring-aop.xsd">
      <!--
          1. 包扫描
      -->
      <context:component-scan base-package="com.jwang"/>
  
  
      <!--
          要使用注解方式配置AOP：开启注解AOP的驱动
      -->
      <aop:aspectj-autoproxy />
  </beans>
  ```

# 第二章 - Spring中的JdbcTemplate  



##  JdbcTemplate介绍

​	Spring除了IOC 和 AOP之外，还对Dao层的提供了支持。 就算没有框架，也对原生的JDBC提供了支持。它是spring框架中提供的一个对象，是对原始Jdbc API对象的简单封装。spring框架为我们提供了很多的操作模板类。

|   持久化技术   |                   模版类                    |
| :-------: | :--------------------------------------: |
|   JDBC    | org.springframework.jdbc.core.JdbcTemplate |
| Hibrenate | org.springframework.orm.hibernate5.HibernateTemplate |
|  MyBatis  |  org.mybatis.spring.SqlSessionTemplate   |

## JDBC模版入门案例

+ 创建Maven工程,导入坐标

```xml
<dependencies>
    <!--Spring核心容器-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--SpringJdbc-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-jdbc</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>

    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.6</version>
    </dependency>
    <!--Spring整合单元测试-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-test</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--单元测试-->
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
        <scope>test</scope>
    </dependency>

    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.12</version>
    </dependency>

    <!--druid连接池-->
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>druid</artifactId>
        <version>1.1.18</version>
    </dependency>
</dependencies>
```

+ Account


```mysql
package com.jwang.pojo;

import lombok.Data;

/**
 * 包名:com.jwang.pojo
 *
 * @author Leevi
 * 日期2020-08-09  14:55
 */
@Data
public class Account {
    private String name;
    private Integer id;
    private Double money;
}
```

+ 使用JDBC模版API

```java
//使用JDBC模版保存
public void save(Account account) {
    //1. 创建数据源
    DriverManagerDataSource dataSource = new DriverManagerDataSource();
    dataSource.setDriverClassName("com.mysql.jdbc.Driver");
    dataSource.setUrl("jdbc:mysql://localhost:3306/spring_day03");
    dataSource.setUsername("root");
    dataSource.setPassword("123456");

    //2. 创建JDBC模版
    JdbcTemplate jdbcTemplate = new JdbcTemplate();
    jdbcTemplate.setDataSource(dataSource);

    //3.操作数据库
    String sql = "insert into account values(?,?,?)";
    jdbcTemplate.update(sql, null,account.getName(),account.getMoney())

}	
```

## 使用JDBC模版完成CRUD

1. 增加

   ```java
   String sql = "insert into account values(?,?,?)";
   jdbcTemplate.update(sql, null,account.getName(),account.getMoney());
   ```

2. 修改

   ```java
   String sql ="update account set name = ? where id = ?";
   Object[] objects = {user.getName(), user.getId()};
   jdbcTemplate.update(sql,objects);
   ```

3. 删除

   ```java
   String sql = "delete from account where id=?";
   jdbcTemplate.update(sql, 6);
   ```

4. 查询单个值

   ```java
   String sql = "select count(*) from account";
   Long n = jdbcTemplate.queryForObject(sql, Long.class);
   ```

   ```java
   String sql = "select name from account where id=?";
   String name = jdbcTemplate.queryForObject(sql, String.class, 4);
   System.out.println(name);
   ```

5. 查询单个对象

   ```java
   String sql = "select * from account where id = ?";
   User user = jdbcTemplate.queryForObject(sql,new BeanPropertyRowMapper<>(Account.class),id);
   ```

6. 查询集合

   ```java
   String sql = "select * from account";
   List<Account> list = List<User> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(Account.class));
   ```


##  在dao中使用JdbcTemplate



### 方式一

​	这种方式我们采取在dao中定义JdbcTemplate

+ AccountDaoImpl.java


```java
public class AccountDaoImpl implements AccountDao {
	@Autowired
	private JdbcTemplate jdbcTemplate;

	@Override
	public Account findAccountById(Integer id) {
		List<Account> list =  jdbcTemplate.query("select * from account where id = ? ",new AccountRowMapper(),id);
		return list.isEmpty()?null:list.get(0);
	}

	@Override
	public Account findAccountByName(String name) {
		List<Account> list =  jdbcTemplate.query("select * from account where name = ? ",new AccountRowMapper(),name);
		if(list.isEmpty()){
			return null;
		}
		if(list.size()>1){
			throw new RuntimeException("结果集不唯一，不是只有一个账户对象");
		}
		return list.get(0);
	}

	@Override
	public void updateAccount(Account account) {
		jdbcTemplate.update("update account set money = ? where id = ? ",account.getMoney(),account.getId());
	}

}
```

+ applicationContext.xml

```xml
	<!-- 配置一个dao -->
	<bean id="accountDao" class="com.jwang.dao.impl.AccountDaoImpl">
		<!-- 注入jdbcTemplate -->
		<property name="jdbcTemplate" ref="jdbcTemplate"></property>
	</bean>
	
	<!-- 配置一个数据库的操作模板：JdbcTemplate -->
	<bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
		<property name="dataSource" ref="dataSource"></property>
	</bean>
	
	<!-- 配置数据源 -->
	<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
		<property name="driverClassName" value="com.mysql.jdbc.Driver"></property>
		<property name="url" value="jdbc:mysql:///spring_day04"></property>
		<property name="username" value="root"></property>
		<property name="password" value="123456"></property>
	</bean>
```

### 方式二

​	这种方式我们采取让dao继承JdbcDaoSupport

+ AccountDaoImpl.java

```java
public class AccountDaoImpl extends JdbcDaoSupport implements AccountDao {

	@Override
	public Account findAccountById(Integer id) {
		//getJdbcTemplate()方法是从父类上继承下来的。
		List<Account> list = getJdbcTemplate().query("select * from account where id = ? ",new AccountRowMapper(),id);
		return list.isEmpty()?null:list.get(0);
	}

	@Override
	public Account findAccountByName(String name) {
		//getJdbcTemplate()方法是从父类上继承下来的。
		List<Account> list =  getJdbcTemplate().query("select * from account where name = ? ",new AccountRowMapper(),name);
		if(list.isEmpty()){
			return null;
		}
		if(list.size()>1){
			throw new RuntimeException("结果集不唯一，不是只有一个账户对象");
		}
		return list.get(0);
	}

	@Override
	public void updateAccount(Account account) {
		//getJdbcTemplate()方法是从父类上继承下来的。
		getJdbcTemplate().update("update account set money = ? where id = ? ",account.getMoney(),account.getId());
	}
}
```

+ applicationContext.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    	xsi:schemaLocation="http://www.springframework.org/schema/beans 
    	http://www.springframework.org/schema/beans/spring-beans.xsd">
	
<!-- 配置dao2 -->
<bean id="accountDao" class="com.jwang.dao.impl.AccountDaoImpl">
	<!-- 注入dataSource -->
	<property name="dataSource" ref="dataSource"></property>
</bean>
<!-- 配置数据源 -->
<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
	<property name="driverClassName" value="com.mysql.jdbc.Driver"></property>
	<property name="url" value="jdbc:mysql:///spring_day04"></property>
		<property name="username" value="root"></property>
		<property name="password" value="123456"></property>
	</bean>
</beans>
```



# 第三章-Spring配置第三方连接池

##  Spring配置第三方连接池


### Spring配置C3P0连接池

官网:http://www.mchange.com/projects/c3p0/	

步骤:

1. 导入c3p0的坐标
2. 注册连接池(修改DataSource的class以及四个基本项)



实现:

+ 导入坐标 


```xml
  <dependency>
    	<groupId>c3p0</groupId>
    	<artifactId>c3p0</artifactId>
    	<version>0.9.1.2</version>
  </dependency>
```

+ 配置数据源连接池

```
 <!-- 配置C3P0数据库连接池 -->
 <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
	<property name="jdbcUrl" value="jdbc:mysql:///spring_jdbc" />
	<property name="driverClass" value="com.mysql.jdbc.Driver" />
	<property name="user" value="root" />
	<property name="password" value="123456" />
 </bean>
 <!-- 管理JDBC模版 -->
 <bean id="jdbcTemplete" class="org.springframework.jdbc.core.JdbcTemplate">
	<property name="dataSource" ref="dataSource" />
 </bean>
```

> 核心类：`com.mchange.v2.c3p0.ComboPooledDataSource

### Spring配置Druid连接池

官网:http://druid.io/

步骤:

1. 导入Druid坐标
2. 修改DataSource的class(四个基本项)

实现:

- 导入坐标

  ```xml
  <dependency>
      <groupId>com.alibaba</groupId>
      <artifactId>druid</artifactId>
      <version>1.0.9</version>
  </dependency>
  ```

- 配置数据源连接池


```xml
<!--注册dataSource -->
<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
    <property name="driverClassName" value="com.mysql.jdbc.Driver"></property>
    <property name="url" value="jdbc:mysql://localhost:3306/spring_day03"></property>
    <property name="username" value="root"></property>
    <property name="password" value="123456"></property>
</bean>
```


### Spring配置HikariCP连接池 

官网:https://github.com/brettwooldridge/HikariCP

步骤: 

1. 添加HikariCP坐标
2. 修改DataSource的class(四个基本项)

实现: 

+ 导入HikariCP坐标

  ```xml
  <dependency>
     <groupId>com.zaxxer</groupId>
     <artifactId>HikariCP</artifactId>
     <version>3.1.0</version>
  </dependency>
  ```

+ 配置数据源连接池

  ```xml
   <!-- 配置HikariCP数据库连接池 -->
  <bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource">
  	<property name="jdbcUrl" value="jdbc:mysql:///spring_jdbc" />
  	<property name="driverClassName" value="com.mysql.jdbc.Driver" />
  	<property name="username" value="root" />
  	<property name="password" value="123456" />
  </bean>
  ```

  >  核心类：`com.zaxxer.hikari.HikariDataSource`


   + 为什么HikariCP为什么越来越火?   
      + 效率高
      + 一直在维护  
      + SpringBoot2.0 现在已经把HikariCP作为默认的连接池了
      
+ 为什么HikariCP被号称为性能最好的Java数据库连接池?  

  + 优化并精简字节码: HikariCP利用了一个第三方的Java字节码修改类库Javassist来生成委托实现动态代理  

  + 优化代理和拦截器：减少代码，代码量越少。一般意味着运行效率越高、发生bug的可能性越低.




​    ![1540557295765](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Spring/s3/img/1540557295765.png)

* 自定义集合类型ConcurrentBag：ConcurrentBag的实现借鉴于C#中的同名类，是一个专门为连接池设计的lock-less集合，实现了比LinkedBlockingQueue、LinkedTransferQueue更好的并发性能。ConcurrentBag内部同时使用了ThreadLocal和CopyOnWriteArrayList来存储元素，其中CopyOnWriteArrayList是线程共享的。ConcurrentBag采用了queue-stealing的机制获取元素：首先尝试从ThreadLocal中获取属于当前线程的元素来避免锁竞争，如果没有可用元素则再次从共享的CopyOnWriteArrayList中获取。此外，ThreadLocal和CopyOnWriteArrayList在ConcurrentBag中都是成员变量，线程间不共享，避免了伪共享(false sharing)的发生。

  + 使用FastList替代ArrayList: FastList是一个List接口的精简实现，只实现了接口中必要的几个方法。JDK ArrayList每次调用get()方法时都会进行rangeCheck检查索引是否越界，FastList的实现中去除了这一检查，只要保证索引合法那么rangeCheck就成为了不必要的计算开销(当然开销极小)。

    
    
  
## 知识点-Spring引入Properties配置文件 


### jdbc.properties

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/spring_day03
jdbc.username=root
jdbc.password=123456
```

###  引入外部properties文件

* 引入配置文件方式一(不推荐使用)

```xml
 <!-- 引入properties配置文件：方式一 (繁琐不推荐使用) -->
<bean id="properties" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer"> 
	<property name="location" value="classpath:jdbc.properties" />
</bean>
```

* 引入配置文件方式二【推荐使用】

```xml
 <!-- 引入properties配置文件：方式二 (简单推荐使用) -->
<context:property-placeholder location="classpath:jdbc.properties" />
```

**classpath表示的是类路径，对于配置文件而言也就是那个resources根目录**

* bean标签中引用配置文件内容
```xml
 <!-- hikariCP 连接池 -->
<bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource">
	<property name="jdbcUrl" value="${jdbc.url}" />
	<property name="driverClassName" value="${jdbc.driver}" />
	<property name="username" value="${jdbc.username}" />
	<property name="password" value="${jdbc.password}" />
</bean>
```

> 注意:在使用`<context:property-placeholder/>`标签时，properties配置文件中的key一定要是带点分隔的。例如`jdbc.url`





# 第四章-Spring管理事务   

## 知识点-Spring管理事务概述 


​	由于Spring对持久层的很多框架都有支持 ， Hibernate 、 jdbc 、JdbcTemplate , MyBatis ，由于使用的框架不同，所以使用事务管理操作API 也不尽相同。 为了规范这些操作， Spring统一定义一个事务的规范 ，这其实是一个接口 。这个接口的名称 ： PlatformTrasactionManager.并且它对已经做好的框架都有支持.

​	如果dao层使用的是JDBC,  JdbcTemplate 或者mybatis,那么 可以使用DataSourceTransactionManager 来处理事务

​	如果dao层使用的是 Hibernate, 那么可以使用HibernateTransactionManager 来处理事务

## 相关的API

###  PlatformTransactionManager 

​	平台事务管理器是一个接口，实现类就是Spring真正管理事务的对象。

​	常用的实现类:

​		**DataSourceTransactionManager**   :JDBC开发的时候(JDBCTemplate,MyBatis)，使用事务管理。

​		HibernateTransactionManager :Hibernate开发的时候，使用事务管理。

###  TransactionDefinition 

​	事务定义信息中定义了事务的隔离级别，传播行为，超时信息，只读。

###  TransactionStatus:事务的状态信息

​	事务状态信息中定义事务是否是新事务，是否有保存点。


## 知识点-编程式(通过代码)(硬编码)事务


+ 添加依赖

```xml
<dependencies>
    <!--依赖-->
    <!--1. spring的核心依赖-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--2. spring-jdbc的依赖-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-jdbc</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--3. spring-test-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-test</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--10. aop的依赖-->
    <dependency>
        <groupId>org.aspectj</groupId>
        <artifactId>aspectjweaver</artifactId>
        <version>1.8.7</version>
    </dependency>
    <!--4. mysql-->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.6</version>
    </dependency>
    <!--5. mybatis-->
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis</artifactId>
        <version>3.5.3</version>
    </dependency>
    <!--6. mybatis-spring-->
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis-spring</artifactId>
        <version>1.3.0</version>
    </dependency>
    <!--7. Junit的依赖-->
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
        <scope>test</scope>
    </dependency>
    <!--8. lombok的依赖-->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.10</version>
    </dependency>
    <!--9. 日志的依赖-->
    <!-- log start -->
    <dependency>
        <groupId>log4j</groupId>
        <artifactId>log4j</artifactId>
        <version>1.2.12</version>
    </dependency>

    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>1.6.6</version>
    </dependency>

    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-log4j12</artifactId>
        <version>1.6.6</version>
    </dependency>
    <!-- log end -->
</dependencies>
```

+ 代码

```java
package com.jwang.service.impl;

import com.jwang.dao.AccountDao;
import com.jwang.pojo.Account;
import com.jwang.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;

/**
 * 包名:com.jwang.service.impl
 * @author Leevi
 * 日期2020-08-12  10:57
 * 持久层不同的框架有不同的事务控制方案:
 * 1. 原始的JDBC:
 *    1.1 开启事务: connection.setAutoCommit(false);
 *    1.2 提交事务: connection.commit();
 *    1.3 回滚事务: connection.rollback();
 *
 * 2. DBUtils框架: 和原始的JDBC是一样的
 * 3. mybatis框架: 底层也是使用的JDBC的事务
 *    3.1 开启事务: sqlSessionFactory.openSession(); 开启事务
 *    3.2 提交事务: sqlSession.commit();
 *    3.3 回滚事务: sqlSession.rollback();
 * 4. 只要某个持久层框架和spring整合了，那么事务相关的操作就都交给spring控制
 *    4.1 编程式事务(了解)
 *    4.2 声明式事务(重点掌握)
 */
@Service
public class AccountServiceImpl implements AccountService{
    @Autowired
    private AccountDao accountDao;
    @Autowired
    private DataSource dataSource;
    @Override
    public void transfer(String fromName, String toName, double money) {
        //创建事务管理者
        DataSourceTransactionManager transactionManager = new DataSourceTransactionManager();
        transactionManager.setDataSource(dataSource);
        //创建事务模板
        TransactionTemplate transactionTemplate = new TransactionTemplate();

        //给事务模板配置事务管理者
        transactionTemplate.setTransactionManager(transactionManager);
        transactionTemplate.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                //1. 转出账户扣款
                accountDao.updateAccount(new Account(null,fromName,-money));

                //出现异常
                int num = 10/0;

                //2. 转入账户收款
                accountDao.updateAccount(new Account(null,toName,money));
                return null;
            }
        });

    }
}
```


##  Spring声明式事务-xml配置方式 

Spring的声明式事务的作用是: 无论spring集成什么dao框架，事务代码都不需要我们再编写了

声明式的事务管理的思想就是AOP的思想。面向切面的方式完成事务的管理。声明式事务有两种,**xml配置方式和注解方式.**


```xml
<dependencies>
    <!--依赖-->
    <!--1. spring的核心依赖-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--2. spring-jdbc的依赖-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-jdbc</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--3. spring-test-->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-test</artifactId>
        <version>5.0.2.RELEASE</version>
    </dependency>
    <!--10. aop的依赖-->
    <dependency>
        <groupId>org.aspectj</groupId>
        <artifactId>aspectjweaver</artifactId>
        <version>1.8.7</version>
    </dependency>
    <!--4. mysql-->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.6</version>
    </dependency>
    <!--5. mybatis-->
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis</artifactId>
        <version>3.5.3</version>
    </dependency>
    <!--6. mybatis-spring-->
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis-spring</artifactId>
        <version>1.3.0</version>
    </dependency>
    <!--7. Junit的依赖-->
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
        <scope>test</scope>
    </dependency>
    <!--8. lombok的依赖-->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.10</version>
    </dependency>
    <!--9. 日志的依赖-->
    <!-- log start -->
    <dependency>
        <groupId>log4j</groupId>
        <artifactId>log4j</artifactId>
        <version>1.2.12</version>
    </dependency>

    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>1.6.6</version>
    </dependency>

    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-log4j12</artifactId>
        <version>1.6.6</version>
    </dependency>
    <!-- log end -->
</dependencies>
```

+ 配置事务管理器

  ```xml
  <bean id="transactionManager" 		class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
  		<property name="dataSource" ref="dataSource"></property>
  </bean>
  ```

+ 配置事务建议(事务的规则)

  ```xml
  <!--配置事务规则-->
  <tx:advice id="transferAdvice" transaction-manager="transactionManager">
      <!--配置事务的属性-->
      <tx:attributes>
          <!--
                  哪个方法需要使用什么样的事务配置
                      rollback-for="java.lang.Exception" 什么时候回滚:遇到所有的Exception都会回滚
                      no-rollback-for="java.lang.NullPointerException" 什么时候不回滚:遇到NullPointerException不回滚
                      timeout="-1" 事务的超时时间，默认不超时
                      read-only="false" 是否是只读事务,默认不是只读事务,只读事务只会针对于查询方法，如果是增删改一定不能设置为只读
                      isolation="" 事务的隔离级别: 目的是为了防止不同事务之间相互影响
                          1. Read Uncommitted  读取到未提交的事务，在这种隔离级别下，可能发生脏读、不可重复读、幻读
                          2. Read Committed(Oracle的默认隔离级别) 读取到已提交的事务，在这种隔离级别下，不可能发生脏读，但是可能发生不可重复读和幻读
                          3. Repeatable Read（mysql的默认隔离级别） 可重复读，在这种隔离级别下不会发生脏读、不可重复读，但是有可能发生幻读
                          4. Serializable 串行化的，在这种隔离级别下不会发生脏读、不可重复读、幻读
  
                      propagation="" 事务的传播行为
                              - PROPAGATION_REQUIRED:默认值，也是最常用的场景.
                                如果当前没有事务，就新建一个事务，
                                如果已经存在一个事务中，加入到这个事务中。
  
                              - PROPAGATION_SUPPORTS：
                                如果当前没有事务，就以非事务方式执行。
                                如果已经存在一个事务中，加入到这个事务中。
  
                              - PROPAGATION_MANDATORY
                                如果当前没有有事务，就抛出异常;
                                如果已经存在一个事务中，加入到这个事务中。
  
                              保证不在同一个事务里:
                              - PROPAGATION_REQUIRES_NEW
                                如果当前有事务，把当前事务挂起,创建新的事务但独自执行
  
                              - PROPAGATION_NOT_SUPPORTED
                                如果当前存在事务，就把当前事务挂起。不创建事务
  
                              - PROPAGATION_NEVER
                                如果当前存在事务，抛出异常
  
              -->
          <tx:method name="transfer"
                     rollback-for="java.lang.Exception"/>
      </tx:attributes>
  </tx:advice>
  ```
  
+ 配置事务的AOP

  ```xml
  <aop:config>
      <!--声明切入点-->
      <aop:pointcut id="pt1" expression="execution(* com.jwang.service.impl.AccountServiceImpl.transfer(..))"/>
      <!--绑定切入点和事务-->
      <aop:advisor advice-ref="transferAdvice" pointcut-ref="pt1"></aop:advisor>
  </aop:config>
  ```


### 事务的传播行为

#### 事务的传播行为的作用

​	我们一般都是将事务设置在Service层,那么当我们调用Service层的一个方法的时候, 它能够保证我们的这个方法中,执行的所有的对数据库的更新操作保持在一个事务中， 在事务层里面调用的这些方法要么全部成功，要么全部失败。

​	如果你的Service层的这个方法中，除了调用了Dao层的方法之外， 还调用了本类的其他的Service方法，那么在调用其他的Service方法的时候， 我必须保证两个service处在同一个事务中，确保事物的一致性。

​	 事务的传播特性就是解决这个问题的。

####  事务的传播行为的取值

保证在同一个事务里面:

- **PROPAGATION_REQUIRED:默认值，也是最常用的场景.**

  如果当前没有事务，就新建一个事务，
  如果已经存在一个事务中，加入到这个事务中。

- PROPAGATION_SUPPORTS：

  如果当前没有事务，就以非事务方式执行。

  如果已经存在一个事务中，加入到这个事务中。

- PROPAGATION_MANDATORY

  如果当前没有有事务，就抛出异常; 

  如果已经存在一个事务中，加入到这个事务中。

保证不在同一个事物里:

- **PROPAGATION_REQUIRES_NEW**

  如果当前有事务，把当前事务挂起,创建新的事务但独自执行

- PROPAGATION_NOT_SUPPORTED

  如果当前存在事务，就把当前事务挂起。不创建事务

- PROPAGATION_NEVER

  如果当前存在事务，抛出异常


##  spring声明式事务-注解方式 


+ 在applicationContext里面打开注解驱动

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
         xsi:schemaLocation="http://www.springframework.org/schema/beans
                             http://www.springframework.org/schema/beans/spring-beans.xsd
                             http://www.springframework.org/schema/aop
                             http://www.springframework.org/schema/aop/spring-aop.xsd
                             http://www.springframework.org/schema/tx
                             http://www.springframework.org/schema/tx/spring-tx.xsd">
      <import resource="classpath:application-mybatis.xml"></import>
      <!--配置申明式事务-->
      <!--
          注解方式配置声明式事务
              1. 配置事务管理者
              2. 加载事务注解驱动
              3. 在代码中使用Transactional注解来标注，哪个方法需要使用事务
      -->
      <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
          <property name="dataSource" ref="dataSource"></property>
      </bean>
      <tx:annotation-driven transaction-manager="transactionManager"/>
  </beans>
  ```

+ 在业务逻辑类上面使用注解

  @Transactional ： 如果在类上声明，那么标记着该类中的所有方法都使用事务管理。也可以作用于方法上，	那么这就表示只有具体的方法才会使用事务。








