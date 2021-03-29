---
title: html语法01--html基础
categories: web
tags:
  - html基础
top: 7
abbrlink: 4252999164
date: 2019-05-11 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/html.jpeg)

###   1.html简介

<!--more-->


```
标记语言：注重文档结构
程序语言：注重控制计算机


常用标记语言：
Xml: XML是元标识语言，用户可以根据自身的需要定义一些标记 
Html: 这是一种用来制作超文本文档的简单标记语言，用其编写的文档通常后缀为html
XHTML:HTML的增强版，它的灵活性和扩展性会适应未来网络应用的更多需求,语法要求更严格
HTML5: html最新标准

js css html 关系
html： 负责创建，负责语义的表达，解决了页面“显示内容是什么”的问题
css：负责解决网页中内容该如何显示的问题
javascript：负责讲解网页内容对事件该做出什么样的反应

```

###  2.html结构


```
<!DOCTYPE html>                     //申明html文档
<html lang="zh-Hans">  
    <head>                          //head 头部标签
        <meta charset="UTF-8">      
//meta 无结束标签，通过对应的属性来设置编码格式（必要）、
设备显示缩放、搜索引擎关键字、描述、浏览器内核渲染方式等内容。        
		<title>Document</title>     //title 设置网页标题
    </head>
    <body></body>                   //body 内容
</html>                             //html 文档跟节点    

```

###  3.html 基础标签和元素


```
h: <h1></h1>  标题，有1，2，3，4。。。等标题
p:<p></p>     段落  不识别回车和空格 （回车会识别为空格，一个或多个空格为一个空格）
body:<body></body>  网页上需要显示的信息，其html主体写在body里面
meta：<meta charset="UTF-8" http-equiv="refresh" content="40">  闭合标签，其中可设置字符集 
		charset:标签属性 设置字符集
		http-equiv: 网页刷新
		content:刷新间隔秒数
title:<title></title>  标题，整个网页的标题
hr:<hr>   水平线标签
br:<br>   换行
a:<a href="url" target="_blank"></a>  超链接
		target="_blank"  从新窗口打开 
		<a href=“url” download>链接文本</a>  下载到本地
		<a href="#c2">跳转到c2</a>  跳转到id=c2所对应的标签
img:<img src="images/a1.png">  浏览器展示图片

b:<b></b>  字体加粗

语义化标签：
	strong:<></>  强调语句
	em:<></>   强调
	div:<></>  布局标签（通用容器）
	article:<></> 用于文章、新闻或博客，表示文档、页面、应用或一个独立的容器 可嵌套
	section:<></> 章节标签
	aside:<></> 指定附注栏，包括引述、侧栏、指向文章的一组链接、广告、友情链接、相关产品列表等
	header:<header></header> 网页的额外信息，比如网页的脚本语言和网页使用的字符集等
	footer:<></>  页脚	
	nav:<></> 标记导航，仅对文档中重要的链接使用
	time:<></> 时间
	main:<></> 页面主要内容，一个页面只使用一次			
			
特殊符号：
		&lt  <
		&gt   >
		&nbsp  空格
		&amp  &
		&quot  "
		&qpos  '

pre:<pre></pre>  原样输出，适合编程语句的显示

iframe框架：通过使用框架，你可以在同一个浏览器窗口中显示不止一个页面
<iframe src="demo_iframe.htm" name="iframe_a" scrolling="yes"></iframe>
name：设置iframe的名称

width：设置iframe的宽度，值可以为像素（不用添加“px”单位）和百分数

height：设置iframe的高度，值可以为像素（不用添加“px”单位）和百分数

src：设置iframe元素内需要显示页面或文件的URL地址，
该属性的值可以由与之关联的a标签点击设置（通过将a标签的“target”
属性的值设置为该iframe的“name”属性的值进行关联）

frameborder：设置是否显示边框（0 表示不显示边框/ 1 表示要显示边框）

scrolling：设置是否允许滚动（auto/yes/no）
```

###  4.html列表标签


|元素|描述|
|:-:| :-:|
|ol|定义有序列表|
|ul|定义无序列表|
|li|列表内容|
|dl|自定义列表|
|dt|列表项目描述|
|dd|列表项目描述|

```
<body>
	<h4>无序列表:</h4>
	<ul>
	  <li>Coffee</li>
	  <li>Tea</li>
	  <li>Milk</li>
	</ul>
</body>


<body>
	<h4>无序列表:</h4>
	<ol start=’50’>
	  <li>Coffee</li>
	  <li>Tea</li>
	  <li>Milk</li>
	</ol>
</body>

<dl>
	 <dt>a</dt>
	 <dd>a1</dd>
	 <dd>a2</dd>
	 <dt>b</dt>
	 <dd>b1</dd>
	 <dd>b2</dd>
	 <dt>c</dt>
	 <dd>c1</dd>
	 <dd>c2</dd>
</dl>

```

###   5.格式化标签


|标签|描述|
|:-:| :-:|
|b|粗字体|
|em|着重|
|i|斜体字|
|small|小号字|
|strong|加重语气|
|sub|下标字|
|sup|上标字|
|ins|插入字|
|del|删除字|

###  6.语言分类


```
编程语言：python，运算用
标记语言：结构化文档
自然语言：信息搜索等

```
