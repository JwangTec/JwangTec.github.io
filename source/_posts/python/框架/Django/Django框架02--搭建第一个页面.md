---
title: Django框架02--搭建第一个页面
categories: python-Django
tags:
  - python
  - Django
top: 8
abbrlink: 2301932064
date: 2019-06-02 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Django.jpeg)


## apps详解:

<!--more-->

#### 1. apps和整体配置文件内部结构

0. 最外部的manage.py

	一个命令行工具,实现django各种功能的文件,比如数据库迁移,静态文件收集,启动django服务等等

1. 首先我们来查看一下 djano_mvc_ppt的结构

    1. \__init__.py 它告诉Python这个目录应该被看做一个Python包
    2.  settings.py 项目的整体配置文件,包含项目启动哪些app,中间件设置,第三方包配置等等都在里面
    3. urls.py 总路由配置文件
    4. wsgi.py 网关协议入口程序

    
2. apps的结构

    migrations 文件夹,数据库迁移记录文件
    init.py apps 初始化文件 一般为空即可
    admin.py 自定义admin后台管理的地方
    apps.py app的在项目注册的名称,默认就行了
    models.py 定义数据模型
    tests.py 单元测试地址
    views.py 视图
    
    
#### 2. 第一个简单页面

>movies/views.py
	
	```	
		from django.http import HttpResponse
		def test1(request):
		    return HttpResponse("Hello, world!")
	```
>djano\_mvc\_ppt/urls.py	

	```
	
	
		from movies.views import test1
		
		urlpatterns = [
		    
		    url(r'^test1$',test1)
		]
	```
	
> 访问 http://127.0.0.1:8000/test1
	
#### 1.解释

1. views 是我们视图函数 他们负责给用户返回什么样的信息
2. url 是路由,试想一个网站有不同的页面,怎么样来走到不同的页面,就是通过这的路由分发来做的。我们把test1的网站转发到我们的views.py里面的test1函数
3. 终上所述,我们在访问页面的时候,就得到了第一个页面

![选择编译器安装](md_pics/chapter2/chapter2_1.png)

#### 3. 第二个页面

1. 我们知道,百度等网页是复杂的html构成的,所以我们需要前端人员的html网页支持,django可以渲染出前端的html网页,使用render
	> movies/views.py
	
	```
		def test2(request):
	
	    return render(request,'movies/index.html')
		
	```
	>djano\_mvc\_ppt/urls.py	
	
	```
	
	
		from movies.views import test2
		
		urlpatterns = [
		    
		    url(r'^test2$',test2)
		]
	```
	
	>templates/movies/index.html
	
	```
	
		<!DOCTYPE html>
		<html lang="en">
		<head>
		    <meta charset="UTF-8">
		    <title>Title</title>
		</head>
		<body>
		<h1>hello html</h1>
		</body>
		</html>
	
	```
	
#### 1.解释

django可以通过一定的方式,把html网页送给浏览器,这时候就不需要我们去直接回复一个字符串

#### 4. 第三个页面

>movies/models.py

	```
		from django.db import models
		
		# Create your models here.
		
		class Test(models.Model):
		    name = models.CharField(max_length=11)
	```
	
> djano\_mvc\_ppt/settings.py

	```
	
		INSTALLED_APPS = [
		    'django.contrib.admin',
		    'django.contrib.auth',
		    'django.contrib.contenttypes',
		    'django.contrib.sessions',
		    'django.contrib.messages',
		    'django.contrib.staticfiles',
		    'movies'
		]
	```
		
	```
	$ python manage.py makemigrations
	$ python manage.py migrate
	```
	>movies/views.py
	
	```
	def test3(request):
	    from movies.models import Test
	    user = Test.objects.all()[0]
	
	    return render(request,'movies/index2.html',context={'name':user.name})
	```
	
	>templates/movies/index2.html
	>
	```
		<!DOCTYPE html>
		<html lang="en">
		<head>
		    <meta charset="UTF-8">
		    <title>Title</title>
		</head>
		<body>
		<h1>hello {{ name }}</h1>
		</body>
		</html>
	
	```

#### 1.解释

1. model可以直接操控数据库,我们不用去写sql语句了,使用对象实例化就可以获取到语句

2. views可以把数据库传递给html,我们称为模板渲染,因为{{ name }}不是html语法,他需要python去加工一下(渲染)


## mtv模式

#### 1. 解释

我们上述的模式就是mtv模式

1. views专门负责取出数据来,怎么取,取多少数据都在views里面
2. model专门负责数据库控制,数据库字段怎么定义,这些字段代表什么就是model.py做的事情
3. html文件负责页面的展现,css js等都写在里面,他就专门负责页面怎么美观就行了

#### 2. 综述

以上就是我们框架的基本模式,主要的思想就是各司其职,分层
	