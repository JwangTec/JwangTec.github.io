---
title: Elasticsearch分词器
categories: 数据库
tags:
  - ElasticSearch
  - 分词器
top: 13
abbrlink: 4163751484
date: 2021-10-13 14:13:16
password:
---



## 分词器

我们刚才在进行说明倒排索引的时候说过，在进行数据存储的时候，需要先进行分词。而分词指的就是按照一定的规则将词一个个切割。这个规则是有内部的分词器机制来决定的，不同的分词器就是不同的规则

<!--more-->

+ standard分词器
+ ik分词器
+ stop分词器
+ 其他的分词器

```properties
以上：在说明这个情况的时候我们应该知道在默认的情况下ES提供了英文相关的分词器默认为standard分词器
对于中文分词不是特别的好。所以我们需要用到中文相关的分词器，那么IK分词器就是其中的佼佼者
```

分词的过程比较复杂，不同的分词器就有不同的规则，例如：

```properties
如有一段文本：Lucene is a full-text search java 

使用标准分词器：
	浏览器地址输入：http://localhost:9200/_analyze?analyzer=standard&text=Lucene is a full-text search java

最终形成词汇为：
Lucene 
is 
a 
full 
text 
search 
java

使用停用分词器：
	浏览器地址输入：http://localhost:9200/_analyze?analyzer=stop&text=Lucene is a full-text search java

最终形成词汇为：
lucene 
full 
text 
search 
java
```





##  IK分词器

### 什么是IK分词器

以上针对英文可以，但是如果使用中文的话，分词效果不好，

IK分词是一款国人开发的相对简单的中文分词器。虽然开发者自2012年之后就不在维护了，但在工程应用中IK算是比较流行的一款！

特点： 

 	1. 能将原本不是词的变成一个词 
 	2. 分词效果优秀 
 	3. 能将原本是一个词的进行停用，这些词我们称为停用词。停用词：单独运用没有具体语言意义的词汇，可根据语义自己定义。

###  IK分词器安装

下载地址：

```
https://github.com/medcl/elasticsearch-analysis-ik/releases
```

 我们已经提供：

![1556181020394](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/ES/ES1/images/1556181020394.png)



- 先将其解压，将解压后的elasticsearch文件夹重命名文件夹为ik
- 将ik文件夹拷贝到elasticsearch/plugins 目录下。
- 重新启动，即可加载IK分词器 

###  IK分词器测试

IK提供了两个分词算法ik_smart 和 ik_max_word. 其中 ik_smart 为最少切分(智能切分)，ik_max_word为最细粒度划分 

+ 第一种：最小切分
+ 第二种：种最细切分

测试第一种：浏览器中输入：

```
http://127.0.0.1:9200/_analyze?analyzer=ik_smart&pretty=true&text=我是程序员
```

![1556181174707](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/ES/ES1/images/1556181174707.png)

测试第二种：浏览器输入：

```
http://127.0.0.1:9200/_analyze?analyzer=ik_max_word&pretty=true&text=我是程序员
```

![1556181210421](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/ES/ES1/images/1556181210421.png)

###  自定义词库/词典

####  测试分词效果

（1）我们现在测试"小小明白"，

浏览器的测试效果如下  http://127.0.0.1:9200/_analyze?analyzer=ik_smart&pretty=true&text=小小明白 

```json
{
  "tokens" : [
    {
      "token" : "传",
      "start_offset" : 0,
      "end_offset" : 1,
      "type" : "CN_CHAR",
      "position" : 0
    },
    {
      "token" : "智",
      "start_offset" : 1,
      "end_offset" : 2,
      "type" : "CN_CHAR",
      "position" : 1
    },
    {
      "token" : "播",
      "start_offset" : 2,
      "end_offset" : 3,
      "type" : "CN_CHAR",
      "position" : 2
    },
    {
      "token" : "客",
      "start_offset" : 3,
      "end_offset" : 4,
      "type" : "CN_CHAR",
      "position" : 3
    }
  ]
}
```

（2）再测试：

```properties
http://127.0.0.1:9200/_analyze?analyzer=ik_smart&pretty=true&text=lucene is a full-text java 中国啊伟大的祖国
```



```json
{
    "tokens": [
        {
            "token": "lucene",
            "start_offset": 0,
            "end_offset": 6,
            "type": "ENGLISH",
            "position": 0
        },
        {
            "token": "a",
            "start_offset": 10,
            "end_offset": 11,
            "type": "ENGLISH",
            "position": 1
        },
        {
            "token": "full-text",
            "start_offset": 12,
            "end_offset": 21,
            "type": "LETTER",
            "position": 2
        },
        {
            "token": "java",
            "start_offset": 22,
            "end_offset": 26,
            "type": "ENGLISH",
            "position": 3
        },
        {
            "token": "中国",
            "start_offset": 27,
            "end_offset": 29,
            "type": "CN_WORD",
            "position": 4
        },
        {
            "token": "啊",
            "start_offset": 29,
            "end_offset": 30,
            "type": "CN_CHAR",
            "position": 5
        },
        {
            "token": "伟大",
            "start_offset": 30,
            "end_offset": 32,
            "type": "CN_WORD",
            "position": 6
        },
        {
            "token": "祖国",
            "start_offset": 33,
            "end_offset": 35,
            "type": "CN_WORD",
            "position": 7
        }
    ]
}
```





####  添加自定义词库/词典



（1）通过测试1发现，小小明白没有作为整体被分词出来。我们需要将其扩展为一个词，此时我们需要自定义扩展词典

- 进入elasticsearch/plugins/ik/config目录 
- 新建一个my.dic文件（文件名任意），**特别注意**编辑内容(以utf8无bom保存, 如果不行加一些换行)

```properties
小小明白
```

+ 修改IKAnalyzer.cfg.xml（在ik/config目录下） 

```xml
<properties>
    <comment>IK Analyzer 扩展配置</comment>
    <!‐‐用户可以在这里配置自己的扩展字典 ‐‐>
    <entry key="ext_dict">my.dic</entry>
    <!‐‐用户可以在这里配置自己的扩展停止词字典‐‐>
    <entry key="ext_stopwords"></entry>
</properties>
```



（2）测试二我们发现有些词我们需要分出来，比如 “啊”

+ 如果需要停用一些词，比如有些文本在进行创建文档建立倒排索引的时候需要过滤掉一些没有用的词，则可以进行自定义词典：我们把他叫做**停用词典**

（1）进入elasticsearch/plugins/ik/config目录 

（2）创建一个stopwords.dic 文件，特别注意：编辑内容(以utf8无bom保存, 如果不行加一些换行)

（3）在文件中添加一个字为：的 

（4)修改IKAnalyzer.cfg.xml（在ik/config目录下） 

```properties
<properties>
    <comment>IK Analyzer 扩展配置</comment>
    <!‐‐用户可以在这里配置自己的扩展字典 ‐‐>
    <entry key="ext_dict">my.dic</entry>
    <!‐‐用户可以在这里配置自己的扩展停止词字典‐‐>
    <entry key="ext_stopwords">stopwords.dic</entry>
</properties>
```

（5）重启eslasticesarch服务器查看效果浏览器中输入：

```properties
http://127.0.0.1:9200/_analyze?analyzer=ik_smart&pretty=true&text=我是小小明白的学生 
```

查看分词效果：并没有出现的，说明这个词已经被过滤掉了。

```json
{
    "tokens": [
        {
            "token": "我",
            "start_offset": 0,
            "end_offset": 1,
            "type": "CN_CHAR",
            "position": 0
        },
        {
            "token": "是",
            "start_offset": 1,
            "end_offset": 2,
            "type": "CN_CHAR",
            "position": 1
        },
        {
            "token": "小小明白",
            "start_offset": 2,
            "end_offset": 6,
            "type": "CN_WORD",
            "position": 2
        },
        {
            "token": "学生",
            "start_offset": 7,
            "end_offset": 9,
            "type": "CN_WORD",
            "position": 3
        }
    ]
}
```


