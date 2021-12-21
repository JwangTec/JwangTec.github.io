---
title: spark实操手册
categories: 大数据
tags:
  - 数据分析
  - spark
top: 1
abbrlink: 4121509675
date: 2019-05-02 18:18:19
password:
---


<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/date.jpeg" width="1000" height="300" align="middle" />

<!--more-->


# spark


[官方文档](http://spark.apache.org/docs/2.4.4/)



# 什么是spark
Spark 是一个用来实现快速而通用的集群计算的平台。优点：
* 极快的处理速度。spark是基于内存的计算框架，因此不需要对磁盘进行多次的读写。
* 适用于各种各样原先需要多种不同的分布式平台的场景，包括批处理、迭代算法、交互式查询、流处理。
* 拥有丰富的编程接口。支持python, java, scalar等语言。

## spark结构图
<pre>
 +-----------+     +----------+  +----------+  +----------+
 |           |     |          |  |          |  |          |  
 | spark SQL |     |  spark   |  |  MLIB    |  | GragH X  |
 |           |     | streaming|  |          |  |          |
 +-----------+     +----------+  +----------+  +----------+
 +--------------------------------------------------------+
 |                                                        |
 |            SPARK                  CORE                 |
 |                                                        |
 +--------------------------------------------------------+
 +-----------+     +--------------------+  +----------+
 |           |     |                    |  |          |
 | 独立调度器  |     |       YARN         |  |  MESOS   |
 |           |     |                    |  |          |
 +-----------+     +--------------------+  +----------+  
</pre>
1) spark core: 定义了rdd的接口，实现spark的基本功能例如：任务调度，内存管理，错误恢复，与存储系统交互等模块。
2) spark sql: 用于操作结构化数据的程序包。
3) spark streaming: 提供对实时数据流式计算的组件。
4) spark MLIB: 提供用于一组机器学习的库。
5) spark GraphX: 用于操作图的程序库。
6) 群集管理器：用于让spark高效的在数千计的节点之间伸缩计算。

## spark的用途
* 数据科学任务（对科学家）
* 数据处理应用（对工程师）


# spark安装与运行

## 下载及安装


## 配置环境变量
* 配置JAVA
 <pre>
    #vim ~/.bash_profile or ~/.bashrc
       export JAVA_HOME=INSTALLATION_PATH
       export PATH=$PATH:$JAVA_HOME/bin     #可选
    #. ~/.bash_profile or ~/.bashrc
 </pre>
 * 配置spark
 <pre>
     #vim ~/.bash_profile or ~/.bashrc
       export SPARK_HOME=SPARK_INSTALLATION_PATH
       export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin     #可选
     #. ~/.bash_profile or ~/.bashrc
 </pre>
 * 测试配置是否成功
  <pre>
      # PYSPARK_PYTHON=python3 pyspark
  </pre>
## 启动

* 启动master
  <pre>
  #start-master.sh -h IP -p PORT
  </pre>
* 启动slave
  <pre>
  #start-slave.sh spark://IP:PORT
  </pre>

## 打开shell
  <pre>
 #pyspark --master spark://HOST:PORT or PYSPARK_DRIVER_PYTHON=ipython SPARK_DIST_CLASSPATH=$(hadoop classpath) pyspark --master spark://localhost:7077
 </pre>
## 提交独立应用
#spark-submit test.py

 # spark核心概念
 spark程序由一个驱动器（driver）与多个执行器（executor）组成。

* 驱动器：包含了应用的main函数，并且定义了集群上的分布式数据集与对这些数据的相关操作。
* 执行器：用于执行操作的执行对象。
  
# spark编程
每一spark应用都应该包含一个sparkcontext对象。初始化过程如下：
from pyspark import SparkConf, SparkContext
conf = SparkConf().setMaster("localhost:7077").setAppName("my app")
sc = SparkContext(conf)

sc.stop()

# RDD编程
RDD称为分布式弹性数据集，在spark中对数据的操作不外乎就是创建rdd，转化rdd与调用rdd等。
## RDD基础
rdd就是spark中不可变的分布式对象集合，每个rdd都被分为多个分区，这些分区运行在集群中的不同节点上。
### rdd的创建
* 读取外部数据集。
  <pre>
      rdd = sc.textFile("file:///test.txt")
  </pre>
* 在驱动器程序里分发驱动器程序的对象集合。
  <pre>
      rdd = sc.parallelize((1,2,3,4,5,6,7,8,9))
  <pre>
  
### rdd的操作
* 转化（transform)。生成新的rdd,转化操作为惰性操作，每一次转化不会真的发生除非被“行动操作”进行触发
<pre>
filter,返回一个由通过传给filter的函数的元素组成的RDD
map，将函数用于RDD中的每个元素并返回新的RDD。
flatMap，将函数用于RDD中的每个元素并将返回的迭代器中的元素生成新的RDD
distinct，去重
union，生成一个包含两个RDD中所有元素的RDD
intersection，求两个RDD共同的元素的RDD
subtract，移除一个RDD中的内容
cartesian，求与另一个RDD的笛卡尔乘积
</pre>
* PairRDD转化操作
<pre>
reduceByKey(func),合并相同键的值。
groupByKey()，对具有相同键的值进行分组。
combineByKey()，使用不同的返回类型合并具有相同的键。
mapValues(func)，对Pair RDD中的每个值应用一个函数而不改变键值。
flatMapValues(func)
keys()，返回一个包含键的RDD。
values()，返回一个包含值的RDD。
sortByKey()，返回一个根据键排序的RDD。
subtractByKey(),删除掉RDD中与其它RDD中键相同的元素。
join，对两个RDD进行内连接。
</pre>
* 行动 (action)。执行转化操作并收集结果。
<pre>
reduce,并行整合RDD中所有数据
aggregate，与reduce类似，但是通常返回不同类型的函数
collect,返回RDD中所有的元素
take，从RDD中返回num个元素
first，返回第一个元素
count，求元素个数
top，从RDD中返回最前面num个元素
foreach，对RDD中的每个元素使用给定的函数
</pre>
 
 ## 聚合操作
 当数据集以键值的形式组织的时候，聚合具有相同键的元素进行一些统计是很常见的操作。下面几个方法用于常见的聚合：
<pre>
fold
combine
reduce
reduceByKey
foldByKey
</pre>

# 数据的读取与保存
## 文件格式
|格式名称|结构化|备注|
|---|---|---|
|文本文件|否|文本文件的每一行作为记录|
|json|半结构化数据|要求每行一条记录|
|csv|是|文本格式，在电子表格中使用|
|sequence file|是|一种hadoop中常见的文件格式|
|protocol buffer|是|快速，节约空间的语言格式|
|对象文件|是|用来将spark作业中的数据存储下来以让共享</br>的代码读取|

## 文本文件
### 读取
<pre>
input = sc.textFile("file:///myfile.txt") #读取本地文件
hdfs_file = sc.textFile("hdfs://192.168.34.45:9099/myfile.txt") #读取hdfs文本文件。
input = sc.wholeTextFiles("file:///20190101.logs") #返回一个pair RDD，键为文件名，值为文本见类容。
</pre>
<b style="color:red">注意:</b> 当传递的路径为一个文件夹路径时，则会读出所有的文件。

### 保存文本文件
<pre>
result.saveAsTextFile(outputFile)
</pre>

## JSON
### 读取
<pre>
import json
data = input.map(lambda x: json.loads(x))
</pre>
### 保存
<pre>
result.map(lambda x: json.dumps(x)).saveAsTextFile(output)
</pre>

## CSV
### 读取
<pre>
def map_to_csv(line):
    input = StringIO.StringIO(line)     
    reader = csv.DictReader(input, 
            fieldnames= ["姓名", "年龄"])     
    return reader.next()

rdd = sc.textFile("file:///users.txt).map(map_to_csv)
</pre>

### 保存
<pre>
import csv
import StringIO

def map_records_to_csv(records):
    output = StringIO()
    csv_writer = csv.DictWriter(output, fieldnames=("姓名", "年龄"))
    for r in records:
        csv_writer.write_row(r)
    return [output.getValues()]

rdd.map(map_records_to_csv).saveAsTextFile(output_path)
</pre>

# Spark SQL结构化数据
在各种情况下，我们把一条 SQL 查询给 Spark SQL，让它对一个数据源执行查询（选出一些字段或者对字段使用一些函数），然后得到由 Row 对象组成的 RDD，每个 Row 对象表示一条记录。在 Python 中，可以使用 row[column_number] 以及 row.column_name 来访问元素。
## JSON
<pre>
from pyspark.sql.dataframe import DataFrame

sf = SparkConf().setMaster("spark://192.168.0.104:7077").setAppName("WordCount")
hiveCtx = SparkSession.builder.config(conf=sf).getOrCreate()
hiveCtx.sparkContext.setLogLevel("WARN")
json_file = hiveCtx.read.json("file:///media/psf/Home/Workspace/Rimi/P1901/lessons/spark/users.json")
# json_file = hiveCtx.createDataFrame([{"name":"john", "age":34}, {"name":"bob", "age": 45}])
df = json_file.select(["name", "age"])
df.show()
</pre>

### 使用sql查询表
json_file.createOrReplaceTempView("user") # 将读出的结构化数据创建一张临时表
users = hiveCtx.sql("select name, age from user") # 执行sql语句
users.show()


### 保存文件
users.write.save("file:///users.json", format="json")

## CSV
<pre>
from pyspark.sql.dataframe import DataFrame

sf = SparkConf().setMaster("spark://192.168.0.104:7077").setAppName("WordCount")
hiveCtx = SparkSession.builder.config(conf=sf).getOrCreate()
hiveCtx.sparkContext.setLogLevel("WARN")
csv_file = hiveCtx.read.csv("file:///media/psf/Home/Workspace/Rimi/P1901/lessons/spark/users.csv", sep=",", header=True)
df = csv_file.select(["name", "age"])
df.show()
</pre>

### 保存文件
users.write.save("file:///users.csv", format="csv")

## JDBC
<pre>
table = hiveCtx.read.jdbc("jdbc:mysql://localhost/roc", "django_migrations", 
                          properties={ 'user' : 'root', 'password' : '123456' })
table.show()
</pre>

### 保存到数据库
<pre>
data.write.save(format="jdbc", url="jdbc:mysql://localhost/ggchat", dbtable="test2", user="root", password="123456")
</pre>

## 用户自定义函数（UDF）
用户自定义函数，也叫 UDF，可以让我们使用 Python/Java/Scala 注册自定义函数，并在 SQL 中调用。这种方法很常用，通常用来给机构内的

* 9-36：Python 版本耳朵字符串长度 UDF

<pre>

hiveCtx.registerFunction("strLenPython", lambda x: len(x), IntegerType()) 
lengthSchemaRDD = hiveCtx.sql("SELECT strLenPython('text') FROM tweets LIMIT 10")

</pre>

# Spark配置与调优

## 使用SparkConf配置Spark

<pre>
sc = SparkConf()
sc.set("spark.app.name", "spark test")
sc.set("spark.master", "spark://localhost:7077")
sc.set("spark.ui.port", 4444)
</pre>

## 常用的选项

|选项|默认值|描述|
|-----|-----|------|
|spark.executor.memory|512m|为每个执行器进程分配的内存|
|spark.executor.cores|1|限制应用使用的核心数量|
|spark.cores.max|无|使用的核心总数|
|spark.speculation|false|是否开启任务预测|
|spark.[X].port|任意值|设置spark用到的端口|

# Spark Streaming

许多应用需要即时处理收到的数据，例如用来实时追踪页面访问统计的应用、训练机器学习模型的应用，还有自动检测异常的应用。Spark Streaming 是 Spark 为这些应用而设计的模型。它允许用户使用一套和批处理非常接近的 API 来编写流式计算应用，这样就可以大量重用批处理应用的技术甚至代码。


## Streaming例子
<pre>
from pyspark.streaming import StreamingContext
from pyspark import SparkConf,SparkContext
# 设置集群信息
sf = SparkConf().setMaster("spark://192.168.0.104:7077").setAppName("xxxxxx")
sc = SparkContext(conf=sf)
sc.setLogLevel("ERROR")
# 初始化streaming对象
s = StreamingContext(sc, 1)
# 设置检查点机制
s.checkpoint("file:///media/psf/Home/Workspace/Rimi/P1901/lessons/spark/checkpoints")
# 通过网络读取数据流形成dstream
dstream = s.socketTextStream("192.168.0.103", 7777)
# 设置滑动窗口
dstream = dstream.window(3)
# dstream转化操作
dstream = dstream.flatMap(lambda x: x.split()).map(lambda x: (x, 1)).groupByKey().mapValues(lambda x: len([w for w in x]))
dstream.pprint()
s.start()
s.awaitTermination()
</pre>

## DStream
DStream被称为离散化流，和spark中的rdd类似。它会随着时间的推移而收到数据的队列。
在内部每个时间区间收到的数据都作为rdd存在，而dstream由这些rdd组成。

### DStream的输入源

* flume
* kafka
* hdfs
* 其它网络io

### DStream的操作

* 转化
* 输出

## 架构与抽象

使用“微批次”的架构，把流式计算当作一系列连续的小规模批处理来对待。Spark Streaming 从各种输入源中读取数据，并把数据分组为小的批次。新的批次按均匀的时间间隔创建出来。在每个时间区间开始的时候，一个新的批次就创建出来，在该区间内收到的数据都会被添加到这个批次中。在时间区间结束时，批次停止增长。时间区间的大小是由批次间隔这个参数决定的。批次间隔一般设在 500 毫秒到几秒之间，由应用开发者配置。每个输入批次都形成一个

<pre>

        +---+--------------------------------+
------->| r |  +-----+ +-----+    +------+   |
        | c |  |     | |     | ...|      |   |   output
------->| e |  |     | |     |    |      |   | ---------->
        | v |  +-----+ +-----+    +------+   |
------->|   |    Spark Streaming             |
        +---+--------------------------------+

</pre>

<pre>
             +------+ +------+ +------+
DStream ---> | 0-1s | | 1-2s | | 2-3s | --->
             +------+ +------+ +------+
              RDD1    RDD2    RDD3
</pre>

## 转化操作

### 无状态转化

在无状态转化操作中，每个批次的处理不依赖于之前批次的数据。转化操作，例如 map() 、 filter() 、 reduceByKey() 等，都是无状态转化操作。
<pre>
map: 对 DStream 中的每个元素应用给定函数，返回由各元素输出的元素组成的 DStream。
flatMap:
filter: 对 DStream 中的每个元素应用给定函数，返回由各元素输出的元素组成的 DStream。
repartition: 改变 DStream 的分区数。
reduceByKey: 将每个批次中键相同的记录归约。
groupByKey: 将每个批次中的记录根据键分组。
</pre>
### 有状态转化

相对地，有状态转化操作需要使用之前批次的数据或者是中间结果来计算当前批次的数据。有状态转化操作包括基于滑动窗口的转化操作和追踪状态变化的转化操作。

* 设置窗口大小与滑动步长
<pre>
...
stream.checkpoint("/checkpoint")
...
ds = stream.socketTextStream("192.168.0.103", 7777)
ds.window(3, 1) # 窗口大小与步长必须是时间间隔的整数倍。
</pre>

## 输入源

* 读取文件目录中的文本文件流
  
   <pre>
   s = stream.textFileStream("logs")
   </pre>

* 网络文本流
  
  <pre>
  s = stream.socketTextStream("127.0.0.1", 7777)
  </pre>

* 其它流（flume, kafka etc）

### 数据源的合并

如前文所述，可以使用类似 union() 这样的操作将多个 DStream 合并。通过这些操作符，可以把多个输入的 DStream 合并起来。有时，使用多个接收器对于提高聚合操作中的数据获取的吞吐量非常必要（如果只用一个接收器，可能会成为性能瓶颈）。另外，有时我们需要用不同的接收器来从不同的输入源中接收各种数据，然后使用

## 输出

将dstream输出到数据库或文件系统之中，实现输出的api如下：

|输出方法|说明|
|-----|-----|
|print|将dstream数据输出到终端|
|saveAsTextFiles|将dstream保存到文本文本|
|saveAsObjectFiles|将dstream保存成对象文件|
|saveAsHadoopFiles|将dstream保存成hadoop文件|
|foreachRDD|迭代dstream，通过提供的回调函数处理传递的RDD|

# Spark大数据分析实例

## 购物篮分析

购物篮分析(MarketBasketAnalysis,MBA)是一个流行的数据挖掘技术,市场营销和
电子商务专业人员经常用这个技术来揭示不同商品或商品组之间的相似度。数据挖掘的
一般目标是从庞大的数据集合中提取有趣的关联信息,例如数百万超市或信用卡销售交
易。购物篮分析可以帮助我们找出很可能会一起购买的商品,关联规则挖掘会发现一个
交易集中商品之间的相关性。然后市场营销人员可以使用这些关联规则在商店货架上或
在线将相关的商品搜放在相邻的位置,使顾客能购买更多的商品。为购物篮分析挖掘关
联规则时要找出频繁商品集,这是一个计算密集型问题,所以非常适合利用MapReduce
来解决。


在数据挖掘中，关联规则有两个度量标准：

* 支持度。一个项集出现的频度，例如：Support({A,C}) = 2表示只在两个交易中同时出现
* 置信度。关联规则左件与右件共同出现的频繁程度。

购物篮分析是用于回答以下问题：

* 哪些商品会一起购买
* 每个购物篮有哪些商品
* 哪些商品应当降价
* 商品应当如何相邻摆放已实现最大利润

### 分析流程

1) 给定交易清单：
        t1: crackers, icecream, coke, apple
        t2: chicken, pizza, coke, bread
        t3: baguette, soda, shampoo, crackers, pepsi, apple
        t4: baguette, cream, cheese, diapers, milk
        t5: crackers, coke, apple, baguette, soda

2) 构建项集(1阶，2阶，3阶), 对于每次交易以两个组合。
   例如：((crackers, icecream), 1), ((crackers, coke), 1), ....
       ((chiken, pizza), 1), ((chiken, coke), 1), ((chiken, bread), 1), ((pizza, coke), 1), ...
       ((crackers, icecream, coke), 1), ((baguette, soda, apple), 2) ...
       (crackers, 1), (icecream, 1), (coke, 1) ....

3) 统计各个阶出现的频度
   例如：((crackers, icecream), 1), ((coke, apple), 2), ((baguette, soda), 2) ...
        (crackers, 2), (coke, 3) ....

4) 生成所有子模式
   例如： ((a, b, c), 2) =>
         ((a, b, c), (null, 2))
         ((a, b), ((a, b ,c), 2))
         ((a, c), ((a, b, c), 2))
         ((b, c), ((a, b, c), 2))

5) 组合子模式(groupByKey)
   例如：
        ([a,b],[(null,2),([a,b,d],1),([a,b,c],1)])
        ([a,b,d],[(null,1)])
        ([c],[(nu1l,3),([b,c],3),([a,c],1)])
        ([b,d],[([a,b,d],1),(null,1)])
        ([d],[([b,d],1),(null,1),([a,d],1)])
6) 生成关联规则
   例如：
   [([a, b], [d], 0.5), ([a, b], [c], 0.5)]
   []
   [([c], [b], 1), ([c], [a], 0.33333)]
   ....

<pre>

# 导出spark库
from pyspark import SparkContext, SparkConf
import re

# 组合算法
def combine(s, n):
    def _iterator(collector, s, i, c, n, data=None):
        if c >= n:
            collector.append(tuple(data))
            return

        for x in range(i, len(s)):
            data.append(s[x])
            _iterator(collector, s, x + 1, c + 1, n, data)
            data.pop()

    data_set = []
    chars = []
    _iterator(data_set, s, 0, 0, n, chars)
    return data_set

sparkConf = SparkConf()
sparkConf.set("spark.master", "spark://10.0.0.252:7077")
sparkConf.set("spark.app.name", "MBA")
sparkConf.set("spark.executor.memory", "512m")
sparkConf.set("spark.executor.cores", "2")

sparkContext = SparkContext.getOrCreate(sparkConf)
sparkContext.setLogLevel("ERROR")
rdd = sparkContext.textFile("file:///root/transaction.txt")


def parse_T(x):
    _, info = re.split(":\\s*", x)
    data = re.split("\\s*,\\s*", info)

    data_set = []

    for d in combine(data, 2) + combine(data, 3):
        data_set.append((d, 1))

    return data_set

# 按二阶三阶进行组合，分组并求出分组后的总和
rdd1 = rdd.flatMap(f=parse_T).groupByKey().mapValues(lambda v: sum(v))

def gen_sub_seq(x):
    key, value = x
    sub_data_set = [(key, (None, value))]
    keys = combine(key, len(key) - 1)
    for k in keys:
        sub_data_set.append((k, (key, value)))
    return sub_data_set

# 求子序列
rdd2 = rdd1.flatMap(f=gen_sub_seq).groupByKey().mapValues(lambda v: [i for i in v])

def not_list(src, dst):
    for x in dst:
        src.remove(x)
    return src


def do_result(x):
    key, value = x
    data_set = []
    total = 0
    for c in value:
        if c[0] == None:
            total = c[1]
        else:
            data_set.append(c)

    if not data_set:
        return data_set

    results = []
    for k, v in data_set:
        if total == 0:
            continue

        pp = float(v) / float(total)
        results.append((pp, (key, not_list(list(k), key))))

    return results

# 求关联性，并排序打印
rdd3 = rdd2.flatMap(f=do_result).sortByKey(ascending=False)
for x in rdd3.top(100):
    print(x)

sparkContext.stop()

</pre>

# MLIB机器学习

## 机器学习分类

* 分类
* 回归
* 聚类

## 机器学习一般流程

* 使用字符串RDD表示消息
* 使用特征提取算法把文本数据转化为数值特征
* 对向量RDD调用分类算法，并返回模型
* 使用模型在测试数据集上测试
* 评估
* 部署
  
## 常用的机器学习算法

* 分布式随机森林
* K-means聚类算法
* 最小二乘发
* 支持向量机
* 等
  
## spark机器学习

### 数据类型

* Vector
  
既支持稠密向量也支持稀疏向量，前者表示向量的每一位都存储下来，后者则只存储非零位以节约空间。后面会简单讨论不同种类的向量。

* LabeledPoint

用来表示带标签的数据点。它包含一个特征向量与一个标签（由一个浮点数表示)

* Rating
  
用户对一个产品的评分，在 mllib.recommendation 包中，用于产品推荐。

* Model类

每个 Model 都是训练算法的结果，一般有一个 predict() 方法可以用来对新的数据点或数据点组成的 RDD 应用该模型进行预测。

### 分类与回归

分类与回归是监督式学习的两种主要形式。监督式学习指算法尝试使用有标签的训练数据（也就是已知结果的数据点）根据对象的特征预测结果。分类和回归的区别在于预测的变量的类型：在分类中，预测出的变量是离散的（也就是一个在有限集中的值，叫作类别）；比如，分类可能是将邮件分为垃圾邮件和非垃圾邮件，也有可能是文本所使用的语言。在回归中，预测出的变量是连续的（例如根据年龄和体重预测一个人的身高）。

1) 线性回归

线性回归是回归中最常用的方法之一，是指用特征的线性组合来预测输出值。MLlib 也支 持 L1 和 L2 的正则的回归，通常称为 Lasso 和 ridge 回归。

<pre>
from pyspark.mllib.regression import LabeledPoint 
from pyspark.mllib.regression import LinearRegressionWithSGD 
points = # (创建LabeledPoint组成的RDD) 
model = LinearRegressionWithSGD.train(points, iterations=200, intercept=True) 
print "weights: %s, intercept: %s" % (model.weights, model.intercept)
model.predict()
</pre>

2) 逻辑回归

逻辑回归是一种二元分类方法，用来寻找一个分隔阴性和阳性示例的线性分割平面。逻辑回归是一种二元分类方法，用来寻找一个分隔阴性和阳性示例的线性分割平面。在MLlib中，它接收一组标签为0或1的LabeledPoint，返回可以预测新点的分类的 LogisticRegressionModel 对象。

3) 支持向量机

支持向量机（简称 SVM）算法是另一种使用线性分割平面的二元分类算法，同样只预期 0 或者 1 的标签。通过 SVMWithSGD 类，我们可以访问这种算法，它的参数与线性回归和逻辑回归的参数差不多。返回的 SVMModel 与 LogisticRegressionModel 一样使用阈值的方式进行预测。

4) 朴素贝叶斯

朴素贝叶斯（Naive Bayes）算法是一种多元分类算法，它使用基于特征的线性函数计算将一个点分到各类中的得分。这种算法通常用于使用 TF-IDF 特征的文本分类，以及其他一些应用。MLlib 实现了多项朴素贝叶斯算法，需要非负的频次（比如词频）作为输入特征。

5) 决策树与随机森林

决策树是一个灵活的模型，可以用来进行分类，也可以用来进行回归。决策树以节点树的形式表示，每个节点基于数据的特征作出一个二元决定（比如，这个人的年龄是否大于20 ？），而树的每个叶节点则包含一种预测结果（例如，这个人是不是会买一个产品？）。决策树的吸引力在于模型本身容易检查，而且决策树既支持分类的特征，也支持连续的特征。

### 聚类

聚类算法是一种无监督学习任务，用于将对象分到具有高度相似性的聚类中。前面提到的监督式任务中的数据都是带标签的，而聚类可以用于无标签的数据。该算法主要用于数据探索（查看一个新数据集是什么样子）以及异常检测（识别与任意聚类都相距较远的点）。

1) K-means
