---
title: Django框架07--表单
categories: python-Django
tags:
  - python
  - Django
top: 8
abbrlink: 3826544670
date: 2019-06-07 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Django.jpeg)




## 作用

django的form有两个功能,第一个是帮助我们生成表单,在html里面,第二个功能是帮我们验证表单

<!--more-->

## 1. 生成表单

1. 首先我们会在一个外部的forms.py文件里面建立我们的表单类,在这个类的定义的字段会直接显示在html里面,我们不用在html里面去写input标签

	>test1/forms.py
	
	```
	
	from django import forms
	
	class LoginForm(forms.Form):
	    zhanghu = forms.CharField(max_length=10)
	    mima = forms.CharField(max_length=20)
	
	```
	
2. 在views里面去实例化表单类,注意,我们是去实例化forms.py里面的LoginForm 然后把实例化的对象login_form 传递给模板 login_test.html 传递的值是 form

	> test1/views.py
	
	```
	
	def test5(request):
	
		 from movies.forms import LoginForm
	    method = request.method
	
	    if method == "GET":
	        login_form = LoginForm()
	        return render(request,'test1/login_test.html',{'form':login_form})
	    elif method == "POST":
	        account = request.POST['account']
	        password = request.POST['password']
	        return HttpResponse('POST')
	
	
	
	```
	
3. 在html里面去调用form,以{{ form }}为接受值,因为我们在views.py里面定义就是form,当然我们也可以定义其他的值
	
	```
	 return render(request,'test1/login_test.html',{'form':login_form})
	
	```
	
	>templates/movies/login_test.html
	
		```
		
		<!DOCTYPE html>
		<html lang="en">
		<head>
		    <meta charset="UTF-8">
		    <title>Title</title>
		</head>
		<body>
		<h1>hi Login!</h1>
		
		<form action="http://127.0.0.1:18001/login/" method="post">
		    {{ form }}
		
		</form>
		</body>
		</html>
		
		
		```
