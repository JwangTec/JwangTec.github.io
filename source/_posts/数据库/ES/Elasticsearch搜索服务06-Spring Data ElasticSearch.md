---
title: Elasticsearch搜索服务06-Spring Data ElasticSearch
categories: 数据库
tags: [Spring Data ElasticSearch, ElasticSearch]
top: 60
abbrlink: 3747212493
date: 2021-10-13 14:13:16
password:
---


## Spring Data ElasticSearch简介

### 什么是Spring Data

​	Spring Data是一个用于简化数据库访问，并支持云服务的开源框架。其主要目标是使得对数据的访问变得方便快捷，并支持map-reduce框架和云计算数据服务。 Spring Data可以极大的简化JPA的写法，可以在几乎不用写实现的情况下，实现对数据的访问和操作。除了CRUD外，还包括如分页、排序等一些常用的功能。

<!--more-->

​	Spring Data的官网：[http://projects.spring.io/spring-data/](http://projects.spring.io/spring-data/)

​	Spring Data常用的功能模块如下：

![1552828591302](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/ES/ES1/img/1552828591302.png)

![1552828597851](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/ES/ES1/img/1552828597851.png)

### 什么是Spring Data ElasticSearch

​	Spring Data ElasticSearch 基于 spring data API 简化 elasticSearch操作，将原始操作elasticSearch的客户端JAVA API 进行封装 。Spring Data为Elasticsearch项目提供集成搜索引擎。Spring Data Elasticsearch POJO的关键功能区域为中心的模型与Elastichsearch交互文档和轻松地编写一个存储库数据访问层。官方网站：http://projects.spring.io/spring-data-elasticsearch/ 

Spring boot 集成spring data elasticsearch的方式来开发更加的方便和快捷

## Spring boot starter data elasticsearch入门

### 需求

需求: 保存Article

步骤:

1. 创建Maven工程(jar),在pom文件导入坐标
2. 创建pojo, 添加注解进行映射
3. 创建Dao接口继承ElasticsearchRepository
4. 创建配置文件进行配置springboot自动进行配置
5. 测试是否创建映射成功

### 代码实现

#### 创建Maven工程(jar)，导入坐标我们已经导入了

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-elasticsearch</artifactId>
</dependency>
```

#### 创建pojo, 添加注解

```java
/**
 * @Document：放置到类上
 *    indexName = "blog1"：表示索引的名称，（小写）
 *    type = "article"：表示类型
 * @Id：放置到字段id上
 *    表示该字段的值存放到索引库的_id字段上，表示主键
 * @Field：放置到字段上
 *    store = true：表示该字段的值存储到索引库
 *    index = true：表示该字段的值要建立索引用于搜索
 *    analyzer = "ik_smart"：建立索引的时候使用什么分词器
 *    searchAnalyzer = "ik_smart"：数据搜索的时候使用什么分词器（可以不写）
 *    type = FieldType.Text：存放字段的数据类型
 */
@Document(indexName = "blog03",type = "article")
public class Article implements Serializable {

    @Id
    private Long id;

    @Field(index = true,searchAnalyzer = "ik_smart",analyzer = "ik_smart",store = true,type = FieldType.Text)
    private String title;

    @Field(index = true,searchAnalyzer = "ik_smart",analyzer = "ik_smart",store = true,type = FieldType.Text)
    private String content;

    public Article() {
    }
    public Article(long id, String title, String content) {
        this.id = id;
        this.title = title;
        this.content = content;
    }


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    @Override
    public String toString() {
        return "Article{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", content='" + content + '\'' +
                '}';
    }
}
```

#### 创建Dao接口继承ElasticsearchRepository

```java
public interface ArticleDao  extends ElasticsearchRepository<Article,Long>{

}
```

#### springboot自动进行配置创建配置文件进行配置

![1584026701562](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/ES/ES1/img/1584026701562.png)



#### 测试

```java
@SpringBootTest
@RunWith(SpringRunner.class)
public class EsApplicationTest03 {
    @Autowired
    private ElasticsearchTemplate elasticsearchTemplate;

    @Autowired
    private ArticleDao dao;

    //创建索引
    //创建映射
    @Test
    public void createMapping() {
        elasticsearchTemplate.createIndex(Article.class);
        elasticsearchTemplate.putMapping(Article.class);
    }


}

```

## Spring Data ElasticSearch常见操作

### CRUD

#### 新增,

```java
//创建文档/更新文档
@Test
public void createDocument() {
    Article article = new Article(1L, "你的手机很好看", "您的手机真的很好看");
    dao.save(article);
}

//批量创建文档
@Test
public void createDocumentS() {
    List<Article> articles = new ArrayList<Article>();
    for (long i = 0; i < 100; i++) {
        Article article = new Article(i, "你的手机很好看" + i, "您的手机真的很好看" + i);
        articles.add(article);
    }
    dao.saveAll(articles);
}
```

#### 删除

```java
//删除文档
@Test
public void DeleteDocument() {
    dao.deleteById(1L);
}
```

####  更新;  没有id对应的数据,就是新增; 有当前id对应的数据,就是更新

```java
//创建文档/更新文档
@Test
public void createDocument() {
    Article article = new Article(1L, "你的手机很好看", "您的手机真的很好看");
    dao.save(article);
}
```

#### 根据id查询

```java
//根据ID查询
@Test
public void selectById() {
    Article article = dao.findById(1L).get();
    System.out.println(article);
}
```

#### 查询所有

```java
//查询所有文档
@Test
public void SelectDocument() {
    Iterable<Article> all = dao.findAll();
    for (Article article : all) {
        System.out.println(article);
    }
}
```

#### 排序查询

```java
    @Test
    //排序
    public void fun07(){
        Iterable<Article> iterable = articleDao.findAll( Sort.by(Sort.Order.asc("id")));
        for (Article article : iterable) {
            System.out.println(article);
        }
    }
```

#### 分页查询

```java
@Test
public void selectAndPageSort() {
    //设置分页条件
    //参数1 当前页码 0 为第一页
    //参数2 每页显示的行
    //参数3 指定排序的条件    参数3.1 指定要排序的类型  参数3.2 指定要排序的字段
    Pageable pageable = PageRequest.of(0, 2, new Sort(Sort.Direction.ASC, "id"));
    Page<Article> articles = dao.findAll(pageable);
    System.out.println("总记录数:" + articles.getTotalElements());
    System.out.println("总页数:" + articles.getTotalPages());
    //获取当前页的集合
    List<Article> content = articles.getContent();
    for (Article article : content) {
        System.out.println(article);
    }

}
```

### 自定义查询

#### 常用查询命名规则

| **关键字**       | **命名规则**              | **解释**              | **示例**                |
| ------------- | --------------------- | ------------------- | --------------------- |
| and           | findByField1AndField2 | 根据Field1和Field2获得数据 | findByTitleAndContent |
| or            | findByField1OrField2  | 根据Field1或Field2获得数据 | findByTitleOrContent  |
| is            | findByField           | 根据Field获得数据         | findByTitle           |
| not           | findByFieldNot        | 根据Field获得补集数据       | findByTitleNot        |
| between       | findByFieldBetween    | 获得指定范围的数据           | findByPriceBetween    |
| lessThanEqual | findByFieldLessThan   | 获得小于等于指定值的数据        | findByPriceLessThan   |

#### 测试

```java
public interface ArticleDao  extends ElasticsearchRepository<Article,Long>{

    //根据title模糊查询
    List<Article> findByTitleLike(String title);

    //根据title模糊查询,根据id降序
    List<Article> findByTitleLikeOrderByIdAsc(String title);

    //模块查询,排序加分页
    Page<Article> findByTitleLikeOrderByIdAsc(String title,Pageable pageable);

}
```



