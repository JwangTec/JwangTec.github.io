---
title: mybatis框架01--mybatis进阶应用
categories: Java_mybatis
tags:
  - Java
  - mybatis
top: 16
abbrlink: 1551825049
date: 2019-07-01 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/mybatis.jpeg" width="1000" height="300" align="middle" />


# MyBatis缓存 

<!--more-->

## MyBatis缓存类别

- 一级缓存：它是sqlSession对象的缓存，自带的(不需要配置)不可关闭的(不想使用还不行).  一级缓存的生命周期与sqlSession一致。

- 二级缓存：它是SqlSessionFactory的缓存。只要是同一个SqlSessionFactory创建的SqlSession就共享二级缓存的内容，并且可以操作二级缓存。二级缓存如果要使用的话，需要我们自己手动开启(需要配置的)。


##  一级缓存 


### 证明一级缓存的存在

```java
import com.jwang.dao.UserDao;
import com.jwang.pojo.User;
import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import java.util.List;

/**
 * mybatis框架以前的名字叫做ibatis
 */
public class TestMybatis {
    private UserDao userDao;
    private InputStream is;
    private SqlSession sqlSession;

    /**
     * 在执行单元测试方法之前要执行的方法
     */
    @Before
    public void init() throws IOException {
        //1. 创建SqlSessionFactoryBuilder对象
        SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
        //2. 读取核心配置文件，转换成字节输入流   底层使用了ClassLoader的getResourceAsStream()
        is = Resources.getResourceAsStream("SqlMapConfig.xml");
        //3. 创建SqlSessionFactory对象  底层使用了构造者模式
        SqlSessionFactory sessionFactory = sqlSessionFactoryBuilder.build(is);
        //4. 创建SqlSession对象 底层使用了工厂模式
        sqlSession = sessionFactory.openSession();
        //5. 创建UserDao的代理对象 底层使用了动态代理模式
        userDao = sqlSession.getMapper(UserDao.class);
    }
    @Test
    public void testFirstLevelCache(){
        //验证一级缓存
        List<User> userList = userDao.findAll();
        for (User user : userList) {
            System.out.println(user);
        }

        System.out.println("---------------------------------------------------");
        //使用同一个SqlSession对象，获取UserDao的代理对象，执行查询
        UserDao userDao2 = sqlSession.getMapper(UserDao.class);
        List<User> userList2 = userDao2.findAll();
        for (User user : userList2) {
            System.out.println(user);
        }
    }

    
    /**
     * 在执行测试方法之后执行
     */
    @After
    public void destroy() throws IOException {
        //关闭资源
        sqlSession.close();
        is.close();
    }
}
```

### 一级缓存分析

​	![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/2/img/tu_2-1572949193589.png)

- 第一次发起查询用户 id 为 1 的用户信息，先去找缓存中是否有 id 为 1 的用户信息，如果没有，从数据库查询用户信息。得到用户信息，将用户信息存储到一级缓存中。第二次发起查询用户 id 为 1 的用户信息，先去找缓存中是否有 id 为 1 的用户信息，缓存中有，直接从缓存中获取用户信息。 

- 如果 sqlSession 去执行 commit操作（执行插入、更新、删除），清空 SqlSession 中的一级缓存，这样做的目的为了让缓存中存储的是最新的信息，避免脏读。

### 测试一级缓存清空

+ 调用sqlSession的commit()或者clearCache()或者close()都能清除一级缓存
+ 更新数据也会清空一级缓存

```java
public class TestMybatis {
    @Test
    public void test01(){
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
        UserDao userDao = sqlSession.getMapper(UserDao.class);
        System.out.println(userDao.findAll());

        userDao.deleteById(26);
        System.out.println("--------------------------------------");

        System.out.println(userDao.findAll());

        sqlSession.commit();
    }
}
```


## -二级缓存


- 二级缓存是SqlSessionFactory的缓存。只要是同一个SqlSessionFactory创建的SqlSession就共享二级缓存的内容，并且可以操作二级缓存.

- 二级缓存的结构

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/2/img/tu_3-1572949193589.png)

### 二级缓存的使用

+ 在 SqlMapConfig.xml 文件开启二级缓存 

```xml
<!--配置开启二级缓存-->
<settings>
  <setting name="cacheEnabled" value="true"/>
</settings>
```

- **因为 cacheEnabled 的取值默认就为 true**，所以这一步可以省略不配置。为 true 代表开启二级缓存；为 false 代表不开启二级缓存。  

+ 配置相关的 Mapper 映射文件 

  `<cache/>` 标签表示当前这个 mapper 映射将使用二级缓存，区分的标准就看 mapper 的 namespace 值。 

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
      PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
      "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.jwang.dao.UserDao">
  <cache/>
  
  <select id="findAll" resultType="User">
      select * from t_user
  </select>
  
  
  <delete id="deleteById" parameterType="int">
      delete from t_user where uid=#{id}
  </delete>
</mapper>
```

* 要进行二级缓存的POJO类必须实现Serializable接口

### 测试

```java
public class TestMybatis {
    @Test
    public void test02(){
        SqlSession sqlSession1 = SqlSessionFactoryUtil.openSqlSession();
        SqlSession sqlSession2 = SqlSessionFactoryUtil.openSqlSession();
        SqlSession sqlSession3 = SqlSessionFactoryUtil.openSqlSession();

        UserDao userDao1 = sqlSession1.getMapper(UserDao.class);
        UserDao userDao2 = sqlSession2.getMapper(UserDao.class);
        UserDao userDao3 = sqlSession3.getMapper(UserDao.class);

        System.out.println(userDao1.findAll());
        //sqlSession使用完之后，要关闭
        sqlSession1.close();

        System.out.println("----------------------");

        System.out.println(userDao2.findAll());
        sqlSession2.close();

        userDao3.deleteById(24);
        System.out.println("----------------------");
        System.out.println(userDao3.findAll());
        sqlSession3.close();
    }
}
```

- 经过上面的测试，我们发现执行了两次查询，并且在执行第一次查询后，我们关闭了一级缓存，再去执行第二次查询时，我们发现并没有对数据库发出 sql 语句，所以此时的数据就只能是来自于我们所说的二级缓存。 

- 当我们在使用二级缓存时，缓存的类一定要实现 java.io.Serializable 接口，这种就可以使用序列化	方式来保存对象。 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/2/img/tu_7-1572949193590.png)





# Mybatis 的多表关联查询  

##  一(多)对一

- 本次案例以简单的用户和账户的模型来分析 Mybatis 多表关系。用户为 User 表，账户为Account 表。一个用户（User）可以有多个账户（Account）,但是一个账户(Account)只能属于一个用户(User)。具体关系如下： 
![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/2/img/tu_19.png)

- 数据库的准备

```java
CREATE TABLE t_account(
		aid INT PRIMARY KEY auto_increment,
		money DOUBLE,
		uid INT
);
ALTER TABLE t_account ADD FOREIGN KEY(uid) REFERENCES t_user(uid);

INSERT INTO `t_account` VALUES (null, '1000', '1');
INSERT INTO `t_account` VALUES (null, '2000', '1');
INSERT INTO `t_account` VALUES (null, '1000', '2');
INSERT INTO `t_account` VALUES (null, '2000', '2');
INSERT INTO `t_account` VALUES (null, '800', '3');
```

- 查询语句

```
select * from t_account a,t_user u where a.uid=u.uid AND aid=#{aid}
```


- 修改Account.java 在 Account 类中加入 User类的对象作为 Account 类的一个属性。 

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Account implements Serializable {
    private Integer aid;
    private Double money;
    private Integer uid;
    /**
     * 表示Account和User的一对一关系
     */
    private User user;
}
```

- AccountDao.java

```java
public interface AccountDao {
    /**
     * 根据aid查询账户信息，并且连接t_user表查询该账户所属的用户信息
     * @param aid
     * @return
     */
    Account findAccountUserByAid(int aid);
}
```

- AccountDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.jwang.dao.AccountDao">
    
    <resultMap id="accountUserMap" type="Account" autoMapping="true">
        <!--
            使用association标签进行一对一映射
                property属性: 要进行一对一映射的属性名
                javaType属性: 要进行一对一映射的属性类型
        -->
        <association property="user" autoMapping="true" javaType="User">
        </association>
    </resultMap>
    <select id="findAccountUserByAid" parameterType="int" resultMap="accountUserMap">
        select
        *
        from
        t_account a,t_user u
        where
        a.uid=u.uid
        AND
        a.aid=#{aid}
    </select>
</mapper>
```


## 一对多

- 查询所有用户信息及用户关联的账户信息。

- sql语句

```mysql
select * from t_user u,t_account a where a.uid=u.uid AND u.uid=#{uid}
```

- Account.java

```java
public class Account {
    private Integer aid;
    private Integer uid;
    private Double money;
}
```

- User.java 为了能够让查询的 User 信息中，带有他的个人多个账户信息，我们就需要在 User 类中添加一个集合，用于存放他的多个账户信息，这样他们之间的关联关系就保存了。 

```java
public class User implements Serializable{
    private int uid;
    private String username;// 用户姓名
    private String sex;// 性别
    private Date birthday;// 生日
    private String address;// 地址

    //表达关系:1个用户对应多个账户
    private List<Account> accountList;
}
```

- UserDao.java

```java
public interface UserDao {
    /**
     * 根据用户的uid查询到一个用户信息，并且连接账号表查询该用户的所有账号
     * @param uid
     * @return
     */
    User findUserAccountListByUid(int uid);
}
```

- UserDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.dao.UserDao">
    <resultMap id="userAccountListMap" type="User">
        <id column="uid" property="uid"/>
        <result column="username" property="username"/>
        <result column="address" property="address"/>
        <result column="sex" property="sex"/>
        <result column="birthday" property="birthday"/>
        <!--
            对accountList属性进行一对多映射,使用collection标签
                property属性: 要进行一对多映射的属性名
                ofType属性(可以不写): 要进行一对多映射的属性类型
        -->
        <collection property="accountList" autoMapping="true" ofType="Account">
        </collection>
    </resultMap>

    <select id="findUserAccountListByUid" resultMap="userAccountListMap" parameterType="int">
        SELECT
        *
        FROM
        t_user u,t_account a
        WHERE
        a.uid=u.uid
        AND
        u.uid=#{uid}
    </select>
</mapper>
```

## 多对多(可以看成俩一对多)


![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/2/img/tu_21.png)

- 实现查询所有角色对象并且加载它所分配的用户信息。 

- 建表语句

```sql
CREATE TABLE t_role(
	rid INT PRIMARY KEY AUTO_INCREMENT,
	rName varchar(40),
	rDesc varchar(40)
);
INSERT INTO `t_role` VALUES (null, '校长', '负责学校管理工作');
INSERT INTO `t_role` VALUES (null, '副校长', '协助校长负责学校管理');
INSERT INTO `t_role` VALUES (null, '班主任', '负责班级管理工作');
INSERT INTO `t_role` VALUES (null, '教务处主任', '负责教学管理');
INSERT INTO `t_role` VALUES (null, '班主任组长', '负责班主任小组管理');


-- 中间表(关联表)
CREATE TABLE user_role(
	uid INT,
	rid INT
);

ALTER TABLE  user_role ADD FOREIGN KEY(uid) REFERENCES t_user(uid);
ALTER TABLE  user_role ADD FOREIGN KEY(rid) REFERENCES t_role(rid);

INSERT INTO `user_role` VALUES ('1', '1');
INSERT INTO `user_role` VALUES ('3', '3');
INSERT INTO `user_role` VALUES ('2', '3');
INSERT INTO `user_role` VALUES ('2', '5');
INSERT INTO `user_role` VALUES ('3', '4');
```


- 查询角色我们需要用到 Role 表，但角色分配的用户的信息我们并不能直接找到用户信息，而是要通过中间表(USER_ROLE 表)才能关联到用户信息。
下面是实现的 SQL 语句： 

```sql
select * from t_user u,t_role r,user_role ur where ur.uid=u.uid and ur.rid=r.rid AND u.uid=#{uid}
```

- User.java

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User implements Serializable {
    private Integer uid;
    private String username;
    private String sex;
    private Date birthday;
    private String address;
    /**
     * user和role的一对多关系
     */
    private List<Role> roleList;
}

```

- Role.java

```java
public class Role {
    private Integer rid;
    private String rName;
    private String rDesc;	
}
```

- UserDao.java

```java
public interface UserDao {
    User findUserRoleListByUid(int uid);
}
```

- UserDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.dao.UserDao">
    <resultMap id="userRoleListMap" type="User">
        <id column="uid" property="uid"/>
        <result column="username" property="username"/>
        <result column="address" property="address"/>
        <result column="sex" property="sex"/>
        <result column="birthday" property="birthday"/>
        <collection property="roleList" autoMapping="true" ofType="Role"></collection>
    </resultMap>
    <select id="findUserRoleListByUid" parameterType="int" resultMap="userRoleListMap">
        SELECT
        *
        FROM
        t_user u,t_role r,user_role ur

        WHERE
        ur.uid=u.uid
        AND
        ur.rid=r.rid
        AND
        u.uid=#{uid}
    </select>
</mapper>
```


1. 以哪张表作为主体查询，那么就将查询到的结果封装到哪张表对应的POJO对象中
2. 如果表的关系是一对一，那么就在一个POJO中添加另外一个POJO的对象属性
3. 如果表的关系是一对多，那么就在一个POJO中添加另外一个POJO的集合属性
4. 使用association标签可以进行一对一的映射
5. 使用collection标签可以进行一对多的映射

#  Mybatis 延迟加载策略 

## 什么是延迟加载 

​	延迟加载：就是在需要用到数据时才进行加载，不需要用到数据时就不加载数据。延迟加载也称懒加载.

​	坏处： 执行查询的次数会增加，所以在执行批量查询的时候，查询次数比使用连接查询要多特别多  

​	好处： 先从单表查询，需要时再从关联表去关联查询，大大提高数据库性能，因为查询单表要比关联查询多张表速度要快.

##  懒加载的配置

* 局部懒加载: 在association标签或者collection标签中，设置fetchType属性的值为lazy

* 全局懒加载: 在mybatis的核心配置文件中添加

```xml
<settings>
  <setting name="lazyLoadingEnabled" value="true"/>
  <setting name="aggressiveLazyLoading" value="false"/>
</settings>
```

## 使用 Assocation 实现延迟加载 (多对一,一对一)

- 查询账户(Account)信息并且关联查询用户(User)信息。

- 先查询账户(Account)信息，当我们需要用到用户(User)信息时再查询用户(User)信息。

```
-- 1. 查询账户
select * from t_account where aid=#{aid}
-- 2, 再查询用户
-- 再根据查询结果里面的uid查询当前账户所属的用户
SELECT * FROM t_user WHERE uid = #{uid}
```

+ User.java

```java
public class User{
    private int uid;
    private String username;// 用户姓名
    private String sex;// 性别
    private Date birthday;// 生日
    private String address;// 地址
}
```

+ Account.java

```java
public class Account {
    private Integer aid;
    private Integer uid;
    private Double money;

    //表达关系:1个用户对应1个账户
    private User user;

}
```

+ AccountDao.java

```java

public interface AccountDao {
    /**
     * 根据aid查询账号信息
     * @param aid
     * @return
     */
    Account findAccountByAid(int aid);
}
```

+ AccountDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.dao.AccountDao">
    <resultMap id="accountUserMap" type="Account" autoMapping="true">
        <id column="uid" property="uid"/>
        <!--
            让mybatis调用第二步查询
                select属性表示要调用的第二步查询的标示
                fetchType="lazy" 表示这次调用第二步查询会延迟加载
        -->
        <association property="user" autoMapping="true"
                     select="com.dao.UserDao.findUserByUid"
                     column="uid">
        </association>
    </resultMap>

    <select id="findAccountByAid" parameterType="int" resultMap="accountUserMap">
        select * from t_account where aid=#{aid}
    </select>
</mapper>
```

+ UserDao.java

```java
public interface UserDao {
    /**
     * 根据uid查询用户信息
     * @param uid
     * @return
     */
    User findUserByUid(int uid);
}
```

+ UserDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.dao.UserDao">
    <select id="findUserByUid" parameterType="int" resultType="User">
        select * from t_user where uid=#{uid}
    </select>
</mapper>
```

+ 测试

```java
/**
 * 目标: 使用者只调用第一次查询，由mybatis选择调用第二次查询
 *
 * 懒加载是需要配置的:
 *  1. 局部懒加载: 只在你配置了的地方才会进行懒加载
 *  2. 全局懒加载: 在核心配置文件添加
 	<settings>
    	<setting name="lazyLoadingEnabled" value="true"/>
    	<setting name="aggressiveLazyLoading" value="false"/>
	</settings>
 */
public class TestMybatis {
    @Test
    public void test01(){
        //如果只需要查询账号信息
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
        AccountDao accountDao = sqlSession.getMapper(AccountDao.class);

        //查询aid为1的账号信息
        Account account = accountDao.findAccountByAid(1);

        //如果需要先查询到账号信息，然后再查询该账号所属的用户信息
        //UserDao userDao = sqlSession.getMapper(UserDao.class);

        //将第一步查询到的uid传入到第二步
        //User user = userDao.findUserByUid(account.getUid());

        //将第二步查询到的user，设置到第一步查询到的account里面
        //account.setUser(user);

        System.out.println(account.getMoney());

        SqlSessionFactoryUtil.commitAndClose(sqlSession);
    }
}
```

## Collection 实现延迟加载  (一对多,多对多)


- 完成加载用户对象时，查询该用户所拥有的账户信息。等账户信息使用的时候再查询.

```sql
-- 1. 根据uid查询用户
SELECT * FROM t_user where uid=#{uid}
-- 2. 查询当前用户下的账户信息
-- 把用户里面的uid作为条件查询账户表
SELECT * FROM t_account WHERE uid = #{uid}
```

+ Account.java

```java
public class Account {
    private Integer aid;
    private Integer uid;
    private Double money;
}
```

+ User.java

```java
public class User implements Serializable{
    private int uid;
    private String username;// 用户姓名
    private String sex;// 性别
    private Date birthday;// 生日
    private String address;// 地址

    //表达关系:1个用户对应多个账户
    private List<Account> accounts;
}
```

+ UserDao.java

```java
public interface UserDao {
    /**
     * 根据uid查询用户信息
     * @param uid
     * @return
     */
    User findUserByUid(int uid);
}
```

+ UserDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.dao.UserDao">
    <resultMap id="userAccountListMap" type="User" autoMapping="true">
        <id column="uid" property="uid"/>
        <collection property="accountList" autoMapping="true"
                    select="com.dao.AccountDao.findAccountListByUid"
                    column="uid">
        </collection>
    </resultMap>
    <select id="findUserByUid" parameterType="int" resultMap="userAccountListMap">
        select * from t_user where uid=#{uid}
    </select>
</mapper>
```

+ AccountDao.java

```java
public interface AccountDao {
    /**
     * 根据uid查询账号的集合
     * @param uid
     * @return
     */
    List<Account> findAccountListByUid(int uid);
}
```

+ AccountDao.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.dao.AccountDao">
    <select id="findAccountListByUid" parameterType="int" resultType="Account">
        select * from t_account where uid=#{uid}
    </select>
</mapper>
```

+ 测试方法

```java
/**
 * 目标: 使用者只调用第一次查询，由mybatis选择调用第二次查询
 *
 * 懒加载是需要配置的:
 *  1. 局部懒加载: 只在你配置了的地方才会进行懒加载
 *  2. 全局懒加载:
 */
public class TestMybatis {
    @Test
    public void test01(){
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();

        UserDao userDao = sqlSession.getMapper(UserDao.class);

        User user = userDao.findUserByUid(1);

        System.out.println(user.getUsername());

        SqlSessionFactoryUtil.commitAndClose(sqlSession);
    }
}
```


# MyBatis注解开发

##  使用 Mybatis 注解实现基本CRUD 


+ Dao

```java
/**
 * mybatis的注解开发，就是在对应的Dao接口的方法上添加注解
 * 查询方法就对应Select注解
 * 添加方法就对应Insert注解
 * 删除方法就对应Delete注解
 * 修改方法就对应Update注解
 * 查询自增长的主键
 */
public interface UserDao {
    /**
     * 添加用户
     * @param user 要添加进数据库的数据
     * @return 受到影响的行数
     */
    @Insert("insert into t_user (username,address,sex,birthday) values (#{username},#{address},#{sex},#{birthday})")
    @SelectKey(keyProperty = "uid",keyColumn = "uid",resultType = int.class,before = false,statement = "select last_insert_id()")
    int addUser(User user);

    /**
     * 根据id删除
     * @param id
     * @return
     */
    @Delete("delete from t_user where uid=#{id}")
    int deleteById(int id);

    /**
     * 修改用户
     * @param user
     */
    @Update("update t_user set username=#{username},sex=#{sex},address=#{address} where uid=#{uid}")
    void updateUser(User user);

    /**
     * 根据id查询
     * @param id
     * @return
     */
    @Select("select * from t_user where uid=#{id}")
    User findById(int id);
}
```

+ 核心配置文件SqlMapConfig.xml

 ![1535361902219](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/mybatis/2/img/1535361902219.png)


## 使用Mybatis注解实现复杂关系映射开发


### 复杂关系映射的注解说明 

+ @Results 注解 , 代替的是标签<resultMap> 

```java
//该注解中可以使用单个@Result 注解，也可以使用@Result 集合
@Results({@Result()， @Result()})或@Results(@Result())
```

+ @Resutl 注解 ,代替了 <id>标签和<result>标签 ,

```java
@Result(column="列名",property="属性名",one=@One(select="指定用来多表查询的 sqlmapper"),many=@Many(select=""))

@Resutl 注解属性说明	
    column 数据库的列名
    Property 需要装配的属性名
```

```java
@Data
public class UserInfo implements Serializable {
    private Integer userId;
    private String username;
    private String userSex;
    private String userAddress;
    private Date userBirthday;
}
```

```java
@Results(id = "userInfoMap",value = {
    @Result(column = "uid",property = "userId",id = true),//id为true表示该字段是主键
    @Result(column = "sex",property = "userSex"),
    @Result(column = "address",property = "userAddress"),
    @Result(column = "birthday",property = "userBirthday")
})
List<UserInfo> findAllUserInfos();
```

+ @One 注解（一对一）,代替了<assocation>标签，是多表查询的关键，在注解中用来指定子查询返回单一对象。 

```java
@Result(column="列名",property="属性名",one=@One(select="指定用来多表查询的 sqlmapper"))

```

+ @Many 注解（一对多） ,代替了<Collection>标签,是是多表查询的关键，在注解中用来指定子查询返回对象集合 

  ​	注意：聚集元素用来处理“一对多”的关系。需要指定映射的 Java 实体类的属性，属性的 javaType（一般
  为 ArrayList） 但是注解中可以不定义； 

```java
@Result(property="",column="",many=@Many(select=""))
```



### 使用注解实现一对一复杂关系映射及延迟加载 

- 查询账户(Account)信息并且关联查询用户(User)信息。先查询账户(Account)信息，当我们需要用到用户(User)信息时再查询用户(User)信息。


+ User.java

```java
public class User implements Serializable{
    private int uid;
    private String username;// 用户姓名
    private String sex;// 性别
    private Date birthday;// 生日
    private String address;// 地址
 }

```

- Account.java

```java
public class Account {
    private Integer aid;
    private Integer uid;
    private Double money;

    //表达关系:1个用户对应1个账户
    private User user;
}

```

- AccountDao.java

```java
/**
 * Results就是手动映射
 */
public interface AccountDao {
    /**
     * 根据aid查询账号信息
     * @param aid
     * @return
     */
    @Select("select * from t_account where aid=#{aid}")
    @Results(
            {
                    //映射主键
                    @Result(column = "uid",property = "uid",id = true),
                    //调用第二步查询进行一对一映射
                    @Result(property = "user",column = "uid",one = @One(select = "com.jwang.dao.UserDao.findUserByUid"))
            }
    )
    Account findAccountByAid(int aid);
}
```

+ UserDao.java

```java
public interface UserDao {
    /**
     * 根据uid查询用户信息
     * @param uid
     * @return
     */
    @Select("select * from t_user where uid=#{uid}")
    User findUserByUid(int uid);
}
```

+ 测试

```java
/**
 * 目标: 使用者只调用第一次查询，由mybatis选择调用第二次查询
 *
 * 懒加载是需要配置的:
 *  1. 局部懒加载: 只在你配置了的地方才会进行懒加载
 *  2. 全局懒加载:
 */
public class TestMybatis {
    @Test
    public void test01(){
        //如果只需要查询账号信息
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
        AccountDao accountDao = sqlSession.getMapper(AccountDao.class);

        //查询aid为1的账号信息
        Account account = accountDao.findAccountByAid(1);

        System.out.println(account);

        SqlSessionFactoryUtil.commitAndClose(sqlSession);
    }
}
```

### 使用注解实现一对多复杂关系映射及延迟加载 

- 完成加载用户对象时，查询该用户所拥有的账户信息。 等账户信息使用的时候再查询.



+ User.java

```java
public class User {
    private Integer uid;
    private String username;// 用户姓名
    private String sex;// 性别
    private Date birthday;// 生日
    private String address;// 地址

    //用于保存用户的多个账户信息
    private List<Account> accounts;  
}

```

- UserDao.java

```java
public interface UserDao {
    /**
     * 根据uid查询用户信息
     * @param uid
     * @return
     */
    @Select("select * from t_user where uid=#{uid}")
    @Results({
            @Result(id = true,column = "uid",property = "uid"),
            @Result(property = "accountList",column = "uid",many = @Many(select = "com.jwang.dao.AccountDao.findAccountListByUid"))
    })
    User findUserByUid(int uid);
}
```

+ AccountDao.java

```java
public interface AccountDao {
    /**
     * 根据uid查询账号的集合
     * @param uid
     * @return
     */
    @Select("select * from t_account where uid=#{uid}")
    List<Account> findAccountListByUid(int uid);
}
```





