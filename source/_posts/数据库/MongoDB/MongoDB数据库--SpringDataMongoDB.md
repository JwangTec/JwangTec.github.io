---
title: MongoDB数据库--SpringDataMongoDB
categories: 数据库
tags:
  - Spring Data API
  - MongoDB
top: 13
abbrlink: 2949536681
date: 2019-05-07 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/MongoDB.jpeg" width="1000" height="200" align="middle" />


##   开发准备

<!--more-->

​	SpringDataMongoDB是SpringData家族成员之一，用于操作MongoDb的持久层框架，封装了底层的==mongodb-driver==。本功能使用SpringDataMongoDB进行开发

步骤:

1. 创建maven项目

2. 添加SpringDataMongoDB起步依赖 

3. 在application.yml里面配置MongoDB

4. 创建pojo(和集合对应)

   1. @Document(collection="集合名称")
   2. @Id标记主键
   
5. 创建一个Dao接口继承MongoRepository


+ 添加依赖：

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.1.4.RELEASE</version>
    <relativePath/>
</parent>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-mongodb</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>
</dependencies>
```

+ 添加配置文件：

```yaml
spring:
  data:
    mongodb:
      host: 192.168.200.131
      port: 27017
      database: commentdb
```

+ 创建实体类

```java
@Document(collection = "comment")
public class Comment implements Serializable {
    @Id
    private String _id;
    private String articleid;
    private String content;
    private String userid;
    private String parentid;
    private Date publishdate;
    private Integer thumbup;
    private String username;
}
```

##   CRUD实现

###   新增

- CommentRepository

```java
public interface CommentRepository extends MongoRepository<Comment,String> {
}
```

+ CommentService

```java
@Service
public class CommentService {
    @Autowired
    private IdWorker idWorker;
    @Autowired
    private CommentRepository commentRepository;

    public void add(Comment comment) {
        String id = idWorker.nextId() + "";
        comment.set_id(id);
        //初始化数据
        comment.setPublishdate(new Date());
        comment.setThumbup(0);
        commentRepository.save(comment);
    }
}    

```

###  删除

业务: 

1. 主键删除

+ CommentService

```java
public void deleteById(String id) {
    commentRepository.deleteById(id);
}
```

###   修改

+ CommentService

```java
public void update(Comment comment) {
    commentRepository.save(comment);
}
```

这种方式的缺陷就是会覆盖原本的数据，应该只修改要修改的数据

```java
public void updateInfo(Comment comment){

    Query condition = new Query();
    condition.addCriteria(new Criteria("_id").is(comment.get_id()));

    Update update = new Update();
    update.set("content","66666666");
    mongoTemplate.updateFirst(condition,update,"comment");
}
```

###  查询所有

- CommentService

```java
public List<Comment> findAll() {
    return commentRepository.findAll();
}
```

###   根据id查询

- CommentService

```java
public Comment findById(String id) {
    return commentRepository.findById(id).get();
}
```

###   获取当前点赞数大于200并统计用户的总点赞数 


```java
public List<Map> findTotalThumbupByUserId(){
    TypedAggregation<Comment> commentTypedAggregation = Aggregation.newAggregation(Comment.class,
                                                                                   Aggregation.match(Criteria.where("thumbup").gt(200)),
                                                                                   Aggregation.group("userid").sum("thumbup").as("sum"));
    
    AggregationResults<Map> aggregate = mongoTemplate.aggregate(commentTypedAggregation, mongoTemplate.getCollectionName(Comment.class), Map.class);
    return aggregate.getMappedResults();
}
```

###   按照点赞数排序，查询前3条评论 

```java
@Data
public class PageResult<T> {

    private int current;

    private List<T> data;

    private int pages;
}
```

```java
public PageResult<Comment> findByPage(int current,int size){

    Sort sort = Sort.by(Sort.Direction.DESC,"thumbup");
    Query query = new Query();
    long total = mongoTemplate.count(query, Comment.class);
    int offset=(current-1)*size;

    List<Comment> list = mongoTemplate.find(query.with(sort).limit(size).skip(offset),
                                            Comment.class,
                                            mongoTemplate.getCollectionName(Comment.class));

    PageResult<Comment> pageResult = new PageResult<>();
    pageResult.setCurrent(current);
    pageResult.setData(list);
    pageResult.setPages((int)(total/size)+1);
    return pageResult;
}
```


