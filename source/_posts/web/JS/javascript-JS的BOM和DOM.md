---
title: javascript-JS的BOM和DOM
categories: web
tags:
  - JS
top: 7
abbrlink: 3393960799
date: 2019-05-11 18:18:19
password:
---


# JS中的BOM

Browser Object Model ,浏览器对象模型. 为了便于对浏览器的操作，JavaScript封装了浏览器中各个对象，使得开发者可以方便的操作浏览器中的各个对象。

<!--more-->

![img](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/javascript/img/tu_1.bmp)

## BOM里面的五个对象

### window: 窗体对象

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



### navigator:浏览器导航对象 

| 属性       | 作用                       |
| ---------- | :------------------------- |
| appName    | 返回浏览器的名称           |
| appVersion | 返回浏览器的平台和版本信息 |

### screen:屏幕对象 

| 方法   | 作用                       |
| ------ | -------------------------- |
| width  | 返回显示器屏幕的分辨率宽度 |
| height | 返回显示屏幕的分辨率高度   |

### history:历史对象 

| 方法      | 作用                              |
| --------- | --------------------------------- |
| back()    | 加载 history 列表中的前一个 URL   |
| forword() | 加载 history 列表中的下一个 URL   |
| go()      | 加载 history 列表中的某个具体页面 |

### location:当前路径信息 

| 属性     | 作用                                |
| :------- | ----------------------------------- |
| host     | 设置或返回主机名和当前 URL 的端口号 |
| **href** | 设置或返回完整的 URL                |
| port     | 设置或返回当前 URL 的端口号         |

location.href;  获得路径

location.href = "http://www.baidu.com";  设置路径,跳转到百度页面



# JS的DOM 



* DOM：**D**ocument **O**bject **M**odel，文档对象模型。是js提供的，用来访问网页里所有内容的(标签,属性,标签的内容)

## 什么是dom树

* 当网页被加载时，浏览器会创建页面的DOM对象。DOM对象模型是一棵树形结构：网页里所有的标签、属性、文本都会转换成节点对象，按照层级结构组织成一棵树形结构。
  * 整个网页封装成的对象叫`document`
  * 标签封装成的对象叫`Element`
  * 属性封装成的对象叫`Attribute`
  * 文本封装成的对象叫`Text`



一切皆节点, 一切皆对象



##  操作标签



### 获取标签

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



###  操作标签

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

 

##  操作标签体


* 获取标签体内容：`标签对象.innerHTML`
* 设置标签体内容：`标签对象.innerHTML = "新的HTML代码";`
  * `innerHTML`是覆盖式设置，原本的标签体内容会被覆盖掉；
  * 支持标签的 可以插入标签, 设置的html代码会生效

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


##  操作属性


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