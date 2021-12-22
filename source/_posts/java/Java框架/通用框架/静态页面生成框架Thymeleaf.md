---
title: 静态页面生成框架Thymeleaf
categories: Java通用框架
tags:
  - Java
  - Thymeleaf
top: 16
abbrlink: 2880107222
date: 2019-07-05 19:18:19
password:
---


## Thymeleaf介绍

它的特点便是：开箱即用，Thymeleaf允许您处理六种模板，每种模板称为模板模式：


<!--more-->

- XML
- 有效的XML
- XHTML
- 有效的XHTML
- HTML5
- 旧版HTML5

所有这些模式都指的是格式良好的XML文件，但*Legacy HTML5*模式除外，它允许您处理HTML5文件，其中包含独立（非关闭）标记，没有值的标记属性或不在引号之间写入的标记属性。为了在这种特定模式下处理文件，Thymeleaf将首先执行转换，将您的文件转换为格式良好的XML文件，这些文件仍然是完全有效的HTML5（实际上是创建HTML5代码的推荐方法）[1](https://www.thymeleaf.org/doc/tutorials/2.1/usingthymeleaf.html#fn1)。

另请注意，验证仅适用于XML和XHTML模板。

然而，这些并不是Thymeleaf可以处理的唯一模板类型，并且用户始终能够通过指定在此模式下*解析*模板的方法和*编写*结果的方式来定义他/她自己的模式。这样，任何可以建模为DOM树（无论是否为XML）的东西都可以被Thymeleaf有效地作为模板处理。



##  Springboot整合thymeleaf

使用springboot 来集成使用Thymeleaf可以大大减少单纯使用thymleaf的代码量，所以我们接下来使用springboot集成使用thymeleaf.

实现的步骤为：

+ 创建一个sprinboot项目
+ 添加thymeleaf的起步依赖
+ 添加spring web的起步依赖
+ 编写html 使用thymleaf的语法获取变量对应后台传递的值
+ 编写controller 设置变量的值到model中

(1)创建工程

创建一个独立的工程springboot-thymeleaf,该工程为案例工程，不需要放到jwang-parent工程中。

**pom.xml依赖**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.jwang</groupId>
    <artifactId>springboot-thymeleaf</artifactId>
    <version>1.0-SNAPSHOT</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.4.RELEASE</version>
    </parent>

    <dependencies>
        <!--web起步依赖-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!--thymeleaf配置-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
    </dependencies>
</project>
```



(2)创建html

在resources中创建templates目录，在templates目录创建 demo1.html,代码如下：

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Thymeleaf的入门</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>
<body>
<!--输出hello数据-->
<p th:text="${hello}"></p>
</body>
</html>

```

解释：`<html xmlns:th="http://www.thymeleaf.org">`:这句声明使用thymeleaf标签

`<p th:text="${hello}"></p>`:这句使用 `th:text="${变量名}"` 表示 使用thymeleaf获取文本数据，类似于EL表达式。



(3)修改application.yml配置

创建application.yml,并设置thymeleaf的缓存设置，设置为false。默认加缓存的，用于测试。

```yaml
spring:
  thymeleaf:
    cache: false
```

在这里，其实还有一些默认配置，比如视图前缀：classpath:/templates/,视图后缀：.html

`org.springframework.boot.autoconfigure.thymeleaf.ThymeleafProperties`部分源码如下：

![1564779051830](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1564779051830.png)



(4)控制层

创建controller用于测试后台 设置数据到model中。

创建com.jwang.controller.TestController，代码如下：

```java
@Controller
@RequestMapping("/test")
public class TestController {

    /***
     * 访问/test/hello  跳转到demo1页面
     * @param model
     * @return
     */
    @RequestMapping("/hello")
    public String hello(Model model){
        model.addAttribute("hello","hello welcome");
        return "demo1";
    }
}
```



(5)测试

创建启动类`com.jwang.ThymeleafApplication`，代码如下：

```java
@SpringBootApplication
public class ThymeleafApplication {

    public static void main(String[] args) {
        SpringApplication.run(ThymeleafApplication.class,args);
    }
}
```



启动系统，并在浏览器访问

```
http://localhost:8080/test/hello
```

![1560936996326](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1560936996326.png)



##  Thymeleaf基本语法

(1)th:href 后台代码

```properties
model.addAttribute("key1","value1");
model.addAttribute("url","/test/hello");
```

html:

```html
<a th:href="@{${url}(key1=${key1},key2=${key1})}">去网站首页</a>
```



(2)th:each 遍历，功能类似jstl中的`<c:forEach>`标签。 

创建com.jwang.model.User,代码如下：

```java
public class User {
    private Integer id;
    private String name;
    private String address;
    //..get..set
}
```



Controller添加数据,List输出

```java
/***
 * 访问/test/hello  跳转到demo1页面
 * @param model
 * @return
 */
@RequestMapping("/hello")
public String hello(Model model){
    model.addAttribute("hello","hello welcome");

    //集合数据
    List<User> users = new ArrayList<User>();
    users.add(new User(1,"张三","深圳"));
    users.add(new User(2,"李四","北京"));
    users.add(new User(3,"王五","武汉"));
    model.addAttribute("users",users);
    return "demo1";
}
```



页面输出

```html
<table>
    <tr>
        <td>id</td>
        <td>姓名</td>
        <td>地址</td>
        <td>下标</td>
    </tr>
    <tr th:each="abc,mystat:${users}">
        <td th:text="${abc.id}"></td>
        <td th:text="${abc.name}">zhangsan</td>
        <td th:text="${abc.address}">深圳</td>
        <td th:text="${mystat.index+1}">深圳</td>
    </tr>
</table>
```



测试效果

![1560941932553](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1560941932553.png)



(3)Map输出 后台添加Map

```java
//Map定义
Map<String,Object> dataMap = new HashMap<String,Object>();
dataMap.put("No","123");
dataMap.put("address","深圳");
model.addAttribute("dataMap",dataMap);
```



页面输出

```html
<div th:each="map,mapStat:${dataMap}">
    <div th:text="${map}"></div>
    key:<span th:text="${mapStat.current.key}"></span><br/>
    value:<span th:text="${mapStat.current.value}"></span><br/>   
</div>
```

或者：

```html
<div th:each="entry:${dataMap}">
    <div th:text="${entry}"></div>
    key:<span th:text="${entry.key}"></span><br/>
    value:<span th:text="${entry.value}"></span><br/>   
</div>
```

测试效果

![1560942024009](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1560942024009.png)

(4)数组输出 后台添加数组

```java
//存储一个数组
String[] names = {"张三","李四","王五"};
model.addAttribute("names",names);
```

页面输出

```html
<div th:each="nm,nmStat:${names}">
    <span th:text="${nmStat.count}"></span><span th:text="${nm}"></span>
    ==============================================
</div>
```



测试效果

![1560942589016](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1560942589016.png)

(5)Date输出

后台添加日期

```java
//日期
model.addAttribute("now",new Date());
```

页面输出

```php+HTML
<div>
    <span th:text="${#dates.format(now,'yyyy-MM-dd hh:ss:mm')}"></span>
</div>
```



测试效果

![1560942631925](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1560942631925.png)



(6)th:if条件  

```java
//if条件
model.addAttribute("age",22);
```

页面输出

```html
<div>
    <span th:if="${(age>=18)}">终于长大了！</span>
</div>
```



测试效果

![1560942782470](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1560942782470.png)



(7)使用javascript

![1566877170657](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1566877170657.png)

java代码为:

 ![1566877199124](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1566877199124.png)

(8) 字符拼接 使用||

后台代码:

![1566877232470](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1566877232470.png)

模板:

![1566877255084](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1566877255084.png)




##  canal监听生成静态页

![1605747848263](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1605747848263.png)



如上图详情页的解决方案. 监听到数据的变化,直接调用feign 生成静态页即可.



###  需求分析

当商品微服务审核商品之后，应当发送消息，这里采用了Canal监控数据变化，数据变化后，调用feign实现生成静态页



###  Feign创建

在jwang-service-api中创建jwang-web-item-api，该工程中主要创建jwang-web-item的对外依赖抽取信息。



(1)Feign创建

在jwang-web-item-api中创建com.jwang.item.feign.PageFeign,代码如下：

```java
@FeignClient(name="item")
@RequestMapping("/page")
public interface PageFeign {

    /***
     * 根据SpuID生成静态页
     * @param id
     * @return
     */
    @RequestMapping("/createHtml/{id}")
    Result createHtml(@PathVariable(name="id") Long id);
}
```



(2)pom.xml依赖

修改jwang-service-canal工程的pom.xml，引入如下依赖：

```xml
<!--静态页API 服务-->
<dependency>
    <groupId>com.jwang</groupId>
    <artifactId>jwang-web-item-api</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>
```



(3)修改jwang-service-canal工程中的启动类

![1566737648843](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1566737648843.png)

```java
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
@EnableEurekaClient
@EnableCanalClient // 启用canal
@EnableFeignClients(basePackages = {"com.jwang.content.feign","com.jwang.item.feign"})
public class CanalApplication {

    public static void main(String[] args) {
        SpringApplication.run(CanalApplication.class, args);
    }
}
```





###  canal监听数据变化

监听类中,监听商品数据库的tb_spu的数据变化,当数据变化的时候生成静态页或者删除静态页

在原来的监听类中添加如下代码即可,

```java
@Autowired
private PageFeign pageFeign;

@ListenPoint(destination = "example",
        schema = "jwang_goods",
        table = {"tb_spu"},
        eventType = {CanalEntry.EventType.UPDATE, CanalEntry.EventType.INSERT, CanalEntry.EventType.DELETE})
public void onEventCustomSpu(CanalEntry.EventType eventType, CanalEntry.RowData rowData) {

    //判断操作类型
    if (eventType == CanalEntry.EventType.DELETE) {
        String spuId = "";
        List<CanalEntry.Column> beforeColumnsList = rowData.getBeforeColumnsList();
        for (CanalEntry.Column column : beforeColumnsList) {
            if (column.getName().equals("id")) {
                spuId = column.getValue();//spuid
                break;
            }
        }
        //todo 删除静态页

    }else{
        //新增 或者 更新
        List<CanalEntry.Column> afterColumnsList = rowData.getAfterColumnsList();
        String spuId = "";
        for (CanalEntry.Column column : afterColumnsList) {
            if (column.getName().equals("id")) {
                spuId = column.getValue();
                break;
            }
        }
        //更新 生成静态页
        pageFeign.createHtml(Long.valueOf(spuId));
    }
}
```



整体的页面代码如下图所示已经实现：

 ![1609257105710](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/staticpage/images/1609257105710.png)