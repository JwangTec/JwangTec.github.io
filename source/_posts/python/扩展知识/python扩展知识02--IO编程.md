---
title: python扩展知识02--IO编程
categories: python扩展
tags:
  - pythonIO编程
top: 2
abbrlink: 3348220571
date: 2019-05-01 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/python01.jpeg)

# IO编程

<!--more-->

### 1. IO

IO在计算机中指Input/Output，也就是输入和输出。由于程序和运行时数据是在内存中驻留，由CPU这个超快的计算核心来执行，涉及到数据交换的地方，通常是磁盘、网络等，就需要IO接口。

>比如你打开浏览器，访问新浪首页，浏览器这个程序就需要通过网络IO获取新浪的网页。浏览器首先会发送数据给新浪服务器，告诉它我想要首页的HTML，这个动作是往外发数据，叫Output
>
>随后新浪服务器把网页发过来，这个动作是从外面接收数据，叫Input。
>
>通常，程序完成IO操作会有Input和Output两个数据流。当然也有只用一个的情况，比如，从磁盘读取文件到内存，就只有Input操作，反过来，把数据写到磁盘文件里，就只是一个Output操作。

### 2. stream

IO编程中，Stream（流）是一个很重要的概念，可以把流想象成一个水管，数据就是水管里的水，但是只能单向流动。

>Input Stream就是数据从外面（磁盘、网络）流进内存，Output Stream就是数据从内存流到外面去。
>
>对于浏览网页来说，浏览器和新浪服务器之间至少需要建立两根水管，才可以既能发数据，又能收数据。


由于CPU和内存的速度远远高于外设的速度，所以，在IO编程中，就存在速度严重不匹配的问题。举个例子来说，比如要把100M的数据写入磁盘，CPU输出100M的数据只需要0.01秒，可是磁盘要接收这100M数据可能需要10秒，怎么办呢？有两种办法：

<strong>1. 第一种是CPU等着，也就是程序暂停执行后续代码，等100M的数据在10秒后写入磁盘，再接着往下执行，这种模式称为同步IO；

2.另一种方法是CPU不等待，只是告诉磁盘，“您老慢慢写，不着急，我接着干别的事去了”，于是，后续代码可以立刻接着执行，这种模式称为异步IO。</strong>

### 3. 同步与异步区别

同步和异步的区别就在于是否等待IO执行的结果。

>好比你去麦当劳点餐，你说“来个汉堡”，服务员告诉你，对不起，汉堡要现做，需要等5分钟，于是你站在收银台前面等了5分钟，拿到汉堡再去逛商场，这是同步IO。

>你说“来个汉堡”，服务员告诉你，汉堡需要等5分钟，你可以先去逛商场，等做好了，我们再通知你，这样你可以立刻去干别的事情（逛商场），这是异步IO。

使用异步IO来编写程序性能会远远高于同步IO，但是异步IO的缺点是编程模型复杂。想想看，你得知道什么时候通知你“汉堡做好了”，而通知你的方法也各不相同。如果是服务员跑过来找到你，这是回调模式，如果服务员发短信通知你，你就得不停地检查手机，这是轮询模式。

>总之，异步IO的复杂度远远高于同步IO。

操作IO的能力都是由操作系统提供的，每一种编程语言都会把操作系统提供的低级C接口封装起来方便使用，Python也不例外。我们后面会详细讨论Python的IO编程接口。


# 同步IO

## 文件读写

### 说明

读写文件是最常见的IO操作。Python内置了读写文件的函数，用法和C是兼容的。

读写文件前，我们先必须了解一下，在磁盘上读写文件的功能都是由操作系统提供的，现代操作系统不允许普通的程序直接操作磁盘，所以，读写文件就是请求操作系统打开一个文件对象（通常称为文件描述符），然后，通过操作系统提供的接口从这个文件对象中读取数据（读文件），或者把数据写入这个文件对象（写文件）。

### 读文件

#### 文本文件

1. 要以读文件的模式打开一个文件对象，使用Python内置的open()函数，传入文件名和标示符：

	```
	f = open('/Users/michael/test.txt', 'r')

	```
	>标示符'r'表示读，这样，我们就成功地打开了一个文件。

2. 如果文件不存在，open()函数就会抛出一个IOError的错误，并且给出错误码和详细的信息告诉你文件不存在：

	```
	>>> f=open('/Users/michael/notfound.txt', 'r')
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	FileNotFoundError: [Errno 2] No such file or directory: '/Users/michael/notfound.txt'
	
	```
	
3. 如果文件打开成功，接下来，调用read()方法可以一次读取文件的全部内容，Python把内容读到内存，用一个str对象表示：

	```
	>>> f.read()
	'Hello, world!'
	
	```
4. 最后一步是调用close()方法关闭文件。文件使用完毕后必须关闭，因为文件对象会占用操作系统的资源，并且操作系统同一时间能打开的文件数量也是有限的：
	
	```
	>>> f.close()
	
	```

5. 由于文件读写时都有可能产生IOError，一旦出错，后面的f.close()就不会调用。所以，为了保证无论是否出错都能正确地关闭文件，我们可以使用try ... finally来实现：

	```
	try:
	    f = open('/path/to/file', 'r')
	    print(f.read())
	finally:
	    if f:
	        f.close()
	
	```

6. 但是每次都这么写实在太繁琐，所以，Python引入了with语句来自动帮我们调用close()方法：

	```
	with open('/path/to/file', 'r') as f:
	    print(f.read())
	
	```
	>这和前面的try ... finally是一样的，但是代码更佳简洁，并且不必调用f.close()方法。

7. 调用read()会一次性读取文件的全部内容，如果文件有10G，内存就爆了，所以，要保险起见，可以反复调用read(size)方法，每次最多读取size个字节的内容。另外，调用readline()可以每次读取一行内容，调用readlines()一次读取所有内容并按行返回list。因此，要根据需要决定怎么调用。

	>如果文件很小，read()一次性读取最方便；如果不能确定文件大小，反复调用read(size)比较保险；如果是配置文件，调用readlines()最方便：

	```
	for line in f.readlines():
	    print(line.strip()) # 把末尾的'\n'删掉
	file-like Object
	```

8. 像open()函数返回的这种有个read()方法的对象，在Python中统称为file-like Object。除了file外，还可以是内存的字节流，网络流，自定义流等等。file-like Object不要求从特定类继承，只要写个read()方法就行。

	>StringIO就是在内存中创建的file-like Object，常用作临时缓冲。

#### 二进制文件

1. 前面讲的默认都是读取文本文件，并且是UTF-8编码的文本文件。要读取二进制文件，比如图片、视频等等，用'rb'模式打开文件即可：

	```
	>>> f = open('/Users/michael/test.jpg', 'rb')
	>>> f.read()
	b'\xff\xd8\xff\xe1\x00\x18Exif\x00\x00...' # 十六进制表示的字节
	
	```

2. 字符编码
要读取非UTF-8编码的文本文件，需要给open()函数传入encoding参数，例如，读取GBK编码的文件：

	```
	>>> f = open('/Users/michael/gbk.txt', 'r', encoding='gbk')
	>>> f.read()
	'测试'
	
	```
3. 遇到有些编码不规范的文件，你可能会遇到UnicodeDecodeError，因为在文本文件中可能夹杂了一些非法编码的字符。遇到这种情况，open()函数还接收一个errors参数，表示如果遇到编码错误后如何处理。最简单的方式是直接忽略：

	```
	>>> f = open('/Users/michael/gbk.txt', 'r', encoding='gbk', errors='ignore')
	```

### 写文件

1. 写文件和读文件是一样的，唯一区别是调用open()函数时，传入标识符'w'或者'wb'表示写文本文件或写二进制文件：

	```
	>>> f = open('/Users/michael/test.txt', 'w')
	>>> f.write('Hello, world!')
	>>> f.close()
	
	```

	>你可以反复调用write()来写入文件，但是务必要调用f.close()来关闭文件。当我们写文件时，操作系统往往不会立刻把数据写入磁盘，而是放到内存缓存起来，空闲的时候再慢慢写入。只有调用close()方法时，操作系统才保证把没有写入的数据全部写入磁盘。忘记调用close()的后果是数据可能只写了一部分到磁盘，剩下的丢失了。

	所以，还是用with语句来得保险：
	
	```
	with open('/Users/michael/test.txt', 'w') as f:
	    f.write('Hello, world!')
	```

	>要写入特定编码的文本文件，请给open()函数传入encoding参数，将字符串自动转换成指定编码。


2. 以'w'模式写入文件时，如果文件已存在，会直接覆盖（相当于删掉后新写入一个文件）。如果我们希望追加到文件末尾怎么办？可以传入'a'以追加（append）模式写入。

	>所有模式的定义及含义可以参考Python的[官方文档](https://docs.python.org/3/library/functions.html#open)。


## StringIO和BytesIO

### StringIO

#### 定义

很多时候，数据读写不一定是文件，也可以在内存中读写。

StringIO顾名思义就是在内存中读写str。

#### 操作

1. 要把str写入StringIO，我们需要先创建一个StringIO，然后，像文件一样写入即可：
	
	```
	>>> from io import StringIO
	>>> f = StringIO()
	>>> f.write('hello')
	5
	>>> f.write(' ')
	1
	>>> f.write('world!')
	6
	>>> print(f.getvalue())
	hello world!
	getvalue()方法用于获得写入后的str。
	```

2. 要读取StringIO，可以用一个str初始化StringIO，然后，像读文件一样读取：

	```
	>>> from io import StringIO
	>>> f = StringIO('Hello!\nHi!\nGoodbye!')
	>>> while True:
	...     s = f.readline()
	...     if s == '':
	...         break
	...     print(s.strip())
	...
	Hello!
	Hi!
	Goodbye!
	BytesIO
	
	```

3. StringIO操作的只能是str，如果要操作二进制数据，就需要使用BytesIO。

	>BytesIO实现了在内存中读写bytes，我们创建一个BytesIO，然后写入一些bytes：
	
	```
	>>> from io import BytesIO
	>>> f = BytesIO()
	>>> f.write('中文'.encode('utf-8'))
	6
	>>> print(f.getvalue())
	b'\xe4\xb8\xad\xe6\x96\x87'
	
	```
	>请注意，写入的不是str，而是经过UTF-8编码的bytes。


4. 和StringIO类似，可以用一个bytes初始化BytesIO，然后，像读文件一样读取：

	```
	>>> from io import BytesIO
	>>> f = BytesIO(b'\xe4\xb8\xad\xe6\x96\x87')
	>>> f.read()
	b'\xe4\xb8\xad\xe6\x96\x87'
	
	```

5. 代码

	```
	#!/usr/bin/env python3
	# -*- coding: utf-8 -*-
	
	from io import StringIO
	
	# write to StringIO:
	f = StringIO()
	f.write('hello')
	f.write(' ')
	f.write('world!')
	print(f.getvalue())
	
	# read from StringIO:
	f = StringIO('水面细风生，\n菱歌慢慢声。\n客亭临小市，\n灯火夜妆明。')
	while True:
	    s = f.readline()
	    if s == '':
	        break
	    print(s.strip())
	
	```
	
	```
	#!/usr/bin/env python3
	# -*- coding: utf-8 -*-
	
	from io import BytesIO
	
	# write to BytesIO:
	f = BytesIO()
	f.write(b'hello')
	f.write(b' ')
	f.write(b'world!')
	print(f.getvalue())
	
	# read from BytesIO:
	data = '人闲桂花落，夜静春山空。月出惊山鸟，时鸣春涧中。'.encode('utf-8')
	f = BytesIO(data)
	print(f.read())
		
	```


## 操作文件和目录

### 定义

如果我们要操作文件、目录，可以在命令行下面输入操作系统提供的各种命令来完成。比如dir、cp等命令。

如果要在Python程序中执行这些目录和文件的操作怎么办？其实操作系统提供的命令只是简单地调用了操作系统提供的接口函数，Python内置的os模块也可以直接调用操作系统提供的接口函数。

### 操作

1. 打开Python交互式命令行，我们来看看如何使用os模块的基本功能：

	```
	>>> import os
	>>> os.name # 操作系统类型
	'posix'
	
	```
	
	>如果是posix，说明系统是Linux、Unix或Mac OS X，如果是nt，就是Windows系统。

2. 要获取详细的系统信息，可以调用uname()函数：

	```
	>>> os.uname()
	posix.uname_result(sysname='Darwin', nodename='MichaelMacPro.local', release='14.3.0', 
	version='Darwin Kernel Version 14.3.0: Mon Mar 23 11:59:05 PDT 2015; 
	root:xnu-2782.20.48~5/RELEASE_X86_64', machine='x86_64')
	```
	>注意uname()函数在Windows上不提供，也就是说，os模块的某些函数是跟操作系统相关的。

3. 环境变量

	在操作系统中定义的环境变量，全部保存在os.environ这个变量中，可以直接查看：
	
	```
		>>> os.environ
		environ({'VERSIONER_PYTHON_PREFER_32_BIT': 'no', 'TERM_PROGRAM_VERSION': '326', 'LOGNAME': 
		'michael', 'USER': 'michael', 'PATH': '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:
		/opt/X11/bin:/usr/local/mysql/bin', ...})
		
	```

	要获取某个环境变量的值，可以调用os.environ.get('key')：

	```
	>>> os.environ.get('PATH')
	'/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/mysql/bin'
	>>> os.environ.get('x', 'default')
	'default'
	
	```

### 操作文件和目录

1. 操作文件和目录的函数一部分放在os模块中，一部分放在os.path模块中，这一点要注意一下。查看、创建和删除目录可以这么调用：

	```
	# 查看当前目录的绝对路径:
	>>> os.path.abspath('.')
	'/Users/michael'
	# 在某个目录下创建一个新目录，首先把新目录的完整路径表示出来:
	>>> os.path.join('/Users/michael', 'testdir')
	'/Users/michael/testdir'
	# 然后创建一个目录:
	>>> os.mkdir('/Users/michael/testdir')
	# 删掉一个目录:
	>>> os.rmdir('/Users/michael/testdir')
	
	```

2. 把两个路径合成一个时，不要直接拼字符串，而要通过os.path.join()函数，这样可以正确处理不同操作系统的路径分隔符。在Linux/Unix/Mac下，os.path.join()返回这样的字符串：
	
	```
	part-1/part-2
	而Windows下会返回这样的字符串：
	
	part-1\part-2
	
	```

3. 同样的道理，要拆分路径时，也不要直接去拆字符串，而要通过os.path.split()函数，这样可以把一个路径拆分为两部分，后一部分总是最后级别的目录或文件名：

	```
	>>> os.path.split('/Users/michael/testdir/file.txt')
	('/Users/michael/testdir', 'file.txt')
	os.path.splitext()可以直接让你得到文件扩展名，很多时候非常方便：
	
	>>> os.path.splitext('/path/to/file.txt')
	('/path/to/file', '.txt')
	```
	>这些合并、拆分路径的函数并不要求目录和文件要真实存在，它们只对字符串进行操作。

4. 文件操作使用下面的函数。假定当前目录下有一个test.txt文件：

	```
	# 对文件重命名:
	>>> os.rename('test.txt', 'test.py')
	# 删掉文件:
	>>> os.remove('test.py')
	
	```
	
	>但是复制文件的函数居然在os模块中不存在！原因是复制文件并非由操作系统提供的系统调用。理论上讲，我们通过上一节的读写文件可以完成文件复制，只不过要多写很多代码。
	
	>幸运的是shutil模块提供了copyfile()的函数，你还可以在shutil模块中找到很多实用函数，它们可以看做是os模块的补充。

5. 利用Python的特性来过滤文件。比如我们要列出当前目录下的所有目录，只需要一行代码：

	```
	>>> [x for x in os.listdir('.') if os.path.isdir(x)]
	['.lein', '.local', '.m2', '.npm', '.ssh', '.Trash', '.vim', 'Applications', 'Desktop', ...]
	要列出所有的.py文件，也只需一行代码：
	
	>>> [x for x in os.listdir('.') if os.path.isfile(x) and os.path.splitext(x)[1]=='.py']
	['apis.py', 'config.py', 'models.py', 'pymonitor.py', 'test_db.py', 'urls.py', 'wsgiapp.py']
	是不是非常简洁？
	
	```
小结

Python的os模块封装了操作系统的目录和文件操作，要注意这些函数有的在os模块中，有的在os.path模块中。

### 代码

```
	#!/usr/bin/env python3
	# -*- coding: utf-8 -*-
	
	from datetime import datetime
	import os
	
	pwd = os.path.abspath('.')
	
	print('      Size     Last Modified  Name')
	print('------------------------------------------------------------')
	
	for f in os.listdir(pwd):
	    fsize = os.path.getsize(f)
	    mtime = datetime.fromtimestamp(os.path.getmtime(f)).strftime('%Y-%m-%d %H:%M')
	    flag = '/' if os.path.isdir(f) else ''
	    print('%10d  %s  %s%s' % (fsize, mtime, f, flag))
	
```



## 序列化

### 定义

1. 在程序运行的过程中，所有的变量都是在内存中，比如，定义一个dict：

	
	>d = dict(name='Bob', age=20, score=88)
	>
	>可以随时修改变量，比如把name改成'Bill'，但是一旦程序结束，变量所占用的内存就被操作系统全部回收。如果没有把修改后的'Bill'存储到磁盘上，下次重新运行程序，变量又被初始化为'Bob'。


2. 我们把变量从内存中变成可存储或传输的过程称之为序列化，在Python中叫pickling，在其他语言中也被称之为serialization，marshalling，flattening等等，都是一个意思。

3. 序列化之后，就可以把序列化后的内容写入磁盘，或者通过网络传输到别的机器上。

4. 反过来，把变量内容从序列化的对象重新读到内存里称之为反序列化，即unpickling。

### 操作

#### pickle

>Python提供了pickle模块来实现序列化。

1. 首先，我们尝试把一个对象序列化并写入文件：

	```
	>>> import pickle
	>>> d = dict(name='Bob', age=20, score=88)
	>>> pickle.dumps(d)
	b'\x80\x03}q\x00(X\x03\x00\x00\x00ageq\x01K\x14X\x05\x00\x00\x00scoreq\x02KXX\x04\x00\x00\x00nameq
	\x03X\x03\x00\x00\x00Bobq\x04u.'
	
	```

2. pickle.dumps()方法把任意对象序列化成一个bytes，然后，就可以把这个bytes写入文件。或者用另一个方法pickle.dump()直接把对象序列化后写入一个file-like Object：
	
	```
	>>> f = open('dump.txt', 'wb')
	>>> pickle.dump(d, f)
	>>> f.close()
	```
	
	>看看写入的dump.txt文件，一堆乱七八糟的内容，这些都是Python保存的对象内部信息。

3. 当我们要把对象从磁盘读到内存时，可以先把内容读到一个bytes，然后用pickle.loads()方法反序列化出对象，也可以直接用pickle.load()方法从一个file-like Object中直接反序列化出对象。我们打开另一个Python命令行来反序列化刚才保存的对象：

	```
	>>> f = open('dump.txt', 'rb')
	>>> d = pickle.load(f)
	>>> f.close()
	>>> d
	{'age': 20, 'score': 88, 'name': 'Bob'}
	```
	>这个变量和原来的变量是完全不相干的对象，它们只是内容相同而已。
	
	>Pickle的问题和所有其他编程语言特有的序列化问题一样，就是它只能用于Python，并且可能不同版本的Python彼此都不兼容，因此，只能用Pickle保存那些不重要的数据，不能成功地反序列化也没关系。

#### JSON

如果我们要在不同的编程语言之间传递对象，就必须把对象序列化为标准格式，比如XML，但更好的方法是序列化为JSON，因为JSON表示出来就是一个字符串，可以被所有语言读取，也可以方便地存储到磁盘或者通过网络传输。JSON不仅是标准格式，并且比XML更快，而且可以直接在Web页面中读取，非常方便。

1. JSON表示的对象就是标准的JavaScript语言的对象，JSON和Python内置的数据类型对应如下：


	|JSON类型|	Python类型
	|:-:|:-:|
	{}	|dict
	[]	|list
	"string"|	str
	1234.56	|int或float
	true/false	|True/False
	null|	None

2. Python内置的json模块提供了非常完善的Python对象到JSON格式的转换。我们先看看如何把Python对象变成一个JSON：

	```
	>>> import json
	>>> d = dict(name='Bob', age=20, score=88)
	>>> json.dumps(d)
	'{"age": 20, "score": 88, "name": "Bob"}'
	
	```
>dumps()方法返回一个str，内容就是标准的JSON。类似的，dump()方法可以直接把JSON写入一个file-like Object。

3. 要把JSON反序列化为Python对象，用loads()或者对应的load()方法，前者把JSON的字符串反序列化，后者从file-like Object中读取字符串并反序列化：
	
	```
	>>> json_str = '{"age": 20, "score": 88, "name": "Bob"}'
	>>> json.loads(json_str)
	{'age': 20, 'score': 88, 'name': 'Bob'}
	
	```

	>由于JSON标准规定JSON编码是UTF-8，所以我们总是能正确地在Python的str与JSON的字符串之间转换。

#### JSON进阶

1. Python的dict对象可以直接序列化为JSON的{}，不过，很多时候，我们更喜欢用class表示对象，比如定义Student类，然后序列化：
	
	```
	import json
	
	class Student(object):
	    def __init__(self, name, age, score):
	        self.name = name
	        self.age = age
	        self.score = score
	
	s = Student('Bob', 20, 88)
	print(json.dumps(s))
	```
	
	>运行代码，毫不留情地得到一个TypeError：
	
	>Traceback (most recent call last):
	>
	> ...
	>
	>TypeError: <__main__.Student object at 0x10603cc50> is not JSON serializable
	
	>错误的原因是Student对象不是一个可序列化为JSON的对象。


2. dumps()方法的参数列表,除了第一个必须的obj参数外，dumps()方法还提供了一大堆的可选参数：

	[https://docs.python.org/3/library/json.html#json.dumps](https://docs.python.org/3/library/json.html#json.dumps)


这些可选参数就是让我们来定制JSON序列化。前面的代码之所以无法把Student类实例序列化为JSON，是因为默认情况下，dumps()方法不知道如何将Student实例变为一个JSON的{}对象。

可选参数default就是把任意一个对象变成一个可序列为JSON的对象，我们只需要为Student专门写一个转换函数，再把函数传进去即可：

```
	def student2dict(std):
	    return {
	        'name': std.name,
	        'age': std.age,
	        'score': std.score
	    }
	    
```
	
>这样，Student实例首先被student2dict()函数转换成dict，然后再被顺利序列化为JSON：
	
```
	>>> print(json.dumps(s, default=student2dict))
	{"age": 20, "name": "Bob", "score": 88}
	
```

不过，下次如果遇到一个Teacher类的实例，照样无法序列化为JSON。我们可以偷个懒，把任意class的实例变为dict：

```
	print(json.dumps(s, default=lambda obj: obj.__dict__))
	
```

因为通常class的实例都有一个__dict__属性，它就是一个dict，用来存储实例变量。也有少数例外，比如定义了__slots__的class。

3. 同样的道理，如果我们要把JSON反序列化为一个Student对象实例，loads()方法首先转换出一个dict对象，然后，我们传入的object_hook函数负责把dict转换为Student实例：
	
	```
	def dict2student(d):
	    return Student(d['name'], d['age'], d['score'])
	运行结果如下：
	
	>>> json_str = '{"age": 20, "score": 88, "name": "Bob"}'
	>>> print(json.loads(json_str, object_hook=dict2student))
	<__main__.Student object at 0x10cd3c190>
	打印出的是反序列化的Student实例对象。
	
	```

### 小结

1. Python语言特定的序列化模块是pickle，但如果要把序列化搞得更通用、更符合Web标准，就可以使用json模块。

2. json模块的dumps()和loads()函数是定义得非常好的接口的典范。当我们使用时，只需要传入一个必须的参数。但是，当默认的序列化或反序列机制不满足我们的要求时，我们又可以传入更多的参数来定制序列化或反序列化的规则，既做到了接口简单易用，又做到了充分的扩展性和灵活性。

### 代码

	```
	#!/usr/bin/env python3
	# -*- coding: utf-8 -*-
	
	import pickle
	
	d = dict(name='Bob', age=20, score=88)
	data = pickle.dumps(d)
	print(data)
	
	reborn = pickle.loads(data)
	print(reborn)
	```
	
	```
	#!/usr/bin/env python3
	# -*- coding: utf-8 -*-
	
	import json
	
	d = dict(name='Bob', age=20, score=88)
	data = json.dumps(d)
	print('JSON Data is a str:', data)
	reborn = json.loads(data)
	print(reborn)
	
	class Student(object):
	
	    def __init__(self, name, age, score):
	        self.name = name
	        self.age = age
	        self.score = score
	
	    def __str__(self):
	        return 'Student object (%s, %s, %s)' % (self.name, self.age, self.score)
	
	s = Student('Bob', 20, 88)
	std_data = json.dumps(s, default=lambda obj: obj.__dict__)
	print('Dump Student:', std_data)
	rebuild = json.loads(std_data, object_hook=lambda d: Student(d['name'], d['age'], d['score']))
	print(rebuild)
	```


#异步IO

## 解释

1. CPU的速度远远快于磁盘、网络等IO。在一个线程中，CPU执行代码的速度极快，然而，一旦遇到IO操作，如读写文件、发送网络数据时，就需要等待IO操作完成，才能继续进行下一步操作。这种情况称为同步IO。

	>在IO操作的过程中，当前线程被挂起，而其他需要CPU执行的代码就无法被当前线程执行了。

	>因为一个IO操作就阻塞了当前线程，导致其他代码无法执行，所以我们必须使用多线程或者多进程来并发执行代码，为多个用户服务。每个用户都会分配一个线程，如果遇到IO导致线程被挂起，其他用户的线程不受影响。

2. 多线程和多进程的模型虽然解决了并发问题，但是系统不能无上限地增加线程。由于系统切换线程的开销也很大，所以，一旦线程数量过多，CPU的时间就花在线程切换上了，真正运行代码的时间就少了，结果导致性能严重下降。

	由于我们要解决的问题是CPU高速执行能力和IO设备的龟速严重不匹配，多线程和多进程只是解决这一问题的一种方法。

	另一种解决IO问题的方法是异步IO。当代码需要执行一个耗时的IO操作时，它只发出IO指令，并不等待IO结果，然后就去执行其他代码了。一段时间后，当IO返回结果时，再通知CPU进行处理。

3. 如果按普通顺序写出的代码实际上是没法完成异步IO的：

	```
	do_some_code()
	f = open('/path/to/file', 'r')
	r = f.read() # <== 线程停在此处等待IO操作结果
	# IO操作完成后线程才能继续执行:
	do_some_code(r)
	所以，同步IO模型的代码是无法实现异步IO模型的。
	```

4. 异步IO模型需要一个消息循环，在消息循环中，主线程不断地重复“读取消息-处理消息”这一过程：
	
	```
	loop = get_event_loop()
	while True:
	    event = loop.get_event()
	    process_event(event)
	```

5. 消息模型其实早在应用在桌面应用程序中了。一个GUI程序的主线程就负责不停地读取消息并处理消息。所有的键盘、鼠标等消息都被发送到GUI程序的消息队列中，然后由GUI程序的主线程处理。

6. 由于GUI线程处理键盘、鼠标等消息的速度非常快，所以用户感觉不到延迟。某些时候，GUI线程在一个消息处理的过程中遇到问题导致一次消息处理时间过长，此时，用户会感觉到整个GUI程序停止响应了，敲键盘、点鼠标都没有反应。这种情况说明在消息模型中，处理一个消息必须非常迅速，否则，主线程将无法及时处理消息队列中的其他消息，导致程序看上去停止响应。

7. 消息模型是如何解决同步IO必须等待IO操作这一问题的呢？当遇到IO操作时，代码只负责发出IO请求，不等待IO结果，然后直接结束本轮消息处理，进入下一轮消息处理过程。当IO操作完成后，将收到一条“IO完成”的消息，处理该消息时就可以直接获取IO操作结果。

8. 在“发出IO请求”到收到“IO完成”的这段时间里，同步IO模型下，主线程只能挂起，但异步IO模型下，主线程并没有休息，而是在消息循环中继续处理其他消息。这样，在异步IO模型下，一个线程就可以同时处理多个IO请求，并且没有切换线程的操作。对于大多数IO密集型的应用程序，使用异步IO将大大提升系统的多任务处理能力。


## 协程

### 定义

1. 协程，又称微线程，纤程。英文名Coroutine。

2. 子程序，或者称为函数，在所有语言中都是层级调用，比如A调用B，B在执行过程中又调用了C，C执行完毕返回，B执行完毕返回，最后是A执行完毕。

	>所以子程序调用是通过栈实现的，一个线程就是执行一个子程序。

	>子程序调用总是一个入口，一次返回，调用顺序是明确的。而协程的调用和子程序不同。

	>协程看上去也是子程序，但执行过程中，在子程序内部可中断，然后转而执行别的子程序，在适当的时候再返回来接着执行。


3. 注意，在一个子程序中中断，去执行其他子程序，不是函数调用，有点类似CPU的中断。比如子程序A、B：

	```
	def A():
    	print('1')
    	print('2')
    	print('3')

	def B():
    	print('x')
    	print('y')
    	print('z')
	```

	>假设由协程执行，在执行A的过程中，可以随时中断，去执行B，B也可能在执行过程中中断再去执行A，结果可能是：

	```
	1
	2
	x
	y
	3
	z
	```

	>但是在A中是没有调用B的，所以协程的调用比函数调用理解起来要难一些。

	>看起来A、B的执行有点像多线程，但协程的特点在于是一个线程执行，那和多线程比，协程有何优势？

### 优势

1. 最大的优势就是协程极高的执行效率。因为子程序切换不是线程切换，而是由程序自身控制，因此，没有线程切换的开销，和多线程比，线程数量越多，协程的性能优势就越明显。

2. 第二大优势就是不需要多线程的锁机制，因为只有一个线程，也不存在同时写变量冲突，在协程中控制共享资源不加锁，只需要判断状态就好了，所以执行效率比多线程高很多。

	>因为协程是一个线程执行，那怎么利用多核CPU呢？最简单的方法是多进程+协程，既充分利用多核，又充分发挥协程的高效率，可获得极高的性能。

### generator

1. Python对协程的支持是通过generator实现的。

	>在generator中，我们不但可以通过for循环来迭代，还可以不断调用next()函数获取由yield语句返回的下一个值。

2. Python的yield不但可以返回一个值，它还可以接收调用者发出的参数。

	>来看例子：
	
	>传统的生产者-消费者模型是一个线程写消息，一个线程取消息，通过锁机制控制队列和等待，但一不小心就可能死锁。

	>如果改用协程，生产者生产消息后，直接通过yield跳转到消费者开始执行，待消费者执行完毕后，切换回生产者继续生产，效率极高：
		
	```
		def consumer():
		    r = ''
		    while True:
		        n = yield r
		        if not n:
		            return
		        print('[CONSUMER] Consuming %s...' % n)
		        r = '200 OK'
		
		def produce(c):
		    c.send(None)
		    n = 0
		    while n < 5:
		        n = n + 1
		        print('[PRODUCER] Producing %s...' % n)
		        r = c.send(n)
		        print('[PRODUCER] Consumer return: %s' % r)
		    c.close()
		
		c = consumer()
		produce(c)
		执行结果：
		
		[PRODUCER] Producing 1...
		[CONSUMER] Consuming 1...
		[PRODUCER] Consumer return: 200 OK
		[PRODUCER] Producing 2...
		[CONSUMER] Consuming 2...
		[PRODUCER] Consumer return: 200 OK
		[PRODUCER] Producing 3...
		[CONSUMER] Consuming 3...
		[PRODUCER] Consumer return: 200 OK
		[PRODUCER] Producing 4...
		[CONSUMER] Consuming 4...
		[PRODUCER] Consumer return: 200 OK
		[PRODUCER] Producing 5...
		[CONSUMER] Consuming 5...
		[PRODUCER] Consumer return: 200 OK
		```
	
3. 注意到consumer函数是一个generator，把一个consumer传入produce后：
	
	>1. 首先调用c.send(None)启动生成器；
		
	>2. 然后，一旦生产了东西，通过c.send(n)切换到consumer执行；
		
	>3. consumer通过yield拿到消息，处理，又通过yield把结果传回；
		
	>4. produce拿到consumer处理的结果，继续生产下一条消息；
		
	>5. produce决定不生产了，通过c.close()关闭consumer，整个过程结束。
		
	>整个流程无锁，由一个线程执行，produce和consumer协作完成任务，所以称为“协程”，而非线程的抢占式多任务。
	

<s>协程的特点：“子程序就是协程的一种特例。”</s>


## asyncio


### 定义

asyncio是Python 3.4版本引入的标准库，直接内置了对异步IO的支持。

asyncio的编程模型就是一个消息循环。我们从asyncio模块中直接获取一个EventLoop的引用，然后把需要执行的协程扔到EventLoop中执行，就实现了异步IO。

### 操作

1. 用asyncio实现Hello world代码如下：

```
import asyncio

@asyncio.coroutine
def hello():
    print("Hello world!")
    # 异步调用asyncio.sleep(1):
    r = yield from asyncio.sleep(1)
    print("Hello again!")

# 获取EventLoop:
loop = asyncio.get_event_loop()
# 执行coroutine
loop.run_until_complete(hello())
loop.close()

```
>@asyncio.coroutine把一个generator标记为coroutine类型，然后，我们就把这个coroutine扔到EventLoop中执行。

hello()会首先打印出Hello world!，然后，yield from语法可以让我们方便地调用另一个generator。

由于asyncio.sleep()也是一个coroutine，所以线程不会等待asyncio.sleep()，而是直接中断并执行下一个消息循环。当asyncio.sleep()返回时，线程就可以从yield from拿到返回值（此处是None），然后接着执行下一行语句。

把asyncio.sleep(1)看成是一个耗时1秒的IO操作，在此期间，主线程并未等待，而是去执行EventLoop中其他可以执行的coroutine了，因此可以实现并发执行。

2. 我们用Task封装两个coroutine试试：

```
import threading
import asyncio

@asyncio.coroutine
def hello():
    print('Hello world! (%s)' % threading.currentThread())
    yield from asyncio.sleep(1)
    print('Hello again! (%s)' % threading.currentThread())

loop = asyncio.get_event_loop()
tasks = [hello(), hello()]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()
观察执行过程：

Hello world! (<_MainThread(MainThread, started 140735195337472)>)
Hello world! (<_MainThread(MainThread, started 140735195337472)>)
(暂停约1秒)
Hello again! (<_MainThread(MainThread, started 140735195337472)>)
Hello again! (<_MainThread(MainThread, started 140735195337472)>)
由打印的当前线程名称可以看出，两个coroutine是由同一个线程并发执行的。
```

>如果把asyncio.sleep()换成真正的IO操作，则多个coroutine就可以由一个线程并发执行。

3. 我们用asyncio的异步网络连接来获取sina、sohu和163的网站首页：

```
import asyncio

@asyncio.coroutine
def wget(host):
    print('wget %s...' % host)
    connect = asyncio.open_connection(host, 80)
    reader, writer = yield from connect
    header = 'GET / HTTP/1.0\r\nHost: %s\r\n\r\n' % host
    writer.write(header.encode('utf-8'))
    yield from writer.drain()
    while True:
        line = yield from reader.readline()
        if line == b'\r\n':
            break
        print('%s header > %s' % (host, line.decode('utf-8').rstrip()))
    # Ignore the body, close the socket
    writer.close()

loop = asyncio.get_event_loop()
tasks = [wget(host) for host in ['www.sina.com.cn', 'www.sohu.com', 'www.163.com']]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()
执行结果如下：

wget www.sohu.com...
wget www.sina.com.cn...
wget www.163.com...
(等待一段时间)
(打印出sohu的header)
www.sohu.com header > HTTP/1.1 200 OK
www.sohu.com header > Content-Type: text/html
...
(打印出sina的header)
www.sina.com.cn header > HTTP/1.1 200 OK
www.sina.com.cn header > Date: Wed, 20 May 2015 04:56:33 GMT
...
(打印出163的header)
www.163.com header > HTTP/1.0 302 Moved Temporarily
www.163.com header > Server: Cdn Cache Server V2.0
...
可见3个连接由一个线程通过coroutine并发完成。

```

### 小结

1. asyncio提供了完善的异步IO支持；

2. 异步操作需要在coroutine中通过yield from完成；

3. 多个coroutine可以封装成一组Task然后并发执行。


### 代码

```
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import threading
import asyncio

@asyncio.coroutine
def hello():
    print('Hello world! (%s)' % threading.currentThread())
    yield from asyncio.sleep(1)
    print('Hello again! (%s)' % threading.currentThread())

loop = asyncio.get_event_loop()
tasks = [hello(), hello()]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()

```

```
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import asyncio

@asyncio.coroutine
def wget(host):
    print('wget %s...' % host)
    connect = asyncio.open_connection(host, 80)
    reader, writer = yield from connect
    header = 'GET / HTTP/1.0\r\nHost: %s\r\n\r\n' % host
    writer.write(header.encode('utf-8'))
    yield from writer.drain()
    while True:
        line = yield from reader.readline()
        if line == b'\r\n':
            break
        print('%s header > %s' % (host, line.decode('utf-8').rstrip()))
    # Ignore the body, close the socket
    writer.close()

loop = asyncio.get_event_loop()
tasks = [wget(host) for host in ['www.sina.com.cn', 'www.sohu.com', 'www.163.com']]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()

```


## async/await

### 定义

1. 用asyncio提供的@asyncio.coroutine可以把一个generator标记为coroutine类型，然后在coroutine内部用yield from调用另一个coroutine实现异步操作。

2. 为了简化并更好地标识异步IO，从Python 3.5开始引入了新的语法async和await，可以让coroutine的代码更简洁易读。

3. 注意，async和await是针对coroutine的新语法，要使用新的语法，只需要做两步简单的替换：

	```
	把@asyncio.coroutine替换为async；
	把yield from替换为await。
	让我们对比一下上一节的代码：
	
	@asyncio.coroutine
	def hello():
	    print("Hello world!")
	    r = yield from asyncio.sleep(1)
	    print("Hello again!")
	用新语法重新编写如下：
	
	async def hello():
	    print("Hello world!")
	    r = await asyncio.sleep(1)
	    print("Hello again!")
	剩下的代码保持不变。
	```

### 小结

Python从3.5版本开始为asyncio提供了async和await的新语法；

注意新语法只能用在Python 3.5以及后续版本，如果使用3.4版本，则仍需使用上一节的方案。


### 代码

```

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import threading
import asyncio

async def hello():
    print('Hello world! (%s)' % threading.currentThread())
    await asyncio.sleep(1)
    print('Hello again! (%s)' % threading.currentThread())

loop = asyncio.get_event_loop()
tasks = [hello(), hello()]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()

```

```
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import threading
import asyncio

async def hello():
    print('Hello world! (%s)' % threading.currentThread())
    await asyncio.sleep(1)
    print('Hello again! (%s)' % threading.currentThread())

loop = asyncio.get_event_loop()
tasks = [hello(), hello()]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()

```


## aiohttp

### 定义

1. asyncio可以实现单线程并发IO操作。如果仅用在客户端，发挥的威力不大。如果把asyncio用在服务器端，例如Web服务器，由于HTTP连接就是IO操作，因此可以用单线程+coroutine实现多用户的高并发支持。

2. asyncio实现了TCP、UDP、SSL等协议，aiohttp则是基于asyncio实现的HTTP框架。

### 操作

1. 安装aiohttp：

		pip install aiohttp

2. 然后编写一个HTTP服务器，分别处理以下URL：
	
		/ - 首页返回b'<h1>Index</h1>'；

		/hello/{name} - 根据URL参数返回文本hello, %s!。
	
	```
	代码如下：
	
	import asyncio
	
	from aiohttp import web
	
	async def index(request):
	    await asyncio.sleep(0.5)
	    return web.Response(body=b'<h1>Index</h1>')
	
	async def hello(request):
	    await asyncio.sleep(0.5)
	    text = '<h1>hello, %s!</h1>' % request.match_info['name']
	    return web.Response(body=text.encode('utf-8'))
	
	async def init(loop):
	    app = web.Application(loop=loop)
	    app.router.add_route('GET', '/', index)
	    app.router.add_route('GET', '/hello/{name}', hello)
	    srv = await loop.create_server(app.make_handler(), '127.0.0.1', 8000)
	    print('Server started at http://127.0.0.1:8000...')
	    return srv
	
	loop = asyncio.get_event_loop()
	loop.run_until_complete(init(loop))
	loop.run_forever()
	
	```
	>注意aiohttp的初始化函数init()也是一个coroutine，loop.create_server()则利用asyncio创建TCP服务。
	
### 代码
	
```
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

__author__ = 'Michael Liao'

'''
async web application.
'''

import asyncio

from aiohttp import web

async def index(request):
    await asyncio.sleep(0.5)
    return web.Response(body=b'<h1>Index</h1>')

async def hello(request):
    await asyncio.sleep(0.5)
    text = '<h1>hello, %s!</h1>' % request.match_info['name']
    return web.Response(body=text.encode('utf-8'))

async def init(loop):
    app = web.Application(loop=loop)
    app.router.add_route('GET', '/', index)
    app.router.add_route('GET', '/hello/{name}', hello)
    srv = await loop.create_server(app.make_handler(), '127.0.0.1', 8000)
    print('Server started at http://127.0.0.1:8000...')
    return srv

loop = asyncio.get_event_loop()
loop.run_until_complete(init(loop))
loop.run_forever()

```