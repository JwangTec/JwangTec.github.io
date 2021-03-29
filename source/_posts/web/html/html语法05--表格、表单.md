---
title: html语法05--表格、表单
categories: web
tags:
  - 表格
  - 表单
top: 7
abbrlink: 1576459572
date: 2019-05-15 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/html.jpeg)

###  1.表格

<!--more-->

		
		表格由 table 标签来定义。
		每个表格均有若干行（由 tr 标签定义），每行被分割为若干单元格（由 td 标签定义）。
		字母 td(table data) 指表格数据，即数据单元格的内容。
		数据单元格可以包含文本、图片、列表、段落、表单、水线、表格等等。
		
```

<table border="1" cellpadding="10”>  border 为边框宽度1 cellpadding 为单元格间距10 
    <tr>
        <td>
            row 1,col 2    
        </td>
    </tr>
</table>

```
####   1.1 表格标签


|标签|描述|
|:-:| :-:|
|table|定义表格
|th|定义表格的表头
|tr|定义表格的行
|td|定义表格的单元
|caption|定义表格的标题
|colgroup|定义表格的组
|col|定义表格列的属性
|thead|定义页眉
|tbody|定义表格的主体
|tfoot|定义表格的页脚

####  1.2 表格三大部分

		
			thead ---------表格的页眉
			tbody ---------表格的主体
			tfoot ---------定义表格的页脚(在最下面,不管代码位置在哪里)
			

```
<table border="1">
	    <tfoot>
	    <tr><th>row end col1</th><th>row end col2</th></tr>
	    </tfoot>
	    <tbody>
	    <tr>
	        <td rowspan="2"> 把包括本身的2格合并起来
	            row 1,col 1
	        </td>
	    </tr>
	    </tbody>
	    <thead>
	    <tr><td>位置</td><td>位置</td></tr>
	    </thead>
	    
```

####  1.3 表格合并
	
		colspan 合并列
		rowspan 合并行
		
### 2 表单

#### 2.1 表单创建

		
	表单是一个包含表单元素的区域。
	HTML 表单用于搜集不同类型的用户输入。
	表单元素是允许用户在表单中输入内容,比如：文本域(textarea)、下拉列表、
	单选框(radio-buttons)、复选框(checkboxes)等等。
	
	表单使用表单标签 form标签来设置:
	多数情况下被用到的表单标签是输入标签 input标签 输入类型是由类型属性（type）定义的。
	
	form标签属性:
		action 提交到哪里去(点击表单之后)
		method 定义提交的方法 get post等方法
		input标签就是我们常见的输入框里面的内容
		placeholder 提示我们输入文字
		required 必须输入
		
	<form action="tables.html" method="get">
	<label>账户</label><input type="text" name="test" placeholder=“输入” required>
	<input type="submit" value="submit">
	</form>
		

#### 2.2 表单标签

		
|标签|描述|
|:-:| :-:|		
|form|	
|input|定义输入域
|textarea|定义文本域 (一个多行的输入控件)
|label|定义了 input元素的标签，一般为输入标题
|fieldset|定义了一组相关的表单元素，并使用外框包含起
|legend|定义了 fieldset 元素的标题
|select|定义了下拉选项列表
|optgroup|定义选项组
|option|定义下拉列表中的选项
|button|定义一个点击按钮
|datalist|指定一个预先定义的输入控件选项列表
|keygen|定义了表单的密钥对生成器字段
|output|定义一个计算结果

	
	我们通过type来定义文本的类型,如果password则不会显示密码里面的字段
	我们习惯在使用label表示表单的名称,在label中使用for,指向input中的id
	就可以在点击label标签的时候,跳转到Input标签中间去	<form action="tables.html" method="get">
    <label for='t1'>账户</label><input type="text" name="name" id="t1">
    <label for="t2">密码</label><input type="password" name="pwd" id="t2">
    <input type="submit" value="submit">
    </form>
    
 
#### 2.3 单选按钮（radio） 复选框（checkbox）

```
type="radio" 标签定义了表单单选框选项
表单中的单选按钮可以设置以下几个属性：value、name、checked value：提交数据到服务器的值
name：为控件命名，以备后台程序 ASP、PHP 使用

checked="checked" 时，该选项被默认选中<form action="#" >
    <input type="radio" name="sex" value="male" checked>male<br>
    <input type="radio" name="sex" value="female">female<br>
</form>

```

#### 2.4 下拉列表（select option）

```
<form action="#" >
    <select name="car">
    <option value="1">bmw</option>
        <option value="2">benz</option>
        <option value="3">audi</option>
    </select>
    <input type="submit" value="submit">

</form>

```

#### 2.5 带边框的表单（filedset）

```

<form action="#">
<fieldset>
    <legend>
        fieldset的
    </legend>
    <label for='t1'>账户</label><input type="text" name="name" id="t1">
    <label for="t2">密码</label><input type="password" name="pwd" id="t2">
</fieldset>
    <input type="submit" value="submit">
</form>

```

#### 2.6 添加文件

```
文件上传 type=“file"
使用file，则form的enctype必须设置为multipart/form-data，method属性为POST。
<form action="#" enctype="multipart/form-data">
    <input type="file" name="upfile">
    <button>上传</button>
</form>

application/x-www-form-urlencoded 	在发送前编码所有字符（默认）
multipart/form-data	 不对字符编码。在使用包含文件上传控件的表单时，必须使用该值。
text/plain	 空格转换为 "+" 加号，但不对特殊字符编码。
```