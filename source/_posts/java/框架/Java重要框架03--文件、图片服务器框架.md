---
title: Java重要框架03--文件、图片服务器框架
categories: Java框架
tags:
  - Java框架
  - FastDFS
top: 11
abbrlink: 3058054830
date: 2019-07-05 18:18:19
password:
---



##  FastDFS

<!--more-->

###  FastDFS简介

####  FastDFS体系结构 

FastDFS是一个开源的轻量级[分布式文件系统](https://baike.baidu.com/item/%E5%88%86%E5%B8%83%E5%BC%8F%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F/1250388)，它对文件进行管理，功能包括：文件存储、文件同步、文件访问（文件上传、文件下载）等，解决了大容量存储和负载均衡的问题。特别适合以文件为载体的在线服务，如相册网站、视频网站等等。

FastDFS为互联网量身定制，充分考虑了冗余备份、负载均衡、线性扩容等机制，并注重高可用、高性能等指标，使用FastDFS很容易搭建一套高性能的文件服务器集群提供文件上传、下载等服务。

FastDFS 架构包括 Tracker server 和 Storage server。客户端请求 Tracker server 进行文件上传、下载，通过Tracker server 调度最终由 Storage server 完成文件上传和下载。

Tracker server 作用是负载均衡和调度，通过 Tracker server 在文件上传时可以根据一些策略找到Storage server 提供文件上传服务。可以将 tracker 称为追踪服务器或调度服务器。Storage server 作用是文件存储，客户端上传的文件最终存储在 Storage 服务器上，Storageserver 没有实现自己的文件系统而是利用操作系统的文件系统来管理文件。可以将storage称为存储服务器。

![1559117928459](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/fastDFS/image/1559117928459.png)



#### 上传流程

![1559117994668](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/fastDFS/image/1559117994668.png)

客户端上传文件后存储服务器将文件 ID 返回给客户端，此文件 ID 用于以后访问该文件的索引信息。文件索引信息包括：组名，虚拟磁盘路径，数据两级目录，文件名。

![1559118013272](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/fastDFS/image/1559118013272.png)

**组名**：文件上传后所在的 storage 组名称，在文件上传成功后有storage 服务器返回，需要客户端自行保存。

**虚拟磁盘路径**：storage 配置的虚拟路径，与磁盘选项store_path*对应。如果配置了

store_path0 则是 M00，如果配置了 store_path1 则是 M01，以此类推。

**数据两级目录**：storage 服务器在每个虚拟磁盘路径下创建的两级目录，用于存储数据

文件。

**文件名**：与文件上传时不同。是由存储服务器根据特定信息生成，文件名包含：源存储

服务器 IP 地址、文件创建时间戳、文件大小、随机数和文件拓展名等信息。



###  FastDFS搭建

####  安装FastDFS镜像

我们使用Docker搭建FastDFS的开发环境,拉取镜像

```properties
docker pull morunchang/fastdfs
```

运行tracker

```properties
docker run -d --name tracker --net=host morunchang/fastdfs sh tracker.sh
```

运行storage

```properties
docker run -d --name storage --net=host -e TRACKER_IP=192.168.211.132:22122 -e GROUP_NAME=group1 morunchang/fastdfs sh storage.sh
```

- 使用的网络模式是–net=host, 192.168.211.132是宿主机的IP
- group1是组名，即storage的组  
- 如果想要增加新的storage服务器，再次运行该命令，注意更换 新组名



#### 配置Nginx

Nginx在这里主要提供对FastDFS图片访问的支持，Docker容器中已经集成了Nginx，我们需要修改nginx的配置,进入storage的容器内部，修改nginx.conf

```properties
docker exec -it storage  /bin/bash
```

进入后

```properties
vi /etc/nginx/conf/nginx.conf
```

添加以下内容

![1564792264719](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/fastDFS/image/1564792264719.png)

上图配置如下：

```properties
location ~ /M00 {
     root /data/fast_data/data;
     ngx_fastdfs_module;
}
```



禁止缓存：

```
add_header Cache-Control no-store;
```



退出容器

```
exit
```



重启storage容器

```properties
docker restart storage
```



查看启动容器`docker ps`

```properties
9f2391f73d97 morunchang/fastdfs "sh storage.sh" 12 minutes ago Up 12 seconds storage
e22a3c7f95ea morunchang/fastdfs "sh tracker.sh" 13 minutes ago Up 13 minutes tracker
```



开启启动设置

```properties
docker update --restart=always tracker
docker update --restart=always storage
```



### 文件存储微服务

创建文件管理微服务 service-file，该工程主要用于实现文件上传以及文件删除等功能。



#### pom.xml依赖

修改pom.xml，引入依赖

```xml
<dependency>
    <groupId>net.oschina.zcx7878</groupId>
    <artifactId>fastdfs-client-java</artifactId>
    <version>1.27.0.0</version>
</dependency>
```



#### FastDFS配置

在resources文件夹下创建fasfDFS的配置文件fdfs_client.conf

```properties
connect_timeout=60
network_timeout=60
charset=UTF-8
http.tracker_http_port=8080
tracker_server=192.168.211.132:22122
```

connect_timeout：连接超时时间，单位为秒。

network_timeout：通信超时时间，单位为秒。发送或接收数据时。假设在超时时间后还不能发送或接收数据，则本次网络通信失败

charset： 字符集

http.tracker_http_port  ：.tracker的http端口

tracker_server： tracker服务器IP和端口设置



####  application.yml配置

在resources文件夹下创建application.yml

```yaml
spring:
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB
  application:
    name: file
server:
  port: 18082
eureka:
  client:
    service-url:
      defaultZone: http://127.0.0.1:7001/eureka
  instance:
    prefer-ip-address: true
feign:
  hystrix:
    enabled: true
```

max-file-size是单个文件大小，max-request-size是设置总上传的数据大小



####   启动类

创建启动类FileApplication

```java
@SpringBootApplication(exclude={DataSourceAutoConfiguration.class})
@EnableEurekaClient
public class FileApplication {

    public static void main(String[] args) {
        SpringApplication.run(FileApplication.class);
    }
}
```

这里禁止了DataSource的加载创建。





### 文件上传



#### 文件信息封装

文件上传一般都有文件的名字、文件的内容、文件的扩展名、文件的md5值、文件的作者等相关属性，我们可以创建一个对象封装这些属性，代码如下：

创建`com.file.FastDFSFile`代码如下：

```java
public class FastDFSFile implements Serializable {

    //文件名字
    private String name;
    //文件内容
    private byte[] content;
    //文件扩展名
    private String ext;
    //文件MD5摘要值
    private String md5;
    //文件创建作者
    private String author;

    public FastDFSFile(String name, byte[] content, String ext, String md5, String author) {
        this.name = name;
        this.content = content;
        this.ext = ext;
        this.md5 = md5;
        this.author = author;
    }

    public FastDFSFile(String name, byte[] content, String ext) {
        this.name = name;
        this.content = content;
        this.ext = ext;
    }

    public FastDFSFile() {
    }

    //..get..set..toString
}
```



(可选)测试文件相关操作:

```java
package com.file.test;

import org.csource.fastdfs.*;
import org.junit.Test;

import java.io.*;
import java.net.InetSocketAddress;

public class FastdfsClientTest {
    @Test
    public void upload() throws Exception {

        //加载全局的配置文件
        ClientGlobal.init("C:\\Users\\Administrator\\IdeaProjects\\beike\\changgou\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");

        //创建TrackerClient客户端对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient对象获取TrackerServer信息
        TrackerServer trackerServer = trackerClient.getConnection();
        //获取StorageClient对象
        StorageClient storageClient = new StorageClient(trackerServer, null);

        //执行文件上传
        String[] jpgs = storageClient.upload_file("C:\\Users\\Administrator\\Pictures\\5b13cd6cN8e12d4aa.jpg", "jpg", null);

        for (String jpg : jpgs) {

            System.out.println(jpg);
        }

    }

    @Test
    public void delete() throws Exception {

        //加载全局的配置文件
        ClientGlobal.init("C:\\Users\\Administrator\\IdeaProjects\\beike\\changgou\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");

        //创建TrackerClient客户端对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient对象获取TrackerServer信息
        TrackerServer trackerServer = trackerClient.getConnection();
        //获取StorageClient对象
        StorageClient storageClient = new StorageClient(trackerServer, null);
        //执行文件上传

        int group1 = storageClient.delete_file("group1", "M00/00/00/wKjThF1VEiyAJ0xzAANdC6JX9KA522.jpg");
        System.out.println(group1);
    }

    @Test
    public void download() throws Exception {

        //加载全局的配置文件
        ClientGlobal.init("C:\\Users\\Administrator\\IdeaProjects\\beike\\changgou\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");

        //创建TrackerClient客户端对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient对象获取TrackerServer信息
        TrackerServer trackerServer = trackerClient.getConnection();
        //获取StorageClient对象
        StorageClient storageClient = new StorageClient(trackerServer, null);
        //执行文件上传
        byte[] bytes = storageClient.download_file("group1", "M00/00/00/wKjThF1VFfKAJRJDAANdC6JX9KA980.jpg");

        File file = new File("D:\\ceshi\\1234.jpg");

        FileOutputStream fileOutputStream = new FileOutputStream(file);

        BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(fileOutputStream);

        bufferedOutputStream.write(bytes);

        bufferedOutputStream.close();

        fileOutputStream.close();
    }

    //获取文件的信息数据
    @Test
    public void getFileInfo() throws Exception {
        //加载全局的配置文件
        ClientGlobal.init("C:\\Users\\Administrator\\IdeaProjects\\beike\\changgou\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");

        //创建TrackerClient客户端对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient对象获取TrackerServer信息
        TrackerServer trackerServer = trackerClient.getConnection();
        //获取StorageClient对象
        StorageClient storageClient = new StorageClient(trackerServer, null);
        //执行文件上传

        FileInfo group1 = storageClient.get_file_info("group1", "M00/00/00/wKjThF1VFfKAJRJDAANdC6JX9KA980.jpg");

        System.out.println(group1);

    } 


}
```





#### 文件操作

创建com.util.FastDFSClient类,在该类中实现FastDFS信息获取以及文件的相关操作，代码如下：

(1)初始化Tracker信息

在`com.util.FastDFSClient`类中初始化Tracker信息,在类中添加如下静态块：

```java
/***
 * 初始化tracker信息
 */
static {
    try {
        //获取tracker的配置文件fdfs_client.conf的位置
        String filePath = new ClassPathResource("fdfs_client.conf").getPath();
        //加载tracker配置信息
        ClientGlobal.init(filePath);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
```



(2)文件上传

在类中添加如下方法实现文件上传：

```java
/****
 * 文件上传
 * @param file : 要上传的文件信息封装->FastDFSFile
 * @return String[]
 *          1:文件上传所存储的组名
 *          2:文件存储路径
 */
public static String[] upload(FastDFSFile file){
    //获取文件作者
    NameValuePair[] meta_list = new NameValuePair[1];
    meta_list[0] =new NameValuePair(file.getAuthor());

    /***
     * 文件上传后的返回值
     * uploadResults[0]:文件上传所存储的组名，例如:group1
     * uploadResults[1]:文件存储路径,例如：M00/00/00/wKjThF0DBzaAP23MAAXz2mMp9oM26.jpeg
     */
    String[] uploadResults = null;
    try {
        //创建TrackerClient客户端对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient对象获取TrackerServer信息
        TrackerServer trackerServer = trackerClient.getConnection();
        //获取StorageClient对象
        StorageClient storageClient = new StorageClient(trackerServer, null);
        //执行文件上传
        uploadResults = storageClient.upload_file(file.getContent(), file.getExt(), meta_list);
    } catch (Exception e) {
        e.printStackTrace();
    }
    return uploadResults;
}
```

(3)获取文件信息

在类中添加如下方法实现获取文件信息：

```java
/***
 * 获取文件信息
 * @param groupName:组名
 * @param remoteFileName：文件存储完整名
 */
public static FileInfo getFile(String groupName,String remoteFileName){
    try {
        //创建TrackerClient对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient获得TrackerServer信息
        TrackerServer trackerServer =trackerClient.getConnection();
        //通过TrackerServer获取StorageClient对象
        StorageClient storageClient = new StorageClient(trackerServer,null);
        //获取文件信息
        return storageClient.get_file_info(groupName,remoteFileName);
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}
```

(4)文件下载

在类中添加如下方法实现文件下载：

```java
 //下载图片
    public static byte[] downFile(String groupName, String remoteFileName) throws Exception {
        //1.创建一个配置文件 用于填写服务端的ip和端口
        //2.加载配置文件 建立链接
        // ClientGlobal.init("C:\\Users\\admin\\IdeaProjects\\98\\changgou98\\changgou-parent\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");
        //3.创建trackerClient
        TrackerClient trackerClient = new TrackerClient();
        //4.根据trackerclient获取到链接对象 trackerServer
        TrackerServer trackerServer = trackerClient.getConnection();
        //5.创建storageServer对象 设置null

        //6.创建stroageClient --->提供了很多的操作图片的API的代码（上传图片，下载 ，删除）
        StorageClient storageClient = new StorageClient(trackerServer, null);

        //7.下在图片
        //参数1 指定要下载的组名
        //参数2 指定要下载的远程文件路径
        byte[] group1s = storageClient.download_file(groupName, remoteFileName);
        return group1s;
    }
```

(5)文件删除实现

```java
/***
 * 文件删除实现
 * @param groupName:组名
 * @param remoteFileName：文件存储完整名
 */
//删除图片
    public static boolean deleteFile(String groupName, String remoteFileName) throws Exception {
        //1.创建一个配置文件 用于填写服务端的ip和端口
        //2.加载配置文件 建立链接
        //ClientGlobal.init("C:\\Users\\admin\\IdeaProjects\\98\\changgou98\\changgou-parent\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");
        //3.创建trackerClient
        TrackerClient trackerClient = new TrackerClient();
        //4.根据trackerclient获取到链接对象 trackerServer
        TrackerServer trackerServer = trackerClient.getConnection();
        //5.创建storageServer对象 设置null

        //6.创建stroageClient --->提供了很多的操作图片的API的代码（上传图片，下载 ，删除）
        StorageClient storageClient = new StorageClient(trackerServer, null);
        int group1 = storageClient.delete_file(groupName, remoteFileName);
        if (group1 == 0) {
            return true;
        } else {
            return false;
        }
    }
```

(6)获取组信息

```java
/***
 * 获取组信息
 * @param groupName :组名
 */
public static StorageServer getStorages(String groupName){
    try {
        //创建TrackerClient对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient获取TrackerServer对象
        TrackerServer trackerServer = trackerClient.getConnection();
        //通过trackerClient获取Storage组信息
        return trackerClient.getStoreStorage(trackerServer,groupName);
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}
```

(7)根据文件组名和文件存储路径获取Storage服务的IP、端口信息

```java
/***
 * 根据文件组名和文件存储路径获取Storage服务的IP、端口信息
 * @param groupName :组名
 * @param remoteFileName ：文件存储完整名
 */
public static ServerInfo[] getServerInfo(String groupName, String remoteFileName){
    try {
        //创建TrackerClient对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient获取TrackerServer对象
        TrackerServer trackerServer = trackerClient.getConnection();
        //获取服务信息
        return trackerClient.getFetchStorages(trackerServer,groupName,remoteFileName);
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}
```

(8)获取Tracker服务地址

```java
/***
 * 获取Tracker服务地址
 */
public static String getTrackerUrl(){
    try {
        //创建TrackerClient对象
        TrackerClient trackerClient = new TrackerClient();
        //通过TrackerClient获取TrackerServer对象
        TrackerServer trackerServer = trackerClient.getConnection();
        //获取Tracker地址
        return "http://"+trackerServer.getInetSocketAddress().getHostString()+":"+ClientGlobal.getG_tracker_http_port();
    } catch (IOException e) {
        e.printStackTrace();
    }
    return null;
}
```

(9)优化

我们可以发现，上面所有方法中都会涉及到获取TrackerServer或者StorageClient，我们可以把它们单独抽取出去，分别在类中添加如下2个方法：

```java
/***
 * 获取TrackerServer
 */
public static TrackerServer getTrackerServer() throws Exception{
    //创建TrackerClient对象
    TrackerClient trackerClient = new TrackerClient();
    //通过TrackerClient获取TrackerServer对象
    TrackerServer trackerServer = trackerClient.getConnection();
    return trackerServer;
}

/***
 * 获取StorageClient
 * @return
 * @throws Exception
 */
public static StorageClient getStorageClient() throws Exception{
    //获取TrackerServer
    TrackerServer trackerServer = getTrackerServer();
    //通过TrackerServer创建StorageClient
    StorageClient storageClient = new StorageClient(trackerServer,null);
    return storageClient;
}
```

修改其他方法，在需要使用TrackerServer和StorageClient的时候，直接调用上面的方法,完整代码如下：

```java
package com.file.util;

import com.file.FastDFSFile;
import org.csource.common.MyException;
import org.csource.common.NameValuePair;
import org.csource.fastdfs.ClientGlobal;
import org.csource.fastdfs.StorageClient;
import org.csource.fastdfs.TrackerClient;
import org.csource.fastdfs.TrackerServer;
import org.springframework.core.io.ClassPathResource;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * @author ljh
 * @version 1.0
 * @date 2020/9/22 11:57
 * @description 标题
 * @package com.file.util
 */
public class FastDFSClient {
    static {
        try {
            ClassPathResource resource = new ClassPathResource("fdfs_client.conf");
            ClientGlobal.init(resource.getPath());
        } catch (IOException e) {
            e.printStackTrace();
        } catch (MyException e) {
            e.printStackTrace();
        }
    }

    //上传图片
    public static String[] upload(FastDFSFile file) throws Exception {
        //1.创建一个配置文件 用于填写服务端的ip和端口
        //2.加载配置文件 建立链接
        //3.创建trackerClient
        TrackerClient trackerClient = new TrackerClient();
        //4.根据trackerclient获取到链接对象 trackerServer
        TrackerServer trackerServer = trackerClient.getConnection();
        //5.创建storageServer对象 设置null

        //6.创建stroageClient --->提供了很多的操作图片的API的代码（上传图片，下载 ，删除）
        StorageClient storageClient = new StorageClient(trackerServer, null);
        //参数1 指定要上传图片的本地的图片的绝对路径
        //参数2 指定要上传图片的图片的扩展名（jpg/png）不要带点
        //参数3 指定元数据 指的是 图片的高度 日期，像素......    可以不给，
        NameValuePair[] meta_list = new NameValuePair[]{
                //像素 高度  大小
                new NameValuePair(file.getName())
        };

        String[] jpgs = storageClient.upload_file(file.getContent(), file.getExt(), meta_list);
        return jpgs;
    }

    //下载图片
    public static byte[] downFile(String groupName, String remoteFileName) throws Exception {
        //1.创建一个配置文件 用于填写服务端的ip和端口
        //2.加载配置文件 建立链接
        // ClientGlobal.init("C:\\Users\\admin\\IdeaProjects\\98\\changgou98\\changgou-parent\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");
        //3.创建trackerClient
        TrackerClient trackerClient = new TrackerClient();
        //4.根据trackerclient获取到链接对象 trackerServer
        TrackerServer trackerServer = trackerClient.getConnection();
        //5.创建storageServer对象 设置null

        //6.创建stroageClient --->提供了很多的操作图片的API的代码（上传图片，下载 ，删除）
        StorageClient storageClient = new StorageClient(trackerServer, null);

        //7.下在图片
        //参数1 指定要下载的组名
        //参数2 指定要下载的远程文件路径
        byte[] group1s = storageClient.download_file(groupName, remoteFileName);
        return group1s;
    }

    //删除图片
    public static boolean deleteFile(String groupName, String remoteFileName) throws Exception {
        //1.创建一个配置文件 用于填写服务端的ip和端口
        //2.加载配置文件 建立链接
        //ClientGlobal.init("C:\\Users\\admin\\IdeaProjects\\98\\changgou98\\changgou-parent\\changgou-service\\changgou-service-file\\src\\main\\resources\\fdfs_client.conf");
        //3.创建trackerClient
        TrackerClient trackerClient = new TrackerClient();
        //4.根据trackerclient获取到链接对象 trackerServer
        TrackerServer trackerServer = trackerClient.getConnection();
        //5.创建storageServer对象 设置null

        //6.创建stroageClient --->提供了很多的操作图片的API的代码（上传图片，下载 ，删除）
        StorageClient storageClient = new StorageClient(trackerServer, null);
        int group1 = storageClient.delete_file(groupName, remoteFileName);
        if (group1 == 0) {
            return true;
        } else {
            return false;
        }
    }
    //获取图片的信息 //todo
}

```



####  文件上传

创建一个FileController，在该控制器中实现文件上传操作，代码如下：

```java
@RestController
public class FileController {
    @Value("${pic.url}")
    private String picPath;

    //1.请求路径
    //2.参数
    //3.返回值

    /**
     * 图片上传
     *
     * @param file
     * @return
     */
    @PostMapping("/upload")
    public String upload(MultipartFile file) {
        try {
            if (!file.isEmpty()) {
                //1.获取到文件本身的字节数组
                byte[] content = file.getBytes();
                //2.获取文件的名称 --》获取图片的后缀
                String name = file.getOriginalFilename();//1234.jpg
                //3.上传到fastdfs上
                //[0] =group1
                //[1] =M00/00/00/wKjThF-qeNyATiVHAAAl8vdCW2Y824.png
                String[] upload = FastDFSClient.upload(new FastDFSFile(
                        name,//文件名
                        content,//文件的本身的字节数组
                        StringUtils.getFilenameExtension(name)
                        ));
                //4.拼接Ulr
                // http://192.168.211.132:8080/group1/M00/00/00/wKjThF-qeNyATiVHAAAl8vdCW2Y824.png
                String realPath = picPath+"/"+upload[0]+"/"+upload[1];

                //5.返回url给页面
                return realPath;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
```



配置：yaml

![1604994284489](images/1604994284489.png)



###  Postman测试文件上传

步骤：

1、选择post请求方式，输入请求地址  http://localhost:18082/upload

2、填写Headers

```properties
Key：Content-Type
Value：multipart/form-data
```

3、填写body

选择form-data   然后选择文件file   点击添加文件，最后发送即可。

![1560479823539](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/fastDFS/image/1560479807807.png)

访问`http://192.168.211.132:8080/group1/M00/00/00/wKjThF0DBzaAP23MAAXz2mMp9oM26.jpeg`如下图

![1560479928441](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/fastDFS/image/1560479928441.png)





注意，这里每次访问的端口是8080端口，访问的端口其实是storage容器的nginx端口，如果想修改该端口可以直接进入到storage容器，然后修改即可。

```properties
docker exec -it storage  /bin/bash
vi /etc/nginx/conf/nginx.conf
```

![1564181128575](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/Java/fastDFS/image/1564181128575.png)

修改后重启storage即可根据自己修改的端口访问图片了。
