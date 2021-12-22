---
title: VueJS
categories: 前端知识集
tags:
  - VueJS
  - 前端框架
top: 11
abbrlink: 2608346066
date: 2019-05-11 18:18:19
password:
---


#  VueJS介绍与快速入门

 Vue.js是一个渐进式JavaScript 框架。Vue.js 的目标是通过尽可能简单的 API 实现响应的数据绑定和组合的视图组件。它不仅易于上手，还便于与第三方库或既有项目整合。

官网:[https://cn.vuejs.org/](https://cn.vuejs.org/)

常见的前端的框架:

​	jQuery、Anglar、Vue、React、Node
​
​<!--more-->

## MVVM模式

​	MVVM是Model-View-View-Model的简写。它本质上就是MVC 的改进版。

​	MVVM 就是将其中的View 的状态和行为抽象化，让我们将视图UI 和业务逻辑分开. MVVM模式和MVC模式一样，主要目的是分离视图（View）和模型（Model）Vue.js 是一个提供了 MVVM 风格的**双向数据绑定**的 Javascript 库，专注于View 层。它的核心是 MVVM 中的 VM，也就是 ViewModel。 ViewModel负责连接 View 和 Model，保证视图和数据的一致性，这种轻量级的架构让前端开发更加高效、便捷.

![1552546278610](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/VUE/img/1552546278610.png)





##  VueJs快速入门



1. 创建工程(war),导入vuejs

 ![1552546458928](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/VUE/img/1552546458928.png)

2. 创建demo01.js(引入vuejs,定义div,创建vue实例)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>vue的入门案例</title>
    <script src="js/vuejs-2.5.16.js"></script>
</head>
<body>
    <!--
        指定一块区域，在这块区域中可以使用vue
        只有这块区域中的标签，才能使用vue和数据模型绑定
    -->
    <div id="app">
        <!--
            将vue的视图中的message绑定到div中,使用插值表达式{{message}}
        -->
        <div>{{username}}</div>
    </div>

    <script>
        var vue = new Vue({
            el:"#app",//指定哪个区域可以使用vue
            data:{
                message:"hello world",
                username:"周杰棍"
            }//数据模型：要展示到视图上的数据
        });
    </script>
</body>
</html>
```

data ：用于定义数据。

### 小结

​	数据绑定最常见的形式就是使用“Mustache”语法 (双大括号) 的文本**插值表达式**，Mustache 标签将会被替代为对应数据对象上属性的值。无论何时，绑定的数据对象上属性发生了改变，插值处的内容都会更新.

#  VueJS 常用系统指令

##  常用的事件 


### @click      

说明: 点击事件(等同于v-on:click)

【需求】：点击按钮事件，改变message的值

+ demo02.html

```html
<!DOCTYPE html>
<html lang="en" xmlns:v-on="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8">
    <title>vue绑定事件</title>
    <script src="js/vuejs-2.5.16.js"></script>
</head>
<body>
    <div id="app">
        <div>{{message}}</div>
        <!--
            点击按钮，改变div中的内容
            使用vue绑定点击事件:
                1. v-on:click="函数()"
                2.@click="函数()"
        -->
        <input type="button" value="改变" @click="fn1()">
    </div>
    <script>
        var vue = new Vue({
           el:"#app",
           data:{
               message:"hello world"
           },
           methods:{
               fn1(){
                    //改变div中的内容,只需要改变message的值就行
                   this.message = "hello vue"
               }
           }
        });
    </script>
</body>
</html>
```

### @keydown  

说明: 键盘按下事件(等同于v-on:keydown)

【需求】：对文本输入框做校验，使用键盘按下事件，如果按下0-9的数字，正常显示，其他按键则阻止事件执行。

+ demo03.js

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>vue绑定键盘按下事件</title>
    <script src="js/vuejs-2.5.16.js"></script>
</head>
<body>
    <!--
        对文本输入框做校验，使用键盘按下事件，如果按下0-9的数字，正常显示，其他按键则阻止事件执行。
    -->
    <div id="app">
        <!--
            $event就是你当前触发的事件
        -->
        <input type="text" @keydown="fn1($event)">
    </div>
    <script>
        var vue = new Vue({
           el:"#app",
           data:{

           },
           methods:{
               fn1(event){
                    //判断你按下的那个按键是否是0-9，如果不是0-9则阻止事件触发
                   //event.keyCode获取当前按键的键码值
                   var keyCode = event.keyCode;
                   //先判断，按键是否是删除键
                   if (keyCode != 8) {
                       if (keyCode < 48 || keyCode > 57) {
                           //说明输入的不是0-9，则阻止事件发生
                           event.preventDefault()
                       }
                   }
               }
           }
        });
    </script>
</body>
</html>
```

### @mouseover

说明:鼠标移入区域事件(等同于v-on:mouseover)

【需求1】：给指定区域大小的div中添加样式，鼠标移到div中，弹出窗口。

+ demo04.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>vue绑定鼠标移入事件</title>
    <script src="js/vuejs-2.5.16.js"></script>
    <style>
        .box {
            width: 300px;
            height: 400px;
            border: 1px solid red;
        }

    </style>
</head>
<body>
    <div id="app">
        <div class="box" @mouseover="fn1()">
            div
        </div>
    </div>
    <script>
        var vue = new Vue({
           el:"#app",
           methods:{
                fn1(){
                    alert("鼠标移入了...")
                }
           }
        });
    </script>
</body>
</html>
```

##  v-text与v-html 


v-text：输出文本内容，不会解析html元素

v-html：输出文本内容，会解析html元素

用在标签的属性里面

【需求】：分别使用v-text, v-html 赋值 `<h1>hello world<h1>` ，查看页面输出内容。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>vue绑定标签体的内容</title>
    <script src="js/vuejs-2.5.16.js"></script>
</head>
<body>
<div id="app">
    <!--
        使用v-text可以绑定标签体中文本内容
    -->
    <div style="color: red" v-text="msg1"></div>

    <!--使用v-html可以绑定标签体中的所有内容-->
    <div style="color: blue" v-html="msg2"></div>
</div>
<script>
    var vue = new Vue({
       el:"#app",
       data:{
           msg1:"hello div1",
           msg2:"hello div2"
       }
    });
</script>
</body>
</html>
```


##   v-bind和v-model 



###  v-bind

**插值语法不能作用在HTML 属性上**，遇到这种情况应该使用 v-bind指令

```html
<!DOCTYPE html>
<html lang="en" xmlns:v-bind="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8">
    <title>vue绑定属性</title>
    <script src="js/vuejs-2.5.16.js"></script>
</head>
<body>
<div id="app">
    <!--
        vue绑定html标签的属性，使用v-bind进行绑定: v-bind:属性名="数据模型"
        简写  :属性名="数据模型"
        绑定a标签的href属性
    -->
    <a :href="url1">跳转到百度</a><br>
    <a :href="'https://www.qq.com?id='+id">跳转到腾讯网，并且携带请求参数id的值</a><br>
    <font :color="ys">你好世界</font>
</div>
<script>
    new Vue({
        el:"#app",
        data:{
            url1:"https://www.baidu.com",
            id:30,
            ys:"red"
        }
    })
</script>
</body>
</html>
```

###  v-model  

用于数据的绑定,数据的读取，主要是用于对表单数据进行双向绑定

【需求】：使用vue赋值json(对象)数据，并显示到页面的输入框中（表单回显）. 点击获取数据，在控制台输出表单中的数据；点击回显数据，设置表单的数据

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>v-model对表单数据进行双向绑定</title>
    <script src="js/vuejs-2.5.16.js"></script>
</head>
<body>
<div id="app">
    <form>
        用户名<input type="text" name="username" v-model="user.username"><br>
        密码<input type="text" name="password" v-model="user.password"><br>
        昵称<input type="text" name="nickname" v-model="user.nickname"><br>
        地址<input type="text" name="address" v-model="user.address"><br>

        <!--
            1. 需求1: 点击获取表单数据的按钮的时候，将表单的所有数据获取到
        -->
        <input type="button" value="获取表单的数据" @click="obtainFormData()"><br>

        <!--
            2. 需求2: 点击回显表单数据，重新设置表单中的内容
        -->
        <input type="button" value="回显表单数据" @click="setFormData()">
    </form>

</div>

<script>
    var vue = new Vue({
       el:"#app",
       data:{
           user:{
               username:"张三",
               password:"123456",
               nickname:"张三疯",
               address:"武当山"
           }
       } ,
       methods:{
           //获取表单数据
           obtainFormData(){
                //其实就是获取数据模型user
                console.log(this.user)
           },
           setFormData(){
                //假设: 接收到了服务器端的响应数据
               var responseData = {
                   username:"李四",
                   password:"654321",
                   nickname:"李四疯",
                   address:"峨眉山"
               }

               //目的：将表单的值设置为responseData里面的值
               //只要将responseData的值设置给user就行了
               this.user = responseData
           }
       }
    });
</script>
</body>
</html>
```

##  v-for,v-if,v-show

###  v-for 

用于操作array/集合，遍历

语法:  `v-for="(元素,index) in 数组/集合"`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>使用v-for遍历</title>
    <script src="js/vuejs-2.5.16.js"></script>
</head>
<body>
    <div id="app">
        <!--城市列表-->
        <ul>
            <!--
                使用v-for绑定数组内容
            -->
            <li v-for="(cityName,index) in cityList" :id="index" v-html="cityName"></li>
        </ul>

        <table border="1" cellspacing="0" align="center" width="500">
            <tr>
                <th>编号</th>
                <th>姓名</th>
                <th>年龄</th>
                <th>地址</th>
            </tr>

            <tr v-for="(linkman,index) in linkmanList">
                <td v-html="index+1"></td>
                <td v-html="linkman.name"></td>
                <td v-html="linkman.age"></td>
                <td v-html="linkman.address"></td>
            </tr>
        </table>
    </div>
<script>
    var vue = new Vue({
       el:"#app",
       data:{
           cityList:["北京","上海","深圳","广州","长沙"],
           linkmanList:[
               {
                   name:"张三",
                   age:18,
                   address:"深圳"
               },
               {
                   name:"李四",
                   age:28,
                   address:"广州"
               },
               {
                   name:"王五",
                   age:18,
                   address:"惠州"
               }
           ]
       }
    });
</script>
</body>
</html>
```

### v-if 与v-show

v-if是根据表达式的值来决定是否渲染元素(标签都没有了)

v-show是根据表达式的值来切换元素的display css属性(标签还在)。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>vue绑定标签的显示和隐藏</title>
    <script src="../js/vuejs-2.5.16.js"></script>
</head>
<body>
    <div id="app">
        <!--
            给img标签绑定v-if，如果值为true就显示，值为false就隐藏; v-if是通过直接删除标签来隐藏标签的

            给img标签绑定v-show，如果值为true就显示，值为false就隐藏;v-show是通过设置display为none来隐藏标签的
        -->
        <img v-show="isShow" src="../https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/VUE/img/mm.jpg" width="400px" height="400px"><br>
        <input type="button" value="切换显示和隐藏" @click="toggleImg()">
    </div>
    <script>
        var vue = new Vue({
           el:"#app",
           data:{
               isShow:true
           },
            methods:{
               toggleImg(){
                    this.isShow = !this.isShow
               }
            }
        });
    </script>
</body>
</html>
```

### 小结

1. v-for:作为标签的属性使用的, 遍历

```
<标签 v-for="(元素,索引) in 数组"></标签>
//1.元素的变量名随便取
//2.索引的变量名随便取

```

2. v-if: 作为标签的属性使用的, 决定了标签是否展示

```
<标签 v-if="boolean类型的"></标签>

//1.v-if里面是true, 展示
//2.v-if里面是false, 不展示,标签都没有
```

###  Vue的常用指令的回顾

1. 在vue的入门案例中，需要注意的点:
   1. JavaScript的版本应该设置为ECMAScript6
   2. el表示vue的容器
   3. data表示数据模型
   4. methods表示vue的函数
2. 绑定事件:
   1. v-on:click="函数"
   2. @click="函数"
3. v-text 和 v-html 设置标签体的内容
4. v-bind绑定属性
5. v-model绑定表单的内容
6. v-for 进行遍历
7. v-if 和 v-show 控制标签的显示和隐藏

# VueJS生命周期 

##  VueJS生命周期

### 什么是VueJS生命周期

​	就是vue实例从创建到销毁的过程. 

​	每个 Vue 实例在被创建到销毁都要经过一系列的初始化过程——例如，需要设置数据监听、编译模板、将实例挂载到 DOM 并在数据变化时更新 DOM 等。同时在这个过程中也会运行一些叫做生命周期钩子的函数，这给了用户在不同阶段添加自己的代码的机会。

![1595430819713](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/VUE/img/1595430819713.png)

+ beforeCreate ：数据还没有监听，没有绑定到vue对象实例，同时也没有挂载对象

+ **created**：数据已经绑定到了对象实例，但是还没有挂载对象（使用ajax可在此方法中查询数据，调用函数）

+ beforeMount: 模板已经编译好了，根据数据和模板已经生成了对应的元素对象，将数据对象关联到了对象的

  el属性，el属性是一个HTMLElement对象，也就是这个阶段，vue实例通过原生的createElement等方法来创
  建这个html片段，准备注入到我们vue实例指明的el属性所对应的挂载点

+ **mounted**:将el的内容挂载到了el，相当于我们在jquery执行了(el).html(el),生成页面上真正的dom，上面我们
  就会发现dom的元素和我们el的元素是一致的。在此之后，我们能够用方法来获取到el元素下的dom对象，并
  进行各种操作当我们的data发生改变时，会调用beforeUpdate和updated方法

+ beforeUpdate ：数据更新到dom之前，我们可以看到$el对象已经修改，但是我们页面上dom的数据还
  没有发生改变

+ updated: dom结构会通过虚拟dom的原则，找到需要更新页面dom结构的最小路径，将改变更新到
  dom上面，完成更新

+ beforeDestroy,destroyed :实例的销毁，vue实例还是存在的，只是解绑了事件的监听、还有watcher对象数据
  与view的绑定，即数据驱动

### vuejs生命周期的演示

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>01_vue入门</title>
    <script src="js/vuejs-2.5.16.js"></script>

</head>
<body>
<div id="app">
    <div id="msg">{{message}}</div>
</div>

<script>
    var vue =  new Vue({
        //表示当前vue对象接管了div区域
        el: '#app',
        //定义数据
        data: {
            message: 'hello word',
        },
        methods:{
            showMsg(msg, obj) {
                console.log(msg);//钩子函数的名称,obj就是vue对象
                console.log("data:" + obj.message);
                console.log("el元素:" + obj.$el);
                console.log("元素的内容:" + document.getElementById("app").innerHTML);
            }
        },
        //beforeCreate:vue对象还没有实例化出来，vue对象中的数据模型还未创建出来
        beforeCreate() {
            this.showMsg('---beforeCreate---', this);
        },
        //created ：数据已经绑定到了对象实例，但是还没有挂载对象
        created() {
            // created钩子函数执行的时候，vue对象已经创建出来了，vue对象中的数据模型已经创建出来了
            // 所以我们可以发送异步请求给服务器获取数据并且赋值给数据模型
            this.message = "你好世界"
            this.showMsg('---created---', this);
        },
        //beforeMount: 模板已经编译好了，根据数据和模板已经生成了对应的元素对象，将数据对象关联到了对象的
        beforeMount() {
            this.showMsg('---beforeMount---', this);
        },
        //mounted:将el的内容挂载到了el，相当于我们在jquery执行了(el).html(el)
        //生成页面上真正的dom，上面我们就会发现dom的元素和我们el的元素是一致的。在此之后，我们能够用方法来获取到el元素下的dom对象，并进行各种操作当我们的data发生改变时，会调用beforeUpdate和updated方法
        mounted() {
            //在mounted里面可以获取视图上的数据
            this.showMsg('---mounted---', this);
        }
    });
</script>
</body>
</html>
```

+ 结果

 ![1552552850107](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/VUE/img/1552552850107.png)


#  VueJS ajax



## vue-resource 

​	vue-resource是Vue.js的插件提供了使用XMLHttpRequest或JSONP进行Web请求和处理响应的服务。 当vue更新到2.0之后，作者就宣告不再对vue-resource更新，而是推荐的axios，在这里大家了解一下vue-resource就可以。

vue-resource的github: [https://github.com/pagekit/vue-resource](https://github.com/pagekit/vue-resource)

+ Get方式

![1552552968981](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/VUE/img/1552552968981.png)

+ Post方式

![1552552988792](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/VUE/img/1552552988792.png)

## axios 

#### 什么是axios

Axios 是一个基于 promise 的 HTTP 库，可以用在浏览器和 node.js 中

注: Promise 对象用于表示一个异步操作的最终状态（完成或失败），以及其返回的值。

axios的github:https://github.com/axios/axios

中文说明: https://www.kancloud.cn/yunye/axios/234845

### axios的语法

+ get请求

```js
// 为给定 ID 的 user 创建请求
axios.get('/user?id=12')
  .then(response=>{
    console.log(response);
  })
  .catch(error=>{
    console.log(error);
  });

// 可选地，上面的请求可以这样做
axios.get('/user', {
    params: {
      id: 12
    }
  })
  .then(response=>{
    console.log(response);
  })
  .catch(error=>{
    console.log(error);
  });
```

+ post请求

```js
axios.post('/user', {
    id: 12,
    username:"jay"
  })
  .then(response=>{
    console.log(response);
  })
  .catch((error=>{
    console.log(error);
  });
```

### axios的使用

需求:使用axios发送异步请求给ServletDemo01,并在页面上输出内容

步骤:

1. 创建ServletDemo01
2. 把axios和vue导入项目 引入到页面
3. 使用get(), post() 请求

* html页面代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>使用axios发送异步请求</title>
    <script src="js/vuejs-2.5.16.js"></script>
    <script src="js/axios-0.18.0.js"></script>
</head>
<body>
    <div id="app">
        用户名:<span v-html="user.username"></span><br/>
        密码:<span v-html="user.password"></span><br/>
        昵称:<span v-html="user.nickname"></span><br/>
        <a href="javascript:;" @click="fn1()">使用axios发送异步的get请求</a>

        <br/>
        <a href="javascript:;" @click="fn2()">使用axios发送异步的post请求</a>
    </div>
    <script>
        var vue = new Vue({
           el:"#app",
           data:{
             user:{}
           },
           methods:{
                //使用axios发送异步的get请求
                fn1(){
                    /*axios.get("demo01?username=aobama&password=123&nickname=圣枪游侠").then(response=>{
                        //response就是http协议中的响应:包含行、头、体，我们要获取的是响应体的数据，其实就是response.data
                        console.log(response.data)
                        //处理响应数据，response就是服务器端的响应数据,将响应数据中的json赋值给user
                        this.user = response.data
                    }).catch(error=>{
                        //处理请求失败,error就是服务器的异常信息
                        console.log(error)
                    })*/

                    //另外一种get请求携带参数的方式
                    axios.get("demo01",{
                        params:{
                            username:"奥巴马",
                            password:"1234567",
                            nickname:"圣枪游侠"
                        }
                    }).then(response=>{
                        //response就是http协议中的响应:包含行、头、体，我们要获取的是响应体的数据，其实就是response.data
                        console.log(response.data)
                        //处理响应数据，response就是服务器端的响应数据,将响应数据中的json赋值给user
                        this.user = response.data
                    }).catch(error=>{
                        //处理请求失败,error就是服务器的异常信息
                        console.log(error)
                    })
                },
                fn2(){
                    //使用axios发送异步的post请求
                    //post请求也可以在?后面携带参数
                    /*axios.post("demo01?username=周杰棍&password=666666&nickname=周杰伦").then(response=>{
                        this.user = response.data
                    })*/

                    //使用axios发送异步的post请求，并且携带json类型的参数(在请求体中)
                    axios.post("demo01",{username:"周杰伦",password:"123456",nickname:"周杰棍"}).then(response=>{
                        this.user = response.data
                    })
                }
           }
        });
    </script>
</body>
</html>
```

* ServletDemo01的代码

```java
package com.itheima.servlet;

import com.itheima.pojo.User;
import com.itheima.utils.JsonUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * @author Leevi
 * 日期2020-10-23  11:41
 * request.getParameter()方法只能获取到"name=value&name=value"这种类型的请求参数
 * 但是该方法无法获取请求体中的json类型的请求参数,就得使用json解析的jar包将json类型的请求参数转换成java对象
 */
@WebServlet("/demo01")
public class ServletDemo01 extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取请求参数
        /*String username = request.getParameter("username");
        String password = request.getParameter("password");
        String nickname = request.getParameter("nickname");

        System.out.println(username + ":" + password + ":" + nickname);
        //向客户端响应数据
        User user = new User(username, password, nickname);*/

        User user = JsonUtils.parseJSON2Object(request, User.class);

        System.out.println(user);
        //int num = 10/0;

        //将user转换成json字符串，响应给客户端
        /*String jsonStr = JSON.toJSONString(user);
        response.getWriter().write(jsonStr);*/

        JsonUtils.printResult(response,user);
    }
}
```

