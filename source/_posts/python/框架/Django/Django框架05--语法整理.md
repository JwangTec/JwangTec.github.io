---
title: Django框架05--语法整理
categories: python-Django
tags:
  - python
  - Django
top: 8
abbrlink: 663967090
date: 2019-06-05 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Django.jpeg)



## 0.笔记格式说明

<!--more-->

1. 代码位置的表示

笔记中会有很多代码,比如

>mytest.views.py
```
from django.contrib.auth.models import User
from rest_framework import serializers, viewsets
...
```

  1. mytest.views.py表示在根目录下面的 mytest文件夹 下面的views.py中
  写入或者查找这些代码
  2. 下面那边表示代码
  3. ... 三个省略号表示已有代码,需要你到代码中去查看


## 1. restful api简介

1. 作用:关于如何去设计url的,url的设计其实是很麻烦

2. 观点: url表示了网站的资源
	1. URL(Uniform Resoure Locator):统一资源定位符
	2. 我们是去通过URL去操控网站里面的资源(数据)
	3. 这个Url或者资源他是静态的

	
4. 关于资源的操作(动态的)
	1. 获取 GET方法
	2. 修改 PUT PATCH修改
	3. 删除 DELETE
	4. 新加 POST
5. 思考 comments/delete url的问题
	    答案: 以restful标准去设计url的话,他所有的url都是表示静态资源的,他不能有动词
   
6. login logout 怎么去改写:
	答案 : 登录是关于session的操作
	
7. http://www.ruanyifeng.com/blog/2014/05/restful_api.html

## 2. 环境搭建

1. 需要安装的软件

    1. django 1.11版本
    2. django drf 最新版本
```
pip install django==1.11
pip install djangorestframework
pip install markdown
pip install django-filter
pip install coreapi
```
   3. postman发送get或者post方法的工具
       https://www.getpostman.com/apps

2. 在setting中加入drf app应用

```
INSTALLED_APPS = (
    ...
    'rest_framework',
)

```

3. 在drf_movie_rimi.urls.py中配置url

```
from django.conf.urls import include

urlpatterns = [
    ...
    url(r'^api-auth/', include('rest_framework.urls'))
]

```

4. 在settings.py中配置drf的权限

```
REST_FRAMEWORK = {
    # Use Django's standard `django.contrib.auth` permissions,
    # or allow read-only access for unauthenticated users.
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.DjangoModelPermissionsOrAnonReadOnly'
    ]
}

```

5. 安装drf自动文档生成功能

drf\_movie_rimi.urls.py

```

from rest_framework.documentation import include_docs_urls

urlpatterns = [
    ...
    url(r'^docs/', include_docs_urls(title='My API title'))
]
```

> 访问文档url  http://127.0.0.1:8001/docs/

## 3. drf快速上手

### 1. 示例代码

1. 新建一个 test的 app 来实验一下drf

```
startapp mytest

```

2. 书写drf代码

> 1.定义视图类和视图类需要的序列化类

> mytest.views.py

```
from django.contrib.auth.models import User
from rest_framework import serializers, viewsets


# 定义序列化数据 把user表里面的 url username mail is_staff字段提取出来
class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        #使用哪个数据模型
        model = User
        #序列化哪些字段出来
        fields = ('url', 'username', 'email', 'is_staff')


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

```

> 2.定义路由 把mytest的url包含到总url中

> drf_movie_rimi.urls.py

```

from django.conf.urls import url,include
from django.contrib import admin


urlpatterns = [
    ...
    url(r'^mytest/', include('mytest.urls')),
]

```

> 在mytest的app中定义路由，指向到我们的视图函数

> mytest.urls.py

```

from rest_framework import routers
from mytest.views import UserViewSet
from django.conf.urls import include,url

router = routers.DefaultRouter()
router.register(r'users', UserViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
]

```

3. 使用 createsuperuser 的api 来新建一个或者几个用户的信息

4. 访问接口 查看数据

5. 代码简单解释

```
/mytest/users/

```

## 4. 知识点讲解




### 1. views

1. drf的views和django原生的views一样,可以返回数据,获取get,post方法的参数,验证数据等等。
也可以像之前listview detailview, createview deleteview 一样,直接帮你做列表和单
个数据的查询,创建数据,删除数据

2. 基础view 函数视图

    1. 我们可以像django最基础的函数视图一样,去返回一个报文给http请求,注意我们需要加上装饰器
    才能运行

    定义views
    >mytest.view_test1.py
    
    ```
    ...
    from rest_framework.decorators import api_view
    from rest_framework.response import Response

    ...
    @api_view()
    def hello_world(request):
        return Response({"message": "Hello, world!"})

    ```



    定义url路由
    >mytest.urls.py
    
   ```
    
    ...
    from mytest.view_test1 import hello_world

    urlpatterns = [
        ...
        url(r'test2',hello_world),
        ...

    ]
   ```

    如果上面的函数运行成功,我们就可以去通过最简单得函数视图去解决 简单得业务逻辑,如get请求
    post请求,但是事情没有那么简单

    我们会发现你用post 方法是不行的,需要加上方法的装饰器
    >mytest.view_test1.py
    
    ```
    
    from rest_framework.decorators import api_view
    from rest_framework.response import Response

 
    @api_view(['GET', 'POST'])
    def hello_world(request):
        return Response({"message": "Hello, world!"})

    ```
    

   练习:
   
   
      1. 使用postman发送post方法 断点查看request的值,实现一个功能, get post方法过来
    分别返回不同的值
      2. 再次观察我们的response
       里面值,我们传递的是一个list或者dict,如果是django的话你会收到一个报错,但是drf里面的response
       会帮我们解析成json数据格式

   查看其实这个request的值其实是rest_framework的request解析过来的,和我们之间的django request有什么不一样

		

   2. APIView

    APIView是我们接触到的第一个类视图,就像django的template view一样 是基础的视图类,你需要自己去定义get post
    方法,需要自己去定义返回的数据,但是我们可以看到,我们不用自己去解析get方法和post方法,
    只用重写get post函数就可以去截取get ost方法传过来的参数

       1. 简单的get post请求
        mytest.view_test1.py
        
        
        
        ```

        from rest_framework.views import APIView
        from rest_framework.response import Response
        from rest_framework import authentication, permissions
        from django.contrib.auth.models import User
        ...

        class ListUsers(APIView):

            def get(self, request, format=None):
                return Response({"get": "Hello, world!"})

            def post(self, request, format=None):
                    return Response({"post": "Hello, world!"})

        ...

        ```


        定义url路由
        >mytest.urls.py

        ```
        ...
        from mytest.view_test1 import ListUsers

        urlpatterns = [
            ...
            url(r'test1',ListUsers.as_view()),
            ...
        ]
        ```

       2. APIView里面包含了很多强大的功能,比如我们权限控制

       我们制作一个接口,访问用户数据接口,由于用户信息比较敏感，我们需要授权用户(登录用户)去才能访问
       APIView里面自带了权限验证接口,接口分为两部分:

       1. 通过一定的方式，比如session或者cookie或者其他区识别用户是哪个
           >authentication_classes

       2. 通过识别好的用户身份，去判断他是否由权限使用这个接口
           > permission_classes

       mytest.view_test1.py
       
       ```

        from rest_framework.views import APIView
        from rest_framework.response import Response
        from rest_framework import authentication, permissions

        class ListUsersV2(APIView):

        #通过什么方式来验证用户,这个例子里面是通过token来验证用户信息
        authentication_classes = (authentication.TokenAuthentication,)
        #用户必须是什么级别才能使用这个接口
        permission_classes = (permissions.IsAdminUser,permissions.IsAuthenticatedOrReadOnly)

        def get(self, request, format=None):
            return Response({"get": "Hello, world!"})


        def post(self, request, format=None):
            return Response([username for username in User.objects.all()])

       ```

        定义url路由
        >mytest.urls.py

        ```
        ...
        from mytest.view_test1 import ListUsersV2

        urlpatterns = [
            ...
            url(r'test3',ListUsersV2.as_view()),
            ...
        ]
        ```

        3. GenericAPIView解析

            1. GenericAPIView解析继承自 APIView 扩展了他的很多功能
            ```
            class GenericAPIView(views.APIView):
            ...
            ```

            2. GenericAPIView的具体功能

                1. 强制要求传递 queryset和serializer_class

                ```
                ...
                queryset = None
                serializer_class = None
                ...
                ```

                2. 为detailview 默认制定pk为查询的依据

                ```
                    lookup_field = 'pk'
                    lookup_url_kwarg = None
                ```

                3. 定义 get_queryset get_serializer_class等class,指定分页 扩展第一个功能

                4. 参看 mytest.view_test5.py 我们可以直接调用他的函数，获取序列化的数据
                返回给前端

                ```


                 class UserListTest5V1(generics.GenericAPIView):
                    queryset = User.objects.all()
                    serializer_class = UserSerializer

                    def get(self, request, format=None):
                        serializer = self.get_serializer(self.get_queryset(), many=True)
                        return Response(serializer.data)
                ```




    4. 访问速度控制

    mytest.view_test1.py
    
    ```
    from rest_framework.throttling import UserRateThrottle
    ...

    class OncePerDayUserThrottle(UserRateThrottle):
        rate = '1/day'

    class ListUsersV2(APIView):

    ...
    throttle_classes = (OncePerDayUserThrottle,)
    ...


    ```

3. Generic views 封装了一定功能的view类

    1. 简介: 回想django的listview 我们通过这个类无需自己去数据库取东西,
    只需要告诉他我们的model是什么 模板用什么 他就可以帮我们自动的完成浏览你要
    访问的model,然后返回给模板数据

    2. ListAPIView 类似于detailview一样 返回给我们所有数据的列表

        1. queryset 告诉他我们需要使用哪个数据

        2. serializer_class 告诉他我们使用哪个序列化定义

    mytest.view_test2.py
    
    ```

    from django.contrib.auth.models import User
    from rest_framework import generics
    from rest_framework.permissions import IsAdminUser
    from rest_framework import serializers


    class UserSerializer(serializers.Serializer):
        username = serializers.CharField(max_length=50)

    class UserList(generics.ListAPIView):
        queryset = User.objects.all()
        serializer_class = UserSerializer


    ```

    mytest.urls.py

    ```

    ...
    from mytest.view_test2 import UserList


    urlpatterns = [
        ...
        url(r'test5',UserList.as_view()),
        url(r'^', include(router.urls)),

    ]

    ```



    3. ListAPIView解析

        查看他的源码 发现他是由mixins和GenericAPIView组合生成的一个类,
        其中重写了get方法,让get方法去执行mixins里面的list方法

        ```
        class ListAPIView(mixins.ListModelMixin,
                          GenericAPIView):
            """
            Concrete view for listing a queryset.
            """
            def get(self, request, *args, **kwargs):
                return self.list(request, *args, **kwargs)
        ```

        mixins是什么，如何理解mixins就成了理解这个类的关键

    4. Mixin解析

        1. 简介:通过上面的ListAPIView 我们可以有了很便捷的方式去获取数据库里面的
        数据 比如通过下面函数我们就可以获取到序列化的数据
        ```
        serializer = self.get_serializer(self.get_queryset(), many=True)
        ```


        2. 但是这样不符合DRY原则,我们每次使用ListAPIView或者APIVIEW
        我们都需要自己的去序列化数据返回给前,我们需要一种方法,他已经给我们
        写好了,我们只需要去继承他,就可以免费的使用它的序列化方法,所有就有了
        Mixins,我们继承mixins其实 就是去让他改写了我们get post等等方法,我们
        就不用想

        3. mixins
            1. ListModelMixin  对应获取列表的方法

            2. RetrieveModelMixin 对应获获取一条数据

            3. CreateModelMixin 对应创建数据

            4. UpdateModelMixin 对应修改数据的时候调用

            5. DestroyModelMixin 对应删除数据的时候调用






    5. 组合构建view的思路解析

        1. APIView

            1. 里面实现了很多基础的方法,比如我们可以通过APIView
            去截获 get post方法，去限制访问速度,限制用户权限

            > 参看 mytest.view_test1.py

            ```
            ...
             class ListUsersV2(APIView):
            ...

            ```

            > 参看 APIView的源码

            2. 比如我们需要获取User表里面的部分数据,我们会怎么办

            练习: 自己实现一个通过get,post,put,delete等方法访问,获取用户不同的字段信息,
            或者返回不同的值,表示了你访问了不同的方法

            答案: mytest.view_test3.py
            
            ```

            from rest_framework.views import APIView
            from django.contrib.auth.models import User
            from rest_framework.response import Response


            class ListUsersV2(APIView):

                def get(self, request, format=None):
                    return Response([i.username for i in User.objects.all()])

            ```

            3. 使用get方法获取用户数据 username,email,password, 并且是key:value的形式
            答案: mytest.view_test3.py
            
            ```

            class ListUsersTest3V2Serializer(serializers.Serializer):
                username = serializers.CharField(max_length=100)
                email = serializers.EmailField()
                password = serializers.CharField(max_length=100)


            class ListUsersTest3V2(APIView):

                def get(self, request, format=None):
                    # datas = []
                    # for i in User.objects.all():


                    datas = ListUsersTest3V2Serializer(User.objects.all()[0])
                    return Response(datas.data)

            ```
            我们可以把数据交给序列化去帮我们把数据转化成可迭代对象或者可以被json化的数据

        2. Mixin + APIView
            1. 通过上面的接口可以知道,我们可以通过APIView实现很多我们想要的功能,
            但是,很多逻辑需要我们自己去实现,比如创建一条时间,遍历一条数据。我们也需要去
            定义get post方法去识别这些方法,来判断是否是遍历数据还是添加数据.这时候 我们
            需要mixin去帮我们实现这些功能,我们就可以少些重复性的代码。

            2. 查看mixin源码 mixins.ListModelMixin 我们可以看到他有一个list方法,
            方法的含义是把model里面的数据交给一个serializer 然后返回数据 这样 listMixin
            就有了遍历所有数据的功能

            ```
            class ListModelMixin(object):
            """
            List a queryset.
            """
            def list(self, request, *args, **kwargs):
                queryset = self.filter_queryset(self.get_queryset())

                page = self.paginate_queryset(queryset)
                if page is not None:
                    serializer = self.get_serializer(page, many=True)
                    return self.get_paginated_response(serializer.data)

                serializer = self.get_serializer(queryset, many=True)
                return Response(serializer.data)

            ```

            3.问题: 既然我们有mixin 为什么不直接继承mixin 而是需要把mixin和APIView
            结合来使用？

        3. ListAPIView其实就这个就是帮你把Mixin和apiview组合好了给你直接使用,
        还有其他很多方法 RetrieveAPIView,DestroyAPIView,RetrieveUpdateDestroyAPIView
        这些便捷的组合方法

        > 我们只需要告诉他使用哪个model queryset serializer_class即可,他自动会帮我们
        完成数据遍历的功能和返回Response的工作
        
        ```
        class ListUsersTest3V3(ListAPIView):

            model = User
            queryset = User.objects.all()
            serializer_class = ListUsersTest3V2Serializer

        ```


        4. rest_framework.viewsets 更加高层的继承方法
            1. GenericAPIView 和 GenericViewSet


                1. 我们可以看到（源码） ListAPIView  viewsets 都是用了各种mixin
               来做组合，但是 他们最后用的GenericAPIView GenericViewSet却不一样。

                2. 所以问题出在 继承的不同的组合mixin 和 GenericAPIView,GenericViewSet
               我们已经了解不同的mixin会给我们带来不同的快捷使用方法
               现在问题就出在 GenericAPIView GenericViewSet

                3. 再次研究 GenericAPIView GenericViewSet我们可以看到
                GenericViewSet继承自 GenericAPIView 和ViewSetMixin，我们已经知道
                GenericAPIView的用处,那么GenericViewSet其实就是去扩展GenericAPIView,
                通过和ViewSetMixin去扩展

                4. ViewSetMixin 其实就是去改写我们的 get post等方法,让他在request.action
                里面变成 list create等等 观察下面的代码


                >mytest.view_test4.py
                
                ```
                class UserListTest4V1(generics.ListAPIView):
                    queryset = User.objects.all()
                    serializer_class = UserSerializer

                    def get_queryset(self):
                        x = self.request.method
                        return super().get_queryset()


                class UserListTest4V2(viewsets.ReadOnlyModelViewSet):
                    queryset = User.objects.all()
                    serializer_class = UserSerializer

                    def get_queryset(self):
                        x = self.action
                        return super().get_queryset()
                ```

                在return上面断点 查看x的值是什么

                5. 再次查看ListAPIView源码 我们发现他的代码逻辑是重写了
                get方法 把get方法换成mixins里面的list方法
                
                ```

                class ListAPIView(mixins.ListModelMixin,
                  GenericAPIView):
                    """
                    Concrete view for listing a queryset.
                    """
                    def get(self, request, *args, **kwargs):
                        return self.list(request, *args, **kwargs)

                ```

                6. 查看viewsets中的方法,没有重写任何方法，直接继承过去,
                得益于我们的GenericViewSet把我们的方法换成了list等等,所以可以直接
                去使用

            2. viewset系列的里面的各种方法

                1. ReadOnlyModelViewSet

                    只能查看单条数据或者多条数据

                2. ModelViewSet

                    增删查改四种方法

    6. 总结:
        1. 最基本的drf的view函数

        2. APIView 提供了权限 限速等等功能 和高级的GenericAPIView提供了必须自定义序列化
        和请求哪个数据库

        3. ListCreateAPIView等等组合的view 来实现各种常用的方法 但是他需要改写get post等等

        4.  ModelViewSet 等等更高级的组合view 他无需改写 get post方法

        5.  区分 generics里面的view 和 viewset里面的view 两者都是组合功能 都可以使用,但是后者更好
        用


### 2. serializers

1. serializers 序列化类的意义(验证数据和展示数据)
    1. 序列化的简介:
        就像form表单一样,帮你生成表单和验证表单,序列化帮你验证和生成数据

    2. 序列化的意义:
        把我们复杂的数据库请求,请求之后得到的数据,转化成json,xml等简单的数据库格式
        类似于之前学到的form表单和formModel类,把我们定义复杂的表单转化成html的实际表单
        ,这样你就不会在乎数据是怎么转化成html或者json的细节问题,只用定义好你对数据要求的
        格式，和需要序列化哪些数据即可

2. 外部使用django:
    1. django平时使用它的的功能把一些数据存入数据库,我们需要启动django的server(runserver),
            定义view然后做路由,然后定义url，访问url,django才会执行view里面的
            相应的函数,试想一下,如果我们直接去执行一个定义好的文件去存入数据,肯定会报错

            见 mytest.test1.py

    2. 但是我们也可以在不启动django server的情况下,启动django的api,比如刚才的存入数据，我们只需要
            在代码的运行环境中去设置django的目录,django的配置（settings.py）的位置接口,我们可以
            解决这个报错,也就可以从外部去启动django

            见 mytest.test2.py

3. 如何把对象序列化

    >mytest.tests.py  在下面的代码中 创建一个对象 然后把对象交给序列化去处理

    ```

        from django.test import TestCase

        # Create your tests here.


        if __name__ == '__main__':
            import sys, os

            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            sys.path.append(base_dir)
            os.environ['DJANGO_SETTINGS_MODULE'] = 'drf_movie_rimi.settings'

            from datetime import datetime
            from rest_framework import serializers


            class Comment(object):
                def __init__(self, email, content, created=None):
                    self.email = email
                    self.content = content
                    self.created = created or datetime.now()


            comment = Comment(email='leila@example.com', content='foo bar')


            class CommentSerializer(serializers.Serializer):
                email = serializers.EmailField()
                content = serializers.CharField(max_length=200)
                created = serializers.DateTimeField()


            serializer = CommentSerializer(comment)
            print(serializer.data)

    ```

         >mytest.tests.py
        使用serializer可以帮我们验证错误的数据


    ```
             ...
             comment_error = Comment(email='leila@example.com', content='foo bar')
             serializer_error = CommentSerializer(data=comment_error)
             print(serializer_error.is_valid())
             print(serializer_error.errors)
    ```
    
4. 序列化详解

    1. serializers.Serializer 最基础的序列化类

        1. 需要我们像form 一样自己去定义每个字段的要求
        
	        >mytest.tests.py
	
	        ```
	        class CommentSerializer(serializers.Serializer):
	            email = serializers.EmailField()
	            content = serializers.CharField(max_length=200)
	            created = serializers.DateTimeField()
	        ```

        2. 序列化后的数据，只会包含我们定义的数据，注意,就像form一样,不管我们的原始
	        数据里面有好多数据,序列化出来的也只有我们定义的时候的那么多字段，注意我们的				对象
	        有test=5但是序列化后的数据是没有test字段的
	        
	        >mytest.tests.py
	        
	        ```
	        
	            class Comment(object):
	                def __init__(self, email, content, created=None):
	                    self.email = email
	                    self.content = content
	                    self.test = '5'
	                    self.created = created or datetime.now()
	        
	        
	            # 实例化一个对象 给予邮箱和内容
	            comment = Comment(email='leila@example.com', content='foo bar')
	        
	        
	            # 定义序列化的数据要求
	            class CommentSerializer(serializers.Serializer):
	                email = serializers.EmailField()
	                content = serializers.CharField(max_length=200)
	                created = serializers.DateTimeField()
	
	        ```
        3. 序列化类可以帮我们验证数据是否满足我们定义的要求,就像form验证数据一样

            1. 我们新建一个对象
            
            2. 把对象进行序列化成dict
            3. 把序列化后的数据(dict)交给序列化类检查(注意使用data)
            4. 验证后 可以使用is_valid查看是否验证成功
            5. errors可以查看验证失败的信息
            6. 验证成功后可以通过validated_data来查看验证成功后的数据
        
	        ##### 注意:他只能验证 dict的数据 而且调用方法也不一样
	        
	        >mytest.tests.py
	        
	        ```
	        
	        ...
	        
			    comment_error = Comment(email='leie@mple.com', content='foo bar')
			    comment_data = CommentSerializer(comment_error)
			    serializer_error = CommentSerializer(data=comment_data.data)
			    print(serializer_error.is_valid())
			    print(serializer_error.errors)
			    print(serializer_error.validated_data)
	        
	        ```
        
        4. 我们可以把序列化后的dict转化为json数据格式
        
        
			 	 >mytest.tests.py
					
					
		        ```    
		        		...
		        		from rest_framework.renderers import JSONRenderer
		    			json = JSONRenderer().render(comment_data.data)
		    			print(json)
		        
		        ```
		        
	        
		   同样 把json转化回来成dict
		   
	
		         ```
		              ...
		              
		              from django.utils.six import BytesIO
					    from rest_framework.parsers import JSONParser
					
					    stream = BytesIO(json)
					    data = JSONParser().parse(stream)
		         
	            ```
	            
	2. serializer 自带数据的存储功能,我们可以定义创建数据或者修改数据的的时候去数据库保存数据
		 1. serializer 带有save 方法,调用save方法可以调用他的create和update方法,
		 在create方法中我们可以去添加自己的逻辑,比如保存数据。
		 
	    2. 保存数据 我们需要定义create方法 让他在调用save的时候的保存数据

		 	> mytest.serializer_test1.py
			 
		    ```
		    
				if __name__ == '__main__':
			    # 外部启动django的方法
			    import sys, os
			    from django.core.wsgi import get_wsgi_application
			
			    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
			    sys.path.append(base_dir)
			    os.environ['DJANGO_SETTINGS_MODULE'] = 'drf_movie_rimi.settings'
			    application = get_wsgi_application()
			
			    from rest_framework import serializers
			    from mytest.models import Mytest
			
			    class MyTestSerializer(serializers.Serializer):
			        name = serializers.CharField(max_length=20)
			        age = serializers.IntegerField()
			        id = serializers.IntegerField()
			
			        #重写save方法 让他验证成功后保存数据
			        def create(self, validated_data):
			            return Mytest.objects.create(**validated_data)
			
				...
			
			
			    serializer_data = MyTestSerializer(data={'name':'测试','age':81})
			    #必须调用了is_valid之后才能调用save方法
			    serializer_data.is_valid()
			    serializer_data.save()
	
		    
		    ```
	    
	    3. 重写update方法 在调用 CommentSerializer(comment, data=data)后再调用save方法 他会去执行我们update函数
	    
			> mytest.serializer_test1.py
				
				
	        ```
	            class MyTestSerializer2(serializers.Serializer):
			        name = serializers.CharField(max_length=20)
			        age = serializers.IntegerField()
			        id = serializers.IntegerField()
			
			        # 重写update方法 让他验证成功后更新数据
			        def update(self, instance, validated_data):
			            id = validated_data.get('id')
			            #获取manager
			            obj = instance.objects.filter(pk=id)[0]
			            #更新数据
			            obj.name = validated_data.get('name', obj.name)
			            obj.age = validated_data.get('age', obj.age)
			            try:
			                #保存更新
			                obj.save()
			            except Exception as e:
			                x = e
			                pass
			
			            return obj
			
			
			    data = Mytest.objects.all()[0]
			    serializer_data = MyTestSerializer2(Mytest, data={'id':4,'name': '测试', 'age': 81})
			    # 必须调用了is_valid之后才能调用save方法
			    serializer_data.is_valid()
			    serializer_data.save()
	        
	        ```

	    4. 梳理:
	    
	        1. 创建数据 serializer_data = MyTestSerializer(data={'name':'测试','age':81})后save是调用create方法

	        2. 更新数据 serializer_data = MyTestSerializer2(Mytest, data={'id':4,'name': '测试', 'age': 81}) 由于没有指定更新到哪个model 所以我们需要把Model传递给我们的MyTestSerializer2

	        
	    
    3. ModelSerializer 
    
        1. 简介 ModelSerializer 类似于我们的formModel类，你需要给定一个数据库的,他会自动的帮你生成验证规则。然后你给定要验证哪些字段(field)就可以了

        2. model serializer中也自带了create和update的方法,我们验证了数据之后可以直接存入数据库(因为我们已经给定了model)

        3. ModelSerializer相当于我们基础serializer的升级版,帮我们简化了很多操作
        
        4. 使用示例
        
        	> mytest.serializer_test2.py
        	
	        ```
	        
			 if __name__ == '__main__':
		    # 外部启动django的方法
		    import sys, os
		    from django.core.wsgi import get_wsgi_application
		
		    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
		    sys.path.append(base_dir)
		    os.environ['DJANGO_SETTINGS_MODULE'] = 'drf_movie_rimi.settings'
		    application = get_wsgi_application()
		
		    from rest_framework import serializers
		    from mytest.models import Mytest
		
		
		    class MyTestSerializer(serializers.ModelSerializer):
		        class Meta:
		            model = Mytest
		            fields = ("name", 'age')
		
		
		    data = MyTestSerializer(data={'name': 'model', 'age': 54})
		    data.is_valid()
		    data.save()
	        
	       
	        ```
	    5. 扩展方法:
	        1. fields : 
	            2. ’“__all__”‘ 代表所有的字段
	            3.  exclude = ('users',) 代表除了 user字段 其他字段都可以

	            
1. 综合使用示例:

	>mytest.test1_views.py
	
	```

		class BookListV2ViewSet(mixins.DestroyModelMixin,mixins.ListModelMixin,mixins.UpdateModelMixin,
								mixins.RetrieveModelMixin,GenericViewSet):
		    queryset = Book.objects.all()
		    serializer_class = BookListSerializer
		
		    def get_queryset(self):
		
		        method = self.request.method
		
		        x = self.action
		        return Book.objects.all()
		
		
		"""
		实现一个方法:放里面有书,
		1.随便哪个用户可以去创建一本书
		2.只有创建这本书的用户可以去修改这本书
		3.只有创建这本书的用户可以去删除这本书
		4.所有用户可以看到所有的书
		"""
		class BookSerializer(serializers.ModelSerializer):
		
		
		    class Meta:
		        model = Book
		        fields = "__all__"
		
		    def create(self, validated_data):
		        validated_data['creator'] = self.context['request']._user
		        validated_data['name'] = '不好意思'
		
		        return super().create(validated_data)
		
		
		    def update(self, instance, validated_data):
		
		        if self.context['request']._user != instance.creator:
		            raise serializers.ValidationError('不是创建者')
		        return super().update(instance,validated_data)
	
	
	```

### 3. url 路由表定义

1.router.register() 只有继承了viewset的类才能使用



#  项目

### 1. 项目简介
    
1. 下载猫眼电影 高仿猫眼电影app
2. restful的风格的基本概念

    1. api接口开发模式

	后台服务器只提供数据接口和返回数据,由前端js负责获取数据。然后动态的展现在前端。

	前后分离的好处-->后端只负责逻辑接口和数据,前端只负责页面展现逻辑。前后端工作进度
	互不干扰

	现在主流的开发模式基本都是前后分离

    2. restful基本概念

		1. 一切的url代表的是资源,api通过get post del等动作去操控资源
		
		restful的目的在于统一化清晰化url的,一个大型网站有很多不同的url,使用restful之后可以很好的管理资源
		
		相关资料
		> http://www.ruanyifeng.com/blog/2014/05/restful_api.html
		
		>  http://www.ruanyifeng.com/blog/2011/09/restful.html
		
		2. restful只是一套url设计理念,具体还是需要自己去实现
		
    3. 再次查看接口文档
        1. create 创建一个实例 post方法

		2. list 获取多个实例 get方法
		
		3. read 方法 获取指定的实例
		
		4. update partial_update更新 put PATCH
		
		5. delete 销毁一个实例 delete

### 2.项目登录

   1. 新建用户model
   
       1. 分析:
            1. 我们知道 django自带的用户系统里面有很多可以用的数据,比如email 是否激活等等,但是还有其他信息需要我们自己去定义,比如手机 生日 昵称 地址 用户头像
            
       2. 创建app和user的model

           ```
           startapp users
           ```
           
       3. 创建用户模型
       
		>users.model.py
			
	       ```
	       from django.db import models
			from django.contrib.auth.models import AbstractUser
		
			# Create your models here.
			
			class UserProfile(AbstractUser):
			    """
			    用户信息
			    """
			    IS_VIP = (
			        (False, '非会员'),
			        (True, '会员')
			    )
			
			    GENDER = (
			        ("male", "男"),
			        ("female", "女")
			    )
			
			    nick_name = models.CharField(default="", max_length=50, verbose_name="昵称", null=True, 
			    								blank=True)
			    birthday = models.DateTimeField(verbose_name="生日", null=True, blank=True, 
			    						auto_created=True)
			    gender = models.CharField(max_length=1, choices=(("1", "男"), ("2", "女")), default="1", 
			    						null=True,blank=True)
			    address = models.CharField(max_length=100, default="", verbose_name='用户所在城市', 
			    						null=True, blank=True)
			    mobile = models.CharField(max_length=14, default="", verbose_name='手机号')
			    register_time = models.DateTimeField(auto_now=True)
			    
			    class Meta:
			        verbose_name = "用户信息"
			        verbose_name_plural = verbose_name
			
			    def __str__(self):
			        return str(self.mobile)
	       
	       
	       ```
	   > settings.py
	   
		   ```
			   ...
			   AUTH_USER_MODEL = "users.UserProfile"
			   ...
			   
			   INSTALLED_APPS = [
						...
				    'users.apps.UsersConfig'
				]
		   
		   ```
		   
		    注释掉settings.py里面的 'django.contrib.admin', 这一行
		   
		   ```
		       makemigrations
		       migrate
		   ```
		   

			打开注释掉settings.py里面的 'django.contrib.admin', 这一行
			
      4. 知识点:
          1.  扩展django已经有的user需要去继承django本身的用户模型表

			>users.model.py
				
	          ```
	          
			          from django.contrib.auth.models import AbstractUser
			
			
						# Create your models here.
						
						
						class UserProfile(AbstractUser):
						...
	          
	          ```
	        
	      2. 在字段信息中新建 choices 参数,表示字段里面的只能是choices里面元组的几个值之一,tuple里面的第一个值是数据库里面值,第二个是备注,比如 数据库里面存 1 表示男 2表示女
	      >users.model.py
	      
		       ```
		           ...
		           
		             GENDER = (
				        ("1", "男"),
				        ("2", "女")
				    )
				
				    nick_name = models.CharField(default="", max_length=50, verbose_name="昵称", 
				    							null=True, blank=True)
				    birthday = models.DateTimeField(verbose_name="生日", null=True, 
				    							blank=True, auto_created=True)
				    gender = models.CharField(max_length=1, choices=GENDER, default="1", null=True,
		           
		           ...
		       
		       ```

	      3. 参数 null=True , blank=True分别表示数据里面可以存null这个值,和数据库里面可以存空值,记住 null 和空值是不一样的

	      4. 参数 auto_now auto_now_add 表示添加数据的时候默认添加当前时间,以后不会自动修改; 修改数据的时候默认添加当前时间,每次修改都会自动变化

	      5. class Meta: 里面的verbose_name 表示amdin查看这个表的时候 会出现你输入的表名
	      6. def __str__(self） 表示查看数据的时候(admin中),每一条数据会返回你定制化的标题,比如我们这个表就会返回一系列的手机号

	      7. 字段里面加入unique表示我们不能重复！ 			
	        >1. 但是这个unique会造成我们的一个困境,如果是注册手机号的话,我们每次新建用户就必须输入不同的手机号,你不能不输入,但是如果我们是用户名和邮箱注册的话,那么我们在注册的时候是不会用到手机号。
	      		
	        >2. 解决方案是给他设置null=True,defalut=None
	        >3. 解决方案的原理是计算机中有一个null|None表示(无),这个在这个计算机中是唯一的

	      	

   2.  制作 注册 登录 注销模块
   
      1. JWT
		
	      1. 简介: 传统的session登录方式受限于设备和浏览器,如果我们制作的是一个app而不是使用浏览器去访问。那么我们的整个的
	      
	      保持用户登录就会变得很麻烦,再者 判断用户登录是否成功也不能依赖于我们的模板文件了 官网地址：
	     > http://getblimp.github.io/django-rest-framework-jwt/
	
	       
	      2. token: token有令牌的意思,他类似以于我们的session，是一串加密数字。我们可以把它理解为session的升级版,因为token更灵活,他可以用于手机app 网页任何地方
	       
	      3. JWT: JWT-> json web token 是token的一个json实现标准,你可以理解为一般互联网企业都是这样做的。所以我们也拿来用即可。JWT最明显的特征是 JWT不会存在于数据库，它类似于csrf_token，我们只用去验证加密是否通过,通过之后就是合法的用户。
	      


	      4. 安装

              ```
                pip install djangorestframework-jwt
              ```

              在配置文件里面加入,下面这行代码的意思是使用token来认证用户身份

              >settings.py

              ```
                  ...
                  REST_FRAMEWORK = {
                    # Use Django's standard `django.contrib.auth` permissions,
                    # or allow read-only access for unauthenticated users.
                    # 'DEFAULT_PERMISSION_CLASSES': [
                    #     'rest_framework.permissions.DjangoModelPermissionsOrAnonReadOnly'
                    # ]

                    'DEFAULT_AUTHENTICATION_CLASSES': (
                        'rest_framework_jwt.authentication.JSONWebTokenAuthentication',
                    ),
                }
                ...
              ```

              >urls.py

              ```
              from rest_framework_jwt.views import obtain_jwt_token
                #...

                urlpatterns = [
                    '',
                    # ...

                    url(r'^api-token-auth/', obtain_jwt_token),
                ]

              ```

          5. 访问 /docs/接口，就可以看到登录的界面(文档自动生成)

          6. 试着登录 就可以看到返回,这个就是我们的登录秘钥,拿着这个秘钥就可以去验证
          用户信息

          ```
                 {
                "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImNhbnZhcyIsImV4cCI6MTUzMjAwODg5OSwiZW1haWwiOiIyQDIuY29tIn0.mVhVHMIZZ2qqhzBen7kS8csylx7yrif1gQhw-09wcus"
                }

          ```
          
          7. 我们把token取出来,在postman上面添加上我们的token
          	1. 在post man headers里面去添加一个 key 为 Authorization
          	value为 JWT（空格） eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImNhbnZhcyIsImV4cCI6MTUzMjAwODg5OSwiZW1haWwiOiIyQDIuY29tIn0.mVhVHMIZZ2qqhzBen7kS8csylx7yrif1gQhw-09wcus
          
          8. 在我们的views里面去配置用户认证
          
          	```
          	from rest_framework_jwt.authentication import JSONWebTokenAuthentication
          	class xxxView()
          	...
          		authentication_classes = (JSONWebTokenAuthentication,)
          	```
          	
          9. 再访问我们的接口看看是不是把用户取出来了

          10. JWT配置:
		
			设置token的过期时间JWT_EXPIRATION_DELTA
			
          ```
          
	          JWT_AUTH = {
	
	
	
			    'JWT_EXPIRATION_DELTA': datetime.timedelta(seconds=3600),
			
			
				}
          
          ```
          	
	     
	      
	  2. 利用JWT做登录接口
	      
	      1. 我们可以从后台新建用户,所以我们可以先做登录,上面我们看到 JWT 登录成功之后返回的是一串token,所以我们登录的任务就是验证数据库账户密码,然后返回一串token给前端。前端以后的请求每次都会带上这个token来,关于前端具体情况我们不用关心。
	      
	      2. 所以我们的问题流程就分解为
	      
	          1. 接收用户传递过来的账户密码
	          2. 验证账户密码
	          3. 验证成功返回token(这里就不用去调用login 接口了 因为我们不用session去做登录) 
	          
	      3. 根据上面的问题流程我们的代码聚体步骤就分为:
	          1. 通过一个view去接收参数,这个view不需要多余的功能,也不会创建遍历数据,只是接收和返回值，所以我们选用 APIView来做view


	          2. 我们需要一个函数去验证用户名和密码,这个函数我们已经知道,django的auth接口
	          3. 我们在最后需要一个东西去加密用户信息成为标准token,然后返回给前端,我们需要jwt的标准接口 查看官网 
	          
	          http://getblimp.github.io/django-rest-framework-jwt/
	          
	          我们可以看到最后官网给了我们标准的token加密方法,代码指出,我们给定用户,然后交给他的用户,他就会给出token,然后我们把token返回给前段即可
	          
		          ```
		          
			          from rest_framework_jwt.settings import api_settings
		
						jwt_payload_handler = api_settings.JWT_PAYLOAD_HANDLER
						jwt_encode_handler = api_settings.JWT_ENCODE_HANDLER
						
						payload = jwt_payload_handler(user)
						token = jwt_encode_handler(payload）
		          ```
		          
		      4. 根据以上思想形成真实代码示例:
		       
		       > users.views.py
		       
			           ```
			           
			              from rest_framework.views import APIView
							from rest_framework_jwt.settings import api_settings
							from rest_framework.response import Response
							from django.contrib.auth import authenticate
							from .serializers import UserLoginSerializer
							
							
							class UserLogin(APIView):
							    def post(self, request):
							
							        datas = UserLoginSerializer(data=request.POST)
							        if datas.is_valid():
							            user = authenticate(**datas.validated_data)
							            if user:
							                jwt_payload_handler = api_settings.JWT_PAYLOAD_HANDLER
							                jwt_encode_handler = api_settings.JWT_ENCODE_HANDLER
							
							                payload = jwt_payload_handler(user)
							                token = jwt_encode_handler(payload)
							                return Response(token)
							
							        return Response(status=401)
	
			           
			           ```
			           
			       > users.serializers.py
			       
			       ```
			       
			       from rest_framework import serializers

					class UserLoginSerializer(serializers.Serializer):
					    username = serializers.CharField(max_length=20,help_text='用户名')
					    password = serializers.CharField(max_length=20,help_text='密码')
			       
			       ```
		           
		           
	3. 利用JWT做注册接口
	
	    1. 流程解析:
	        1. 用户提交注册申请,也就是用户名密码
	        2. 后端验证用户名是否存在,存在返回错误
	        3. 生成用户
	        4. 给生成的用户返回token 然后直接登录成功
	        
	    2. 代码解析:
	    
	    	1. 接收用户的参数
	    	2. 验证用户名是否重复
	    	3. 生成用户
	    	4. 返回token
	    
	    3. 代码示例:
	    		>users.views.py
	    		
		       ```
		       ...
		       
		       class UserRegister(APIView):
			    # 如果是post请求
			    def post(self, request):
			        # 我们验证他的post数据,和序列化
			        datas = UserLoginSerializer(data=request.POST)
			        if datas.is_valid():
			            # 我们把验证成功的数据交给django验证
			            data = datas.validated_data
			            # 获取用户model
			            User = get_user_model()
			            # 获取用户信息
			            user = User.objects.filter(username=data['username'])
			            # 如果有用户则不创建用户
			            if not user:
			                user = User.objects.create_user(**data)
			                # 调用jwt官方指定的方法加密用户信息获取到token
			                jwt_payload_handler = api_settings.JWT_PAYLOAD_HANDLER
			                jwt_encode_handler = api_settings.JWT_ENCODE_HANDLER
			
			                payload = jwt_payload_handler(user)
			                token = jwt_encode_handler(payload)
			                return Response({'token': token})
			        # 如果失败,我们统一返回401表示登录不成功
			        return Response(status=401)
		           
		       ```
		       
		   还可以使用mixins去注册用户
	> users.views.py
	
			```
				
			# 通过mixin来创建用户
			from django.contrib.auth.hashers import make_password
			from django.contrib.auth import get_user_model
			from rest_framework import mixins
			
			User = get_user_model()
			
			
			class UserInfoSerializer(serializers.ModelSerializer):

			...
			略
			```
	

		       
    4. 扩展注册接口
    	1. 简介:我们的注册远没有那么多简单,我们需要手机注册,发送短信验证码。或者邮箱验证码之类的。然后填入验证码才能激活用户
    	2. 为了防止爬虫,我们需要在下面多添加一个图形验证码。每次请求需要用户提交图形验证码系统才会执行发送短信的接口。
    	3. 试想一个问题:
    	
    	    1. 发送短信的原理其实就是我们首先去运营商那里购买短信服务,然后提交要送发的短信内容,和接收的短信的手机号。是运营商帮我们去发送短信。然后发送成功后,运营商通知我们短信发送成功。我们去通知用户。

    	    2. 上面那个流程有一个重大的bug,在上面的步骤中,请求运营商发送短信和等待运营商通知我们的服务器接收短信的时间是很长的。用户会一直卡在那里,程序也会一直卡在那里。如果运营商发送短信的时间很长,那么势必会卡死我们的程序线程。那么一个新开的网站,用户访问量大得时候,你是无法去承载这个网站的
    	    3. 这个时候,我们需要异步接口,即把发送短信请求或者发送邮箱请求的接口交给其他程序去做,我们不用理会,直接返给给用户申请成功。请求等待短信即可

    
		    4. 画图解释
		    
		4. 问题解决思路:
		    1. 我们需要知道注册的具体流程:
		    
		        1. 首先 注册时候手机验证码是在后台生成的,然后存入数据库,但是要首先验证码账户是否存在
		        2. 把这个验证码 通过一定的接口发送给用户
		        3. 用户得到验证码之后,再把账户和验证码和密码一起提交,服务器收到验证码和用户名之后,对比数据库,如有符合的数据,就可以确认这个手机(收到验证码的手机)是这个用户的。
		        4. 传统方式下 第一步第二步是链接在一起的
		        5. 如果是异步接口,我们的程序只到第一步,第二步骤会有专门的程序去执行这个接口。
		        6. 执行这个异步接口的实现方案是 队列任务,顾名思义,就是让发送验证码这个耗时的操作去让其他程序执行,如果其他程序执行不过来,那么发送验证码任务就会排队处理（在其他程序中,主程序已经结束）,但是这不会影响到用户体验,因为用户收到验证码这个时间本来就是耗时的。
		        
		5. 代码思路:
		    1. 接受用户账户的接口,验证账户是否已经存在
		    2. 生成随机验证码的接口
		    3. 请求发送验证码的接口
		    4. 接受异步任务的接口
		    5. 由于没有手机验证码,我们使用邮箱验证码做替代
		    
		6. 基本代码实现 
		
		   1. 传统的同步方式 没有图像验证码 发送接收一个邮箱,然后发送邮箱验证码,我们首先建立一个接受验证码的model 里面有邮件 验证码两个字段 外键添加时间判断验证码是否过期
		   
		      >users.models.py
		   
			   ```
			   
			 class CaptchaReg(models.Model):
				    """
				    用户注册验证码
				    """
				
				    captcha = models.CharField(max_length=6, verbose_name='验证码', help_text='验证码')
				    email = models.EmailField(verbose_name='注册邮箱',help_text='注册邮箱')
				    add_time = models.DateTimeField(auto_now=True, verbose_name='添加时间', 
				    help_text='添加时间')
				
				    class Meta:
				        verbose_name = '用户注册验证码'
				        verbose_name_plural = '用户注册验证码'
			   
			   ```
			   
		   2. 我们使用createmixins来做view 因为我们相当于去创建一条验证码的数据
		   3. 我们需要在serializer中改写captcha的方式,让captcha字段自动去生成,而且不是让用户传递过来

        			  
         		
          4. 我们还需要创建两个函数
         
			  1. 一个是生成随机验证码的

				  ```		  
				  def gen_captcha():
					    captcha_str = ""
					    for i in range(6):
					        captcha_str += str(random.randint(0, 9))
					    return captcha_str
				  
				  ```
			  2. 把生成的随机验证码通过邮件发送

			5. 把生成验证码的函数放在serializer里面
				1. 知识点
				    1. serializer里面的validate函数可以帮我们验证数据,并且把合法的数据传递给create函数去创建数据,由于我们没有定义captcha字段,但是又需要captcha字段去写入数据库,所以我们在validate里面取增加captcha 当然 增加的是我们函数调用的生成随机验证码
				    
			    
					    ```
					    
										    
							class UserRegisterCaptchaCreateSerializer(serializers.ModelSerializer):
							    """
							    验证邮箱是否已经被注册了
							    """
							
							    def create(self, validated_data):
							        email = validated_data['email']
							        if User.objects.filter(email=email).exists():
							            raise serializers.ValidationError('邮箱已经存在')
							
							        return super().create(validated_data)
							
							
							    def validate(self, attrs):
							        captcha = captchas.gen_captcha()
							        attrs['captcha'] = captcha
							        return super().validate(attrs)
					    
					    
					    ```
			    
		
			6. 生成一个发送通过邮件发送验证码的接口:
			    1. 知识点:
			    
			        1. smtp邮件服务器
			        
			            1. smtp邮件服务器是一种协议
			            2. 我们可以调用网易的smtp邮件接口给其他人发邮件
			            3. 其实就相当于你去登录网易邮件手写一封邮件
			            4. 不过由于你有了邮件接口,你可以在程序中配置好账户密码 然后调用程序去帮你发送验证码。效果和3差不多
			        2. 邮件发送接口调用
			            1. 查看自己的邮件接口
			                1. https://mail.163.com
			                2. 查看设置 最下面有pop3 smtp imap服务
			                3. 查看网易邮件服务的端口 http://help.163.com/09/1223/14/5R7P3QI100753VB8.html
			                4. 在settings.py里面去配置

			                   > mytest.settings.py

                                    ```
                                    EMAIL_HOST = 'smtp.163.com'                   #SMTP地址
                                    EMAIL_PORT = 25                                 #SMTP端口
                                    EMAIL_HOST_USER = 'qq360167228@163.com'       #我自己的邮箱
                                    EMAIL_HOST_PASSWORD = 'rimi123'                  #我的邮箱授权码

                                    ```

			                5. 然后我们调用邮件函数就可以去发送,函数主要需要邮件标题,邮件内容,收件人的地址三个参数

			                    1. 测试版本

                                    > mytest.test_mail.py

                                    ```
                                        if __name__ == '__main__':
                                            # 外部启动django的方法
                                            import sys, os
                                            from django.core.wsgi import get_wsgi_application

                                            base_dir = 
                                            os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
                                            sys.path.append(base_dir)
                                            os.environ['DJANGO_SETTINGS_MODULE'] = 
                                            'drf_movie_rimi.settings'
                                            
                                            application = get_wsgi_application()

                                            from django.core.mail import send_mail

                                            x = send_mail('注册验证码', 'Here is the message.', 
                                            'qq360167228@163.com',['qq360167229@163.com'])

                                            print(x)
                                    ```

			                    2. 正式版本:
			                    	
			                    	>utils.send_sms_email.py

			                   		```
			                   		
			                   		from django.core.mail import send_mail
										from drf_movie_rimi.settings import EMAIL_HOST_USER
										
										
										def my_send_mail(title, context, to_mail):
										    # 三个参数为 发送标题 内容 收件人
										    res = send_mail(title, context, EMAIL_HOST_USER,
										                    [to_mail])
										
										    return bool(res)

			                   		
			                   		
			                   		```

			        3. django注册发送验证码的流程

			        	1. 知识点:
			        	
			        	    1. 我们需要在整体流程的最后一步 也就是先发送验证码,发送验证码成功后,存储验证码到数据库,然后返回给用户发送成功信息。所以我们需要改写views里面的最后一步 perform_create 在这一步里面,views会存储合法数据到数据库。
			        	    2. 改写 serializers.py里面的validate 函数,由于我们只提供了email参数,所以我们必须把验证码(captcha加入进去)
			        		3. 知识点梳理 

			        		    perform_create是createmixin里面的方法。他是在最后存储数据的时候调用
			        		    
			        		    validate 是serializer里面的方法,他控制了所有有效数据的,我们可以在这里面去改写有效数据
			        		
        			 
        			    
        			    	       
						>users.views.py
						
						
						```
						...		
						
						class UserRegisterCaptchaCreateViewSet(CreateModelMixin, GenericViewSet):
						    queryset = UserRegisterCaptchaCreateSerializer.Meta.model.objects.all()
						    serializer_class = UserRegisterCaptchaCreateSerializer
						
						    def perform_create(self, serializer):
						        data = serializer.validated_data
						        captcha = '您的验证码为{}'.format(data['captcha'])
						        res = my_send_mail('注册验证码',captcha,data['email'])
						        if not res:
						            return Response(status=401)
						        return super().perform_create(serializer)
			   
						
						```
			
			
						>users.serializers.py
						
						```
						
						
						class UserRegisterCaptchaCreateSerializer(serializers.ModelSerializer):
					    """
					    验证邮箱是否已经被注册了
					    """
					
						    def create(self, validated_data):
						        email = validated_data['email']
						        if User.objects.filter(email=email).exists():
						            raise serializers.ValidationError('邮箱已经存在')
						
						        return super().create(validated_data)
						
						    def validate(self, attrs):
						        captcha = captchas.gen_captcha()
						        attrs['captcha'] = captcha
						        return super().validate(attrs)
						
						    class Meta:
						        model = CaptchaReg
						        fields = ('email',)
						
						```
						
				4. 通过mixins去做用户注册操作的版本
					>users.serializers.py
					
					```
					
										#验证码升级版##############
					class UserInfoSerializer(serializers.ModelSerializer):
					
					    # 这个步骤是专门给你用的,用于你去修改已经验证好的数据,大前提是你的数据通过验证了
					    # 才去做定制化
					    def validate(self, attrs):
					    
					    ...
					
					```
					
					>users.views.py
					
					```
					
					class UserRegisterCaptchaCreateViewSet(CreateModelMixin, GenericViewSet):
					    queryset = UserRegisterCaptchaCreateSerializer.Meta.model.objects.all()
					    serializer_class = UserRegisterCaptchaCreateSerializer
					  
					  ...
					
					```
			
					
			7. 升级版,使用队列异步发送代码 
			
			    1. [首要步骤django-celery知识点](#django-celery)
			    
			8. 继续升级邮箱验证码时间的验证
				1. 问题:
					1. 我们不能让一个邮箱才发送了一个邮件就又马上又发送,一般会有一分钟的间隔
					2. 验证码拿过来也是有时效的,一般5分钟内有效
					3. 如果一个验证码验证了,那么他就失效了
				2. 流程梳理:
				
					1. 如果你一个邮件发送后,他会有发送时间，我们规定，在1分钟之后才能发送
					2. 验证邮箱验证码时,我们永远去验证最新（时间）的验证码
					3. 如果验证码发送时间距离验证的时间超过五分钟，那么他也是无效的

				3. 代码实现:
				
					>users.serializers.py
					
						```
						
						class UserRegisterCaptchaCreateSerializer(serializers.ModelSerializer):
		
						...
						
						     #验证是否是发送验证码过于频繁
					        expire_time = timezone.now() -
					        timezone.timedelta(minutes=EMAIL_CAPTCHA['delay_time']['register'])
					
					        if CaptchaReg.objects.filter(email=email,add_time__gt=expire_time).exists():
					            raise serializers.ValidationError('请稍后再发送邮件')
					
					        return super().create(validated_data)
						```
						
					>users.settins.py
						
						```
						
						#邮箱验证码过期时间
						
						EMAIL_CAPTCHA = {
						    'expire_time':{
						       'register':5
						    },
						
						    'delay_time':
						        {
						            'register':1
						        }
						}
						
						```
						
				4. 现在 用户注册的时候,需要把邮箱验证码提交给我们,通过了才能注册
					1.我们加入验证email password username captcha的四个字段的验证码程序
					2.email和capcha要在有效时间内找到才能通过,通过后 用户基本验证成功
				
					>users.views.py
					
					```
					
					class UserRegisterV2(APIView):
					    # 如果是post请求
					    def post(self, request):
					        # 我们验证他的post数据,和序列化
					        datas = UserLoginV2Serializer(data=request.POST)
					        if datas.is_valid():
					            # 我们把验证成功的数据交给django验证
					            data = datas.validated_data
					            # 获取用户model
					            User = get_user_model()
					            # 获取用户信息
					            user = User.objects.filter(username=data['username'])
					            # 如果有用户则不创建用户
					            if user:
					                raise serializers.ValidationError('用户名重复')
					
					            # 验证验证码码是否正确
					            expire_time = timezone.now() - 
					            timezone.timedelta(minutes=EMAIL_CAPTCHA['expire_time']['register'])
					
					            if not CaptchaReg.objects.filter(email=data['email'], 
					            captcha=data['captcha'],add_time__gt=expire_time).exists():
					                raise serializers.ValidationError('邮箱错误或验证码失效')
					
					
					            user = User.objects.create_user(**data)
					
					```

				
			
	5. JWT 升级登录接口		
	    1. 我们登录接口需要验证用户名或者邮箱然后密码 合法就登录

			代码实现，我们需要把登录的合法用户取出来,然后给JWT加密 返回token信息
		   		```
		   		
			   		class UserLogin(APIView):
					    # 如果是post请求
					    def post(self, request):
					        # 我们验证他的post数据,和序列化
					        datas = UserLoginSerializer(data=request.POST)
					        if datas.is_valid():
					            # 我们把验证成功的数据交给django验证
					            user = authenticate(**datas.validated_data)
					            if user:
					                # 调用jwt官方指定的方法加密用户信息获取到token
					                jwt_payload_handler = api_settings.JWT_PAYLOAD_HANDLER
					                jwt_encode_handler = api_settings.JWT_ENCODE_HANDLER
					
					                payload = jwt_payload_handler(user)
					                token = jwt_encode_handler(payload)
					                return Response({'token': token})
					        # 如果失败,我们统一返回401表示登录不成功
					        return Response(status=401)
		   		
	   			```
	   			
### 3.项目页面展示


1. 项目需求分析:
	1. 电影模型分析:
		1. 首先我们需要一部影片信息的model 存储电影的信息
		2. 我们的电影有职员(演员 导演 编辑等等) 他们和电影是多对多
		3. 电影职员和类型也是对多对 比如马特达蒙 是演员 导演编辑
		4. 电影有所属国家 是多对多关系
		5. 电影有制作类型,比如2D, 3D等等 他和电影是对多对关系
		6. 电影有分类,比如动作,悬疑,科幻 他和电影是多对多关系
		
	2. 影院模型分析:
		 1. 我们购买电影会细化到某个影院,某个座位,某个时间的电影
		 2. 我们需要影院
		 3. 我们的影院里面有很多影厅,他和影院是一对多关系
		 4. 影厅中很多座位,他和影厅是一对多关系
		 5. 我们电影有很多的片场,每个片场必须有一个影厅,他和影厅是一对多关系
	     6. 影院有所属城市,他和影院是一对多关系
	3. 根据上面的分析 我们的模型设计如下

			>movie.model.py
		
		知识点:
		
		1. help_text 可以做描述文档使用
		2. manytomanyfield  through 可以定制manytomany表
		
	4. 合并 迁移数据, 把数据交给amdin后台管理
	
2. 数据的展示:
	1. 添加了部分数据之后,我们需要把数据给展示出来,运用我们之间学习的知识,做一个电影的数据展示接口
	
		课堂练习: 1.做一个把所有电影列表展示出来的接口(get方法)
		
	2. 思路梳理:
		1. 我们需要把数据库的里面的电影信息都展示出来,展示分为两种 一种是遍历一个列表 一种是获取一条数据的详细信息 我们一般来说 遍历只需要大致的信息,而获取详细信息需要更多的信息和关联信息比如演员 演员的相关文章等等
		2. 所以我们需要一个 view 一个url 两个serializer
		3. views根据不同的请求 来给出不同的serializer展示信息
	
	3. 代码实现(基础):
		1. 我们获取详细信息的时候 我们需要 
			1. 电影名
			2. 电影是否是热门电影
			3. 电影是否是最新电影
			4. 上映时间
			5. 电影类型
			6. 电影制片类型(2D,3D)
			7. 电影目前的状态(上映中 下架中等等)
			8. 电影的部分演员 导演
			9. id号
			10. 点赞数量
			11. 影片长度
			12. 国家
			13. 分数(评级)
			14. 用户浏览数量
			...
		2. 但是我们获取列表的时候只需要
			1. 电影名
			2. 电影想看次数
			3. 评分

			>movie.serializer.py
			
			```
			
			from rest_framework import serializers
	
			from .models import MovieDetail
			class MovieListSerializer(serializers.ModelSerializer):
			    class Meta:
			        model = MovieDetail
			        fields = ('name','status','user_want_num')
			
			
			class MovieDetailSerializer(serializers.ModelSerializer):
			    class Meta:
			        model = MovieDetail
			        fields = "__all__"
			
			```
			
			>movie.views.py
			
			```
			
			from rest_framework import viewsets
			
			from .models import MovieDetail
			
			from .serializers import MovieListSerializer
	
			class MovieViewSet(viewsets.ReadOnlyModelViewSet):
			    """
			    获取电影信息接口
			    """
			
			    queryset = MovieDetail.objects.all()
			    def get_serializer_class(self):
			        if self.action == 'list':
			            return MovieListSerializer
			        if self.action == 'retrieve':
			
			```
			
	4. 代码实现 高级
	
		1. 通过上面的接口可以看到,很多数据是没有详细的信息的, 比如kind_category,他只有id号,但是没有具体的信息,我们需要获取这些具体的信息来返回给用户
		
		 知识点:
			1. 我们需要遍历嵌套的序列化数据
			2. 我们可以通过加入其它的serializer到字段里面取,他就会自动的给我们遍历出嵌套的关系
			3. 如果是manytomany关系 我们需要定义参数 many=true
		
				>movie.serializers.py
					
					
					```
					
					from rest_framework import serializers
			
					from .models import MovieDetail, MovieCountry, SubTitle, MovieStaff, MovieStaffCategory, 
					MovieKindCategory,MovieTypeCategory
					
					
					class MovieListSerializer(serializers.ModelSerializer):
					    class Meta:
					        model = MovieDetail
					        fields = ('name', 'status', 'user_want_num')
					
					
					class MovieCountrySerializer(serializers.ModelSerializer):
					    class Meta:
					        model = MovieCountry
					        fields = "__all__"
					
					
					class SubTitleSerializer(serializers.ModelSerializer):
					    class Meta:
					        model = SubTitle
					        fields = "__all__"
					
					
					class MovieStaffSerializer(serializers.ModelSerializer):
					    class Meta:
					        model = MovieStaff
					        fields = "__all__"
					
					
					class MovieStaffCategorySerializer(serializers.ModelSerializer):
					    class Meta:
					        model = MovieStaffCategory
					        fields = "__all__"
					
					
					class MovieKindCategorySerializer(serializers.ModelSerializer):
					    class Meta:
					        model = MovieKindCategory
					        fields = "__all__"
					
					
					class MovieTypeCategorySerializer(serializers.ModelSerializer):
					    class Meta:
					        model = MovieTypeCategory
					        fields = "__all__"
					
					
					class MovieDetailSerializer(serializers.ModelSerializer):
					    movie_state = MovieCountrySerializer(many=True, read_only=True)
					    sub_title = SubTitleSerializer(many=True, read_only=True)
					    staffs = MovieStaffSerializer(many=True, read_only=True)
					    kind_category = MovieKindCategorySerializer(many=True, read_only=True)
					    type_category = MovieTypeCategorySerializer(many=True, read_only=True)
					
					    class Meta:
					        model = MovieDetail
					        fields = "__all__"
					
					
					```
					
					
	 2. 我们需要统计用户点赞数量和打分情况
	 	
	 	1. 新建点赞和打分情况的类视图(有打分和修改打分,有点赞和取消点赞)

	 		代码知识点:
	 			1. 如果两个类都引用的话 会造成循环引用,所以使用第三方来操作两个类
	 			2. serializers 里面有 hiddenfields 可以隐藏我们需要的值,然后使用 	 			
	 			3. serializers.CurrentUserDefault() 可以取出当前用户
			    
	 		
	 		>user_movie_operations.models.py
	 		
	 		```
	 		
	 			from django.db import models
				from django.contrib.auth import get_user_model
				# Create your models here.
				
				from movie.models import MovieDetail
				
				User = get_user_model()
				
				
				class UserStarMovie(models.Model):
				    """
				    用户对电影的评分,一个用户可以对多个电影评分,一部电影也可以拥有多个用户的评分,用户评分之后
				    就不能再去评分这个电影了
				    """
				
				    STAR = (
				        ('1', ''),
				        ('2', ''),
				        ('3', ''),
				        ('4', ''),
				        ('5', ''),
				        ('6', ''),
				        ('7', ''),
				        ('8', ''),
				        ('9', ''),
				        ('10', ''),
				    )
				    user = models.ForeignKey(User, verbose_name='评论用户', help_text='评论用户')
				    movie = models.ForeignKey(MovieDetail, verbose_name='所属电影', help_text='所属电影')
				    star = models.CharField(max_length=2, choices=STAR, 
				    verbose_name='用户对电影的评分', help_text='用户对电影的评分')
				
				    class Meta:
				        verbose_name = '用户评论一部电影'
				        verbose_name_plural = verbose_name
				
				        unique_together = ("user", "movie")
				
				
				class UserFavMovie(models.Model):
				    """
				    用户点赞一个电影
				    """
				
				    user = models.ForeignKey(User, verbose_name='点赞用户', help_text='点赞用户')
				    movie = models.ForeignKey(MovieDetail, verbose_name='所属电影', help_text='所属电影')
				
				    class Meta:
				        verbose_name = '用户评论一部电影'
				        verbose_name_plural = verbose_name
				
				        unique_together = ("user", "movie")

	 		
	 		```
	 		
	 		>user\_movie_operations.serializers.py
	 		
	 		```
	 		
	 		from rest_framework import serializers
			from django.contrib.auth import get_user_model
			from .models import UserStarMovie,UserFavMovie
			
			from movie.serializers import MovieListSerializer
			
			User = get_user_model()
			
			# class UserStarMovieSerializer(serializers.ModelSerializer):
			#     model = UserStarMovie
			#     fields = "__all__"
			
			
			class UserFavMovieCreateSerializer(serializers.ModelSerializer):
			    user = serializers.HiddenField(
			        default=serializers.CurrentUserDefault()
			    )
			
			
			    class Meta:
			        model = UserFavMovie
			        fields = ("user","movie","id")
			
			
			class UserFavMovieReadSerializer(serializers.ModelSerializer):
			    user = serializers.HiddenField(
			        default=serializers.CurrentUserDefault()
			    )
			    movie = MovieListSerializer(many=False)
			
			    class Meta:
			        model = UserFavMovie
			        fields = ("user","movie","id")
	 		
	 		
	 		```
	 		
	 		> user\_movie_operations.views.py
	 		
	 		```
	 			略
	 		```
	 	
	 3.	在遍历电影的时候获取打分获取点赞数量
	 	简介: 我们已经可以让用户对电影打分和点赞,取消点赞了,但是我们需要在浏览电影的时候,把点赞数量和打分情况返回给我们的前端,我们需要在遍历电影的serializer里面做文章
	 	
	 	1. 代码实现:
	 		
	 		>movie.serializers.py
	 		
		 		```
		 		from django.db.models import Avg
		 		class MovieListSerializer(serializers.ModelSerializer):
				    fav_num = serializers.SerializerMethodField(read_only=True)
				    star_num = serializers.SerializerMethodField(read_only=True)
				
				    def get_star_num(self, obj):
				        score = UserStarMovie.objects.filter(movie=obj).aggregate(Avg('star'))
				        return round(score['star__avg'],1)
				    def get_fav_num(self, obj):
				        return UserFavMovie.objects.filter(movie=obj).count()
				
				    class Meta:
				        model = MovieDetail
				        fields = ('name', 'status', 'user_want_num', 'fav_num', 'star_num')
		 		
		 		
		 		```
	 		
	 	6. 知识点:
	 	
	 		1. 我们可以在serializer里面取定义自定义字段方法,只需要继承SerializerMethodField方法,设置read_only = True,然后在下面写上关于他的函数,固定用法 get_xxxx ,serializer就会自动的帮我们使用自定义方法去约束字段信息
	 		
	 		
	 			>serializers.SerializerMethodField(read_only=True)
	 		
	 		2. 我们使用了count(),方法去计算点赞的数量

	 		3. 我们使用了 aggregate 去做统计数据的平均值
	 		
	5. 使用缓存系统去升级我们的页面
	
		1. 简介:每次请求我们都需要大量的计算用户点赞数量，打分的平均值如果请求数量过多,这势必是一个很大的开销,但是这些数据又是相对固定的,你不会每分钟都更新一次电影吧,所以我们需要在获取信息的页面增加缓存
		2. web后台缓存原理:为什么要做缓存,缓存其实就是把数据存储在redis，或者文件系统中,你每次访问,我就把这个缓存的信息返给你,这样,我们就避免了查询数据库的过大开销


	
			
### 4.评论系统和权限控制

1. 简介:

	1.我们的电影下方带有评论,评论有对评论回复功能,显示回复评论功能,然后有评论的点赞行为
	2.用户可以去删除评论,修改评论,管理员看评论不当,也可以去删除评论,屏蔽用户发帖的功能

2. 电影评论的基本实现:
	1. 模型梳理:
	
		1. 哪个用户去评论
		2. 评论哪一部电影
		3. 评论的内容
		4. 评论的时间
		5. 回复评论(也就是所外键是自己)

	2. 模型代码实现:

		1.知识点: 在外键中 使用 'self' 可以表示自己对应自己
		
		>user\_movie_opertions.models.py
		
		```
		
		class UserMovieShortComments(models.Model):
		    """
		    用户对一个电影进行评论
		    """
		
		    user = models.ForeignKey(User, verbose_name='评论用户', help_text='评论用户')
		    movie = models.ForeignKey(MovieDetail, verbose_name='评论的电影', help_text='评论的电影')
		    comments = models.TextField(max_length=255, verbose_name='短评的内容', help_text='短片的内容')
		    add_time = models.DateTimeField(auto_now=True, verbose_name='评论的时间', help_text='评论时间')
		    reply_to = models.ForeignKey('self',verbose_name='回复某个评论',
		    help_text='回复某个评论也可以不回复',null=True)
		
		    class Meta:
		        verbose_name = '用户对一个电影进行短评论'
		        verbose_name_plural = verbose_name
		
		        unique_together = ('user', 'movie')
		
		```
	
	3. 评论思路梳理:
		
		1. 用户创建评论
		2. 用户可以修改评论(自己的)
		3. 用户可以删除评论(自己的)
		4. 用户可以查看所有评论(自己的)
		5. 用户可以查看评论的详细信息(自己的)
		
	4. 评论代码实现:
	

		1. 逻辑代码
		
			>user\_movie_opertions.views.py

			```
			
			
			class UserMovieShortCommentsViewSet(ModelViewSet):
			    """
			    create:
			        用户增加一条对电影的评论
			    list:
			        查看自己的所有短评
			    retrieve:
			        查看自己的一条短评
			    update:
			        修改自己的短评信息
			    destroy:
			        删除自己的评论信息
			    """
			
			    serializer_class = UserMovieShortCommentsCreateSerializer
			    queryset = UserMovieShortCommentsCreateSerializer.Meta.model.objects.all()
			    permission_classes = (IsAuthenticated,)
			
			    def get_throttles(self):
			        if self.action == "create":
			            return [t() for t in (OncePerDayUserThrottle,)]
			
			```		
		2. 限制用户的速度限速代码

			>user\_movie_opertions.throttles.py
			
			```
				from rest_framework.throttling import UserRateThrottle
		
				
				class OncePerDayUserThrottle(UserRateThrottle):
				    rate = '10/minute'
			
			```
			
3. 升级版,用户评论的权限控制逻辑
	
	1. 简介:
		之前的代码逻辑为用户只能浏览自己的帖子,删除自己的帖子,修改自己的帖子。但是这样的代码逻辑过于简单,我们无法把这些评论交由专门的管理员去管理这些帖子。所以我们需要让某些管理员能够管理其他用户的帖子。这就不仅仅的需要判断一下帖子属于谁这么简单了。我们需要存储帖子的权限是什么,谁能够操控这些权限。
	
	2. 逻辑分析:
	
		1. 首先建立管理员组
		2. 在发帖的时候对用户(个人)和管理员(组)授权
		3. 授权内容为:
			用户: 查看 删除 修改 这个篇帖子
			管理员组: 查看 删除 这个篇帖子
	    4. 用户发帖如果被设置为不能发帖的状态,用户就不能发帖
	3. 代码实现:
		
		1.在创建帖子的时候去添加权限
		>user\_movie_operations.views.py
		
		```
		
		class UserMovieShortCommentsViewSet(ModelViewSet):
		    """
		    create:
		        用户增加一条对电影的评论
		    list:
		        查看自己的所有短评
		    retrieve:
		        查看自己的一条短评
		    update:
		        修改自己的短评信息
		    destroy:
		        删除自己的评论信息
		    """
		
		    serializer_class = UserMovieShortCommentsCreateSerializer
		    queryset = UserMovieShortCommentsCreateSerializer.Meta.model.objects.all()
		    permission_classes = (IsAuthenticated,)
		
		    def perform_create(self, serializer):
		        user = self.request._user
		        group = Group.objects.get_or_create(name='site_managers')[0]
		        #在创建这篇帖子的时候,授予权限
		        #然后再在做操作的时候,查看验证有木有这个权限
		        instance = serializer.save()
		        assign_perm('change_usermovieshortcomments', user, instance)
		        assign_perm('delete_usermovieshortcomments', user, instance)
		        assign_perm('delete_usermovieshortcomments', group, instance)
		
		
		    def get_throttles(self):
		        if self.action == "create":
		            return [t() for t in (OncePerDayUserThrottle,)]
		
		```	
		2. 在必要的时候去查看权限
		>user_movie_operations.serialziers.py
		
		```
		
		class UserMovieShortCommentsCreateSerializer(serializers.ModelSerializer):
		    # 创建短评论的用户
		    user = serializers.HiddenField(
		        default=serializers.CurrentUserDefault()
		    )
		
		    update = serializers.SerializerMethodField(read_only=True)
		    delete = serializers.SerializerMethodField(read_only=True)
		
		    def get_update(self, ins):
		        user = self.context['request']._user
		
		        return 'change_usermovieshortcomments' in get_perms(user,ins)
		
		    def get_delete(self, ins):
		        user = self.context['request']._user
		        return 'delete_usermovieshortcomments' in get_perms(user,ins)
		
		    class Meta:
		        model = UserMovieShortComments
		        fields = ('id','user', "movie", "comments", 'reply_to','update','delete')
		
		```
		
4.过多评论 我们需要给他分页,筛选评论

>参见 分页部分

### 5. 支付功能的原理与实现

1. 简介: 我们需要为网站加上支付的功能,他是网站能存活下去的基本

2. 支付流程: 

	1. 用户在网站内选择想要的商品,点击支付功能
	2. 网站后台先查看用户是否合法,商品是否还有剩余等等
	3. 检查合格后,网站把用户想买的商品锁定起来,以免其他人来购买,并根据付款金额,商品,付款人生成流水号。
	4. 第三步骤还不能成为订单号,因为这个时候用户还没有付款,所以我们需要占时的锁定这个商品。生成流水号,交给用户要支付的平台。
	5. 支付平台会生成支付链接返回给网站后台
	6. 网站后台把支付链接交给用户
	7. 用户通过支付链接付款 
	8. 付款完成后 平台会通过网站支付已经成功
	9. 网站校验平台推送的支付成功信息,没有问题就会把商品交给用户

	
	####路梳理
	角色:
	
	    1. 用户
	    2 .网站后台
	    3. 支付平台
	
	 交互:
	 
	     1. 用户是在平台上面给钱,收钱的也是平台
	     2. 平台是发送通知让后台知道用户已经给钱了

3. 电影项目逻辑梳理:

	1. 用户选中还没有锁定或者售出的电影座位（用户其实够买的是电影片场里面的座位）
	2. 用户提交够买或者订购的申请
	3. 系统再次检测座位是否被锁定住或者出售
	4. 系统生成一个流水号(为什么叫流水号,因为这个时候用户还没有给钱,他可以取消不给钱,所以只是一个临时的订单叫做流水号） 流水号里面包含用户信息,订单价格,要购买的商品信息(座位)
	5. 系统把这个流水号信息,和要支付的信息交给支付宝或者微信等第三方平台。第三方平台会生成一个支付链接,我们把这个支付链接转交给用户。
	6. 用户一旦得到了支付链接之后,就会在网页或者app里面去跳转 然后支付
	7. 平台收到用户支付的钱之后,会通知系统里面的一个收货接口。
	8. 系统收到收货接口支付成功或者失败的通知之后,把商品正式的提交给那个用户

	



	
### <span id="django-celery">5.缓存系统(django-cache)</span>		

1. django 缓存简介:
	1. django的缓存很灵活,你可以设置缓存到memcached,文件,数据库系统,也可以共享缓存

2. 缓存分类设置:

	1. Memcahed缓存:
	
		```
		
		CACHES = {
		    'default': {
		        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
		        'LOCATION': '127.0.0.1:11211',
		    }
		}
		```
		
	2. 数据库缓存:
		
		```
		CACHES = {
		    'default': {
		        'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
		        'LOCATION': 'my_cache_table',
		    }
		}
		
		```
	  创建缓存表,使用数据库缓存之前，你必须用这个命令来创建缓存表：
	
		```

		python manage.py createcachetable
		
		```
	3. 文件系统:
	
		```
		
		CACHES = {
		    'default': {
		        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
		        'LOCATION': '/var/tmp/django_cache',
		    }
		}
		
		```
		
	4. 缓存时间全局设置:
	
		```
		 'TIMEOUT': 60
		```
		
3. 缓存函数视图

			
			
	1. 使用函数视图 加上装饰器,查看页面是否会缓存
	
		>my\_test.cache_view.py
		
		在装饰器后面加上cache_page(10) 表示缓存10秒
		
		```
		
			from django.views.decorators.cache import cache_page
			@cache_page(10)
			def cache_view(request):
				pass
		
		```
				
	2. 同时 我们也可以在url上面加上缓存
	
		>my\_test.urls.py
			   
			   
		```
			   
			   from django.views.decorators.cache import cache_page
			   ...
			   url(r'^test13/$',cache_page(10)(cache_view))
			   
		```

	
	
		
4. django-redis缓存:
		通过这个设置开启redis缓存功能
		
		```
		
		CACHES = {
		    'default': {
		        'BACKEND': 'django_redis.cache.RedisCache',
		        'LOCATION': 'redis://your_host_ip:6379',
		        "OPTIONS": {
		            "CLIENT_CLASS": "django_redis.client.DefaultClient",
		             "PASSWORD": "yoursecret",
		        },
		    },
		}
		
		```
		
	1. 使用redis-cli去查看缓存的数据
	2. 查看redis中的key
	
5. 高级缓存配置


	1. TIMEOUT 全局缓存时间设置
	2. OPTIONS:
		
		1. MAX_ENTRIES:高速缓存允许的最大条目数，超出这个数则旧值将被删除. 这个参数默认是300.
		2. CULL_ENTRIES:当达到MAX_FREQUENCY 的时候,被删除的条目比率。 实际比率是 1 / CULL_FREQUENCY, 所以设置CULL_FREQUENCY 为2会在达到MAX_ENTRIES 所设置值时删去一半的缓存。 这个参数应该是整数，默认为 3.
		
		 把 CULL_FREQUENCY的值设置为 0 意味着当达到MAX_ENTRIES时,缓存将被清空。 某些缓存后端 (database尤其)这将以很多缓存丢失为代价,大大 提高接受访问的速度。
		 
		3. KEY_PREFIX: 缓存的key的开头
		4. KEY_FUNCTION:一个字符串，其中包含一个函数的虚线路径，该函数定义了如何将前缀，版本和密钥组合成最终缓存密钥。
		5. VERSION：由Django服务器生成的缓存键的默认版本号。
	
	3. 实际的示例
	
	```
	
	
	
	```

6. drf_extension缓存配置
	1. 库简介: drf_extension是一个drf的扩展库,它带有对view的扩展和缓存的扩展
	2. 使用的必要条件: 必须是继承了 APIView的类才能使用
	3. CacheResponseMixin 类视图的缓存
		1. 他一般会缓存 get方法
		2. 使用方法
			
	
	4. 配置简介

		1. DEFAULT_CACHE_RESPONSE_TIMEOUT全局设置缓存的时间
		2. DEFAULT_USE_CACHE 选择使用哪个缓存方式去缓存,一搬不会写
		3. 
		
		```
		REST_FRAMEWORK_EXTENSIONS = {
	    	'DEFAULT_CACHE_RESPONSE_TIMEOUT': 60 * 15
	    	'DEFAULT_USE_CACHE': 'special_cache'
		}
		
		```
		
	5. 使用方式:
		
		>mytest.cache_view.py
		
		```
			from rest_framework_extensions.cache.mixins import CacheResponseMixin
			class BookViewSet(CacheResponseMixin,viewsets.ReadOnlyModelViewSet):
	
	
	    queryset = Book.objects.all()
	    serializer_class = BookSerializer
		
		```
	
7. drf_extension配置深度解析
			
			
### <span id="django-celery">5.队列任务(django-celery)</span>

1. 队列任务的基础概念:
    1. 高并发环境下，由于来不及同步处理，我们需要把这些东西交给一套系统去排队处理。这样不会导致我们主程序卡死,从而不能接受请求，出现大面积404
    2. 画图解释队列架构
    
2. 队列任务的实现方式:
    1. 我们以django celery为例:
        1. 调度器:就是我们的django-celery 他去调用这些任务的执行,我们存储任务执行的结果
        2. 任务执行器:我们发送邮件的函数就是一个任务执行器,celery可以去调度他执行发送邮件的任务。也可以在任务较多的时候。然他排队去执行。
        3. 消息中间件: 我们把一个任务交给了任务执行器。但是任务多久完成，我们是不知道的。他可能在排队,也可能执行失败。也可能执行成功。我们需要一个东西去存储他目前的状态。通用的消息中间件有 redis rabbitMQ。
    2. 队列任务大致流程梳理:
        1. 把发送邮件的任务交给django-celery处理,并把调用任务的变量传递给django-celery
        2. django-celery把这个任务给定一个唯一任务id号,然后存储到消息中间件中(这里我们用redis)
        3. django-celery 把这个任务排队,等到能执行这个任务的时候，他去调用我们发送邮件程序去发送邮件
        4. 当任务执行成功或者失败他都会把这个消息存入到我们的消息中间件中.

 3. django-celery:
 
     1. 安装 celery
     
     		第一个安装 celery 第二个安装 python redis 让python能使用redis 第三个安装celery的任务执行结果存储地区
     		
	     	```
	     		pip install celery
	     		pip install redis
	     		pip install django-celery-results
	     		
	     	
	     	```
     	
     2. 使用redis作为消息中间件,安装redis
     	
     		[redis安装使用相关知识点](#redis)
     		
     3. django中配置celery

         1. 在配置文件下面新加celery.py

        		
        	
         
         		> drf\_movie_rimi.celery.py
         
             ```
				from __future__ import absolute_import, unicode_literals
				import os
				from celery import Celery
				
				# set the default Django settings module for the 'celery' program.
				os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'drf_movie_rimi.settings')
				
				#启动项目的名字 最好和项目名字一样 broker中间件  backend 存储结果的地方
				app = Celery('drf_movie_rimi',
				             broker='redis://localhost:6379',
				             backend='redis://localhost:6379'
				
				             )
				
				#在redis中以CELERY
				app.config_from_object('django.conf:settings', namespace='CELERY')
				
				#使celery能够读取到所有apps里面分配的任务
				app.autodiscover_tasks()


             
             ```
             
          2. drf\_movie_rimi.settings.py

              ```
              
              INSTALLED_APPS = [
						...
				    'django_celery_results',
				]
				
				...
				
				CELERY_RESULT_BACKEND = 'django-db'
              ```
              
              安装好app之后做迁移
              
              ```
              makemigrations
              migrate
              ```
              
  		    3. 在项目配置的init.py里面加入启动文件

  		    	drf\_movie_rimi.__init__.py
  				
  				```
  				
  				from __future__ import absolute_import, unicode_literals

				# This will make sure the app is always imported when
				# Django starts so that shared_task will use this app.
				from .celery import app as celery_app
				
				__all__ = ('celery_app',)
  				
  				``` 
              
   		4. 启动和使用celery
   		
   			1. 启动django
   			2. 在命令行中启动celery
   				        
	              >启动命令 虚拟环境下 项目目录下执行
	              
	              ```
	              celery -A drf_movie_rimi worker -l info 
	              ```
	              
          3. 把我们的发送邮件任务转移给celery去执行
          
          	   1. 按照固定用法引入包
          	   2. 在函数前面加入@shared_task装饰器来使他成为队列任务

	              >users.tasks.py
	              
	              ```
	              
	                 # Create your tasks here
						from __future__ import absolute_import, unicode_literals
						from celery import shared_task
						from utitls import send_sms_email
						
						...
						
						
						@shared_task
						def reg_send_mail(title, context, to_mail):
						    res = send_sms_email.my_send_mail(title, context, to_mail)
						
						    success_context = '向{}邮箱发送注册验证码成功,信息内容:{}'.format(to_mail, context)
						    fail_context = "向{}发送邮箱验证码失败".format(to_mail)
						
						    if res == 1:
						        return success_context
						    return fail_context
	
	              ```
	            3. 在views里面去调用队列,引入我们刚才的队列函数,使用xxx.delay()去唤醒他
	            
	            
	            		> users.views.py
		            	 ```
		            	 
						class UserRegisterCaptchaCreateViewSet(CreateModelMixin, GenericViewSet):
						    queryset = UserRegisterCaptchaCreateSerializer.Meta.model.objects.all()
						    serializer_class = UserRegisterCaptchaCreateSerializer
						
						    def perform_create(self, serializer):
						        data = serializer.validated_data
						        captcha = '您的验证码为{}'.format(data['captcha'])
						        #res = my_send_mail('注册验证码',captcha,data['email'])
						        reg_send_mail.delay('注册验证码',captcha,data['email'])
						        
						        ...
		            	 
		            	 ```
		            	 
		        4. 在我们的admin后台去查看结果

		5. 总结：
		
			1. 队列任务是一个抽象概念
			2. 队列任务的标准是叫你去实现 
				1. 调度队列的程序(celery) 
				2. 消息中间件-broker(redis)
				3. 执行结果存储器 backend (mysql或者redis)
			3. celery只是python里面去实现了队列的程序,当然你可以自己写,java那些也有自己的程序			
   				

   			
   			
    
  
 
### <span id="redis">6.redis</span>   

1. redis的简介:
	1. redis是一个nosql数据库
	2. redis他是一个存在于内存上面的数据库
	3. redis他有时候会用来做缓存
	4. nosql数据库一张表只能有一个特定的用途

2. redis的安装:

	
3. redis的配置,他的软件的用法

	1. Makefile: make && make install的安装依据文档,如果你安装出问题的话,就可以去找个文件
	2. redis.conf 配置文件
	3. sentinel.conf 我们redis 哨兵,高可用配置,如果reids崩掉的话,监听,然后做出决策
	4. 文件夹 src:
		1. redis-benchmark redis的压测工具
		2. redis-server redis-cli redis服务器 reids客户端
		3. redis-sentinel 启动我们的哨兵
	5. 配置文件（redsi.conf）:
		1. bind 127.0.0.1  启动的监听ip 一般监听内网ip
		2. port 6379 监听端口 一般会改掉
		3. masterauth <master-password> 主从备份密码 主的密码 等于你主机 requirepass 前提是你配置了 slaveof
		4. requirepass redis密码
		5. slaveof 127.0.0.1 6379 配置主从 主的ip和端口 让自己成为slaveof（从库）
		7. dump.rdb redis的持久化数据
		8. save 60 10000 表示 60秒之内 你有大于等于10000次数据变化,他就会给你存储到rdb(硬盘)上面
		9. redis有两种存储方式, 一种是rdb 一种是 aof 默认是rdb
			1. rdb的原理是一段时间内把你磁盘的镜像存储下来(思考git) 坏处是:发生灾难,灾难的期间的数据是没有的 比如你 12.00保存了数据 12.00：30秒发生灾难, 30秒的数据就没有了
			2. aof 存储 append only 原理是把你每一次数据库的变化记录下来，恢复数据的时候,根据你每次的变化来推演。 好处: 发生灾难了数据很会很小。坏处:无法达到性能或者是很耗性能
		10. 数据过期命令:
			expire value second 给一个key设置过期时间,完成之后就被删除
			最主要的地方用在缓存数据上面
			
			ttl key可以去看他有还有多少的寿命
			
		
	6. redis命令:
		-h hostip
		-p 端口
		-a 密码
		tips:如果你的密码错误,你是可以链接的,但是你无法看到数据
		链接命令: src/redis-cli -h 192.168.0.169 -p 16379 -a rimi12345678
	
	7. redis的数据库结构:
		1. 前提
			1. 大前提 redis 数据库结构是基于nosql的 所以的数据库都是 key value
			2. 没有主键和外键 比如设了外键,主键被删了之后,他的没有任何影响
			3. 表于表之间没有任何关系 
		2. 数据结构:
			1. string 字符串 key value 存储字符串和数字 
				命令: 
					1. set 设置key和value
					2. get 获取key所代表的value
					3. incr 自增1
					4. decr 自减1
					5. incrby key num 
					6. decrby 
			2. hash 散列表:
				1. 相当于一个 dict 但是只有一层
				  命令:
				  	hset 设置一个散列表 hset person1 name luhan age 25 gender renyao
				  	hgetall key 获取hash里面的所有key value
				  	
				  	hmget key field1 field2 ... 获取执行的value  hmget person1 name age
				  	hmset key fiels value 精准的修改hash表(已经存在)里值,没有就会新建
				  	
				  2. 性能优化:
				 		1. 一般不会用hash表,我们用string表来代替他（存入json）
						2. 或者他推荐我们去使用 hgetall命令,少用hmget
				
			3. zset 有序集合:
			
				1. 是一个有排名的集合数据，每一条数据他都有排名:
				
				2. 命令：
					1. 添加数据: zadd key score value 给定数据的分数
					2. 取出数据并且排名: ZREVRANGE hackers 0 -1 withscores
						1. withscores 会把分数一并的给你显示出来
					3. zcard value 统计我们的集合里面的数据量
					4. zscore value key 取出某个key的分数
					5. zrem value key  移除某个分数
			4. set 无序结合:
				
				1. 是一个无需集合:
				
					2.命令:
						1. sadd key value1 value2 .... 添加值到我们的集合里面去
						2. smembers key 获取集合里面的信息
						3. scard key 获取集合的数据
						4. sdiff 集合的差集
			5. list 双向列表结构:
			
				1. 他是双向列表,他可以把数据从左边或者右边压入,压入之后可以左右弹出
				2. 可以用这个来做队列任务

				
			6. eval redis脚本:
			
				执行脚本可以保证你的数据的一致性
				
				script表示的是lua脚本:
				
					1. lua申明变量需要local
					2. lua拼接字符串需要 ..
					3. 调用脚本的时候 使用 redis.call() 跟你的命令
					4. keys args相当于传递参数进去，在脚本里面大写入KEYS[1]
					
				```
				def new_user():
				    script = """
				        local user_id = redis.call("incr", KEYS[1])
				        local hash_table_name = "user:"..user_id
				        redis.call("zadd","user_set",user_id,hash_table_name)
				        redis.call("hmset",hash_table_name,"name",user_id)
				    """
				    script1 = r.register_script(script)
				    x = script1(keys=["user_id"], args=[])
				
				```		
				
			6. pipeline:
				可以帮我们加速redis执行效率,一次性执行所有的所有操作
				
				```
				    with r.pipeline() as p:
				        for i in range(100000):
				            user_id = p.incr('user_id')
				            hash_table_name = "user:{}".format(user_id)
				            p.zadd('user_set', user_id, hash_table_name)
				            p.hmset(hash_table_name, {"name": "user:{}".format(user_id), 'password': 
				            'rimiaaa{}'.format(user_id)})
				        p.execute()
								
				```	
				
		1. 实验：设计一张表:

			要求: 使用redis来做用户表
			
			    1. 存入账户密码
			    2. 用户新建之后,id自增
			    3. 可以查看到所有的用户
			    4. 可以统计用户的数量
		
			mytest.redis_test.py
		
		



### 8.django-gurdian 控制用户权限的逻辑

1. 简介:
	  1. 他是django第三方权限管理扩展库
	  2. 为什么要使用权限管理系统?我们参考一下百度贴吧,你发的帖子会被管理员删除掉,当然你自己也可以删除掉自己的帖子,但是你是不能删除其他人或者管理员发出的帖子的。这就是一个典型的权限管理系统
	  3. RBAC->刚才所讲的问题我们可以通过RBAC模型去解决,RBAC的全称为 role-based access control,即基于角色的访问控制。
	  4. 那其实我们刚才的那个问题就可以化解为授予权限,和在要使用权限的时候去检查这个用户是否有权限。
	  5. django-guradian是一个实现了rabc模型的强大工具,它是专门扩展django权限管理的第三方库。
	  6. 具有授予,删除,查看权限等等丰富的功能
	  7. 官网: http://django-guardian.readthedocs.io/en/latest/
	  8. 他是对象级别的权限控制
	  9. django是model级别的权限控制

2. 安装:
	  1. 库安装
	  
	  ```
	  $ pip install django-guardian
	  ```
	  2. 把guardian放入django的apps里面
		
	  ```
	  	INSTALLED_APPS = (
		 ...
		 'guardian',
		)
	  
	  ```
	  
	  ```
	  $ pip install django-guardian
	  ```
3. api使用规范:
	1. 权限授予: guardian.shortcuts.assign_perm(perm, user_or_group, obj=None) 
	
	2. 权限查看:guardian.shortcuts.get_perms(user_or_group, obj)—返回一个用户给这个对象权限的list,其实就是一个含有perm的list
	
	3. 参数说明: perm要授予的权限(删除或者修改权限),user_or_group授予权限的用户或者用户组(用户),obj被操控的对象(博文
	4. 在model中加入权限: model的Meta里面可以加扩展permissons,这个扩展的permissions就是上面perm参数

4. 实现我们的逻辑代码:
	1. 我们这个时候就需要给用户分组了 
		1. 普通用户 （使用普通的网站功能）
		2. 网站管理员 （管理用户回复评论中的帖子,删帖,修改用户帖子,屏蔽用户发帖）
		3. 系统管理员 (添加或者删除网站管理员)
	2. 用户发帖之后,帖子是一个对象,所以我们的授权就应该在这个时候去完成
		1. 删除权限
		2. 修改权限
		3. 授予网站管理员和发帖用户这个权限

5. 底层原理:
	其实是数据库的中数据的记录


### 9.pagination django的分页
1. 简介 如果页面的数据过多,那么我们不能在页给他显示完成,我们可以采用分页显示数据,减少数据库压力
2. 实现分页所需要的部件:
	最大数据量 返回给前端表示我们有多少的数据量
	每页数据量 返回给前端每页能显示多少的数据量 当然这个可以修改
	当前页面页码 让前端知道当前在哪个页面上面
3. django中的分页配置:

    1. 全局默认配置 当我们配置好了之后,会在list页面看到我们的分页信息
    
        ```
        
        REST_FRAMEWORK = {
				...
			
			    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
			    'PAGE_SIZE': 10
	}
        
        ```
    2. 定制化分页配置

    	参数解释:
    		1. page_size 默认每页个数
    		2. page_size_query_param 在url里面去设置每页个数
    		3. max_page_size 每页最大的个数 page_size_query_param最大值不能超过他

        ```
        
        
		from rest_framework.pagination import PageNumberPagination
		
		class LargeResultsSetPagination(PageNumberPagination):
		    page_size = 10
		    page_size_query_param = 'page_size'
		    max_page_size = 100
		    
		    
		class MovieShortCommentsReadAllViewSet(ListModelMixin,GenericViewSet):
		    """
		    查看相关电影的所有评论,并且返回可以管理这条评论
		    """
		    serializer_class = UserMovieShortCommentsCreateSerializer
		    queryset = UserMovieShortCommentsCreateSerializer.Meta.model.objects.all()
		
		    pagination_class = LargeResultsSetPagination
        
        ```


### 10.django-filter 筛选数据
1. 简介:

2. django-filter使用方法:


	1. 在drf中使用filter去搜索或者排序数据
		用法: 1.我们使用 filters去激活 filter_backends让他拥有搜索和排序的功能,然后我们给定搜索和排序的位置即可
		
		
		```
		
		from rest_framework import filters
		class MovieViewSet(mixins.ListModelMixin,mixins.RetrieveModelMixin,mixins.
		UpdateModelMixin,viewsets.GenericViewSet):
		    """
		    获取电影信息接口
		    """
		
		    queryset = MovieDetail.objects.all()
		    filter_backends = (filters.SearchFilter, filters.OrderingFilter)
		    search_fields = ('name',)
		    ordering_fields = ('id',)
		
		```
		
	2. 分类筛选器

	   1. 简介: 通过上面的配置我们已经可以去搜索字段,然后给定字段的排序了,但是我们还需要分类筛选信息,比如电影类型筛选,上映时间筛选等等
	   2. 安装:
	   
	   	    1. 官方地址: http://django-filter.readthedocs.io/en/master/
	   		 2. 安装命令:
	   			
	   			```
	   			$ pip install django_fliter
	   			```

				
		3. 使用方法:
		
			1. movies.views.py
			 
				```
				
				class MovieViewSet(mixins.ListModelMixin,mixins.RetrieveModelMixin,
				mixins.UpdateModelMixin,viewsets.GenericViewSet):
				    """
				    获取电影信息接口
				    """
				
				    queryset = MovieDetail.objects.all()
				    filter_backends = (DjangoFilterBackend,filters.SearchFilter, filters.OrderingFilter)
				    search_fields = ('name',)
				    ordering_fields = ('id',)
				    filter_class = MovieDetailFilter
				
				```
				
			2. 在专门的filters中去配置 类似于我们的form功能

				```
				
				import django_filters.rest_framework as filters
				from .models import MovieDetail
				
				
				class MovieDetailFilter(filters.FilterSet):
				    class Meta:
				        model = MovieDetail
				        fields = [
				            'name',
				        ]
				
				```
				
		4. fields使用方法:
			 可以用更多选择去约束筛选条件
			 
			 ```
			 
			     class Meta:
			        model = MovieDetail
			        fields = {
			            'name':['exact', 'contains']
			        }
			 
			 ```
			 
			 上面的会给你创建两个筛选字段 一个给你精确匹配，一个给你模糊pip
			 
		5. 筛选条件详解
		
			1. exact 精确匹配
			2. contains icontains 包含 i表示忽略大小写
			3. gt gte 大于 大于等于
			4. lt lte 小于 小于等于
		6. 外键的使用:
		    1. __ 表示魔术方法
		    2. kind_category__name
	   		
	   			
	   		

	
### 11.admin 后台管理定制化

1. 简介:
   我们的admin里面包含了字段的所有信息,但是有些信息我们是不想让人去修改的,比如所点赞数量,浏览数量,或者其他定制化的东西,所以我们需要调用admin里面的方法去修改我们对admin里面字段的约束
   
2. 约束修改方法:
	1. 只显示哪些字段
		fields = ('name', 'status') 
	2. 不显示哪些字段
		exclude = ('name',)
	3. 哪些字段在一行里面去显示:
	
		1. 注意点: 不能把外键放在里面
	
		fields = (('name', 'status'), 'sub_title')
	4. 组合字段展示,可以把字段放在合集里面展示，给出标题和样式。collapse表示下拉栏
	
		```
		    fieldsets = (
		        (None, {
		            'fields': (('name', 'status'), 'sub_title')
		        }),
		        ('Advanced options', {
		            'classes': ('collapse',),
		            'fields': ('view_num', 'is_banner'),
		        }),
		    )
		
		```
	5. list_display:
		顾名思义,会在展示list的时候,展示哪些数据
		
		```
			...	
			list_display = ('id','name','status')
		```
	
	6. list_display_links:
		配置了之后会生成一个连接 直接连接过去:
		
		```	
		...	
		list_display_links = ('name', 'status')
		```
	7. list_editable:
		
		可以直接在list面板修改值,不用进入到里面去修改
		
		list_editable = ("status",)
		
	8. list_filter:
		可以在list面板配置分类功能 
		
		```
		list_filter = ('kind_category',)
		
		```
	9. search_fields:
		搜索框搜索页面
		
		```
		search_fields = ['name']
		```
		
	10. inlines:
		如果有外键指向了这个model,就可以使用inlines方便的管理,而不用去外面单独的编辑外键
		
		```
		class Img(admin.TabularInline):

		    model = MovieImages
		
		    inlines = [Img]
		
		```
	
	11. 其他:
	
	   https://yiyibooks.cn/xx/Django_1.11.6/ref/contrib/admin/index.html

3. 富文本编辑器 ckeditor

    1. 官网 https://github.com/django-ckeditor/django-ckeditor

    2. 安装

        ```
        pip install django-ckeditor
        ```

        在settings的app里面加入 ckeditor

        新建文件夹 static

        配置 STATIC_ROOT = static
        
        ```
			        
			CKEDITOR_UPLOAD_PATH = 'ckeditor/'
			CKEDITOR_RESTRICT_BY_USER = True
			CKEDITOR_BROWSE_SHOW_DIRS = True
			CKEDITOR_RESTRICT_BY_DATE = True
			CKEDITOR_IMAGE_BACKEND = 'PIL'
			CKEDITOR_BASEPATH = "/static/ckeditor/ckeditor/"
			CKEDITOR_CONFIGS = {
			    'default': {
			        'update': ['Image', 'Update', 'Flash', 'Table', 'HorizontalRule', 
			        'Smiley', 'SpecialChar', 'PageBreak'],
			        'skin': 'moono',
			        # 'skin': 'office2013',
			        'toolbar_Basic': [
			            ['Source', '-', 'Bold', 'Italic']
			        ],
			        # 'toolbar_YourCustomToolbarConfig': [
			        #     {'name': 'document', 'items': ['Source', '-', 'Save', 'NewPage',
			         'Preview', 'Print', '-', 'Templates']},
			        #     {'name': 'clipboard', 'items': ['Cut', 'Copy', 'Paste',
			         'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo']},
			        #     {'name': 'editing', 'items': ['Find', 'Replace', '-', 
			        'SelectAll']},
			        #     {'name': 'forms',
			        #      'items': ['Form', 'Checkbox', 'Radio', 'TextField', 
			        'Textarea', 'Select', 'Button', 'ImageButton',
			        #                'HiddenField']},
			        #     '/',
			        #     {'name': 'basicstyles',
			        #      'items': ['Bold', 'Italic', 'Underline', 'Strike', 
			        'Subscript', 'Superscript', '-', 'RemoveFormat']},
			        #     {'name': 'paragraph',
			        #      'items': ['NumberedList', 'BulletedList', '-', 
			        'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-',
			        #                'JustifyLeft', 'JustifyCenter', 'JustifyRight', 
			        'JustifyBlock', '-', 'BidiLtr', 'BidiRtl',
			        #                'Language']},
			        #     {'name': 'links', 'items': ['Link', 'Unlink', 'Anchor']},
			        #     {'name': 'insert',
			        #      'items': ['Image', 'Flash', 'Table', 'HorizontalRule', 
			        'Smiley', 'SpecialChar', 'PageBreak', 'Iframe']},
			        #     '/',
			        #     {'name': 'styles', 'items': ['Styles', 'Format', 'Font', 'FontSize']},
			        #     {'name': 'colors', 'items': ['TextColor', 'BGColor']},
			        #     {'name': 'tools', 'items': ['Maximize', 'ShowBlocks']},
			        #     {'name': 'about', 'items': ['About']},
			        #     '/',  # put this to force next toolbar on new line
			        #     {'name': 'yourcustomtools', 'items': [
			        #         # put the name of your editor.ui.addButton here
			        #         'Preview',
			        #         'Maximize',
			        #
			        #     ]},
			        # ],
			        # 'toolbar': 'YourCustomToolbarConfig',  # put selected toolbar config here
			        # # 'toolbarGroups': [{ 'name': 'document', 'groups': 
			        [ 'mode', 'document', 'doctools' ] }],
			        # # 'height': 291,
			        # # 'width': '100%',
			        # # 'filebrowserWindowHeight': 725,
			        # # 'filebrowserWindowWidth': 940,
			        # # 'toolbarCanCollapse': True,
			        # # 'mathJaxLib': '//cdn.mathjax.org/mathjax/2.2-latest/MathJax.js
			        ?config=TeX-AMS_HTML',
			        # 'tabSpaces': 4,
			        # 'extraPlugins': ','.join([
			        #     # 'uploadimage',  # the upload image feature
			        #     # your extra plugins here
			        #     'div',
			        #     'autolink',
			        #     'autoembed',
			        #     'embedsemantic',
			        #     'autogrow',
			        #     # 'devtools',
			        #     'widget',
			        #     'lineutils',
			        #     'clipboard',
			        #     'dialog',
			        #     'dialogui',
			        #     'elementspath'
			        # ]),
			    }
			}
        
        
        ```

        执行 collectstatic
        
        在url里面取配置静态文件服务器和ckeditor的
        
	        ```
	        
	        
	        urlpatterns = [
					...
				    url(r'^ckeditor/', include('ckeditor_uploader.urls')),
					...
				
				]
	        ...
	        
	        urlpatterns += [
				    # 启动一个文件服务器(django的文件服务器 实际上线后使用nginx之类的服务器作为文件服务器)
				    url(r'^static/(?P<path>.*)$', serve, {
				        'document_root': settings.STATIC_ROOT
				    }),
				    url(r'^media/(?P<path>.*)$', serve, {
				        'document_root': settings.MEDIA_ROOT
				    })
				]
				        
	        
	        ```
        
        CKEDITOR_BASEPATH 一定要在结尾加上 / 比如 "/static/ckeditor/ckeditor/"
        
    3. 在model中取替换我们的field即可,然后去admin里面取查看

	    ```
	    
		    from ckeditor_uploader.fields import RichTextUploadingField
		    
		    class MovieDetail(models.Model):
			...
		    movie_brief = RichTextUploadingField(default='目前没有还有简介', max_length=500, 
		    verbose_name='电影简介', help_text='电影简介')
			...
	
	    
	    ```

	       
### 12. django 文件存储系统

1. python 文件基础:
	1. 使用python 打开文件:
	
		1. 使用python 打开文件并写入字符串:

			读写模式:
			
				r: 只读
				
				r+: 读写
				
				w: 只写
				
				w+: 读写
				
				a: 只写(追加写入)
				
				a+: 读写(追加写入)
				
			>my_test.file_test1.py
			
			```
			def test1():
			    file = os.path.join(base_dir,'test1.txt')
			    with open(file,'w+') as f:
			        f.write('hello worasdfld')
			
			```
			
		2. 读取文件 读取大型文件或者打印大型文件的时候需要循环遍历
	
			>my_test.file_test1.py


			```
			
			def test3():
			    file = os.path.join(base_dir,'test2.txt')
			    with open(file,'r') as f:
			        datas = f.readlines()
			        for i in datas:
			            print(i)
			
			```
			

2. form-data x-www-form-urlencoded raw binary区别

	https://blog.csdn.net/shangmingtao/article/details/74463500
	
3. urlencode解释:
	
	因为有时候我们get方法里面的参数会带空格 问号等等,但是这些是我们Url的特殊符号,如果url里面带有了空格问号，他就会执行其他命令。而不是把他作为字符串看待，所以我们需要把们encode 变成url不会识别成特殊符号的字符串，参考我们的正则表达式。
	
	
	>my\_test.file_test1.py

	```
			
	def test4():
	    from urllib import parse
	
	    url_test = 'www.baidu.com?'
	    url_params = 'a=阿凡达拉水电费&b=发的说法发?生?的浪费阿斯蒂芬'
	    print(url_test+ parse.quote(url_params))
			
	```
	
	思考 post方法需要urlencode吗?

			
			

4. django 文件理清思路: static vs media
	
	1. static是静态文件
	2. media是资源文件,资源文件是随时会变的,比如用户上传的头像,后台发布的文章,他是随时会变的
	3. 你看的网页是如何显示的图片的?
		一般会有img标签,浏览器遍历到Img标签,取出img标签里面的关于资源文件(图片,视频的网址),然后访问这个url得到的资源文件,显示给用户去看。
	
	4. 图片是如何生成如何传输的?
	
		计算机以RGB三原色或者其他算法来显示图片,其实对计算机来说,图片就是一个普通的txt文件,里面存放的是把这个图片哪个位置显示哪个颜色的信息。比如1080p就是有 1080*1920个像素点,每个像素点表现什么颜色就是我们里面存入的信息。
		
		那么如何传输,只需要传输txt信息给浏览器,浏览器会根据这些信息来解密,展示图片
		
		jpg,png是什么?
			就是把同一个图片里面的信息加密的方式,就像我们的utf8 utf16等等,加密过程中可能会有部分信息的删除。
	
	5. 那么django的媒体系统是如何设计的?
		
		我们可以指定存储图片的位置, media_root，然后我们上传图片后,图片会存在于文件夹中。数据库里面存储的是图片存储的位置信息
	
5. django文件上传基础:

	1. django 接受的文件上传模式是 form-data模式,如此他会把我们的文件信息(或者二进制流)放入他的 request.FILES,我们使用post上传一个文件,断点查看files里面的信息。

		
		查看我们传过来的file是什么: 他是一个 inMemoryUploadFile 类
		
	
		>mytest.file_view.py
		
		```
		
		@csrf_exempt
		def test_files(request):
		    # write_files(request.FILES['test_files'])
		
		    return HttpResponse('hello world')
		
		```
	
	2. 我们可以把这个二进制数据写入到文件中(这个时候 信息还在变量中(内存))
	
		1. 我们使用wb+模式来写入文件 因为图片等文件是用二进制流传入的
		

			>mytest.file_view.py
			
			```
			
			def write_files(file):
			    media_dir = os.path.join(BASE_DIR, 'media', 'test1')
			    media_file = os.path.join(media_dir, file.name)
			
			    with open(media_file, 'wb+') as f:
			        #断点查看i 二进制
			        for i in file.chunks():
			            f.write(i)
			
			```
			
		2. 我们可以利用这个方法把文件写在外部，注意 你需要文件的写入权限

			>mytest.file_view.py
			
			```
			def write_files_out_side(file):
			    media_dir = os.path.dirname(BASE_DIR)
			    media_file = os.path.join(media_dir, 'test_store',file.name)
			
			    with open(media_file, 'wb+') as f:
			        #断点查看i
			        for i in file.chunks():
			            f.write(i)
			
			```
		
			

	3. django中自带的文件写入类,我们使用这个类就不用去想我们刚才使用函数方法一样去自己做这些事情了,定义ImageField即可或者FileField。然后我们把inMemoryUploadFile类的对象传递给我们imgfield 他就会自动的帮我们上传完成图片。其实我们刚才的函数是一样的,不过有部分限制:
	   1. 图片的传入顶层目录必须是我们在settings中去指定的图片目录。

	   2. 如果图片有重名，他会自动的给我们重命名文件。
	   
	   3. 他的img字段里面存储的是图片的存储路径,而不是图片
	
		>mytest.models.py
		
		```
		class FileTestImage(models.Model):
		    name = models.CharField(max_length=20,verbose_name='文件写入测试名称')
		    img = models.ImageField(upload_to='test1',verbose_name='测试图片')
		
		    class Meta:
		        verbose_name = '图片写入测试'
		        verbose_name_plural = verbose_name
		
		    def __str__(self):
		        return self.name
		
		```
		
		> mytest.file\_test.py
		
		```
		
		@csrf_exempt
		def test_files(request):
		
		    data = request.FILES['test_files']
		    # write_files_out_side(request.FILES['test_files'])
		    FileTestImage.objects.create(name='测试1',img=data)
		
		
		    return HttpResponse('hello world')
		
		```
	
	4. 问题:我们存储文件需要分开存储,试想一个大型网站有多少用户,一个文件夹里面存储10w张图片?光是系统打开这个文件都已经够消耗资源了。所以我们需要合理的去分割图片存储的文件。最常见的是以日期为准,比如每个月的图片存在于当月文件夹中，又或者每个文件夹存1000张,存满后换下一文件。但是这一切的核心问题是你需要自己去接管图片存储位置的逻辑,然后做适合业务的算法出来

	5. django 文件存储自定义文件夹:
	
	    1. 我们可以自定义文件的存储位置,只需要给定upload一个函数(平时我们给定的一个字符串,表示文件定死存储在哪里)
		    
		    ```
		    def test_directory_path(instance, filename):
			    ext = filename.split('.')[-1]
			    filename = '{}.{}'.format(uuid.uuid4().hex[:8], ext)
			    # return the whole path to the file
			    return "{0}/{1}/".format("avatar", filename)
		    
		    
		    ```
	    
	    2. 升级版:
	        我们需要给定传递给哪个文件夹
		        
		    ```
		    
		       import uuid
				from django.utils.deconstruct import deconstructible
				from django.utils.timezone import now
				import os
				
				
				@deconstructible
				class UploadToPathAndRename(object):
				    def __init__(self, path):
				        year = str(now().year)
				        month = str(now().month)
				
				        self.sub_path = os.path.join(path, year, month)
				
				    def __call__(self, instance, filename):
				        ext = filename.split('.')[-1]
				        filename = '{}.{}'.format(uuid.uuid4().hex[:8], ext)
				        return os.path.join(self.sub_path, filename)
		    
		    ```
		    
	6. 

<!--3. 分布式文件传输

	1. 新的问题:
		我们已经把图片路径切割为自己定制化的路径了，但是依然有一个问题，一般线上的服务器都是把图片存储在一个专门的目录
		或者一个专门的文件服务器上面,我们这样存在整体代码里面是不可行的。静态文件可以在代码文件里面,但是媒体文件不行。
		
	2. 解决上面的问题其实就是做一个系统把文件可以写到另外的文件夹(本机器中)
	3. 我们可以使用分布式存储库来解决这个问题 django-resto
	

		```
		$ pip install django-resto
		
		```
		
		```
		
		```-->


### 13. django 部署

1. 基础知识:
	1. 我们的web服务是一个deamon程序,他们需要一直稳定的跑在服务器上面,每当有浏览器请求过来,他就需要去解析报文,然后把含有(get post参数等)的信息传递给我们的程序
	2. web服务也有可能崩掉,所以我们需要一个第三方的程序去监听他,在web服务down的时候去自动的启动

2. gunicorn 部署
	1. 简介 gunicorn是一个django的cgi服务,它最主要的特点是轻量化 简单配置 可以使用python来做配置文件

	2. 使用:
	
		1. 安装gunicorn服务
		
			```
			$ pip install gunicorn
			
			```
		
		2. gunicorn的配置文件

			
			```
			
			import multiprocessing
			import os
			
			base_dir = os.path.dirname(os.path.abspath(__file__))
			# unix:file_path 使用socket方式
			bind = "0.0.0.0:8009"
			#socket_file = os.path.join(base_dir,'mysocket','mysock.sock')
			#bind = "unix:{}".format(socket_file)
			# 2-4 x $(NUM_CORES) range
			workers = multiprocessing.cpu_count() * 2 + 1
			#worker_class= "gevent"
			# port = 8002
			backlog = 2048  # 就是设置允许挂起的连接数的最大值
			# timeout默认值：30
			# reload 默认值：False 重载 更改代码的时候重启workers， 只建议在开发过程中开启。
			reload = False
			# daemon以守护进程形式来运行Gunicorn进程。默认值：False
			daemon = False
			# accesslog 设置访问日志存放的地方
			# 默认值：None
			accesslog = os.path.join(base_dir, 'log', 'gunicorn', 'access.log')
			# errorlog 设置错误日志的存放地址
			errorlog = os.path.join(base_dir, 'log', 'gunicorn', 'error.log')

			
			```
			
		3. 在django项目下面去启动服务器

			```
			
			command=/Users/canvas/virtualenvs/django_drf_rimi_teaching/bin/gunicorn -c 
			gunicorn_conf.py drf_movie_rimi.wsgi &
			
			```
			
3. superviosr

	1. 在上面我们完成了gunicorn的部署之后,我们需要一个第三方监听程序去监听他。所以我们决定使用superviosr来做这个事情
	2. supservioser的安装
	
		注意使用sudo 和python 2.4 以上版本，不能使用python3
		
		```
		sudo pip2.7 install supervisor
		```
	
	3. 安装完成之后,首选配置

		```
		
			
			; Sample supervisor config file.
			;
			; For more information on the config file, please see:
			; http://supervisord.org/configuration.html
			;
			; Notes:
			;  - Shell expansion ("~" or "$HOME") is not supported.  Environment
			;    variables can be expanded using this syntax: "%(ENV_HOME)s".
			;  - Quotes around values are not supported, except in the case of
			;    the environment= options as shown below.
			;  - Comments must have a leading space: "a=b ;comment" not "a=b;comment".
			;  - Command will be truncated if it looks like a config file comment, e.g.
			;    "command=bash -c 'foo ; bar'" will truncate to "command=bash -c 'foo ".
			
			[unix_http_server]
			file=/tmp/supervisor.sock   ; the path to the socket file
			;chmod=0700                 ; socket file mode (default 0700)
			;chown=nobody:nogroup       ; socket file uid:gid owner
			;username=user              ; default is no username (open server)
			;password=123               ; default is no password (open server)
			
			[inet_http_server]         ; inet (TCP) server disabled by default
			port=127.0.0.1:9001        ; ip_address:port specifier, *:port for all iface
			username=user              ; default is no username (open server)
			password=123               ; default is no password (open server)
			
			[supervisord]
			logfile=/tmp/supervisord.log ; main log file; default $CWD/supervisord.log
			logfile_maxbytes=50MB        ; max main logfile bytes b4 rotation; default 50MB
			logfile_backups=10           ; # of main logfile backups; 0 means none, default 10
			loglevel=info                ; log level; default info; others: debug,warn,trace
			pidfile=/tmp/supervisord.pid ; supervisord pidfile; default supervisord.pid
			nodaemon=false               ; start in foreground if true; default false
			minfds=1024                  ; min. avail startup file descriptors; default 1024
			minprocs=200                 ; min. avail process descriptors;default 200
			;umask=022                   ; process file creation umask; default 022
			;user=chrism                 ; default is current user, required if root
			;identifier=supervisor       ; supervisord identifier, default is 'supervisor'
			;directory=/tmp              ; default is not to cd during start
			;nocleanup=true              ; don't clean up tempfiles at start; default false
			;childlogdir=/tmp            ; 'AUTO' child log dir, default $TEMP
			;environment=KEY="value"     ; key value pairs to add to environment
			;strip_ansi=false            ; strip ansi escape codes in logs; def. false
			
			; The rpcinterface:supervisor section must remain in the config file for
			; RPC (supervisorctl/web interface) to work.  Additional interfaces may be
			; added by defining them in separate [rpcinterface:x] sections.
			
			[rpcinterface:supervisor]
			supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
			
			; The supervisorctl section configures how supervisorctl will connect to
			; supervisord.  configure it match the settings in either the unix_http_server
			; or inet_http_server section.
			
			[supervisorctl]
			serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket
			;serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
			;username=chris              ; should be same as in [*_http_server] if set
			;password=123                ; should be same as in [*_http_server] if set
			;prompt=mysupervisor         ; cmd line prompt (default "supervisor")
			;history_file=~/.sc_history  ; use readline history if available
			
			; The sample program section below shows all possible program subsection values.
			; Create one or more 'real' program: sections to be able to control them under
			; supervisor.
			
			;[program:theprogramname]
			;command=/bin/cat              ; the program (relative uses PATH, can take args)
			;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
			;numprocs=1                    ; number of processes copies to start (def 1)
			;directory=/tmp                ; directory to cwd to before exec (def no cwd)
			;umask=022                     ; umask for process (default None)
			;priority=999                  ; the relative start priority (default 999)
			;autostart=true                ; start at supervisord start (default: true)
			;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
			;startretries=3                ; max # of serial start failures when starting (default 3)
			;autorestart=unexpected        ; when to restart if exited after running (def: unexpected)
			;exitcodes=0,2                 ; 'expected' exit codes used with autorestart (default 0,2)
			;stopsignal=QUIT               ; signal used to kill process (default TERM)
			;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
			;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
			;killasgroup=false             ; SIGKILL the UNIX process group (def false)
			;user=chrism                   ; setuid to this UNIX account to run the program
			;redirect_stderr=true          ; redirect proc stderr to stdout (default false)
			;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
			;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
			;stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
			;stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
			;stdout_events_enabled=false   ; emit events on stdout writes (default false)
			;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
			;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
			;stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
			;stderr_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
			;stderr_events_enabled=false   ; emit events on stderr writes (default false)
			;environment=A="1",B="2"       ; process environment additions (def no adds)
			;serverurl=AUTO                ; override serverurl computation (childutils)
			
			; The sample eventlistener section below shows all possible eventlistener
			; subsection values.  Create one or more 'real' eventlistener: sections to be
			; able to handle event notifications sent by supervisord.
			
			;[eventlistener:theeventlistenername]
			;command=/bin/eventlistener    ; the program (relative uses PATH, can take args)
			;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
			;numprocs=1                    ; number of processes copies to start (def 1)
			;events=EVENT                  ; event notif. types to subscribe to (req'd)
			;buffer_size=10                ; event buffer queue size (default 10)
			;directory=/tmp                ; directory to cwd to before exec (def no cwd)
			;umask=022                     ; umask for process (default None)
			;priority=-1                   ; the relative start priority (default -1)
			;autostart=true                ; start at supervisord start (default: true)
			;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
			;startretries=3                ; max # of serial start failures when starting (default 3)
			;autorestart=unexpected        ; autorestart if exited after running (def: unexpected)
			;exitcodes=0,2                 ; 'expected' exit codes used with autorestart (default 0,2)
			;stopsignal=QUIT               ; signal used to kill process (default TERM)
			;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
			;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
			;killasgroup=false             ; SIGKILL the UNIX process group (def false)
			;user=chrism                   ; setuid to this UNIX account to run the program
			;redirect_stderr=false         ; redirect_stderr=true is not allowed for eventlisteners
			;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
			;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
			;stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
			;stdout_events_enabled=false   ; emit events on stdout writes (default false)
			;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
			;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
			;stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
			;stderr_events_enabled=false   ; emit events on stderr writes (default false)
			;environment=A="1",B="2"       ; process environment additions
			;serverurl=AUTO                ; override serverurl computation (childutils)
			
			; The sample group section below shows all possible group values.  Create one
			; or more 'real' group: sections to create "heterogeneous" process groups.
			
			;[group:thegroupname]
			;programs=progname1,progname2  ; each refers to 'x' in [program:x] definitions
			;priority=999                  ; the relative start priority (default 999)
			
			; The [include] section can just contain the "files" setting.  This
			; setting can list multiple files (separated by whitespace or
			; newlines).  It can also contain wildcards.  The filenames are
			; interpreted as relative to this file.  Included files *cannot*
			; include files themselves.
			
			;[include]
			;files = relative/directory/*.ini
			
			[program:django3]
			command=/Users/canvas/virtualenvs/django_drf_rimi_teaching/bin/gunicorn -c 
			gunicorn_conf.py drf_movie_rimi.wsgi &
			directory=/Users/canvas/project/django_drf_rimi_teaching/drf_movie_rimi
			startsecs=0
			stopwaitsecs=0
			autostart=true
	autorestart=true


		```
		
		
		
	4. 启动它
	
		```
		

		supervisord -c supervisor1.conf	
		
		
		```
		
	5. 使用supervisorctl去查看状态


### 14. nginx 服务器

1. nginx 服务器说明:
	
	nginx是一款反向代理服务器 -> 代理服务器意思是本身不会处理任何代码,他只是将你的请求转发给其他端口处理 比如他可以把服务交给django服务程序处理
	
	nginx是纯C语言实现的 性能很高 他的意义是引擎的意思
	
	一般我们会把nginx作为文件服务器,因为文件服务器的特性是没有什么逻辑程序在其中,只需要单纯的按照协议来发送文件请求即可,这点也符合nginx的代码简单 效率高的特点。
	
	我们一般会把django中的文件交给nginx处理,django只负责逻辑代码，比如复杂的数据库请求，序列化等等
	
2. nginx的安装

	1. 官网下载 编译安装
	
		```
		$ http://nginx.org/download/nginx-1.15.2.tar.gz
		
		```
		
		解压
		
		```
		$ ./configure
		$ sudo make && make install
		```
	2. nginx启动命令和重启命令

		```
		$ sudo /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx_test.conf 
		
		$ sudo /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx_test.conf -s reload
		
		```

3. nginx服务器配置解释

	1. user 后面跟启动用户 和用户所在的用户组
	2. worker_processes 启动多少个线程
	3. events 需要多少最大连接
	4. error_log 错误日志
	5. http 代码http模块 nginx里面只能有一个http{}
	6. server 表示虚拟服务器 一个http里面可以有很多虚拟服务器
	7. listen 表示绑定到哪个端口
	8. location 表示端口对应的url匹配模式(正则表达式)
	9. root表示如果是文件服务的话，他会去哪里找到文件
	10. proxy_pass 表示转发到哪个服务上面去

	```
	#使用nginx的 用户和用户组
	user  canvas staff;
	worker_processes  2;
	
	#错误日志地方
	error_log  /Users/canvas/project/django_drf_rimi_teaching/drf_movie_rimi/log/nginx/error_run.log;
	#error_log  logs/error.log  notice;
	#error_log  logs/error.log  info;
	
	#pid        logs/nginx.pid;
	
	
	events {
	    worker_connections  4096;
	}
	
	
	http {
	    include       mime.types;
	    default_type  application/octet-stream;
	
	
	    sendfile        on;
	    #tcp_nopush     on;
	
	    #keepalive_timeout  0;
	    keepalive_timeout  65;
	
	    #gzip  on;
	
	    #监听18080端口
	    server {
	        charset utf-8;
	        listen 18080;
	
		    #client_max_body_size 5;
	   	    #location /static {
		    #    client_max_body_size 5m;
	       	#	alias /root/project/moudu_movie_online_test/backend/static;
			#    allow all;
	   	    #}
	
	        location / {
		        client_max_body_size 5m;
	       	    proxy_set_header Host $host;
	       	    #把18080端口转发给8005
	       	    proxy_pass http://127.0.0.1:8005;
	        }
	
	        error_log /Users/canvas/project/django_drf_rimi_teaching/drf_movie_rimi/log/nginx/error.log;
		    access_log /Users/canvas/project/django_drf_rimi_teaching/drf_movie_rimi/log/nginx/access.log;
	    }
	
	    server {
	        listen 10081;
	        root  /Users/canvas/project/django_drf_rimi_teaching/drf_movie_rimi;
	        location ~ .*\.(js|css|html|gif|jpg|jpeg|png|bmp|dat|zip|jz|mp3|exe|dds|alpha|rar|spr|dll|pdb|
	        pak|xxx|pck|cur|rs|atf|pwz|flv|lnk|psd|pwb|wav)$
	        
	        {
	            expires      240h;
	        }
	
	        error_log /Users/canvas/project/django_drf_rimi_teaching/drf_movie_rimi/log/nginx/
	        static_error.log;
		    access_log /Users/canvas/project/django_drf_rimi_teaching/drf_movie_rimi/log/nginx/
		    static_access.log;
	    }
	}

	
	```




