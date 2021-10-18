---
title: Elasticsearch搜索服务03-ES实际运用
categories: 数据库
tags:
	- ElasticSearch操作
	-  ElasticSearch
top: 60
abbrlink: 3823127571
date: 2021-10-13 14:13:16
password:
---


## 理解

操作ES就相当于对操作数据库，我们应该知道针对数据库我们有不同的CRUD功能，那么同样的道理，操作elasticsearch也能有CRUD功能，只不过叫法不一样。有两种方式:如下：

<!--more-->

+ 使用Elasticsearch提供的restfull风格的API实现操作ES （查看另外一个world文档）
+ 使用elasticsearch提供的java Client API来实现操作ES 又有许多方式，我们这里主要使用springboot集成spring data elasticsearch来实现
  + java API 使用官方提供的TransportClient(暂时演示使用官方)
  + java API 使用 REST clients
  + java api 使用  Jest
  + java api 使用 spring data elasticsearch（后续推荐使用）

## 搭建ElasticSearch操作环境 

### 创建springboot工程

创建一个springboot工程,注意添加springboot 的spring data elasticsearch的起步依赖，我们使用该起步依赖中的transport-elasticsearch的官方的API

###  pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.wang</groupId>
    <artifactId>wang-springboot-es</artifactId>
    <version>1.0-SNAPSHOT</version>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.4.RELEASE</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-elasticsearch</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

### 创建启动类和配置连接服务器地址

在com.wang下创建启动类：

```java
@SpringBootApplication
public class ESApplication {
    public static void main(String[] args) {
        SpringApplication.run(ESApplication.class, args);
    }
}
```



创建yml文件：

```yaml
server:
  port: 8080
spring:
  data:
    elasticsearch:
      cluster-nodes: 127.0.0.1:9300
      cluster-name: elasticsearch
```



##  操作ElasticSearch

###  新建索引+添加文档

使用创建索引+自动创建映射（Elasticsearch帮助我们自动建立映射，后续讲完分词器后，手动建立映射）

（1）创建POJO 用于存储数据转成JSON

```java
public class Article implements Serializable {
    private Long id;
    private String content;
    private String title;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }
}
```



（2）创建测试类并完成创建索引和添加文档（自动添加映射）com.wang下创建测试类 

```java
@SpringBootTest
@RunWith(SpringRunner.class)
public class EsApplicationTest01 {

    @Autowired
    private TransportClient transportClient;

    @Autowired
    private ObjectMapper objectMapper;

    //创建索引 并 添加文档  增加   //修改文档
    @Test
    public void createIndexAndDocument() throws Exception {
        //设置数据
        Article article = new Article();
        article.setTitle("华为手机很棒");
        article.setContent("华为手机真的很棒");
        article.setId(1L);

        IndexResponse indexResponse = transportClient
                .prepareIndex("blog01", "article", "1")
                .setSource(objectMapper.writeValueAsString(article), XContentType.JSON)
                .get();
        System.out.println(indexResponse);
    }
}
```

###  根据ID查询文档

```java
    //根据Id获取数据
    @Test
    public void getById() {
        GetResponse documentFields = transportClient.prepareGet("blog01", "article", "1").get();
        System.out.println(documentFields.getSourceAsString());
    }
```


###  根据ID删除文档

```java

//删除文档
@Test
public void deleteById() {
    transportClient.prepareDelete("blog01", "article", "1");
}

```


