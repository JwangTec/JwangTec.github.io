---
title: Django框架04--基础知识
categories: python-Django
tags:
  - python
  - Django
top: 8
abbrlink: 3407305082
date: 2019-06-04 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Django.jpeg)


### 安装

<!--more-->

```
安装：
pip3 install django -i https://pypi.doubanio.com/simple/

查看：
django-admin

 
```

### 创建项目

```
pycharm中可直接创建

或者命令行：django-admin startproject priject_name


运行Django：python3 manage.py runserver   浏览器打开有小火箭即成功

创建app：python3 manage.py  startapp app_name

pycharm: debug运行  ：edit可设置ip和端口

```


### Django


#### 配置目录

```
与Django一样名字的目录为配置目录

urls：各种链接，功能的实现，路由URL    
	1.path(‘地址栏取名’,相关函数)
		例如：path('hello/', views.hello_world) 
	2.需要使用import调用函数所在文件 调用的为views中的函数
		例如：from app1 import views
settings：
	1.allowed_hosts（允许访问的IP）bug:同一局域网里IP可随意访问
	2.templates:模版  ‘dirs’：确认html放置的文件夹
		例如：'DIRS': [os.path.join(BASE_DIR, 'templates')]
			base_dir:该项目的路径

```

#### app操作


```
自己建立的app包中：

views：创建函数   
	1.httpresponse函数：创建报文内容 用于return HttpResponse(‘html语句’)  需要使用import导入该函数
	2.requests参数：创建函数时必须加上该参数，用于接收数据等便于使用 
	3.render(re参数,html位置—>直接html名,参数dict) ：将其发送给浏览器
```



#### 文件发送

```
html：
	1.创建放置html文件夹
	2.确认文件夹位置：settings 2  templates中
	3.书写html
	4.编写调用函数 views 3
	5.urls增加该网页 urls 1，2

css/js/images(静态文件访问):
	1.在编写的html中增加
		<head>中加：
		激活：
             {% load static %}
             自动生成静态文件链接：
	      <link rel="stylesheet" href='{% static "css.css" %}'>
		html中的{{}}
		<li>{{ age }}</li>
		编写views中的函数内容时可以将{{}}中的参数以dict的形式发送过来并替换其中的字段
	2.创建css js文件夹
	3.settings添加：
		1.设置访问url的路径（网址名）：STATIC_URL = '/static/'	
		2.确认位置：STATICFILES_DIRS = [os.path.join(BASE_DIR, “html存放路径”),] 
	
		
	4.配置urls:
	    from django.conf import settings  调用上面的设置
	 from django.conf.urls.static import static   调用该函数
	 urlpatterns = [
				]+static(settings.STATIC_URL)
	5.书写css js images
	6.浏览器访问：/static/css.css
	7.浏览器访问对应html便可以
```


#### 数据库连接


1.与settings在相同文件夹下创建：my.cnf普通文件

```
		# my.cnf
		[client]
		database = NAME
		user = USER
		password = PASSWORD
		default-character-set = utf8mb4
```

2.settings设置：databases 中将本身数据库配置替换成mysql的配置代码

```
		# settings.py
		DATABASES = {
    		'default': {
     		   'ENGINE': 'django.db.backends.mysql',
      		  'OPTIONS': {
      		      'read_default_file': os.path.join(base_dir,‘django_s’,’my.cnf’),
      		  },
   		 }
		}
```

3.安装pymysql : 

```
pip install pymsql 

// pycharm/preferences/project.django_s/

```

4.Django使用mysql：settings同级的__init__中增加代码：

```
		
(1).__init__中代码：

	import pymysql			
	pymysql.version_info(2,0,0)        <—版本报错问题解决 无可不修改
	pymysql.install_as_MySQLdb()

(2).在external library//site-packages/django/db/backends/mysql/operations
中将与下面5 1对应修改146行  可以先运行会自定跳到该错误这里修改即可

last_executed_query中query.decode改成encode

```

#### 数据库操作

1.命令行：在manage.py同级目录下执行

```
		python3 manage.py migrate   —>在mysql中直接创建django内置的表 
```

```

(1).出现’decode’:在 external library/python 3.7/site-packages/django/db/backends/mysql/operations
last_executed_query中query.decode改成encode  (直接vim修改)

```


2.orm:通过对象操作数据库


（1）在views同级的models.py中编写定义自己的数据库表：即class创建

```
			例如：创建一个文章发布的数据库
				score = models.FloatField(default = 0,verbose_name=‘电影评分’)
				class Article(models.Model):
				title = models.CharField(max_length=255)  #文章标题
				punish_time = models.DateTimeField()  #文章发布时间
				author = models.CharField(max_length=20) #文章作者
				text = models.CharField(max_length=2000)  #文章内容
		
				def __str__(self):
					return self.title       (admin中直接以title字段显示)

```

（2）在settings：

```
installed_apps=[‘添加自己创建的app,即views所在文件夹名’ 例：’app1’]

```

（3）生成数据库表：命令行执行：

```
1.python3 manage.py makemigrations    (会在migrations文件夹下生成一个数据库迁移文件) 
2.python3 manage.py migrate     （根据（3）生成的建表文件在数据库中建表）

```

	注意：1执行成功的迁移文件会在数据库中django_migrations表中也创建一个该记录  
			必须同时存在才行 不然会一直报错：table
	解决：
		（1）删除migrations中的相关文件 再删除数据库表中的对应的记录 重新执行上述两个命令

(4）数据库表数据读取并在html中显示出来：

	1.创建html相关网页
	2.views：
		创建函数提取：
				引入models中的相关class  即2(1)中创建的相关表的类名
				from app1.models import Article
				
		编写发送函数：
				def article(requests):
					#相当于select * from article where id = 1 语句（并未执行）：
					data = Article.objects.filter(id=1)
					#切片执行该语句：
					res = data[0]
					return render(requests,’article.html’,{html中{{}}}的对应值dict})
	3.配置urls ：与上面urls配置一样 先导入再添加

	
#### admin用户创建

1.命令行：

```
python3 manage.py createsuperuser  (本次设置user:wangqi password:wang1995)

```

2.添加数据库到admin：

   （1）admin文件中添加代码
   
    ```
	   导入models中创建的数据库类名：
	   from app1.models import Article
		 添加到admin中：
			@admin.register(Article)
			class ArticleAdmin(admin.ModelAdmin):
				pass
	```

   (2）浏览器中进入admin即有自己创建的数据库，可以进行相关插入等操作



#### 外部app(或者html)

1.在django文件夹下：

```
python3 manage.py startapp ‘名字’  创建新的app
先运行 python3 manage.py rumserver  确定Django开启成功

```

2.将其外部的网页代码放入django 项目下

3.配置路径 

```
settings installed_apps添加该app名 templates:添加html存放路径  
在最后添加存放静态文件（html中的css/js）的代码以及媒体文件的media路径（见下）

```


4.配置urls  先连接index.html看是否成功

5.设置css/js/images

		1) python中 提供 win+r 可以查询+替换修改代码中的相关代码  
		2) 在使用正则表达式时需要勾选Regex  
		3) 查询：(css/.*\.css)  加括号表示一个整体    \ 转译     
		4) 替换：{% static ‘$1’ %}    $1表示匹配（3）中的第一个括号里的东西 再replace
		     
		     
6.建立数据库:

		1)modele:建表 + 命令行操作数据库链接
		2)admin建立后台
		3)settings设置路径 databases添加数据库my.cnf文件位置
		4)views添加查询和插入函数     将切片转到html代码中去：
				html中循环：{% for %}     循环代码     {% endear %}

					
	例如


	views:
				def index_movie(requests):
					data = Movie.objects.all()
					return render(requests, 'index.html', {‘data’:data}
	html：
						{% for movie in data %}
						<li><p class='title'>{{ movie.title }}</p></li>
						{% endfor %}
	模版中切片：{% for movie in data |slice:"0:5"%}
			取前5个


	5)url建立连接
	


7.图片处理：

```

models:添加字段：

		img = models.ImageField(upload_to='images',verbose_name='电影图片')再执行数据库操作2（3）
		
注意 ：进行3第一步时会跳出选择：
			1.后续更改 先创建 2.退出,先添加 选择1 然后随便添加内容回车html中修改图片的链接
		   
```

8.html中使用自定义函数：

函数模版：

	在app中建立一个目录：名字固定：templatetags  其中包含__init__文件
	创建一个功能名.py文件
	在该.py中自定义函数编写：
		模版：from django import template
			  register = template.Library()
			  import math

			@register.filter(name = ‘count_star’)  #计算星星数量
			def count_star(value):
				return range(math.floor(value))


	在需要该函数的html中装载：{% load 功能名 %}


9.媒体文件访问

图片以及视频与静态文件分开：

(1)创建图片视频等存放文件夹

(2)settings : 
 
```

templates添加：django.template.context_processors.media
			最后添加：#代表媒体文件的存储路径
			MEDIA_ROOT = os.path.join(BASE_DIR,'media')  #指定后 其媒体文件根目录为media
			MEDIA_URL = '/media/'
					
```

(3)urls：

```

调用re_path 使用正则表达式
		from django.urls import path,re_path
		from django.views.static import serve
		from p1904_django2.settings import MEDIA_ROOT,MEDIA_URL
		urlpatterns添加：
 			re_path(r'^media/(?P<path>.*)$', serve, {'document_root':MEDIA_ROOT}),
 			   
```


(4)html:

	装载：{% load movie_extras %} 
	 替换所有img:{% static  movie.img.url %}    \{ % static  '(images/.*\.jpg)' %\}
		替换成： {{ MEDIA_URL }}images/m15.jpg     \{ MEDIA_URL }}$1
		以及：{{ movie.img.url }}
		
(5)models：

	修改img的存储结构（路径格式）其媒体跟目录为media 只需要在这个跟目录下创建images文件用来存放媒体文件即可



10.登陆 注册 退出

```

django 自带用户表  auth_user :password   pbkdf2_sha256$150000$   使用sha256加密了150000次
		   使用该表并使用orm继承并扩展
		1.建立一个用户单独的app python3 manage.py startalp users    (django官网：documentation 查询user有步骤)
		2.用户models 中 
			from django.contrib.auth.models import AbstractUser   #在用户app中继承用户模型
			class UserInfo(Abstract..)
		3.添加app到 settings：确认其修改
			INS.._APP添加：users
			AUTH_USER_MODEL = ‘users.UserInfo’
		4.命令行执行：数据库迁移  执行时会出问题：用户表在数据库中存在，删除不了
								解决办法：在Django之前就创建好上诉继承代码 若已经创建 直接删除所有表
										然后再python3 manage两步  再创建命令行超级用户
		5.注册功能：
			views：导入数据库models中创建表类名
				def register(requests):pass   
					UserInfo.objects.create_user(username=requ.POST[‘username’],password=..)  creat_user:可在生成名字时就会生成密码					return HttpResponse(‘hello’) #检测链接
				
				出现CSRF验证：settings中middleware中注销掉Csrf  
				     
			urls：添加该函数到path
				网页中找到注册表单—html中找到相应位置 修改action http://ip/register函数   所有表单信息便传到该函数的requests中
			
		6.登陆功能：
			views：def login(re..):
				username = re…POST[‘username’]
				password = re…POST[‘ps’]
				user = UserInfo.objects.filter(username=username)[0]  #数据库查询语句 查询用户表中username密码
						check_password 函数(需要导入)： 检测密码
				return  

				注意：表单形式的验证前后端需要同时做：
				例如：密码验证需要前后端都同时做
						前端：html：min_length = ‘4’   （这里设置后，如果后端没改，前端网页里的限制条件仍然可以改，因其html保存在本地的，在elements中						可以修改，相当于漏洞）
							后端：if leng(‘username’) < 4:
									return HttpResponse(‘用户名长度必须大于4’)

		7.登陆注册只用后端做的方法
			forms模块(表单渲染 生成表单和验证表单 生成表单属于index中的  解决6中注意)  class LoginForm(forms.Form)
			charfield:数据库中为varchar()   html:type元素    
			app中创建forms.py文件：			
				导入forms模块  :
			 	与创建module一样创建相关class，比如登陆表单的input字段等
							密码字段定义：password = forms.CharField(min_length = 8, widget = forms.PasswordInput)  将type中改成password
							邮箱字段:EmailField
							网址字段:urlfiled
			views:添加该相关函数的值到html调用函数中进行实例化，f = LoginForm()   表示在html中生成表单
			html:在form表单中直接使用该字段
		
			验证表单：users app中
				导入表单
				f = LoginForm(requests.POST)    
				print(f.is_valid())  :ture false    表示该表单符合创建表单其中的字段限制
				username = f.cleaned_data[‘username’]    从cleaned中取html中验证成功的相关字段  （与form表单中的字段名需要一致） 用户不存在:try

			ModelForm模块（与数据库相连，比上面更好,可以以数据库中字段创建表）：  
					forms.py:
					from django.contrib.auth import get_user_model  #获取user的数据库信息  类
					User = get_user_model()			
					class UserForm(forms.ModelForm):      #
						class Meta: 
							model = User      #创建用户模版
							fields = (“username”, “password”)    #需要验证的字段
							widgets = {         #选择需要修改的字段
								‘password’: forms.PasswordInput(attrs={“min_length”:8}),     #设置最小长度 （数据库中该字段只有max_length）
								‘username’: forms.TextInput(attrs={“min_length”:4, ‘class’: text})  #启动class字段
										}
					html/views：
					users/views:登陆注意:is_valid()函数会验证在数据库中是否存在，需要在上述中将该方法在上面类下重写方法  def validate_unique(self):pass
				

		8.保持登陆： Django中的login方法  
			引用：from django.contrib.auth import login as user_login
				在登陆函数中users/views/login:check_password 正确后：user_login(requests, user) 将该user加到报文中，并在html中保存为session以及数据库中				保存
			在登陆页面（index.html）：加入判断语句：{% if not requests.user.is_authenticated %} 判断是否登陆，以此返回不同的标签 {% else %}{% endif %} 以此保持登陆
		退出：loginout模块
			user/views: def logout:user_logout(requests) return HttpResponse(‘logout success’)
			urls中配置
			html中加入到相关href中
		urls:可以设置别名：name=‘’    相应href 中可以使用{% url ‘别名’ %}  可以把固定地址换成与后台同步
		
跳转页面		
from django.shortcuts import redirect	
from django.urls 
return redirect(‘http// …’)
return redirect(‘别名’)
```


10 评分：

```
 新建评分app
settings：添加app
新建model：导入models Movie get_user_model 模块
		User = get_user_model
		class Score(models.Model):
			tags = ((1, ‘aa’),(2,’bb’),)
			movie_score = models.Int..(choices=tags)  选择分数
			movie = models.ForieginKey(‘movie.Movie’, on_delete=models.CASCADE)   删除的方式
			user = models.for…key(‘users.UserInfo, ..’)

			class Meta:
				unique_together = (‘movie’, ‘user’)  唯一

注意：字段不能与相关联表的字段重合

命令行创建数据库表	

修改之前自定义打星函数：

```

11.部署：将本地代码放到云服务器以便所有人都可以访问


```
1.服务器
2.登陆部署电脑：ssh rimi@10.2.0.26
3.本地上传代码到 git 再在部署电脑上拷贝下来
4. 部署机：安装django, 注意版本号
5.输出本地关于oython3的所有包版本号:pip3 freeze > requirements.txt
6.服务器:pip3 install -r requirements.txt
7. 启动 0.0.0.0:8000 所有人都可以访问（测试用）gunicorn(上线)
8.gunicorn:    安装   线程数量：cpu*2 +1   进程 = 线程/2   
9.启动：wigs: scoket 接收http协议    需要将python的socket替换成wigs
10.访问日志/报错
11.图片美化  分类搜索  活动  后台分类（分级） 
```