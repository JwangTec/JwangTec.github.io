---
title: Django框架09--序列化
categories: python-Django
tags:
  - python
  - Django
top: 8
abbrlink: 2889044135
date: 2019-06-09 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Django.jpeg)


## 基础知识

<!--more-->

1. 操作系统: 

	os 操作系统是管理计算机硬件与软件资源的计算机程序，同时也是计算机系统的内核与基石。操作系统需要处理如管
	理与配置内存、决定系统资源供需的优先次序、控制输入设备与输出设备、操作网络与管理文件系统等基本事务。操作
	系统也提供一个让用户与系统交互的操作界面。

2. 操作系统中的进程调度策略：先来先服务调度算法  短作业(进程)优先调度算法  高优先权优先调度算法  高响应比优先调度算法等

3. 分时操作系统： 将一个时间段分成多段运行多个程序  时分：按时间分  频分：按频率分发

4. CPU：对指令运行  不同操作系统执行的程序不同：格式不同其无法识别，解析不出指令  例如：windows(PE) Linux(tar)

5. 破解原理：识别格式--找寻相关指令--进行修改

6. os:python 中可以
path:环境变量  命令行输入命令时，会找寻path中的 

7. 程序加载到内存 

	进程包括：文本段（指令） data（数据段 初始化/未初始化）堆（可全局访问 类的对象） 
	栈（执行函数时会给函数分配一个空间<符合递归>函数执行完成后,栈相关内存销毁,所以不同函数之间的变量不可以相互访问）

8. 地址引用：一个变量指向地址  python全是地址引用

值引用：

进程管理：

9. 进程创建：fork()  每一个进程都有父进程，不一定有子进程 树状结构 

10. ps: pid() ppid(父进程)  []：内核进程  未加括号的：用户进程


## django REST framework

### 前期知识


api接口开发，最核心最常见的一个过程就是序列化，所谓序列化就是把数据转换格式，序列化可以分两个阶段：

1.序列化： 把我们识别的数据转换成指定的格式提供给别人。
	
	例如：我们在django的ORM中获取到的数据默认是模型对象，但是模型对象数据无法直接提供给前端或别的
	平台使用，所以我们需要把数据进行序列化，变成字符串或者json数据，提供给别人。

2.反序列化：把别人提供的数据转换/还原成我们需要的格式。
	
	例如：前端js提供过来的json数据，对于python而言就是字符串，我们需要进行反序列化换成模型类对象，
	这样我们才能把	数据保存到数据库中。
		1.接收数据[反序列化]
		2.操作数据
		3.响应数据[序列化]

### 基础准备


[中文文档](https://q1mi.github.io/Django-REST-framework-documentation/#django-rest-framework)
(github: https://github.com/encode/django-rest-framework/tree/master)


1. 需要安装的包：

```python
pip install djangorestframework
pip install markdown       # Markdown support for the browsable API.
pip install django-filter  # Filtering support

或者：
git clone https://github.com/encode/django-rest-framework

```

2. 项目目录下：settings--app添加--'rest_framework'

3. 根urls：

```
from django.conf.urls import url
from django.urls import path, include
urlpatterns = [
    
    url(r'^api-auth/', include('rest_framework.urls'))  #添加该urls
]

```

### jquert/api

#### jquery

1.创建Model并迁移

```
class UserModer(models.Model):
    username = models.CharField(max_length=200, null=False, blank=False)
    age = models.IntegerField()
    gender = models.BooleanField(default=False)
    
    def to_json(self):
    return {"username": self.username, "age": self.age, "gender": self.gender}
   
```

2.编辑views

```
调用所有的网页页面  例如：foo/html/index.html/

def index(request, file):
	return render(request, file)
```

3.前端网页 jquery 接收request中的数据进行处理并显示在前端

```
head头里 index.html 编写用户信息展示表单：
	1.导入jquery:
		<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
	2.使用：
    <script>
        $(document).ready(function() {
            $.get("/foo/api/user/",
                function (users) {
                    users.forEach(function (user) {
                        // $('#id_users').append(user.user);
                        // $('#id_users').append(user.age);
                       $("#id_users").append("<tr><td>"+user.username+"</td><td>" + 
                       user.age + "</td></tr>")
                    })
                }
            )
        });
    </script>
    页面...
    <tbody id = "id_users">
    	上面设置的后端处理内容将显示在这里
    </tbody>

4.urls创建：如api 1步骤

```

#### api

1.urls（该app下）设置api

```
app下创建urls.py
from django.urls import path
from foo import views

urlpatterns = [
	path('html/<str:file>', views.index)
	path('api/user/', views.get_user)

	

根urls:
from django.contrib import admin
from django.urls import path
from django.conf.urls import url
from django.urls import path, include
urlpatterns = [
    path('admin/', admin.site.urls),
    path('foo/', include('foo.urls')),
    url(r'^api-auth/', include('rest_framework.urls'))
]

```

2.使用api 实现前后端分离

```
前端调用展示相关数据：

1 html(user.html) 编写用户输入表单:
<form method='post', action='/foo/api/user/'>
	username:<input placeholder="username", name="username">....  #添加name以此为POST数据的名称
	</form>
	
2 views:
	只推送数据到前端展示：地址：foo/api/user/
		def get_user(request):
				users = UserModer.object.all()
				user_info = [u.to_json() for u in users]
				return JsonResponse(user_info, safe=False)
	POST则获取前端user.html的表单数据并保存(foo/html/user.html)/否则返回数据到前端(foo/api/user/)
		@csrf_exempt
		def do_user(request):
			if request.method == "POST":
				user = UserModel() #取出Model中的字段
				user.username = request.POST['username']  #赋值给相应字段
				...
				user.save()   #保存到数据库
				return JsonResponse(user.to_json())  #将数据发送给前端  地址：foo/api/user/
			else: 推送数据到前端


3 urls(当前app中):
	path('api/user/', views.do_user)  #2推送的消息返回前端的地址规则

```


### serializers 序列化器

#### 原理

```
1. 序列化,序列化器会把模型对象转换成字典,经过response以后变成json字符串
2. 反序列化,把客户端发送过来的数据,经过request以后变成字典,序列化器可以把字典转成模型
3. 反序列化,完成数据校验功能


```

#### 常用字段类型

|字  段  名  称|字段构造方式 serializers.字段构造方式()
|:----:|:----:|
BooleanField|	BooleanField()
NullBooleanField	|NullBooleanField()
CharField	|CharField(max_length=None, min_length=None, allow_blank=False, trim_whitespace=True)
EmailField|	EmailField(max_length=None, min_length=None, allow_blank=False)
RegexField	|RegexField(regex, max_length=None, min_length=None, allow_blank=False)
SlugField	|SlugField(max*length=50, min_length=None, allow_blank=False) 正则字段，验证正则模式 [a-zA-Z0-9*-]+
URLField	|URLField(max_length=200, min_length=None, allow_blank=False)
UUIDField	|UUIDField(format='hex_verbose') format:1) 'hex_verbose' 如"5ce0e9a5-5ffa-654b-cee0-1238041fb31a"2) 'hex' 如 "5ce0e9a55ffa654bcee01238041fb31a"3) 'int' - 如: "123456789012312313134124512351145145114"4) 'urn' 如: "urn:uuid:5ce0e9a5-5ffa-654b-cee0-1238041fb31a"
IPAddressField	|IPAddressField(protocol='both', unpack_ipv4=False, **options)
IntegerField	|IntegerField(max_value=None, min_value=None)
FloatField	|FloatField(max_value=None, min_value=None)
DecimalField	|DecimalField(max_digits, decimal_places, coerce_to_string=None, max_value=None, min_value=None)max_digits: 最多位数 decimal_palces: 小数点位置 
DateTimeField|DateTimeField(format=api_settings.DATETIME_FORMAT, input_formats=None)
DateField	|DateField(format=api_settings.DATE_FORMAT, input_formats=None)
TimeField	|TimeField(format=api_settings.TIME_FORMAT, input_formats=None)
DurationField|	DurationField()
ChoiceField	|ChoiceField(choices) choices与Django的用法相同
MultipleChoiceField|	MultipleChoiceField(choices)
FileField	|FileField(max_length=None, allow_empty_file=False, use_url=UPLOADED_FILES_USE_URL)
ImageField|	ImageField(max_length=None, allow_empty_file=False, use_url=UPLOADED_FILES_USE_URL)
ListField	|ListField(child=, min_length=None, max_length=None)
DictField	|DictField(child=)

#### 选项参数

|参数名称|	作用
|:----:|:----:|
max_length|	最大长度
min_length|	最小长度
allow_blank|	是否允许为空
trim_whitespace|	是否截断空白字符
max_value	|最大数值
min_value	|最小数值

#### 通用参数

|参数名称|	说明
|:----:|:----:|
read_only	|表明该字段仅用于序列化输出，默认False
write_only|	表明该字段仅用于反序列化输入，默认False
required	|表明该字段在反序列化时必须输入，默认True
default	|反序列化时使用的默认值
allow_null|	表明该字段是否允许传入None，默认False
validators|	该字段使用的验证器
error_messages|	包含错误编号与错误信息的字典
label	|用于HTML展示API页面时，显示的字段名称
help_text|	用于HTML展示API页面时，显示的字段帮助提示信息

####  创建序列化类（用户为例）

1.新建文件并导入序列化器 serializers.py  (当前app下)   用于序列化与反序列化

```
## serializers.py
from rest_framework import serializers

class UserSerializer(serializers.Serializer):
	username = serializers.CharFiled(requird = True, max_length=50)
	...  #需要进行数据转换的字段设,并修改字段相应类型
	def create(self, validated_data):  #重写create方法 
		model = UserModel()
		model.username = validated_data['username']
		...
		model.save()
		return model 
		
model ：指明该序列化器处理的数据字段从模型类Student参考生成
fields ：指明该序列化器包含模型类中的哪些字段，__all__指明包含所有字段   

```

2.views：获取前端表单数据并返回数据给前端 创建serializer对象


定义好Serializer类后，就可以创建Serializer对象了。

Serializer的构造方法为：

```
Serializer(instance=None, data=empty, **kwarg)

```

说明：

1）用于序列化时，将模型类对象传入instance参数

2）用于反序列化时，将要被反序列化的数据传入data参数

3）除了instance和data参数外，在构造Serializer对象时，还可通过context参数额外添加数据，如

```
serializer = StudentSerializer(instance, context={'request': request})
```
通过context参数附加的数据，可以通过Serializer对象的context属性获取。

	1.使用序列化器的时候一定要注意，序列化器声明了以后，不会自动执行，需要我们在视图中进行调用才可以。
	2.序列化器无法直接接收数据，需要我们在视图中创建序列化器对象时把使用的数据传递过来。
	3.序列化器的字段声明类似于form表单系统。
	4.开发restful api时，序列化器会帮我们把模型数据转换成字典.
	5.drf提供的视图会帮我们把字典转换成json,或者把客户端发送过来的数据转换字典.

序列化器的使用分两个阶段：

1.在客户端请求时，使用序列化器可以完成对数据的反序列化。

2.在服务器响应时，使用序列化器可以完成对数据的序列化。


```
def do_user(request):
	if request.method == "POST":  #foo/api/user/1   
		serializer = UserSerializer(data=request.POST)   
			#包括：serializer的__init__中有instance,data，many等字段，
		if not serializer.is_valid():  
			return JsonResponse(serializer.errors)
		serializer.save(force_insert=True)
		return JsonResponse(serializer.validated_data)  
		
		#serializer中会将data中的数据赋值给validated_data
		
	else:
			users = UserModer.object.all()
			user_info = [u.to_json() for u in users]
			return JsonResponse(user_info, safe=False)
			


```

3.app_name/urls.py

```
path('api/user/<int:id>', views.do_user) 

```

3.serializers 序列化/反序列化

说明：

```
使用序列化器进行反序列化时，需要对数据进行验证后，才能获取验证成功的数据或保存成模型类对象。

在获取反序列化的数据前，必须调用is_valid()方法进行验证，验证成功返回True，否则返回False。

验证失败，可以通过序列化器对象的errors属性获取错误信息，返回字典，包含了字段和字段的错误。
如果是非字段错误，可以通过修改REST framework配置中的NON_FIELD_ERRORS_KEY来控制错误字典中的键名。

验证成功，可以通过序列化器对象的validated_data属性获取数据。

在定义序列化器时，指明每个字段的序列化类型和选项参数，本身就是一种验证行为。

```

```
## serializers.py
class UserSerializer2(serializers.ModelSerializer): #需申明调用模型信息
	class Meta:
		model = UserModel  #model添加上to_json  直接继承Model的字段
		exclude = ('gender',)  #不在前端展示的字段
	
## views.py
def do_user(request, id=None):
	if not id:
		if request.method == "POST":  #根据前端输入的资源进行保存数据库中并返回给前端  
			serializer = UserSerializer(data=request.POST)  #数据转换（反序列化） 
			if not serializer.is_valid():  
				return JsonResponse(serializer.errors)  #响应错误
			serializer.save(force_insert=True)  #存储数据
			return JsonResponse(serializer.validated_data)  #响应数据
		else:  #被序列化的是包含多条数据的查询集QuerySet，可通过many=True参数补充说明 
				users = UserModer.object.all() #获取数据
				#不需要在model中定义to_json传资源
				user_info = UserSerializer2(instance=users, many=True) #转化多个数据，需要加上many=True
				#user_info.data ：序列化器转化后的数据（字典） 
				return JsonResponse(user_info.data, safe=False)
				#响应数据给客户端
				#返回的Json数据，如果是列表，需要声明safe=False
	else:  
		if request.method == "GET"：  
			user = UserModel.object.get(pk = id)  #获取数据
			user_info = UserSerializer2(instance=user) #数据转换（序列化）
			return JsonResponse(user_info.data)   #响应数据
```

### ModelSerializer

如果我们想要使用序列化器对应的是Django的模型类，DRF为我们提供了ModelSerializer模型类序列化器来帮助我们快速创建一个Serializer类。

ModelSerializer与常规的Serializer相同，但提供了：

	基于模型类自动生成一系列字段
	基于模型类自动为Serializer生成validators，比如unique_together
	包含默认的create()和update()的实现

#### 定义

```
class BookSerializer(serializers.ModelSerializer):
    """图书数据序列化器"""
    class Meta:
        model = Book
        fields = '__all__'

model 指明参照哪个模型类
fields 指明为模型类的哪些字段生成

我们可以在python manage.py shell中查看自动生成的BookSerializer的具体实现
>>> from booktest.serializers import BookSerializer
>>> serializer = BookSerializer()
>>> serializer

```

#### 指定字段 

1) 使用fields来明确字段，__all__表名包含所有字段，也可以写明具体哪些字段

2) 使用exclude可以明确排除掉哪些字段

3) fields 指明为模型类的哪些字段生成

4) 指明只读字段  可以通过read_only_fields指明只读字段，即仅用于序列化输出的字段

#### 添加额外参数

我们可以使用extra_kwargs参数为ModelSerializer添加或修改原有的选项参数

```
class BookSerializer(serializers.ModelSerializer):
    """图书序列化器"""
    class Meta:
        model = Book
        fields = ('id', 'title', 'pub_date', 'read', 'comment')
        extra_kwargs = {
            'read': {'min_value': 0, 'required': True},
            'comment': {'min_value': 0, 'required': True},
        }

```
### 序列化过程（lesson为例）

#### Model创建

```
#models.py
class LessonModel(models.Model):
    subject = models.CharField(max_length=255)
    student = models.ForeignKey('UserModer', on_delete=models.CASCADE)

```

#### 序列化类

```
#serializer.py
class LessonSerializer(serializers.ModelSerializer):
	#序列化调用上面学生信息（对student字段进行处理后返回）
	student = serializer.SerializerMethodField()
	
	def get_student(self, instance):
		#instance.student 为获取数据
		u = UserSerializer2(instance=instance.student) #数据转化
		return u.data #返回转化数据  使得该序列化可以转化学生信息数据并一起发给前端
	
	#定义任意需要的字段
	count = serializer.SerializerMethodField()
	
	def get_count(self, instance):
		return 12
		
    class Meta:
        model = LessonModel  #声明model  (instance中包括的字段)
        fields = ("subject", "student", 'count')  #指明序列化model中的字段与exclude相反

```

#### 转化为序列化对象

```
#views.py
def do_lesson(request, id=None):
	if not id:
		lesson = LessonModel.object.all() #获取数据
		json_lesson = LessonSerializer(instance=lesson, many=True)  #数据转化（序列化）
		return JsonResponse(json_lesson.data, safe=False)  
		#响应数据(subject,student,count的所有序列化返回的数据)
```

### 反序列化过程

#### 数据验证(以图书为例)

使用序列化器进行反序列化时，需要对数据进行验证后，才能获取验证成功的数据或保存成模型类对象。

在获取反序列化的数据前，必须调用is_valid()方法进行验证，验证成功返回True，否则返回False。

验证失败，可以通过序列化器对象的errors属性获取错误信息，返回字典，包含了字段和字段的错误。如果是非字段错误，可以通过修改REST framework配置中的NON_FIELD_ERRORS_KEY来控制错误字典中的键名。

验证成功，可以通过序列化器对象的validated_data属性获取数据。

在定义序列化器时，指明每个字段的序列化类型和选项参数，本身就是一种验证行为。


```
新建一个子应用books。

data = {'title': 'python'}  #传入的数据
serializer = BookSerializer(data=data)  #序列化
serializer.is_valid()  # True   验证结果返回值 （字段的限制若不满足直接False）
serializer.errors  # {}  错误信息
serializer.validated_data  #  OrderedDict([('btitle', 'python')])

```

	is_valid()方法还可以在验证失败时抛出异常serializers.ValidationError，
	可以通过传递raise_exception=True参数开启，REST framework接收到此异常，
	会向前端返回HTTP 400 Bad Request响应。

#### 补充定义验证行为

1）validate_字段名

```
class BookSerializer(serializers.Serializer):
    """图书数据序列化器"""
    ...
    def validate_title(self, value):
        if 'django' not in value.lower():
            raise serializers.ValidationError("图书不是关于Django的")
        return value

验证：
from book.serializers import BookSerializer
data = {'title': 'python'}
serializer = BookSerializer(data=data)
serializer.is_valid()  # False   
serializer.errors
#  {'title': [ErrorDetail(string='图书不是关于Django的', code='invalid')]}

```

2) 多个字段进行验证 定义validate方法

```
class BookSerializer(serializers.Serializer):
    """图书序列化器"""
    ...

    def validate(self, attrs):
        read = attrs['read']
        comment = attrs['comment']
        if read < comment:
            raise serializers.ValidationError('阅读量小于评论量，不可以通过')
        return attrs
        
   
from book.serializers import BookSerializer
data = {'title': 'about django', 'read': 10, 'comment': 20}
s = BookSerializer(data=data)
s.is_valid()  # False
s.errors
#  {'non_field_errors': [ErrorDetail(string='阅读量小于评论量', code='invalid')]}
```
3) validators  字段中添加该补充验证行为选项参数

```
def about_django(value):
    if 'django' not in value.lower():
        raise serializers.ValidationError("图书不是关于Django的")

class BookSerializer(serializers.Serializer):
    """图书序列化器"""
    id = serializers.IntegerField(label='ID', read_only=True)
     #验证字段title
    title = serializers.CharField(label='名称', max_length=20, validators=[about_django])    	 pub_date = serializers.DateField(label='发布日期', required=False)
    read = serializers.IntegerField(label='阅读量', required=False)
    comment = serializers.IntegerField(label='评论量', required=False)

  
from book.serializers import BookSerializer
data = {'title': 'python'}
serializer = BookSerializer(data=data)
serializer.is_valid()  # False   
serializer.errors
#  {'title': [ErrorDetail(string='图书不是关于Django的', code='invalid')]}
```

#### 保存/更新数据

##### 以密码保存和更新为例

```
#Model.py
class UserModel(models.Model):
	password = models.CharField(max_length=255, null=True)
   salt = models.CharField(max_length=255, default='123456')

#serializers.py 序列化

如果创建序列化器对象的时候，没有传递instance实例，则调用save()方法的时候，create()被调用，相反，
如果传递了instance实例，则调用save()方法的时候，update()被调用

class UserSerializer2(serializers.ModelSerializer):
    class Meta:
        model = UserModer
        exclude = ('password', ）
	#创建密码  validated_data是反序列化验证成功后获得的数据
    def create(self, validated_data):
        model = super().create(validated_data)
        model.salt = uuid.uuid4().hex
        password = '12345' + model.salt
        import hashlib
        md5 = hashlib.md5()
        md5.update(password.encode('utf-8'))
        model.password = md5.hexdigest()
        model.save()
        return model
	# 更新密码
    def update(self, instance, validated_data):
        model = super().update(instance, validated_data)
        if "password" in validated_data:
            password = validated_data['password'] + model.salt
            import hashlib
            md5 = hashlib.md5()
            md5.update(password.encode('utf-8'))
            model.password = md5.hexdigest()
            model.save()
        	  return model

```

### api_view(基于方法的视图)


api_view 是一个装饰器，用 http_method_names 来设置视图允许响应的 HTTP 方法列表，举个例子，

编写一个简单的视图，手动返回一些数据。

```
@api_view(['GET', 'POST'])  #如果未制定 默认是GET 其它以“405 Method Not Allowed ”进行响应
def hello_world(request):
    if request.method == 'POST':
        return Response({"message": "Got some data!", "data": request.data})
    return Response({"message": "Hello, world!"})

```


#### api_view装饰器

##### 实例
```
# views.py

@api_view("GET", "POST" ) 
def do_user(request, id=None): #可指定format:json(前端显示方式为json)
	assert isinstance(request, Request)
	# request.query_params == request.GET  urls中的数据
	# request.data == request.POST   报文中的数据
	if not id:
		if request.method == "POST":   
			serializer = UserSerializer(data=request.POST)   
			if not serializer.is_valid():  #序列化验证 
				return JsonResponse(serializer.errors)  
			serializer.save(force_insert=True) #保存 
			#return JsonResponse(serializer.validated_data)
			#使用rest_framework 的Response 
			return Response(serializer.validated_data)  #响应数据  
 
# app/urls
path('api/user', views.do_user, {'format':'json'}) #上述指定format后需要制定

```

##### 类视图(APIView例) 


```
#views.py

class UserView(APIView):
    def get(self, request, id=None, *args, **kwargs):
    # request.query_params == request.GET  urls中的数据
	 # request.data == request.POST   报文中的数据
        if id:
            user = UserModer.objects.get(pk=id)
            user_info = UserSerializer2(instance=user)
            return Response(user_info.data)
        else:
            users = UserModer.objects.all()
            users_info = UserSerializer2(instance=users, many=True)
            return Response(users_info.data)

    def post(self, request, *args, **kwargs):
        serializer = UserSerializer2(data=request.data)
        if not serializer.is_valid():
            return JsonResponse(serializer.errors)
        serializer.save()
        return Response(serializer.validated_data)
    def put(self, request, id=None, *args, **kwargs):
    	  if id:
    	  		model = UserModel.object.get(pk=id)
    	  else:
    	  		model = UserModel.object.get(pk=request.data['id'])
    	  serializer = UserSerializer2(data=request.data)
    	  if not serializer.is_valid():
    	  	  print(serializer.errors)
            return Response(status=401)
        serializer.save()
        return Response(serializer.data)
    	  

# app/urls.py

path('api/user/', views.UserView.as_view())

```

### mixins

```
class UserView(mixins.ListModelMixin,
               mixins.CreateModelMixin,
               mixins.RetrieveModelMixin,
               mixins.UpdateModelMixin,
               mixins.DestroyModelMixin,
               generics.GenericAPIView):

    queryset = UserModer.objects.all()
    serializer_class = UserSerializer2

    def get(self, request, pk=None, *args, **kwargs):
        if not pk:
            return self.list(request, *args, **kwargs)
        else:
            return self.retrieve(request, pk, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
        
```

### ModelViewSet

详细：

```
#views.py:

class UserView(ModelViewSet):
    queryset = UserModer.objects.all()
    serializer_class = UserSerializer2


list_view = UserView.as_view({
        "get": "list",
        "post": 'create'})

detail_view = UserView.as_view(
    {
        "get": "retrieve",
        "put": "update",
        "delete": "destroy"
    }
)

    # path('api/user/', views.list_view),
    # path('api/user/<int:pk>', views.detail_view),
```


简化1：

```
#views.py
 class LessonView(ModelViewSet):
     queryset = LessonModel.objects.all()
     serializer_class = LessonSerializer
     
#app/urls.py
from rest_framework.routers import DefaultRouter
router = DefaultRouter()
router.register('user', views.UserView)
router.register('lesson', views.LessonView)

path('api/', include(router.urls)),

```

### 验证

主要是对是否符合查看条件，符合则返回相关响应数据，否则返回权限不足

```
from rest_framework.permissions import IsAuthenticated, BasePermission

class TokenPermissionClass(BasePermission): #验证方法重写
    def has_object_permission(self, request, view, obj):
        pass
    def has_permission(self, request, view):
        if isinstance(view, UserView):
            return False
        return True
           
class LessonView(ModelViewSet):
    permission_classes = [TokenPermissionClass]  #调用上面的验证方式
    queryset = LessonModel.objects.all()
    serializer_class = LessonSerializer
```


自定义验证

1.新建验证文件 authentications.py

```
#authentications.py

from rest_framework.authentication import BaseAuthentication, BasicAuthentication
from foo.models import UserModer

class UserPasswordAuthentication(BaseAuthentication):
    def authenticate(self, request):
        user = request.query_params.get('username')
        password = request.query_params.get('password')
        try:
            user = UserModer.objects.get(username=user)
        except:
            return None, None
        new_password = password + user.salt
        import hashlib
        md5 = hashlib.md5()
        md5.update(new_password.encode('utf-8'))
        if user.password == md5.hexdigest():
            return user, None
        else:
            return None, None
            
#views.py

class UserView(ModelViewSet):  #若有权限即验证通过，则序列化
    permission_classes = [IsAuthenticated]
    authentication_classes = [UserPasswordAuthentication]
    queryset = UserModer.objects.all()
    serializer_class = UserSerializer2
 
 #models.py
 class UserModer(models.Model):
 	...
 	
   @property
   def is_authenticated(self):  
   #(IsAuthenticated中request.user和request.user.is_authenticated需要同时满足 这里重写其中一个)
        return True

```

### 查询

```
#地址栏输入  字段名=值 可以查询出该字段里所有符合的值的数据
class UserView(ModelViewSet):  
    queryset = UserModer.objects.all()
    serializer_class = UserSerializer2

    def list(self, request, *args, **kwargs):
        for arg, value in request.query_params.items():
            self.queryset = self.queryset.filter(**{arg: value})

        return super(UserView, self).list(request, *args, **kwargs)
```

### django-filters

```
pip3 install django-filters

import django_filters.rest_framework


class UserView(ModelViewSet):

    queryset = UserModer.objects.all()
    filter_backends = [django_filters.rest_framework.DjangoFilterBackend, SearchFilter]
    serializer_class = UserSerializer2
    filterset_fields = ['gender', 'salt']

#http://127.0.0.1:8000/foo/api/user/?gender=1

class LessonView(ModelViewSet):
    queryset = LessonModel.objects.all()
    serializer_class = LessonSerializer
    filter_backends = [SearchFilter]
    search_fields = ['subject', 'student__username']

#http://127.0.0.1:8000/foo/api/lesson/?search=a
```











