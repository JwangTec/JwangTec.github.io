---
title: Java重要框架01--mybatis概述
categories: Java框架
tags:
  - Java框架
  - mybatis
top: 11
abbrlink: 2012208407
date: 2019-07-01 18:18:19
password:
---



<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/mybatis.jpeg" width="1000" height="300" align="middle" />


#  MyBatis框架概述

<!--more-->

## jdbc 程序回顾

+ 注册驱动				    
+ 获得连接                            
+ 创建预编译sql语句对象    
+ 设置参数, 执行
+ 处理结果
+ 释放资源

```java
public static void main(String[] args) {
    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;
    try {
        //1.加载数据库驱动
        Class.forName("com.mysql.jdbc.Driver");
        //2.通过驱动管理类获取数据库链接
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/mybatis?characterEncoding=utf-8", "root", "123"); 
        //3.定义 sql 语句 ?表示占位符
        String sql = "select * from user where username = ?";
        //4.获取预处理 statement
        preparedStatement = connection.prepareStatement(sql);
        //5.设置参数，第一个参数为 sql 语句中参数的序号（从 1 开始），第二个参数为设置的参数值
        preparedStatement.setString(1, "王五");
        //6.向数据库发出 sql 执行查询，查询出结果集
        resultSet = preparedStatement.executeQuery();
        //7.遍历查询结果集
        while (resultSet.next()) {
            System.out.println(resultSet.getString("id") + "
                               "+resultSet.getString("username"));
                               }
                               } catch (Exception e) {
                                   e.printStackTrace();
                               } finally {
                                   //8.释放资源
                                   if (resultSet != null) {
                                       try {
                                           resultSet.close();
                                       } catch (SQLException e) {
                                           e.printStackTrace();
                                       }
                                   }
                                   if (preparedStatement != null) {
                                       try {
                                           preparedStatement.close();
                                       } catch (SQLException e) {
                                           e.printStackTrace();
                                       }
                                   }
                                   if (connection != null) {
                                       try {
                                           connection.close();
                                       } catch (SQLException e) {
                                           e.printStackTrace();
                                       }
                                   }
                               }
                           }
```

### jdbc 问题分析  

1. 数据库链接创建、释放频繁造成系统资源浪费从而影响系统性能，如果使用数据库链接池可解决此问题。
2. Sql 语句在代码中硬编码，造成代码不易维护，实际应用 sql 变化的可能较大， sql 变动需要改变java 代码。 
3. 使用 preparedStatement 向占有位符号传参数存在硬编码，因为 sql 语句的 where 条件不一定，可能多也可能少，修改 sql 还要修改代码，系统不易维护。
4. 对结果集解析存在硬编码（查询列名）， sql 变化导致解析代码变化，系统不易维护，如果能将数据库记录封装成 pojo 对象解析比较方便  

##  MyBatis框架 

1. MyBatis: 持久层的一个框架, 封装了JDBC. 操作数据库
2. 为什么要学习MyBatis?
   + JDBC和DBUtils都有一些很明显的缺点, JDBC和DBUtils不适合做项目
   + MyBatis是工作里面的主流的持久层框架, 使用几率特别大
   

# Mybatis入门


## 步骤


1. 创建maven工程(javase)

2. 引入依赖:mysql、mybatis、Junit、lombok
3. 创建POJO类、创建Dao接口
4. 创建Dao接口对应的映射配置文件
   1. 路径要在resources里面和Dao接口的路径一致，而且在resources目录中创建目录的时候要使用"/"而不是"."
   2. 映射配置文件的文件名要和对应的Dao接口的名字一致
5. 创建mybatis的核心配置文件
6. 编写mybatis的测试代码进行测试 





##  Mapper动态代理方式规范


### Mapper.xml(映射文件)

 1. 映射配置文件存储的路径在resources里面，要和对应的Dao接口的路径保持一致

 2. 映射配置文件的文件名必须和Dao接口名保持一致

 3. 一定要引入约束文件

 4. namespace属性的值和对应Dao接口的全限定名一致

 


```
每一个子标签，就对应Dao接口中的一个方法
查询方法就对应select标签
添加方法就对应insert标签
删除方法就对应delete标签
修改方法就对应update标签
    
标签的id就对应方法的名字
    
标签的parameterType就对应方法的参数类型
    
标签的resultType(只有select标签才有)就对应方法的返回值类型，如果返回值类型是List，那么
resultType就是List的泛型类型
    
标签体中的内容就是要执行的sql语句
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.jwang.dao.UserDao">
    <select id="findAll" resultType="User">
        SELECT *FROM t_user
    </select>
</mapper>
```

### Mapper.java(dao接口)

```java
public interface UserDao {

    /**
     * 查询所有的用户
     * @return
     */
    List<User> findAll();

}
```

### 规范

Mapper接口开发需要遵循以下规范： 

1. 存储路径建议和对应的Dao接口保持一致
2. 文件名建议和对应Dao接口的名字保持一致
3. 配置文件的根标签的namespace属性必须和对应的Dao接口的全限定名保持一致
4. 接口中的每一个方法，就对应映射配置文件中的一个标签:
   1. 查询方法，对应select标签
   2. 添加方法，对应insert标签
   3. 删除方法，对应delete标签
   4. 修改方法，对应update标签
5. 映射配置文件中的标签的id属性，就必须和对应的方法的方法名保持一致
6. 映射配置文件中的标签的parameterType属性，必须和对应的方法的参数类型(全限定名)保持一致
7. 映射配置文件中的标签的resultType属性，必须和对应的方法的返回值类型(全限定名)保持一致，但是如果返回值是List则和其泛型保持一致


## 核心配置文件详解


![image-20191226095424936](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/image-20191226095424936.png)  


### properties

- jdbc.properties

```properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/mybatis_day01?characterEncoding=utf-8
jdbc.user=root
jdbc.password=123
```

- 引入到核心配置文件

```xml
<configuration>
   <properties resource="jdbc.properties">
    </properties>
    <!--数据源配置-->
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="UNPOOLED">
                <property name="driver" value="${jdbc.driver}"/>
                <property name="url" value="${jdbc.url}"/>
                <property name="username" value="${jdbc.user}"/>
                <property name="password" value="${jdbc.password}"/>
            </dataSource>
        </environment>
    </environments>
    ....
</configuration>
```

### typeAliases（类型别名）

#### 定义单个别名

- 核心配置文件

```xml
<typeAliases>
      <typeAlias type="com.jwang.bean.User" alias="user"></typeAlias>
 </typeAliases>
```

- 修改UserDao.xml

```java
<select id="findAll" resultType="user">
    SELECT  * FROM  user
</select>
```

#### 批量定义别名

使用package定义的别名：就是pojo的类名，大小写都可以

- 核心配置文件

```xml
<typeAliases>
    <package name="com.jwang.bean"/>
</typeAliases>
```

- 修改UserDao.xml

```java
<select id="findAll" resultType="user">
         SELECT  * FROM  user
</select>
```

### Mapper

#### 方式一:引入映射文件路径

```xml
<mappers>
     <mapper resource="com/jwang/dao/UserDao.xml"/>
 </mappers>
```

#### 方式二:扫描接口

- 配置单个接口

```xml
<mappers>
 	<mapper class="com.jwang.dao.UserDao"></mapper>
</mappers>
```

- 批量配置

```xml
<mappers>
   <package name="com.jwang.dao"></package>
</mappers>
```




# MyBatis进阶

## 日志的使用 

- 导入坐标

```xml
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
```

- 拷贝log4j.properties到resources目录

```properties
log4j.rootLogger=DEBUG,stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
#[%-5p] %t %l %d %rms:%m%n
#%d{yyyy-MM-dd HH:mm:ss,SSS\} %-5p [%t] {%c}-%m%n
log4j.appender.stdout.layout.ConversionPattern=[%-5p] %t %l %d %rms:%m%n
log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.File=D:\\idea_project\\jwang_mm_backend.log
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss,SSS\} %-5p [%t] {%c}-%m%n
```

- 级别:error > warn > info>debug>trace  


## 使用Mybatis完成CRUD


### 新增用户

#### 实现步骤

- UserDao中添加新增方法 

```java
public interface UserDao {
    /**
     * 添加用户
     * @param user 要添加进数据库的数据
     * @return 受到影响的行数
     */
    int addUser(User user);
}
```

- 在 UserDao.xml 文件中加入新增配置 

```xml
    <insert id="addUser" parameterType="User">
        insert into t_user (username,sex,birthday,address) values (#{username},#{sex},#{birthday},#{address})
    </insert>

	<!--我们可以发现， 这个 sql 语句中使用#{}字符， #{}代表占位符，我们可以理解是原来 jdbc 部分所学的?，它们都是代表占位符， 具体的值是由 User 类的 username 属性来决定的。
	parameterType 属性：代表参数的类型，因为我们要传入的是一个类的对象，所以类型就写类的
全名称。-->
```

- 添加测试类中的测试方法 

```java
public class TestMybatis {

    private UserDao userDao;
    private SqlSession sqlSession;
    private InputStream is;

    @Before
    public void init() throws Exception {
        //1. 让mybatis框架去加载主配置文件
        //1.1 将主配置文件SqlMapConfig.xml转换成字节输入流
        is = Resources.getResourceAsStream("SqlMapConfig.xml");
        //1.2 创建一个SqlSessionFactoryBuilder
        SqlSessionFactoryBuilder factoryBuilder = new SqlSessionFactoryBuilder();
        //1.3 使用factoryBuilder对象加载字节输入流，创建SqlSessionFactory对象
        SqlSessionFactory sessionFactory = factoryBuilder.build(is); //使用了构建者模式
        //1.4 使用sessionFactory对象创建出sqlSession对象
        //使用了工厂模式
        sqlSession = sessionFactory.openSession();

        //2. 使用sqlSession对象创建出UserDao接口的代理对象
        //使用了动态代理
        userDao = sqlSession.getMapper(UserDao.class);
    }
    @Test
    public void testAddUser(){
        //3. 调用userDao对象的addUser方法添加用户
        User user = new User(null, "贾克斯", "召唤师峡谷", "女", new Date());
        //用户添加之前的id为null
        userDao.addUser(user);

        //目标是添加完用户之后，获取到该用户的id : 在以后的多表中，进行关联添加
        System.out.println(user.getUid());
    }
    @After
    public void destroy() throws IOException {
        //提交事务
        sqlSession.commit();

        //4. 关闭资源
        sqlSession.close();
        is.close();
    }
}
```

#### 新增用户 id 的返回值 

​	新增用户后， 同时还要返回当前新增用户的 id 值，因为 id 是由数据库的自动增长来实现的，所以就相当于我们要在新增后将自动增长 auto_increment 的值返回。 

- SelectKey获取主键

| **属性**    | **描述**                                                     |
| ----------- | ------------------------------------------------------------ |
| keyProperty | selectKey 语句结果应该被设置的目标属性。                     |
| resultType  | 结果的类型。MyBatis 通常可以算出来,但是写上也没有问题。MyBatis 允许任何简单类型用作主键的类型,包括字符串。 |
| order       | 这可以被设置为 BEFORE 或 AFTER。如果设置为 BEFORE,那么它会首先选择主键,设置 keyProperty 然后执行插入语句。如果设置为 AFTER,那么先执行插入语句,然后是 selectKey 元素-这和如  Oracle 数据库相似,可以在插入语句中嵌入序列调用。 |

- UserDao.xml

```xml
<!--
resultType只有select标签才有

我们需要在标签体的SQL语句中，获取pojo类型的参数的属性: #{属性名}


selectKey标签: 查询主键
    keyColumn 表示要查询的列名
    keyProperty 表示要赋值的属性名
    resultType 表示查询出来的结果的类型
    order 表示在前或者在后执行
select last_insert_id() 查询最后一个自增长的id的值
-->
<insert id="addUser" parameterType="User">
<selectKey resultType="int" order="AFTER" keyProperty="uid" keyColumn="uid">
    select last_insert_id()
</selectKey>
insert into t_user (username,sex,birthday,address) values (#{username},#{sex},#{birthday},#{address})
</insert>
```

### 根据id查询用户

* UserDao添加根据id查询方法

```
User findById(Integer id);
```

* UserDao.xml文件中新增配置

```xml
<select id="findById" parameterType="int" resultType="User">
    select * from t_user where uid=#{id}
</select>
```

### 修改用户

- UserDao中添加修改方法 

```java
public interface UserDao {
    /**
     * 更新用户
     * @param user
     */
    void  updateUser(User user);
}
```

- 在 UserDao.xml 文件中加入新增配置 

```xml
<update id="updateUser" parameterType="User">
    update t_user set username=#{username},sex=#{sex},address=#{address} where uid=#{uid}
</update>
```

- 添加测试类中的测试方法 

```java
@Test
public void testUpdate(){
    User user = userDao.findById(6);
    user.setUsername("aobama");
    user.setAddress("召唤师峡谷");

    userDao.updateUser(user);
}
```

#### 删除用户

- UserDao中添加新增方法 

```java
public interface UserDao {
    int deleteById(int id);
}
```

- 在 UserDao.xml 文件中加入新增配置 

```xml
<delete id="deleteById" parameterType="int">
    DELETE FROM t_user WHERE uid = #{id}
</delete>
```

- 添加测试类中的测试方法 

```java
@Test
public void testDeleteById(){
    //根据id删除用户
    userDao.deleteById(1);
}
```

### 模糊查询

#### 方式一（工作中不会采用这种做法）

- UserDao 中添加新增方法 

```java
public interface UserDao {
    /**
     * 模糊查询
     * @param name
     * @return
     */
    List<User> searchByUsername(String name);
}
```

- 在 UserDao.xml 文件中加入新增配置 

```xml
<select id="searchByUsername" parameterType="string" resultType="User">
  	SELECT * FROM t_user WHERE username LIKE #{name}
</select>
```

- 添加测试类中的测试方法 

```java
@Test
public void testSearch(){
    List<User> userList = userDao.searchByUsername("%a%");
    for (User user : userList) {
        System.out.println(user);
    }
}
```

####  方式二

- UserDao 中添加新增方法 

```java
public interface UserDao {
    /**
     * 根据用户名进行模糊查询
     * @param username
     * @return
     */
    List<User> searchByUsername(String username);
}
```

- 在 UserMapper.xml 文件中加入新增配置 

```xml
<!--
    模糊查询
    另外一种在SQL语句中引用方法的参数的方式：${}
        1. 引用pojo中的属性: '${属性名}'
        2. 引用简单类型的参数: '${value}'，但是高版本的mybatis中可以'${任意字符串}'
-->
<select id="searchByUsername" parameterType="string" resultType="User">
    <!--select * from t_user where username like "%"#{username}"%"-->
    <!--select * from t_user where username like concat("%",#{username},"%")-->

    select * from t_user where username like '%${value}%'
</select>
```

​` 我们在上面将原来的#{}占位符，改成了${value}。注意如果用模糊查询的这种写法，那么${value}的写法就是固定的，不能写成其它名字。` 

- 添加测试类中的测试方法 

```java
@Test
public void testSearch(){
    List<User> userList = userDao.searchByUsername("a");
    for (User user : userList) {
        System.out.println(user);
    }
}
```

#### `#{}与${}`的区别 

1. `#{}`一定不能写在引号里面，`${}`一定要写在引号里面
2. 如果是pojo、map类型的参数，无论是`#{}`还是`${}`里面都是些属性名
3. 如果是简单类型的参数，`#{}`里面可以写任意字符串，但是`${}`里面只能写value(以前的版本)
4. 如果使用`#{}`引入参数的话，其实是先使用?占位符，然后再设置参数；而使用`${}`引入参数的话，是直接拼接SQL语句

### SqlSessionFactory工具类的抽取

**步骤:**

1. 创建SqlSessionFactoryUtils
2. 定义一个getSqlSession()方法获得sqlSession
3. 定义释放资源方法
4. 保证SqlSessionFactory只有一个(静态代码块)

**实现**

```java

/**
 * 1. 类加载的时候就创建出来了一个SqlSessionFactory对象
 * 2. 我们得声明一个方法，用于创建SqlSession对象,因为每次执行SQL语句的sqlSession对象不能是同一个
 */
public class SqlSessionFactoryUtil {
    private static SqlSessionFactory sqlSessionFactory;
    static {
        try {
            //1 将主配置文件SqlMapConfig.xml转换成字节输入流
            InputStream is = Resources.getResourceAsStream("SqlMapConfig.xml");
            //2 创建一个SqlSessionFactoryBuilder
            SqlSessionFactoryBuilder factoryBuilder = new SqlSessionFactoryBuilder();
            //3 使用factoryBuilder对象加载字节输入流，创建SqlSessionFactory对象
            sqlSessionFactory = factoryBuilder.build(is); //使用了构建者模式

            is.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 创建SqlSession对象
     * @return
     */
    public static SqlSession openSqlSession(){
        return sqlSessionFactory.openSession();
    }

    /**
     * 提交事务并且关闭sqlSession
     * @param sqlSession
     */
    public static void commitAndClose(SqlSession sqlSession){
        sqlSession.commit();
        sqlSession.close();
    }

    /**
     * 回滚事务并且关闭sqlSession
     * @param sqlSession
     */
    public static void rollbackAndClose(SqlSession sqlSession){
        sqlSession.rollback();
        sqlSession.close();
    }
}
```


## parameterType深入


### 传递简单类型

单个参数，方法就以简单类型传入即可，那么在映射配置文件中的parameterType的值就是这个简单类型的别名;在SQL语句中引入简单类型的参数`#{任意字符串}`

```java
User findById(int id);
```

```xml
<select id="findById" parameterType="int" resultType="User">
    select * from t_user where uid=#{id}
</select>
```

### 传递 pojo 对象 或者 Map

1. 将多个参数封装到一个POJO中,那么在映射配置文件中parameterType的值就是这个POJO的全限定名或者别名; 在SQL语句中引入参数`#{POJO的属性名}`或者`${POJO的属性名}`
2. 将多个参数封装到一个Map中(要封装的参数没有对应的POJO),那么在映射配置文件中parameterType的值是map; 在SQL语句中引入参数`#{map的key}`或者`'${map的key}'`

```java
void addUser(User user);

void updateUser(Map map);
```

```xml
<insert id="addUser" parameterType="User">
    insert into t_user(username,sex,birthday,address) values (#{username},#{sex},#{birthday},#{address})
</insert>

<update id="updateUser" parameterType="map">
    update t_user set username=#{username},sex=#{sex} where uid=#{uid}
</update>
```

### 传递多个参数

- 使用Param注解指定参数名称

```java
User findByUsernameAndAddress(@Param("uname") String username, @Param("addr") String address);
```

```xml
<select id="findByUsernameAndAddress" resultType="User">
    select * from t_user where username=#{uname} and address=#{addr}
</select>
```



### 传递 pojo 包装对象类型 

- 开发中通过 pojo 传递查询条件 ，查询条件是综合的查询条件，不仅包括用户查询条件还包括其它的查询条件（比如将用户购买商品信息也作为查询条件），这时可以使用包装对象传递输入参数。Pojo 类中包含 pojo。京东查询的例子:

![1539830569011](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/1539830569011.png)

- 需求：根据用户id查询用户信息并进行分页，查询条件放到 QueryVo 的 user 属性中。 

- QueryVo  

```java
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Query 查询
 * Vo  ViewObject 视图对象
 * QueryVo 就是封装查询视图的数据
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class QueryVo {
    public QueryVo(Long currentPage, Integer pageSize, User queryCondition) {
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.queryCondition = queryCondition;
    }

    private Long currentPage;
    private Integer pageSize;
    /**
     * 查询条件
     */
    private User queryCondition;

    private Long offset;

    public Long getOffset() {
        return (currentPage - 1)*pageSize;
    }
}
```

- UserDao接口 

```java
public interface UserDao {
    List<User> searchByCondition(QueryVo queryVo);
}
```

- UserDao.xml文件 

```xml
<select id="searchByCondition" parameterType="QueryVo" resultType="User">
    select * from t_user where sex=#{queryCondition.sex} and address=#{queryCondition.address}
    limit #{offset},#{pageSize}
</select>
```

- 测试代码

```java
@Test
public void test03(){
    SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
    UserDao mapper = sqlSession.getMapper(UserDao.class);

    User user = new User();
    user.setSex("男");
    user.setAddress("北京");

    QueryVo queryVo = new QueryVo(1l,5,user);
    List<User> userList = mapper.searchByCondition(queryVo);

    for (User user1 : userList) {
        System.out.println(user1);
    }

    SqlSessionFactoryUtil.commitAndClose(sqlSession);
}
```



##  resultType深入   


### 输出简单类型

查询的结果是单个数据, 映射配置文件中的resultType属性的值就是这个数据的类型

```java
/**
  * 查询用户的总个数
  * @return
  */
Long findTotal();
```

```xml
<select id="findTotal" resultType="long">
    select count(*) from t_user
</select>
```

### 输出pojo对象(一个pojo对象就对应一行数据)或者一个Map

查询的结果是一行数据:

* 将这一行数据存储到POJO对象中, 映射配置文件的resultType的值就是POJO的全限定名或者别名,此时就要求查询结果的字段名和类型        要和POJO的属性名和类型一致    
* 将这一行数据存储到Map对象,映射配置文件的resultType的值就是map，那么此时查询结果中的字段名就是        map的key，字段值就是map的value

```java
/**
  * 根据id查询一条数据
  * @param id
  * @return
  */
User findById(int id);

/**
  * 根据用户名查询用户
  * @param username
  * @return
  */
Map findByUsername(String username);
```

```xml
<select id="findById" parameterType="int" resultType="User">
    select * from t_user where uid=#{id}
</select>

<select id="findByUsername" parameterType="string" resultType="map">
    select * from t_user where username=#{username}
</select>
```

### 输出pojo列表(一个pojo列表就对应多行数据)或者Map的列表

查询的结果是多行数据:

* 将多条数据存储到List<POJO>中，映射配置文件的resultType的值就是POJO的别名 

* 将多条数据存储到List<Map>中，映射配置文件的resultType的值就是map

### resultMap结果类型 

- resultType可以指定pojo将查询结果映射为pojo，但需要pojo的属性名和sql查询的列名一致方可映射成功。如果sql查询字段名和pojo的属性名不一致，可以通过resultMap将字段名和属性名作一个对应关系 ，resultMap实质上还需要将查询结果映射到pojo对象中。resultMap可以实现将查询结果映射为复杂类型的pojo，比如在查询结果映射对象中包括pojo和list实现一对一查询和一对多查询。(下次课讲) 
- 返回的列名与实体类的属性不一致时的情况

* UserInfo.java

```java

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserInfo implements Serializable {
    private Integer userId;
    private String username;
    private String userSex;
    private String userBirthday;
    private String userAddress;
}

```

- UserDao.java

```java
public interface UserDao {
    /**
     * 查询所有用户信息，封装到UserInfo对象
     * @return
     */
    List<UserInfo> findAllUserInfo();
}
```

- UserDao.xml

```xml
<!--
        resultType属性会进行自动映射: 根据结果集的字段名和POJO的属性名的对应关系进行映射

        resultMap属性: 结果集映射(手动映射),我们要先使用resultMap标签编写一个手动映射规则，然后使用这个映射规则
    -->
<!--
        id就是这个映射规则的唯一标识
        type就是要进行手动映射的类型:UserInfo

        autoMapping="true" 表示能自动映射的就会进行自动映射，不能自动映射的属性，才进行手动映射
    -->
<resultMap id="userInfoMap" type="UserInfo" autoMapping="true">
    <!--
            id标签表示对主键进行映射
                column属性是要进行映射的主键的字段名(列名)
                property是要进行映射的POJO的属性名
        -->
    <id column="uid" property="userId"></id>
    <!--
            result标签就是对其它的非主键进行映射
        -->
    <result column="sex" property="userSex"></result>
    <result column="birthday" property="userBirthday"></result>
    <result column="address" property="userAddress"></result>
</resultMap>

<select id="findAllUserInfo" resultMap="userInfoMap">
    select * from t_user
</select>
```


# Mybatis 连接池与事务 

## Mybatis 的连接池技术【了解】


### Mybatis 连接池的分类 

+ 可以看出 Mybatis 将它自己的数据源分为三类：

  +  UNPOOLED 不使用连接池的数据源
  +  POOLED 使用连接池的数据源
  +  JNDI 使用 JNDI 实现的数据源,不要的服务器获得的DataSource是不一样的. 注意: 只有是web项目或者Maven的war工程, 才能使用. 我们用的是tomcat, 用的连接池是dbcp.

  ![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/tu_2-1572948297061.png)

+ 在这三种数据源中，我们目前阶段一般采用的是 POOLED 数据源（很多时候我们所说的数据源就是为了更好的管理数据库连接，也就是我们所说的连接池技术）,等后续学了Spring之后,会整合一些第三方连接池。 

### Mybatis 中数据源的配置 

+ 我们的数据源配置就是在 SqlMapConfig.xml 文件中， 具体配置如下： 

  ![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/tu_3-1572948297061.png)

+ MyBatis 在初始化时，解析此文件，根据<dataSource>的 type 属性来创建相应类型的的数据源DataSource，即：

  ​	type=”POOLED”： MyBatis 会创建 PooledDataSource 实例, 使用连接池
  ​	type=”UNPOOLED” ： MyBatis 会创建 UnpooledDataSource 实例, 没有使用的,只有一个连接对象的
  ​	type=”JNDI”： MyBatis 会从 JNDI 服务上查找 DataSource 实例，然后返回使用. 只有在web项目里面才有的,用的是服务器里面的.  默认会使用tomcat里面的dbcp

### Mybatis 中 DataSource 配置分析 

+ 代码,在21行加一个断点, 当代码执行到21行时候,我们根据不同的配置(POOLED和UNPOOLED)来分析DataSource

![1533783469075](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/1533783469075.png)

+ 当配置文件配置的是type=”POOLED”, 可以看到数据源连接信息

  ![1533783591235](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/1533783591235.png)



+ 当配置文件配置的是type=”UNPOOLED”, 没有使用连接池

  ![1533783672422](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/1533783672422.png)



##  Mybatis 的事务控制 【了解】


### JDBC 中事务

​	在 JDBC 中我们可以通过手动方式将事务的提交改为手动方式，通过 setAutoCommit()方法就可以调整。通过 JDK 文档，我们找到该方法如下： 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/tu_8-1572948297061.png)

​	那么我们的 Mybatis 框架因为是对 JDBC 的封装，所以 Mybatis 框架的事务控制方式，本身也是用 JDBC的 setAutoCommit()方法来设置事务提交方式的。 

### Mybatis 中事务提交方式 

+ Mybatis 中事务的提交方式，本质上就是调用 JDBC 的 setAutoCommit()来实现事务控制。我们运行之前所写的代码： 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/tu_9-1572948297061.png)

+ userDao 所调用的 saveUser()方法如下： 

  ![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/tu_10-1572948297061.png)

+ 观察在它在控制台输出的结果： 

  ![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/tu_11-1572948297061.png)

  ​	这是我们的 Connection 的整个变化过程， 通过分析我们能够发现之前的 CUD操作过程中，我们都要手动进行事务的提交，原因是 setAutoCommit()方法，在执行时它的值被设置为 false 了，所以我们在CUD 操作中，必须通过 sqlSession.commit()方法来执行提交操作。 

### Mybatis 自动提交事务的设置 

​	通过上面的研究和分析，现在我们一起思考，为什么 CUD 过程中必须使用 sqlSession.commit()提交事务？主要原因就是在连接池中取出的连接，都会将调用 connection.setAutoCommit(false)方法，这样我们就必须使用 sqlSession.commit()方法，相当于使用了 JDBC 中的 connection.commit()方法实现事务提交。明白这一点后，我们现在一起尝试不进行手动提交，一样实现 CUD 操作。 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/img/tu_12-1572948297062.png)

​	我们发现，此时事务就设置为自动提交了，同样可以实现 CUD 操作时记录的保存。虽然这也是一种方式，但就编程而言，设置为自动提交方式为 false 再根据情况决定是否进行提交，这种方式更常用。因为我们可以根据业务情况来决定提交是否进行提交。 


1. MyBatis的事务使用的是JDBC事务策略. 
   + 通过设置autoCommit()去控制的
   + 默认情况下, MyBatis使用的时候 就把autoCommit(false)
     + 也就是意味着, 我们要进行增删改的时候, 需要手动的commit
2. 后面做项目, 工作里面的事务管理, 基本上都是交给Spring管理. 所以此章节只做了解

#  Mybatis 映射文件的 SQL 深入【重点】 

​	
##  动态 SQL 之 if标签 


+ UserDao.java

```java
public interface UserDao {
   /**
     * 根据address查询用户,如果没有传入地址则查询出所有用户
     * @param address
     * @return
     */
    List<User> findUserListByAddress(@Param("address") String address);

    /**
     * 根据用户的地址和性别查询用户, 如果有address才考虑address的条件，如果有sex才考虑sex的条件
     * @param user
     * @return
     */
    List<User> findUserListByAddressAndSex(User user);
}
```

+ UserDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.jwang.dao.UserDao">
    <select id="findUserListByAddress" parameterType="string" resultType="User">
        select * from t_user
        <!--
            加入一个判断，判断传入的address是否为空,使用if标签进行判断,该标签中的test属性就编写判断条件
        -->
        <if test="address != null">
            where address=#{address}
        </if>
    </select>

    <select id="findUserListByAddressAndSex" parameterType="User" resultType="User">
        select * from t_user
        where 1=1
        <if test="address != null">
            and address=#{address}
        </if>

        <if test="sex != null">
            and sex=#{sex}
        </if>
    </select>
</mapper>
```

+ 测试

```java
@Test
public void test01(){
    SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
    UserDao mapper = sqlSession.getMapper(UserDao.class);

    List<User> userList = mapper.findUserListByAddress(null);

    for (User user : userList) {
        System.out.println(user);
    }

    SqlSessionFactoryUtil.commitAndClose(sqlSession);
}

@Test
public void test02(){
    SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
    UserDao mapper = sqlSession.getMapper(UserDao.class);

    User user = new User();
    user.setAddress("北京");
    user.setSex("男");
    mapper.findUserListByAddressAndSex(user);

    SqlSessionFactoryUtil.commitAndClose(sqlSession);
}
```

 

##  动态 SQL 之where标签 


- 修改 UserDao.xml 映射文件如下： 

> 注意: <where />可以自动处理第一个 and 

```xml
<select id="findUserListByAddressAndSex" parameterType="User" resultType="User">
    <include refid="select_all"/>

    <!--
            where标签的作用:
                1. 可以在条件之前添加where关键字
                2. 可以去掉第一个条件前的and
        -->
    <where>
        <if test="address != null">
            and address=#{address}
        </if>

        <if test="sex != null">
            and sex=#{sex}
        </if>
    </where>
</select>
```

1. where标签用在自己写sql语句的时候 where关键字不好处理的情况,代替where '1' = '1'
2. <where />可以**自动处理第一个 and , 建议全部加上and**

## 动态标签之foreach标签  

### LinkManDao代码

```java
/**
  * 批量删除
  * @param ids
  */
void deleteByIds(List<Integer> ids);
```

### LinkManDao映射配置文件

```xml
<delete id="deleteByIds" parameterType="int">
    delete from t_user

    <!--
            将传入的集合中的数据遍历出来，放到()里面
            使用foreach标签遍历
                collection属性:要遍历的集合，如果要遍历的是一个List则写成list
                item属性: 遍历出来的每一个元素
                separator属性: 遍历出来的每一个元素之间的分隔符
                index属性: 遍历出来的每一个元素的索引
                open属性: 在遍历出来的第一个元素之前拼接字符串
                close属性: 在遍历出来的最后一个元素之后拼接字符串
        -->
    <foreach collection="list" item="id" separator="," open="where uid in(" close=")">
        #{id}
    </foreach>

</delete>
```

### 测试代码

```java
@Test
public void test03(){
    SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
    UserDao mapper = sqlSession.getMapper(UserDao.class);
    List<Integer> ids = new ArrayList<>();

    ids.add(1);
    ids.add(2);
    ids.add(3);
    ids.add(4);

    mapper.deleteByIds(ids);

    SqlSessionFactoryUtil.commitAndClose(sqlSession);
}
```

## 动态标签之Sql片段 

- Sql 中可将重复的 sql 提取出来，使用时用 include 引用即可，最终达到 sql 重用的目的。我们先到 UserDao.xml 文件中使用<sql>标签，定义出公共部分.


+ 使用sql标签抽取

```xml
<!--
    使用sql标签将重复的sql语句部分封装起来

    在需要使用这个sql片段的地方，就用include标签引入就行了
 -->
<sql id="select_all">
    select uid,username,sex,address,birthday from t_user
</sql>
```

+ 使用include标签引入使用

```xml
<select id="findUserListByAddress" parameterType="string" resultType="User">
    <include refid="select_all"/>
    <!--
            加入一个判断，判断传入的address是否为空,使用if标签进行判断,该标签中的test属性就编写判断条件
        -->
    <if test="address != null">
        where address=#{address}
    </if>
</select>

<select id="findUserListByAddressAndSex" parameterType="User" resultType="User">
    <include refid="select_all"/>

    <!--
            where标签的作用:
                1. 可以在条件之前添加where关键字
                2. 可以去掉第一个条件前的and
        -->
    <where>
        <if test="address != null">
            and address=#{address}
        </if>

        <if test="sex != null">
            and sex=#{sex}
        </if>
    </where>
</select>
```

1. sql标签可以把公共的sql语句进行抽取, 再使用include标签引入. 好处:好维护, 提示效率

