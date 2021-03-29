---
title: Django框架01--入门
categories: python框架
tags:
  - Django
top: 6
abbrlink: 216270077
date: 2019-06-01 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Django.jpeg)

## 1. 虚拟环境安装和django项目启动

<!--more-->

#### 1.安装python虚拟环境

	```
	$ pip install virtualenv
	$ pip install virtualenvwrapper
	
	$ pip install virtualenvwrapper-win (windows系列)
	
	$ export WORKON_HOME=~/Envs
	$ mkdir -p $WORKON_HOME
	$ source /usr/local/bin/virtualenvwrapper.sh
	```
	
> 虚拟环境位置文档位置

> https://virtualenvwrapper.readthedocs.io/en/latest/

1. 注意点 virtualenv是初级的工具 只能用在你当前文件夹的目录下面去新建
2. wrapper所带的 mkvirtualenv 和 workon命令可以让你在任何地方管理虚拟环境 不用考虑文件夹位置

#### 2.新建一个虚拟环境 激活虚拟环境 并且安装django 查看安装的django版本

	```
	virtualenv ruimi_django -p python3.6
	source ruimi_django/bin/activate
	pip install django==1.11
	python -m django --version
	```
	
#### 3.pycharm安装django环境

1. 在pycharm中选择newproject django
2. 选择虚拟环境(你在本地建好的虚拟环境)
3. 点击create,新建成功

![选中新建环境](md_pics/chapter1/chapter1_2.png)
![选择编译器安装](md_pics/chapter1/chapter1_1.png)

#### 4. 命令行安装django

1. 使用命令行创建django 效果等同于pycharm 其实pycharm的原理就是去帮你执行这些命令而已

2. 我们需要先切换到有django的虚拟环境才行

	```
	$ django-admin startproject test
	```
	

## 通过django创建第一个app和命令配置文件说明

#### 1 通过django 创建第一个app

```
django-admin startapp movies

```

> 有两个djano_mvc_ppt 第一个是总目录 第二个djano_mvc_ppt是项目的配置目录 settings urls 路由就在里面。他是定义整个项目的配置路由等。
> 我们刚才新建的是app目录是单独的功能目录,比如用户信息就可以新建一个目录来表示。在app目录里面我们去定义视图,模型等等。这个在后面章节会讲到。

#### 2 启动django

1. 命令行来启动django 

	1. python必须是我们的django环境里面的python程序
	2. manage.py是我们django项目目录下面的manage.py
	3. runserver是启动django 后台服务的命令 后面跟上ip和端口即可
	
	```
	python manage.py runserver 0.0.0.0:8000
	```
	
2. pycharm 启动django项目

	1. debug模式, 使用debug模式启动django,我们可以打断点,程序过来以后,就能截取到值
	2. run 模式,那么程序只会执行,不会有断点查看功能
		![选择编译器安装](md_pics/chapter1/chapter1_3.png)
	3. 最后 我们可以在下方 看到运行的状态 

		![选择编译器安装](md_pics/chapter1/chapter1_4.png)

    4. 启动完成后我们就可以查看启动是否成功了	

    	![选择编译器安装](md_pics/chapter1/chapter1_5.png)

## 为什么使用1.11版本

1. 2.0版本的lts(long time serve)目前还没有出来,到2019年我们就可以顺利使用django 2.0啦


	![选择编译器安装](md_pics/chapter1/chapter1_6.png)

