---
title: javascript实际应用
categories: 前端知识集
tags:
  - javascript
top: 11
abbrlink: 383037982
date: 2019-05-13 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/html.jpeg)


### 实例

<!--more-->

#### 1.基础

```

<script>
      /*
      //前端语法会尽量隐藏报错
      const i = 10;  //常量定义
      var a = 10;
      var b = 20;
      var c = a + b;
      var d = "helllo world";
      var e = "1234"
      console.log(a);
      console.log(c); //在浏览器中开发者工具console中打印输出
      console.log(d);
      document.write(a);//在浏览器页面输出
      document.write(d);
      document.write(a+d);  //可以直接加减任何类型
      document.write(Number(e)+a); //使用Number String等进行类型转换
      alert("helllo world") //页面弹窗
      //js中类型
      var b;
      b = 10; // 'number'
      console.log(typeof b);
      b = true; // 'boolean'
      console.log(typeof b);
      a = 'Henrry Lee'; // 'string'
      console.log(typeof a);
      a = function(){}; // 'function'
      console.log(typeof a);
      a = {age:26}; // 'object'
      console.log(typeof a);

      */
      var aa = [1,2,3,4,56,23,1];
      for(var i in aa){
          document.write("下标：" + i + "  ||值：" + aa[i] + '<br>');
      }
      for (var i of aa){
          document.write(i+'  ');
      }

      function plus(num) {
          if(num === 1){
              return num;
          }
          return num + plus(num - 1);
      }
      var sum = plus(100);
      document.write('<br>' + sum);
    </script>

```

#### 2.函数方法

```

<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>js基础教学</title></head>
<body>
<ol>
</ol>
<button onclick=first()>确认</button>  <!--捕捉onclik事件操作并执行所对应函数 
可以写在这里也可以重新定义函数引用-->
<button onclick="">第二次确认</button>
<br>
<hr>
<button onclick="">第三次确认</button>
</body>
<script>
  function first(){                //定义函数
      alert('确认点击后 弹窗函数被执行');
  }
  var b = document.getElementsByTagName('button')[1];  //确认位置
  b.onclick = function(){   //函数编写并绑定'点击'事件
      alert('新方法，直接绑定点击事件并弹窗');
  };
  var c = document.getElementsByTagName('button')[2];
  c.onmouseover = function(){    //移到该位置便弹窗事件
      alert('鼠标进过便弹窗')
  };
  /*
  ol = document.getElementsByTagName("ol");
  ol = ol[0];
  ol.children;
  ol.childNodes;
  ol.childNodes[2];
  ol.firstElementChild;
  ol.lastElementChild;
  l1 = ol.parentElement;
   x1 = li1.previousElementSibling; //直接在console中输入即可
   */
  ol = document.getElementsByTagName('ol')[0];  //插入子节点步骤 1。获取标签
  var li2 = document.createElement('li'); //2。创建子标签
  ol.appendChild(li2); //3。添加标签
  li2.innerText = 'Test'; //4，标签内容
  var li3 = document.createElement('li');
  ol.appendChild(li3);
  li3.innerText = 'Test2';
  var body1 = document.getElementsByTagName('body');  //插入相邻节点步骤 1。获取标签
  body1 = body1[0];  //2。精确定位标签
  var div1 = document.createElement('div'); //3。创建div标签
  body1.insertBefore(div1,ol);  //4.插入该标签
  div1.innerText = 'xxxxx'; //5.标签内容
</script>
</html>


```

#### 3.js练习

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>js练习</title>
</head>
<style>
  td{
    border: 1px solid black;
  }
  *{
    margin: 0;
  }
</style>
<body>

<table cellspacing="0px" id = 't1'>
  <tr>
    <td colspan="4">
      <button onclick="add()">添加</button><button onclick="del()">删除</button>
    </td>
  </tr>
  <tr>
    <td>全选 <input type="checkbox" name="check"></td>
    <td>书号</td>
    <td>书名</td>
    <td>作者</td>
  </tr>
</table>

</body>
<script>
  function add() {   //添加按钮：添加表格标签并加入内容
      var table = document.getElementById('t1');  //获取table下标签
      var tr1 = document.createElement('tr');  //创建tr标签
      tr1.innerHTML = "<td><input type = \"checkbox\" name=\"check\">
      </td><td>1</td><td>2</td><td>3</td>"; //在tr标签中输入html语法
      table.appendChild(tr1); //tr中添加该语法
  }
  function del() {
      var inputs = document.getElementsByTagName('input');
      var del_inputs = [];
      for(let i of inputs){
          console.log(i.checked);   //是否选中：根据checked的值确定
          if(i.checked) {
              del_inputs.push(i)     //删除该按钮的值
          }
      }
      //return del_inputs
      for(let i of del_inputs){
          let tr2 = i.parentNode.parentNode;
          let table2 = tr2.parentNode;
         table2.removeChild(tr2);
      }
  }
</script>
</html>
```