---
title: web02--html属性
categories: web
tags:
  - html属性
top: 7
abbrlink: 2741279174
date: 2019-05-12 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/html.jpeg)

###  id

<!--more-->

```
该属性能用于所有的HTML元素，为HTML元素指定一个唯一的标识符，用于CSS设置，
JavasSript进行操作或其它脚本语言及服务器端语言进行设置操作。

<p id="des"></p>
<b id="title"></b>

```

###  class


```
该属性可以用于所有HTML元素，为元素添加一个或多个类名。通常是用于CSS设置或配
合JavaScript进行操作设置，多个类名以空格符进行分隔，多个元素可以使用同一个类名。

<section class="box fr"></section>
<section class="box"></section>

```

###  title


```
该属性可以用于所有HTML元素，通过设置它的值，可以让用户鼠标悬浮在该元素上显示出“title”
属性中所设置的值。如之前提到的标签。起到一个补充说明的作用。

<img src="1.jpegv" alt="图片加载失败..." title="Ferrari">

```

###  lang


```
该属性用于设置元素的语言类型，不支持的标标有<base>，<br>，<frame>，<frameset>，
<hr>，<iframe>，<param> 及 <script>，但通常的使用方式是直接给标签设置该属性，
如：<html lang="zh-cn">、<html lang="zh">、<html lang="en">这样的形式，
分别表示将语言类型设置为“简体中文”、“中文”、“英文”。
```

###  h5播放器


```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>

<video controls="controls" autoplay="autoplay">
    <source src="h5_player1.mp4" type="video/mp4" />
</video>

</body>
</html>

```