---
title: javascript入门级学习
categories: 前端知识集
tags:
  - javascript
top: 11
abbrlink: 3488377525
date: 2019-05-11 18:18:19
password:
---

# JS基础


* JS，全称JavaScript，是一种**直译式**脚本语言，是一种动态类型、**弱类型**、基于对象的脚本语言，内置支持类型。 

<!--more-->

* JS语言和Java语言对比：

| 对比           | Java                   | JS                       |
| -------------- | ---------------------- | ------------------------ |
| 运行环境       | JVM虚拟机              | JS引擎，是浏览器的一部分 |
| 是否跨平台运行 | 跨平台                 | 跨平台                   |
| 语言类型       | 强类型语言             | 弱类型，动态类型语言     |
| 是否需要编译   | 需要编译，是编译型语言 | 不需要编译，是解释型语言 |
| 是否区分大小写 | 区分大小写             | 区分大小写               |

## JS的作用

具体来说，有两部分作用：

* JS代码可以操作浏览器(BOM)：进行网址跳转、历史记录切换、浏览器弹窗等等

* JS代码可以操作网页(DOM)：操作HTML的标签、标签的属性、样式、文本等等

  注意：JS的是在浏览器内存中运行时操作，并不会修改网页源码，所以刷新页面后网页会还原

## JS的组成 

* ECMAScript(核心)：是JS的基本语法规范
* BOM：Browser Object Model，浏览器对象模型，提供了与浏览器进行交互的方法
* DOM：Document Object Model，文档对象模型，提供了操作网页的方法

# JS使用

## JS引入

### 语法

* 在html里增加`<script>`标签，把js代码写在标签体里

```html
<script>
	//在这里写js代码
</script>
```

### 示例

* 创建html页面，编写js代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>js引入方式-内部js</title>
    <script>
        //操作浏览器弹窗
        alert("hello, world");
    </script>
</head>
<body>

</body>
</html>
```

* 打开页面，浏览器会弹窗

![1571279916433](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571279916433.png)

## 外部JS

### 语法

* 把js代码写在单独的js文件中，js文件后缀名是`.js`
* 在HTML里使用`<script>`标签引入外部js文件

```html
<script src="js文件的路径"></script>
```

### 示例 

* 创建一个`my.js`文件，编写js代码

  * 第1步：创建js文件

  ![1571279674760](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571279674760.png)

  * 第2步：设置js文件名称

  ![1571279704696](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571279704696.png)

  * 第3步：编写js代码

```js
alert("hello, world! 来自my.js");
```

* 创建一个html，引入`my.js`文件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>js引入方式-外部js</title>
    <!--引入外部的my.js文件-->
    <script src="../js/my.js"></script>
</head>
<body>

</body>
</html>
```

* 打开页面，浏览器会弹窗

![1571279953863](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571279953863.png)


### 注意事项

* 一个`script`标签，不能既引入外部js文件，又在标签体内写js代码。

  * 错误演示

  ```html
  <script src="../js/my.js">
  	alert("hello");
  </script>
  ```

  * 正确演示

  ```html
  <script src="../js/my.js"></script>
  <script>
  	alert("hello");
  </script>
  ```




## 实操-JS小功能和JS调试


### 小功能

+ alert(): 弹出警示框
+ console.log(): 向控制台打印日志 

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_3.png)



+ document.write(); 文档打印. 向页面输出内容. 

### 调试

1. 按`F12`打开开发者工具
2. 找到`Source`窗口，在左边找到页面，如下图
   * 打断点之后，当代码执行到断点时，会暂时执行
   * 在窗口右侧可以查看表达式的值、单步调试、放行等等

![1571577895543](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571577895543.png)



3. 如果代码执行中出现异常信息，会在控制台`Console`窗口显示出来

![1571578078067](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571578078067.png)

4. 点击可以定位到异常位置

![1571578109301](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571578109301.png)


# JS基本语法

## 更改idea中的js语言的版本

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1.png)

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/2.png)

## 变量

+ JavaScript 是一种**弱类型语言**，javascript的变量类型由它的值来决定。 定义变量需要用关键字 'var'或者'let'

```
int i = 10;   		 var i = 10;        或者 i = 10;
String a = "哈哈";   let str = "哈哈";  或者 str = "哈哈";  或者 str = "哈哈"
...


注意:
	1.var或者可以省略不写,建议保留
	2.最后一个分号可以省略,建议保留
	3.同时定义多个变量可以用","隔开，公用一个‘var’关键字. var c = 45,d='qwe',f='68';
```

## 数据类型

1.五种原始数据类型

| 数据类型    | 描述       | 示例                  |
| ----------- | ---------- | --------------------- |
| `number`    | 数值类型   | `1`, `2`, `3`, `3.14` |
| `boolean`   | 布尔类型   | `true`, `false`       |
| `string`    | 字符串类型 | `"hello"`, 'hello'    |
| `object`    | 对象类型   | `new Date()`,  `null` |
| `undefined` | 未定义类型 | var a;                |

2.typeof操作符

+ 作用： 用来判断变量是什么类型

+ 写法：typeof(变量名) 或 typeof 变量名

+ null与undefined的区别：

  ​	null: 对象类型，已经知道了数据类型，但对象为空。
  ​	undefined：未定义的类型，并不知道是什么数据类型。

3.小练习

+ 定义不同的变量,输出类型,

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_13.png)

+ 代码

```js
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<script type="text/javascript">
    var i = 5;   //整数
    var f = 3.14;  //浮点
    var b = true;  //布尔
    var c = 'a';  //字符串
    var str = "abc";   //字符串
    var d = new Date();  //日期
    var u;   //未定义类型
    var n = null; //空
    document.write("整数：" + typeof(i) + "<br/>");
    document.write("浮点 ：" + typeof(f) + "<br/>");
    document.write("布尔：" + typeof(b) + "<br/>");
    document.write("字符：" + typeof(c) + "<br/>");
    document.write("字符串：" + typeof(str) + "<br/>");
    document.write("日期：" + typeof(d) + "<br/>");
    document.write("未定义的类型：" + typeof(u) + "<br/>");
    document.write("null：" + typeof(n) + "<br/>");
</script>
</body>
</html>

```

字符串转换成数字类型 

+ 全局函数(方法)，就是可以在JS中任何的地方直接使用的函数，不用导入对象。不属于任何一个对象

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_14.png)



## 运算符

+ 关系运算符:> >= < <=

- number类型和字符串做-,*,/的时候,字符串自动的进行类型转换,前提字符串里面的数值要满足**number**类型

```
var i = 3;
var j = "6";
alert(j-i);//结果是3, "6" ==> 6  
alert(j*i);//结果是18, 
alert(j/i);//结果是2, 
```

- 除法,保留小数  

```
var i = 2;
var j = 5; 
alert(j/i);
```

- `==` 比较数值,	`=== ` 比较数值和类型

```
var i = 2;
var j = "2"; 
alert(i==j); // ==比较的仅仅是数值, true
alert(i===j); // ===比较的是数值和类型.false
```

## 语句

+ for循环

```javascript
<script>
    //将数据装到表格中
    document.write("<table border='1' cellspacing='0' width='900px'>")
for(let j=1;j<=9;j++){
    //一行
    document.write("<tr>")
    for(let i=1;i<=j;i++){
        //一个单元格
        document.write("<td>")

        //每一个乘法表达式就是td中的内容
        document.write(j+"x"+i+"="+(j*i))

        document.write("</td>")
    }
    document.write("</tr>")
}

document.write("</table>")
</script>
```

+ if... else

```javascript
var a = 6;
if(a==1)
{
    alert('语文');
}
else if(a==2)
{
    alert('数学');
}
else
{
    alert('不补习');
}
```

+ switch

```javascript
<script>
	var str = "java"; 

	switch (str){
		case "java":
			alert("java");
			break;
		case "C++":
			alert("C++");
			break;

		case "Android":
			alert("Android");
			break;	
       }
</script>
```
 
## 函数 
 

* 函数： 是被设计为执行特定任务的代码块 ，在被调用时会执行 
* 函数类似于Java里的方法，用于封装一些可重复使用的代码块

### 普通(有名)函数

#### 语法

* 定义普通函数

```js
function 函数名(形参列表){
    函数体
    [return 返回值;]
}
```

* 调用普通函数

```js
var result = 函数名(实参列表);
```

#### 示例

* 计算两个数字之和

```html
<script>
    //js的函数的作用:为了封装代码，在要使用这些代码的地方直接调用函数
    //js的函数的声明方式:1. 普通函数(命名函数)  2.匿名函数
    //普通函数: function 函数名(参数名,参数名...){函数体}，函数没有返回值类型，没有参数类型
    function total(a,b,c) {
        console.log("arguments数组中的数据:"+arguments.length)
        console.log(a+","+b+","+c)
        return a+b+c
    }

    //调用函数
    //var num = total(1,2,3);
    //console.log(num)

    //js的函数还有俩特点:1. 函数声明时候的参数个数和函数调用时候传入的参数个数，可以不一致;因为函数内部有一个arguments数组，用于存放传入的参数
    //2. js的函数是没有重载的，同名函数后面的会覆盖前面的

    function total(a,b) {
        return a+b
    }

    var num = total(1,2,3);
    console.log(num)
</script>
```



### 匿名函数

匿名函数，也叫回调函数，类似于Java里的函数式接口里的方法

```js
function(形参列表){
    函数体
    [return 返回值;]
}
```


# JS事件 


* HTML 事件是发生在 HTML 元素上的“事情”， 是浏览器或用户做的某些事情
* **事件通常与函数配合使用，这样就可以通过发生的事件来驱动函数执行。** 

## 常见事件

| 属性        | 此事件发生在何时...                  |
| ----------- | ------------------------------------ |
| onclick     | 当用户点击某个对象时调用的事件句柄。 |
| ondblclick  | 当用户双击某个对象时调用的事件句柄。 |
| onchange    | 域的内容被改变。                     |
| onblur      | 元素失去焦点。                       |
| onfocus     | 元素获得焦点。                       |
| onload      | 一张页面或一幅图像完成加载。         |
| onsubmit    | 确认按钮被点击；表单被提交。         |
| onkeydown   | 某个键盘按键被按下。                 |
| onkeypress  | 某个键盘按键被按住。                 |
| onkeyup     | 某个键盘按键被松开。                 |
| onmousedown | 鼠标按钮被按下。                     |
| onmouseup   | 鼠标按键被松开。                     |
| onmouseout  | 鼠标从某元素移开。                   |
| omouseover  | 鼠标移到某元素之上。                 |
| onmousemove | 鼠标被移动。                         |

## 事件绑定

### 普通函数方式

说白了设置标签的属性

```html
<标签 属性="js代码，调用函数"></标签>
```

### 匿名函数方式

```html
<script>
    标签对象.事件属性 = function(){
        //执行一段代码
    }
</script>
```

## 事件使用

### 重要的事件

+ 点击事件

  需求: 没点击一次按钮 弹出hello...

```js
<input type="button" value="按钮" onclick="fn1()">

    <input type="button" value="另一个按钮" id="btn">
        <script>
        //当点击的时候要调用的函数
        function fn1() {
        alert("我被点击了...")
    }

//给另外一个按钮，绑定点击事件:
//1.先根据id获取标签
let btn = document.getElementById("btn");
//2. 设置btn的onclick属性(绑定事件)
//绑定命名函数
//btn.onclick = fn1

//绑定匿名函数
btn.onclick = function () {
    console.log("点击了另外一个按钮")
}
</script>
```

+ 获得焦点(onfocus)和失去焦点(onblur)

  需求:给输入框设置获得和失去焦点

```js
var ipt = document.getElementById("ipt");

//绑定获取焦点事件
ipt.onfocus = function () {
    console.log("获取焦点了...")
}

//绑定失去焦点事件
ipt.onblur = function () {
    console.log("失去焦点了...")
}
```

+ 内容改变(onchange)

  需求: 给select设置内容改变事件

```javascript
<body>
    <!--内容改变(onchange)-->
    <select onchange="changeCity(this)">
        <option value="bj">北京</option>
        <option value="sh">上海</option>
        <option value="sz">深圳</option>
    </select>

</body>
<script>
    function changeCity(obj) {
        console.log("城市改变了"+obj.value);
    }
</script>
```

+ 等xx加载完成(onload)  可以把script放在body的后面/下面, 就可以不用了

```javascript
window.onload = function () {
    //浏览器窗体加载完毕之后要执行的代码写到这里面
}
```

### 掌握的事件

+ 键盘相关的, 键盘按下(onkeydown)  键盘抬起(onkeyup)

```java
//给输入框绑定键盘按键按下和抬起事件
ipt.onkeydown = function () {
    //当按键按下的时候，数据并没有到达输入框
    //输出输入框里面的内容
    //console.log(ipt.value)
}

ipt.onkeyup = function () {
    //输出输入框的内容:当键盘按键抬起的时候，数据已经到达了输入框
    console.log(ipt.value)
}
```

+ 鼠标相关的, 鼠标在xx之上(onmouseover ), 鼠标按下(onmousedown),鼠标离开(onmouseout)

````java
//给输入框绑定鼠标移入事件
ipt.onmouseover = function () {
    console.log("鼠标移入了...")
}
//给输入框绑定鼠标移出事件
ipt.onmouseout = function () {
    console.log("鼠标移出了...")
}
````


#  正则表达式 

正则表达式是对字符串操作的一种逻辑公式，就是用事先定义好的一些特定字符、及这些特定字符的组合，组成一个“规则字符串”，这个“规则字符串”用来表达对字符串的一种过滤逻辑。

​	用我们自己的话来说: **正则表达式用来校验字符串是否满足一定的规则的公式**

## 正则表达式的语法

### 创建对象

* 对象形式：`var reg = new RegExp("正则表达式")`当正则表达式中有"/"那么就使用这种
* 直接量形式：`var reg = /正则表达式/`一般使用这种声明方式

### 常用方法

| 方法           | 描述             | 参数           | 返回值                    |
| -------------- | ---------------- | -------------- | ------------------------- |
| `test(string)` | 校验字符串的格式 | 要校验的字符串 | boolean，校验通过返回true |

### 常见正则表达式规则

| **符号**    | **作用**                           |
| ----------- | ---------------------------------- |
| \d          | 数字                               |
| \D          | 非数字                             |
| \w          | 英文字符：a-zA-Z0-9_               |
| \W          | 非英文字符                         |
| .           | 通配符，匹配任意字符               |
| {n}         | 匹配n次                            |
| {n,}        | 大于或等于n次                      |
| {n,m}       | 在n次和m次之间                     |
| +           | 1~n次                              |
| *           | 0~n次                              |
| ?           | 0~1次                              |
| ^           | 匹配开头                           |
| `$`           | 匹配结尾                           |
| [a-zA-Z]    | 英文字母                           |
| [a-zA-Z0-9] | 英文字母和数字                     |
| [*xyz*]     | 字符集合, 匹配所包含的任意一个字符 |



### 使用示例

需求:

1. 出现任意数字3次
2. 只能是英文字母的, 出现6~10次之间
3. 只能由英文字母和数字组成，长度为4～16个字符，并且以英文字母开头
4. 手机号码: 以1开头, 第二位是3,4,5,6,7,8,9的11位数字

步骤:

1. 创建正则表达式
2. 调用test()方法

```js
<script>
    //1.出现任意数字3次
    //a. 创建正则表达式
    var reg1  = /^\d{3}$/; //出现任意数字3次
    //b. 校验字符串
    var str1 = "3451";
    var flag1 = reg1.test(str1);
    //alert("flag1="+flag1);

    //2.只能是英文字母的, 出现6~10次之间
    var reg2  =/^[a-zA-Z]{6,10}$/;
    var str2 = "abcdef11g";
    //alert(reg2.test(str2));

    //3 用户名：只能由英文字母和数字组成，长度为4～16个字符，并且以英文字母开头
    var reg3  =/^[a-zA-Z][a-zA-Z0-9]{3,15}$/;
    var str3 = "zs";
   // alert(reg3.test(str3));


    //4. 手机号码: 以1开头, 第二位是3,4,5,6,7,8,9的11位数字
    //var reg4  =/^1[3456789]\d{9}$/i; //忽略大小写的
    var reg4  =/^1[3456789]\d{9}$/; //不忽略大小写的
    var str4 = "188245899";
    alert(reg4.test(str4));


</script>
```


# 内置对象之Array数组 


## 创建数组对象

 

* `var arr = new Array(size)`
* `var arr = new Array(element1, element2, element3, ...)`
* `var arr = [element1, element2, element3, ...];`一般采用这种方式创建

## 数组的特点

* 数组中的每个元素可以是任意类型
* 数组的长度是可变的，更加类似于Java里的集合`List`


```js
  //1.数组定义方式
    //1.1 方式一  new Array(size);
    var array01 = new Array(4);
    array01[0] = 1;
    array01[1] = 2;
    array01[2] = 3;
    array01[3] = 99;


    //1.2 方式二  new Array(ele,ele...);
    var array02 = new Array(1, 2, 3, 99);

    //1.3 方式三  [ele,ele]
    var array03 = [1, 2, 3, 99];


    //2.数组特点  ①js里面数组可以存放不同类型的数据 ②js里面的数组可变, 没有越界的概念
    var array04 = [1, 2, 3, "哈哈"];

    //console.log(array04[0]); //1
    //console.log(array04[3]); //"哈哈"
    //console.log(array04[5]); //在Java里面是数组越界 js里面是undefined

    console.log(array04.length);  //4
    array04[6] = "你好";  //[1,2,3,"哈哈",undefined,undefined,"你好"]
    console.log(array04.length);  //7
```

## 数组常见的方法

### API介绍

| 方法      | 描述                                                         |
| --------- | ------------------------------------------------------------ |
| concat()  | 连接两个或更多的数组，并返回结果。                           |
| join()    | 把数组的所有元素放入一个字符串。元素通过指定的分隔符进行分隔。 |
| reverse() | 颠倒数组中元素的顺序。                                       |

### 示例

```js
//3.常用的方法
//3.1 concat() 连接两个或更多的数组，并返回结果。【重点】
var array05 = [1, 2, 3, 4];
var array06 = ["哈哈", "你好", 100, 200];
var array07 = array05.concat(array06);
console.log(array07);

//3.2 join() 把数组的所有元素放入一个字符串。元素通过指定的分隔符进行分隔。
var str =   array05.join("**");  
console.log(str);

//3.3 reverse() 颠倒数组中元素的顺序。
array06 =  array06.reverse();
console.log(array06);
```

## 二维数组

1. 数组里面再放数组 就是二维数组
2. 示例

```js
    //4.二维数组
    //方式一:
    var citys = new Array(3);
    citys[0] = ["深圳", "广州", "东莞", "惠州"];
    citys[1] = ["武汉", "黄冈", "黄石", "鄂州", "荆州"];
    citys[2] = ["济南", "青岛", "烟台", "淄博", "聊城"];

    var citys02 = [
        ["深圳", "广州", "东莞", "惠州"],
        ["武汉", "黄冈", "黄石", "鄂州", "荆州"],
        ["济南", "青岛", "烟台", "淄博", "聊城"]
    ];
    for (var i = 0; i < citys02.length; i++) {
        var cityArray = citys02[i];
        
        console.log(cityArray);

        for(var j = 0;j<=cityArray.length;j++){
            console.log(cityArray[j]);
        }
    }

```


# 内置对象之-Date日期 

## 创建日期对象

  

* 创建当前日期：`var date = new Date()`

* 创建指定日期：`var date = new Date(年, 月, 日)`   

  注意：月从0开始，0表示1月

* 创建指定日期时间：`var date = new Date(年, 月, 日, 时, 分, 秒)`

  注意：月从0开始，0表示1月

 

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>日期</title>
</head>
<body>

<script>
    //创建当前日期
    var date1 = new Date();
    console.log(date1);

    //创建指定日期: 2019-11-11
    var date2 = new Date(2019, 10, 11);
    console.log(date2);

    //创建指定日期时间：2019-11-11 20:10:10
    var date3 = new Date(2019, 10, 11, 20, 10, 10);
    console.log(date3);
</script>
</body>
</html>
```

![1571473450137](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/1571473450137.png)

## 日期常用方法

### API介绍

| 方法                                                         | 描述                                               |
| :----------------------------------------------------------- | :------------------------------------------------- |
| [Date()](https://www.w3school.com.cn/jsref/jsref_Date.asp)   | 返回当日的日期和时间。                             |
| [getDate()](https://www.w3school.com.cn/jsref/jsref_getDate.asp) | 从 Date 对象返回一个月中的某一天 (1 ~ 31)。        |
| [getDay()](https://www.w3school.com.cn/jsref/jsref_getDay.asp) | 从 Date 对象返回一周中的某一天 (0 ~ 6)。           |
| [getMonth()](https://www.w3school.com.cn/jsref/jsref_getMonth.asp) | 从 Date 对象返回月份 (0 ~ 11)。                    |
| [getFullYear()](https://www.w3school.com.cn/jsref/jsref_getFullYear.asp) | 从 Date 对象以四位数字返回年份。                   |
| [getHours()](https://www.w3school.com.cn/jsref/jsref_getHours.asp) | 返回 Date 对象的小时 (0 ~ 23)。                    |
| [getMinutes()](https://www.w3school.com.cn/jsref/jsref_getMinutes.asp) | 返回 Date 对象的分钟 (0 ~ 59)。                    |
| [getSeconds()](https://www.w3school.com.cn/jsref/jsref_getSeconds.asp) | 返回 Date 对象的秒数 (0 ~ 59)。                    |
| [getMilliseconds()](https://www.w3school.com.cn/jsref/jsref_getMilliseconds.asp) | 返回 Date 对象的毫秒(0 ~ 999)。                    |
| [getTime()](https://www.w3school.com.cn/jsref/jsref_getTime.asp) | 返回 1970 年 1 月 1 日至今的毫秒数（时间戳）。     |
| [parse()](https://www.w3school.com.cn/jsref/jsref_parse.asp) | 返回1970年1月1日午夜到指定日期（字符串）的毫秒数。 |
| [setDate()](https://www.w3school.com.cn/jsref/jsref_setDate.asp) | 设置 Date 对象中月的某一天 (1 ~ 31)。              |
| [setMonth()](https://www.w3school.com.cn/jsref/jsref_setMonth.asp) | 设置 Date 对象中月份 (0 ~ 11)。                    |
| [setFullYear()](https://www.w3school.com.cn/jsref/jsref_setFullYear.asp) | 设置 Date 对象中的年份（四位数字）。               |
| [setYear()](https://www.w3school.com.cn/jsref/jsref_setYear.asp) | 请使用 setFullYear() 方法代替。                    |
| [setHours()](https://www.w3school.com.cn/jsref/jsref_setHours.asp) | 设置 Date 对象中的小时 (0 ~ 23)。                  |
| [setMinutes()](https://www.w3school.com.cn/jsref/jsref_setMinutes.asp) | 设置 Date 对象中的分钟 (0 ~ 59)。                  |
| [setSeconds()](https://www.w3school.com.cn/jsref/jsref_setSeconds.asp) | 设置 Date 对象中的秒钟 (0 ~ 59)。                  |
| [setMilliseconds()](https://www.w3school.com.cn/jsref/jsref_setMilliseconds.asp) | 设置 Date 对象中的毫秒 (0 ~ 999)。                 |
| [setTime()](https://www.w3school.com.cn/jsref/jsref_setTime.asp) | 以毫秒设置 Date 对象。                             |
| [toLocaleString()](https://www.w3school.com.cn/jsref/jsref_toLocaleString.asp) | 根据本地时间格式，把 Date 对象转换为字符串。       |

  

```js
<script>
    //1.创建日期对象
    var myDate =  new Date();

    //2.调用方法
    console.log("年:" + myDate.getFullYear());
    console.log("月:" + (myDate.getMonth()+1));
    console.log("日:" + myDate.getDate());
    console.log("时:" + myDate.getHours());
    console.log("分:" + myDate.getMinutes());
    console.log("秒:" + myDate.getSeconds());
    console.log("毫秒:" + myDate.getMilliseconds());

    console.log(myDate.toLocaleString()); //打印本地时间    2019-12-06 12:02:xx
    //console.log(myDate);

	//获取某个时间的时间戳
    var time = myDate.getTime();
    console.log(time)
    
    //需求:计算到11放假还有多少天
    var date5 = new Date(2020,9,1);
    var date6 = new Date(2020,6,9);

    var totalTime = date5.getTime() - date6.getTime();
    var days = totalTime/(1000*60*60*24);
    console.log(days)
</script>
```

# 第二章-JS的BOM

## 知识点-JS的BOM

### 1.目标

- [ ] 掌握BOM中常用的API

### 2.路径

1. BOM介绍
2. BOM里面的五个对象

### 3.讲解

#### 3.1概述

​	Browser Object Model ,浏览器对象模型. 为了便于对浏览器的操作，JavaScript封装了浏览器中各个对象，使得开发者可以方便的操作浏览器中的各个对象。







![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_1.bmp)

#### 3.2.BOM里面的五个对象

##### 3.2.1 window: 窗体对象

| **方法**                         | **作用**                                         |
| -------------------------------- | ------------------------------------------------ |
| **alert()**                      | **显示带有一段消息和一个确认按钮的警告框**       |
| **confirm()**                    | 显示带有一段消息以及确认按钮和取消按钮的对话框   |
| **prompt()**                     | 弹出输入框                                       |
| **setInterval('函数名()',time)** | 按照指定的周期（以毫秒计）来调用函数或计算表达式 |
| **setTimeout('函数名()',time)**  | 在指定的毫秒数后调用函数或计算表达式             |
| clearInterval()                  | 取消由 setInterval() 设置的 Interval()。         |
| clearTimeout()                   | 取消由 setTimeout() 方法设置的 timeout。         |

```js
//1. 警告框
//window.alert("hello")

//2. 确认框
/*let flag = confirm("你确定要删除吗?");
        console.log(flag)*/

//3. 输入框
let age = prompt("请输入你的年龄");

if (parseInt(age) >= 18) {
    alert("可以访问")
}else {
    alert("请大一点了再访问")
}

//定时器的话就是隔一段事件执行一个任务
//1. setTimeout(),只执行一次的定时器,其实也就相当于一个延时器
//第一个参数是要执行的匿名函数，第二个参数是执行时间
/*setTimeout(function () {
            document.write("hello world")
        },3000)*/

//2. setInterval(),循环执行的定时器
//第一个参数是要执行的匿名函数，第二个参数是间隔时间，该方法的返回值是这个定时器id
let i = 0
var id = setInterval(function () {
    i ++
    document.write("你好世界<br/>")

    //我们还有一个方法，clearInterval(定时器的id)清除定时器
    if (i == 5) {
        clearInterval(id)
    }
},2000);
```



##### 3.2.2,navigator:浏览器导航对象【了解】

| 属性       | 作用                       |
| ---------- | :------------------------- |
| appName    | 返回浏览器的名称           |
| appVersion | 返回浏览器的平台和版本信息 |

##### 3.2.3,screen:屏幕对象【了解】

| 方法   | 作用                       |
| ------ | -------------------------- |
| width  | 返回显示器屏幕的分辨率宽度 |
| height | 返回显示屏幕的分辨率高度   |

##### 3.2.4,history:历史对象【了解】

| 方法      | 作用                              |
| --------- | --------------------------------- |
| back()    | 加载 history 列表中的前一个 URL   |
| forword() | 加载 history 列表中的下一个 URL   |
| go()      | 加载 history 列表中的某个具体页面 |

##### 3.2.5 location:当前路径信息(最重要)

| 属性     | 作用                                |
| :------- | ----------------------------------- |
| host     | 设置或返回主机名和当前 URL 的端口号 |
| **href** | 设置或返回完整的 URL                |
| port     | 设置或返回当前 URL 的端口号         |

location.href;  获得路径

location.href = "http://www.baidu.com";  设置路径,跳转到百度页面

### 4.小结

1. BOM: 浏览器对象模型, JS里面封装了五个对象 用来操作浏览器的
2. window对象
   + alert()  弹出警告框
   + confirm()  弹出确认框
   + prompt() 弹出输入框
   + setInterval('函数()',时间)  周期执行
   + setTimeout(''函数()',时间)  延迟执行
3. location
   + location.href;  获得路径
   + location.href=""; 设置路径





# 第三章-JS的DOM(最重要)

## 知识点-DOM介绍

### 目标

* 了解dom相关的概念

### 分析

1. 什么是dom
2. 什么是dom树

### 讲解

#### 1. 什么是dom

* DOM：**D**ocument **O**bject **M**odel，文档对象模型。是js提供的，用来访问网页里所有内容的(标签,属性,标签的内容)

#### 2. 什么是dom树

* 当网页被加载时，浏览器会创建页面的DOM对象。DOM对象模型是一棵树形结构：网页里所有的标签、属性、文本都会转换成节点对象，按照层级结构组织成一棵树形结构。
  * 整个网页封装成的对象叫`document`
  * 标签封装成的对象叫`Element`
  * 属性封装成的对象叫`Attribute`
  * 文本封装成的对象叫`Text`

![](img\dom树.png)

一切皆节点, 一切皆对象





### 小结

1. dom: 文档对象模型, 用来操作网页
2. dom树: html通过浏览器加载到内存里面形成了一颗dom树, 我们就可以操作dom树节点(获得节点, 添加节点, 删除节点)

## 知识点-操作标签

### 1. 目标

*  能够使用dom操作标签

### 2. 分析

1. 获取标签
2. 操作标签

### 3.讲解

#### 3.1. 获取标签

| 方法                                         | 描述                     | 返回值          |
| -------------------------------------------- | ------------------------ | --------------- |
| `document.getElementById(id)`                | 根据id获取标签           | `Element`对象   |
| `document.getElementsByName(name)`           | 根据标签name获取一批标签 | `Element`类数组 |
| `document.getElementsByTagName(tagName)`     | 根据标签名称获取一批标签 | `Element`类数组 |
| `document.getElementsByClassName(className)` | 根据类名获取一批标签     | `Element`类数组 |

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>获取标签的方法介绍</title>
    </head>
    <body>
        <div id="d1" name="n1">hello div1</div>
        <div class="c1">hello div2</div>
        <span class="c1">hello span1</span>
        <span name="n1">hello span2</span>
        <script>
            //根据id获取标签
            //console.log(document.getElementById("d1"))

            //根据name获取标签的数组
            //console.log(document.getElementsByName("n1"))

            //根据标签名获取标签
            //console.log(document.getElementsByTagName("div"))

            //根据类名获取标签
            //console.log(document.getElementsByClassName("c1"))

            //扩展俩方法:1. 获取单个标签
            //console.log(document.querySelector("#d1"))

            //2. 获取多个标签
            console.log(document.querySelectorAll("span"))
        </script>
    </body>
</html>
```



#### 3.2. 操作标签

| 方法                                    | 描述     | 返回值        |
| --------------------------------------- | -------- | ------------- |
| `document.createElement(tagName)`       | 创建标签 | `Element`对象 |
| `parentElement.appendChild(sonElement)` | 插入标签 |               |
| `element.remove()`                      | 删除标签 |               |

```html
<body>
    <ul id="city">
        <li>北京</li>
        <li id="sh">上海</li>
        <li>深圳</li>
        <li>广州</li>
    </ul>
    <input type="button" value="添加" onclick="addCity()">
    <input type="button" value="删除" onclick="removeCity()">
    <script>
        //点击添加按钮，往城市列表的最后面添加"长沙"
        function addCity() {
            //1. 创建一个li标签
            var liElement = document.createElement("li");
            //2. 设置li标签体的文本内容为"长沙"
            liElement.innerText = "长沙"
            //3. 往id为city的ul中添加一个子标签
            //3.1 获取id为city的ul
            var city = document.getElementById("city");
            //3.2 往city里面添加子标签
            city.appendChild(liElement)
        }

        //点击删除按钮，删除上海
        function removeCity() {
            //要删除某一个标签: 那个标签.remove()
            document.getElementById("sh").remove()
        }
    </script>
</body>
```



### 4.小结

1. 获得标签
   + document.getElementById("id”)   根据id获得
   + document.getElementsByTagName("标签名")  根据标签名获得
   + document.getElementsByClassName("类名")  根据类名获得
2. 操作节点(标签,文本)
   + `document.createElement(tagName)`  创建标签  `Element`对象  
   + `document.createTextNode("文本")`  创建文本节点
   + `parentElement.appendChild(sonElement)`  插入标签 
   +    `element.remove()`  删除标签    

## 知识点-操作标签体

### 1. 目标

* 掌握操作标签体内容的方法

### 2. 路径

* 获取/设置标签体内容

### 3. 讲解

#### 3.1语法

* 获取标签体内容：`标签对象.innerHTML`
* 设置标签体内容：`标签对象.innerHTML = "新的HTML代码";`
  * `innerHTML`是覆盖式设置，原本的标签体内容会被覆盖掉；
  * 支持标签的 可以插入标签, 设置的html代码会生效

#### 3.2示例

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>操作标签体</title>
</head>
<body>
    <div id="city"><h1>北京</h1></div>
    <script>
        //获取id为city的那个标签的标签体的内容
        var innerHTML = document.getElementById("city").innerHTML;
        console.log(innerHTML)

        //设置id为city的标签体的内容
        document.getElementById("city").innerHTML = "<h1>深圳</h1>"

    </script>
</body>
</html>
```

### 4. 小结

1. 获得标签的内容 (一并获得标签)

```
标签对象.innerHTML;
```

2. 设置标签的内容(①会把前面的内容覆盖 ②支持标签的)

```
标签对象,innerHTML = "html字符串"; 
```



## 知识点-操作属性

### 1. 目标

* 能够操作HTML标签的属性

### 2.路径

1. 使用JS操作标签的属性

### 3. 讲解

* 每个标签`Element`对象提供了操作属性的方法

| 方法名                               | 描述       | 参数             |
| ------------------------------------ | ---------- | ---------------- |
| `getAttribute(attrName)`             | 获取属性值 | 属性名称         |
| `setAttribute(attrName, attrValue)`  | 设置属性值 | 属性名称, 属性值 |
| `removeAttribute(attrName)` 了解即可 | 删除属性   | 属性名称         |

```html
<body>
    <input type="password" id="pwd">
    <input type="button" value="显示密码" onmousedown="showPassword()" onmouseup="hidePassword()">
    <script>
        //目标:按住显示密码按钮的时候，就显示密码框中的密码; 按键松开的时候，就隐藏密码
        //1. 给按钮绑定onmousedown事件
        function showPassword() {
            //让密码框的密码显示: 修改密码框的type属性为text
            document.getElementById("pwd").setAttribute("type","text")
        }

        //2. 给按钮绑定onmouseup事件
        function hidePassword() {
            //就是设置密码框的type为password
            document.getElementById("pwd").setAttribute("type","password")

            //getAttribute(属性名)，根据属性名获取属性值
            var type = document.getElementById("pwd").getAttribute("type");
            console.log(type)
        }
    </script>
</body>
```



### 4.小结

1. `getAttribute(attrName)`  获取属性值 
2.  `setAttribute(attrName, attrValue)`  设置属性值 
3. `removeAttribute(attrName)`  删除属性



# 第四章-JS案例

## 案例-使用JS完成表单的校验

### 1. 案例需求

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_10.png)

- 用户名输入框、手机号码 ,  失去焦点进行校验

- 用户名：只能由英文字母和数字组成，长度为4～16个字符，并且以英文字母开头
- 手机号：以1开头, 第二位是3,4,5,7,8的11位数字     /^1[34578]\d{9}$/

### 2.思路分析

1. 给用户名输入框设置获得焦点事件

```
<input type="text" onfocus="showTips()"/>
```

2. 创建showTips()函数提示

```
function showTips(){
	//1.获得用户名输入框后面的span标签
	//2.调用innerHTML插入提示
}
```

3. 给用户名输入框设置失去焦点事件

```
<input type="text" onblur="checkUsername()"/>
```

4. 创建checkUsername()函数

```
function checkUsername(){
	//1.获得用户输入的用户名
	//2.使用正则表达式进行校验
	//3.判断是否符合规则, 提示
}
```

### 3.代码实现

```js
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>验证注册页面</title>
        <style type="text/css">
			body {
				margin: 0;
				padding: 0;
				font-size: 12px;
				line-height: 20px;
			}
			.main {
				width: 525px;
				margin-left: auto;
				margin-right: auto;
			}
			.hr_1 {
				font-size: 14px;
				font-weight: bold;
				color: #3275c3;
				height: 35px;
				border-bottom-width: 2px;
				border-bottom-style: solid;
				border-bottom-color: #3275c3;
				vertical-align: bottom;
				padding-left: 12px;
			}
			.left {
				text-align: right;
				width: 80px;
				height: 25px;
				padding-right: 5px;
			}
			.center {
				width: 280px;
			}
			.in {
				width: 130px;
				height: 16px;
				border: solid 1px #79abea;
			}

			.red {
				color: #cc0000;
				font-weight: bold;
			}

			div {
				color: #F00;
			}
        </style>
        <script type="text/javascript">
        </script>
    </head>

    <body>
        <form action="#" method="post" id="myform" onsubmit="return checkForm()">
            <table class="main" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td><img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/logo.jpg" alt="logo" /><img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/banner.jpg" alt="banner" /></td>
                </tr>
                <tr>
                    <td class="hr_1">新用户注册</td>
                </tr>
                <tr>
                    <td style="height:10px;"></td>
                </tr>
                <tr>
                    <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td class="left">用户名：</td>
                            <td class="center">
                                <!--给用户名输入框绑定失去焦点事件-->
                                 <input id="username" name="user" type="text" class="in" onblur="checkUsername(this.value)"/>
                                 <span id="usernamespan" style="color: red">

                                 </span>
                            </td>
                        </tr>
                        <tr>
                            <td class="left">密码：</td>
                            <td class="center">
                            <input id="pwd" name="pwd" type="password" class="in" />
                            </td>
                        </tr>
                        <tr>
                            <td class="left">确认密码：</td>
                            <td class="center">
                            <input id="repwd" name="repwd" type="password" class="in"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="left">电子邮箱：</td>
                            <td class="center">
                            <input id="email" name="email" type="text" class="in"/>
                            </td>
                        </tr>
                        <tr>
                           <!-- 以1开头, 第二为是3,4,5,7,8的11位数字-->
                            <td class="left">手机号码：</td>
                            <td class="center">
                                <!--手机号输入框绑定失去焦点事件-->
                                 <input id="mobile" name="mobile" type="text" class="in" onblur="checkPhone(this.value)"/>
                                 <span id="mobilespan" style="color: red"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="left">生日：</td>
                            <td class="center">
                            <input id="birth" name="birth" type="text" class="in"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="left">&nbsp;</td>
                            <td class="center">
                            <input name="" type="image" src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/register.jpg" />
                            </td>
                        </tr>
                    </table></td>
                </tr>
            </table>
        </form>
    <script>
        //声明一个校验用户名的方法
        function checkUsername(value) {
            //使用正则表达式校验用户名
            //只能由英文字母和数字组成，长度为4～16个字符，并且以英文字母开头
            //1. 编写一个正则表达式
            var reg = /^[a-zA-Z][a-zA-Z0-9]{3,15}$/
            //2. 使用正则表达式取校验用户名
            if (reg.test(value)) {
                //校验通过
                //1. 找到用户名输入框后面的那个span
                var element = document.getElementById("usernamespan");
                //2. 设置span的标签体的内容是一个图片标签
                element.innerHTML = "<img src='https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/gou.png' width='35' height='15\'/>"
            }else {
                //校验不通过
                //1. 找到用户名输入框后面的那个span
                var element = document.getElementById("usernamespan");
                //2. 设置span的标签体的内容为"用户名格式不正确"
                element.innerHTML = "用户名格式不正确"
            }
        }


        function checkPhone(value) {
            //1. 声明一个正则表达式：以1开头, 第二位是3,4,5,7,8的11位数字
            var reg = /^[1][34578][0-9]{9}$/
            //2. 使用正则表达式校验手机号
            if (reg.test(value)) {
                //校验通过
                //找到手机号输入框后面的span
                var element = document.getElementById("mobilespan");
                //设置span中的内容为钩的图片
                element.innerHTML = "<img src='https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/gou.png' width='35' height='15\'/>"
            }else {
                //校验不通过
                //找到手机号输入框后面的span
                var element = document.getElementById("mobilespan");
                //设置span中的内容为手机号格式不正确
                element.innerHTML = "手机号格式不正确"
            }
        }
    </script>
    </body>
</html>
```

### 4,小结

1. 获得和失去焦点
2. 函数
3. 操作标签体
4. 获得标签, 获得标签的value

## 案例-使用JS完成图片轮播效果

### 1.需求分析

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_17.png)

- 实现每过3秒中切换一张图片的效果，一共3张图片，当显示到最后1张的时候，再次显示第1张。

### 2.思路分析

1. 创建定时任务

```js
setInterval(function(){
	//改变img标签的src
},3000);
```

### 3.代码实现

```js
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>轮播图</title>
</head>
<body>
    <div style="text-align: center">
        <img id="tu" src="../https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/banner_1.jpg" width="750" height="200"
             onmouseover="pauseMove()" onmouseout="startMove()">
    </div>
    <script>
        var imgs = ["../https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/banner_1.jpg","../https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/banner_2.jpg","../https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/banner_3.jpg"]
        var i = 0
        //每隔三秒钟切换一张轮播图图片
        var id
        //1. 定时器: 每隔三秒钟做一件事情
        function startMove(){
            id = setInterval(function () {
                i ++
                if (i == 3) {
                    i = 0
                }
                //2. 切换img的图片:重新设置img标签的src
                document.getElementById("tu").setAttribute("src",imgs[i])
            },3000);
        }

        //页面加载的时候开启轮播
        startMove()

        //要求: 当鼠标悬停在轮播图上的时候，停止轮播，鼠标移开，恢复轮播
        //给轮播图绑定鼠标移入和移出事件
        function pauseMove() {
            //暂停轮播: 清除定时器
            clearInterval(id)
        }
    </script>
</body>
</html>
```

### 4.小结

1. 定时任务  

```
setInterval(匿名函数, time);
```

2. 操作属性

```
setAttribute("属性名","属性值")
```



## 案例-JS控制二级联动

### 1.需求分析

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_22.png)

- 在注册页面添加籍贯,左边是省份的下拉列表,右边是城市的下拉列表.右边的select根据左边的改变而更新数据

### 2.思路分析

1. 创建这个页面	(两个select)
2. 给省份的select设置onchange事件

3. 当省份改变的时候

```js
//1.获得省份的value
//2.根据省份的数据 获得当前省份的城市数据  eg: ["深圳", "广州", "东莞", "惠州"]
//3.清除城市下拉框中的城市
//4.遍历出每一个城市
//5.把每一个城市创建成option节点  eg: <option>深圳</option>
//6.把option节点添加到右边的城市的select里面
```

### 3.代码实现

```html
<body>
    <select id="provinceSelect">
        <option value="0">请选择省份</option>
        <option value="1">广东省</option>
        <option value="2">湖南省</option>
        <option value="3">湖北省</option>
    </select>
    <select id="citySelect">
        <option>请选择城市</option>
    </select>

    <script>
        //准备数据
        var cities = [
            [],
            ["广州","深圳","惠州","东莞"],
            ["长沙","岳阳","常德","衡阳"],
            ["武汉","黄冈","宜昌","荆州"]
        ]

        //2. 给省份的下拉框绑定onchange事件
        var provinceSelect = document.getElementById("provinceSelect");

        provinceSelect.onchange = function () {
            //2.1 获取当前选择的省份的所有城市
            var value = provinceSelect.value;
            //当前省份的城市数组
            var items = cities[value];

            //2.2 遍历出每一个城市
            //遍历添加之前，先清除城市下拉框中的所有option
            document.getElementById("citySelect").innerHTML = "<option>请选择城市</option>"
            for (var i = 0; i < items.length; i++) {
                //每一个城市
                var cityName = items[i];
                //创建option
                var optionElement = document.createElement("option");
                //将城市名设置到option标签体中
                optionElement.innerHTML = cityName
                //将option标签添加到城市下拉框中
                document.getElementById("citySelect").appendChild(optionElement)
            }
        }
    </script>
</body>
```

### 4.小结

1. 内容改变事件

2. 二维数组
3. innerHTML
   + 会把前面的内容覆盖掉
   + 支持标签的
4. dom
   + 父节点.appendChild(子节点)
   + document.createElement()
   + document.createTextNode()
