---
title: html语法04--css语法
categories: web
tags:
  - css语法
top: 7
abbrlink: 1650027718
date: 2019-05-14 18:18:19
password:
---

![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/html.jpeg)

###  css基础

<!--more-->

####  1.“行内样式”、“内嵌样式”、“外链样式”、“导入式”


```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" http-equiv="refresh">
    <title>中国男篮排位赛广州进行，将与国足下榻同一酒店</title>
  <style>                              // 内嵌样式
    p{
      text-indent: 4em;
    }
    h4{
      text-align: center;
    }
    img{
      width: 560px;
      height: 450px;
    }
    .p1{
      color: chocolate;
    }
    .p2{
      color: aqua;
    }
    #x2{
      color: cornflowerblue;
    }
    *{
      border: 0;
      margin: 0;
    }
  </style>
  <link rel="stylesheet" href="h5_css_1.css">   
  //外链样式 链接地址为编写的css外部代码
</head>
<body>
<article>
<header><h1 style="text-align: center">中国男篮排位赛广州进行</h1></header> 
//行内样式
<hr>
<h4 class="p1">(原标题)</h4>
<h5><img src="http://cms-bucket.ws.126.net/
2019/09/05/4740f77e15b9402a8877f302eb67a908.jpeg"></h5>
<p id = "x2">中国男篮59-72不敌委内瑞拉</p>
<p>而据澎湃新闻记者从国足处</p>
</article>

<p><b>延伸 · 回顾</b><hr></p>
<p><a href="https://sports.163.com/19/0904/21/EO8T046J00059AJ8.html">男篮无缘16强球
迷终于忍不了全场高喊"李楠下课"</a></p>
<p class="p2">北京时间9月4日晚</p>
<hr>
</body>
</html>

/*h5_css_1.css*/
h5{
  text-align: center;
}
```

####  2.css选择器


```
1.标签选择器
div  { width:  300px; height: 300px; background-color: red; }
p    { text-indent: 2em; color: blue; }
span { letter-spacing: 5px; font-size: 20px; }

2. 类选择器
.box  { width:  300px; height: 300px; background-color: red; }
p.des { text-indent: 2em; color: blue; }

3. id选择器
#box { width:  300px; height: 300px; background-color: red; }
#des { text-indent: 2em; color: blue; }

4. 通用选择器
通用选择器使用 * 表示，它的作用是选择页面中所有的标签元素

5. 后代选择器  可选择嵌套其中的任意一个子类
<style>
.container article { text-align: center; }
.container h1 { color: #000000; }
.container p  { color: #008800; }
</style>
<div class="container">
    <article>
        <h1>Napoléon Bonaparte</h1>
        <p>Adversity is the midwife of genius.</p>
    </article>
</div>

6. 子类选择器  只能选择直系嵌套下的子类

<style>
.container > article { text-align: center; }
.container > article > h1 { color: #000000; }
.container > article > p  { color: #008800; }
</style>

7. 伪类选择器

link：表示链接在正常情况下（即页面刚加载完成时）显示的颜色。
visited：表示链接被点击后显示的颜色。
hover：表示鼠标悬停时显示的颜色。
focus：表示元素获得光标焦点时使用的颜色，主要用于文本框输入文字时使用（鼠标松开时显示的颜色,
可以使用input来查看）。
active：表示当所指元素处于激活状态（鼠标在元素上按下还没有松开）时所显示的颜色。

a { text-decoration: none; }		
a:hover { text-decoration: underline;}
      a:link{
            color: red;
        }
        a:visited{
            color: green;
        }
        a:hover{
            color: red;
        }
        a:focus{
            color:black;
        }
        a:active{
            color: yellow;
        }

8. 群组选择器

<style>
a, div, span, p { font-size: 20px; }
div, p { margin:  0; padding: 0; }
</style>


<a href="javascript:;">超链接</a>
<div>布局标签</div>
<span>文本标签</span>
<p>段落标签</p>
```

#### 3.权重计算值

```
行内权重值：1000
ID选择器的权重值：100
class和伪类：10
标签选择器：1

!important 最高权重：10000 

#html1 {
           color: #73d44d !important;
           background-color: #93c1d4;
        }
        
```

		
		1.每种权重值的最大值只能叠加9次
		2.如果两个地方定义的权重一样的话,那么就按照最后定义的权重为准,这个原则
		使用于 <style>和 <link>混合来使用
		
		
#### 4.css高级选择器


CSS高级选择器区别于CSS普通选择器,是对标签元素的结构、标签元素的索引、标签元素
的状态等一些更为复杂的条件下进行的选择，甚至能改变现有标签的状态结构。

```
伪元素选择器：向指定的选择器添加指定的效果

1.：first-letter
	选择“块级元素”文本段落中的首个字符，只对块级元素生效 如<p>
2.:first-line
	选择“块级元素”文本段落中的首行文本，与1一样
3.:before
	在指定的选择器之前插入一段内容。插入内容默认为“行内元素”，可通过“display”强制转换类型。
	如果需要插入文本字符串，则直接将字符串赋值给 content 属性，
	如：`content: 'Hello, world!'	
	p {
    		letter-spacing: 5px;
    		font-size: 25px;
    		color: #ff4500;
    		text-shadow: 1px 1px 2px #000;
		}	
	p:after {
    		/*插入内容，这里以插入图片为例*/
    			content: url('xiaoxin.jpg');

    			position: relative;
    			top: 20px;
		}
		
		
结构性伪类选择器：该类选择器主要用于当前选择器精确地通过元素“索引值”或“匹配类型”
的索引值定位到该选择器的同级指定元素

1.:first-child
	对该类所有父元素中的首个子元素进行选择。
2.：last-child
	对该类所有父元素中的最后一个子元素进行选择。
3. :first-of-type
	对该类所有父元素中的首个匹配到类型的子元素进行选择。
4. :last-of-type
	对该类所有父元素中的最后一个匹配到类型的子元素进行选择。
5. :only-child
	对该类所有父元素中只含有唯一所匹配（不包含同级元素/只有一个子元素）的子元素进行选择。
6. :only-of-type
	对该类所有父元素中只含有唯一所匹配类型的子元素进行选择。
7. :nth-child(n)
	对其父元素的第“n”个子元素进行选择，通过设置参数“n(0开始)”指定为第几个元素。
	(该选择器不仅能准确的匹配到第“几”个指定类型的元素，还能对匹配类型元素的“
	奇偶索引”值进行选择。odd 表示奇数，even 表示偶数。)
8. :nth-last-child(n)
	该选择器和“:nth-child(n)”的特性基本一致，唯一的不同点就是该选择器的索引值是从该选
	择器匹配到的元素的同级元素中的最后一个开始进行计算的
9. :empty
  	该选择器会匹配所有，或指定基本选择器内没有元素（没有子节点）的标签元素。
10. :not(selector)
  	该选择器是用于排除指定元素的选择器。
```

### css文本和字体


#### 1.文本设置


```

01. 文本对齐方式
	text-align 属性用于控制“行内块元素”、“块元素”或“行内元素”（文本元素）的居中方式，
	包含三个值：

	left：局左对齐（m o'ren）
	right：居右对齐
	center：居中对齐


02. 段落首行缩进
	text-indent 属性是用于设置每个段落首行缩进数量值的属性，CSS字体大小（font-size）可
	以设置的数值和单位在该属性的值中都可以使用（除了百分比）。如果是用于中文布局，一般会使
	用“2em”的数值和单位来为每个段落的首行缩进“两个字符”。1em就等于16px，2em就是32px。
	
03. 文本装饰线
	text-decoration 属性是为文本上添加一根装饰线，带"href"属性的<a>标签默认
	会带有一根下划线，就是由该属性的值“underline”设置的。“text-decoration”
	属性有以下值：

	none（默认）：不显示任何装饰线
	underline：在文本下方显示装饰线
	overline：在文本上方显示装饰线
	line-through：在文本中间显示装饰线，相当于删除线
	
04. 大小写转换
	text-transform 属性能将“行内元素”中的英文文本进行大小写转换，以满足网站对
	规范性的要求。该属性有以下属性值：

	none（默认）：保持文本中英文单词的默认大小写
	capitalize：每个英文单词首字母为大写字母，其它为小写字母
	uppercase：将所有英文单词转换为大写字母
	lowercase：将所有英文单词转换为小写字母

05. 文本阴影
text-shadow 属性的作用是给文本添加阴影效果。目前除了IE9及之前版本不支持该属性外，
其它主流浏览器均支持该属性。该属性有4个值，具体如下：text-shadow: H V blur color;

H：水平偏移，“0”表示维持原位，正数为向右偏移，负数为向左偏移。单位为像素“px”。
V：垂直偏移，“0”表示维持原位，正数为向下偏移，负数为向上偏移。单位为像素“px”。
blur ：模糊距离，用 正数 表示阴影模糊的单位距离，距离越大模糊程度越高。单位为像素“px”。
color：阴影颜色，支持Web技术中的常用颜色模式：“颜色英文单词”、“HEX”、“RGBa”、“HSLa”。

<p style="text-shadow: 2px 2px 5px #000;">Hello, World!</p>

06. 文本行高
line-height 属性是用于设置“行内元素”中文本元素在一行中所占据的高度
当文本元素只有一行时，可以将该行的文本行高设为和父容器元素高度一致，以此到达文
本垂直居中的效果。使用场景如：表格、导航按钮、自定义样式按钮、标题栏等。

<!-- HTML 部分 -->
<div class="txt">CHINA</div>

<!-- CSS 部分 -->
<style type="text/css">
    .txt {
        width:  260px;
        height: 260px;
        background-color: #000;

        color: #fff;
        text-align: center;
        line-height: 260px;

        /*字符间距*/
        letter-spacing: 5px;
        /*字体大小*/
        font-size: 36px;
        /*文本阴影*/
        text-shadow: 3px 3px 5px skyblue;
    }
</style>


07. 单词间距  word-spacing 如“像素（px）”，“字符（em）”，“点（pt）”等，可以为负数。

08. 字符间距 letter-spacing 属性是用于控制字符间的间距，即无论单词或词语中含有空格
	（该属性对空格字符无效），该属性都会生效，单位同样为Web技术的常用度量单位，
	同样为可以为负数。


```

#### 2.字体设置

```

01. 字体颜色
在目前的浏览器标准中，要想改变浏览器默认字体的颜色（#000000）唯一的途径就是通过
CSS的 color 属性进行设置。颜色属性可以设置4种类型的值，有以下类型：颜色属于继承属性

颜色英文单词
	HEX（16进制颜色）
	RGBa/RGB（Alpha的三原色）
	HSLa（Alpha的Hue、Saturation、Lightness）
	Transparent（透明）
	inherit（继承父级）

02. 字体样式
font-style 用于设置字体类型，可设置以下值：

	normal：普通字体
	italic：斜体
	oblique：倾斜字体

03. 字体粗细
font-weight 用于设置字体粗细，可设置以下值：

	normal：正常粗细
	bold：粗体
	bolder：更粗的字体
	lighter：更细的字体
	100~900：步长为100，400 等同于 normal，而 700 等同于 bold
	
04. 字体大小 font-size 目前浏览器的主流的字号都是采用16像素（px）的字体。

05. 字体名称 font-family 用于设置字体系列，就是我们通常说的“所用字体”。

06. 字体组合值 font 属性用于设置字体样式的组合值写法，其语法形式为：


扩展：文字两端对齐

div {

    width: 120px;
    padding: 5px;
    margin:  2px;
    border:  1px solid #ff4500;
    border-radius: 5px;

    text-align-last: justify; /*两端对齐*/
}
```

###  css元素分类

```
1.在CSS中，html中的标签元素大体被分为三种不同的类型：
	块状元素、内联元素(又叫行内元素)和内联块状元素。

常用的块状元素有：
<div>、<p>、<h1>...<h6>、<ol>、<ul>、<dl>、<table>、<address>、<blockquote> 、<form>
常用的内联元素有：
<a>、<span>、<br>、<i>、<em>、<strong>、<label>、<q>、<var>、<cite>、<code>
常用的内联块状元素有：
<img>、<input>

2.块级元素 block

块级元素特点：
	1、每个块级元素都从新的一行开始，并且其后的元素也另起一行。
	2、元素的高度、宽度、行高以及顶和底边距都可设置。
	3、元素宽度在不设置的情况下，是它本身父容器的100%（和父元素的宽度一致），
	   除非设定一个宽度


3.内联元素 inline
	内联元素特点:
	1、和其他元素都在一行上；
	2、元素的高度、宽度及顶部和底部边距不可设置；
	3、元素的宽度就是它包含的文字或图片的宽度，不可改变。


4.内联块状 inline-block
	特点
	1、和其他元素都在一行上；
	2、元素的高度、宽度、行高以及顶和底边距都可设置。


5.类型转换  通过display:block 我们可以将元素转换类型  a{display:block;}
```

### 4.盒模型

```
1. 所谓盒子模型，即是将网页布局中的元素（行内/行内块元素）进行拟物化的比喻，一个盒子由内容
（content）、内间距（padding）、边框（border）以及外边距（margin）组成
提示：只有 块级元素 与 行内块元素 具备盒子模型。


2. CSS盒子模型的类型主要有两个：
	IE浏览器盒子模型：box-sizing:border-box;
	标准（W3C，其它主流浏览器）盒子模型（默认）：box-sizing:content-box;

3.盒子属性：
	宽度：width
	高度：height
	内间距：padding  设置盒子内容与边框之间的间距，即内间距（填充）
			padding 可以接收的值为：像素（px）、百分比（%）、inherit（继承）
									以及auto（浏览器自计算）
	外间距：margin   margin 属性主要用于设置某元素相对于同级元素和父级元素的一个距离值，
	       常用单位像素“px”。该属性对文本类元素（即“行内元素”）标签是无效的。
	       和 padding 一样


4.边框：border 属性的作用是为设定该属性的元素添加边框 该属性能对任何显示类型的元素设置，包括
		“行级元素（inline）”。该属性有三个分支属性：
		1）、border-width
		设置边框宽度，单位为像素。设定边框的宽度。可以为Web技术中常用的度量单位，
		通常为像素“px”。
		2）、border-style
		设置边框的类型，主要有以下可以设定的值：
				none：无边框  solid：实线边框  dotted：点线边框  
				dashed：虚线边框
				double：双线边框  groove：3D凹槽边框  
				ridge：3D凸槽边框 
				inset：内浮雕边框  outset：外浮雕边框
		3）、border-color
		设置边框颜色，支持英文单词、十六进制以及rgb颜色。
		4）、border  
		通过 border 属性直接设置四个方向的边框样式
		
		
5.盒子圆角
border-radius：设置边框圆角

6.元素阴影
box-shadow 属性能够让元素获得一个“阴影”效果，根据颜色的不同，有时候也可以叫做“发光”效果


```

### css布局模型

```
1.css的布局模式分类: 
	流动模型（Flow）浮动模型 (Float) 层模型（Layer）

2.流动（Flow）是默认的网页布局模式。也就是说网页在默认状态下的 HTML 网页元素都是根据流动模型
来分布网页内容的。
	特征：（1）块状元素都会在所处的包含元素内自上而下按顺序垂直延伸分布，因为在默认状态下，
				块状元素的宽度都为100%。实际上，块状元素都会以行的形式占据位置。
		 （2）第二点，在流动模型下，内联元素都会在所处的包含元素内从左到右水平分布显示。
		 		（内联元素可不像块状元素这么霸道独占一行）
			
3.float 浮动模型
	块状元素都是独占一行，如果现在我们想让两个块状元素并排显示
	任何元素在默认情况下是不能浮动的，但可以用 CSS 定义为浮动，如 div、p、table、img 
	等元素都可以被定义为浮动。

4.层模型：能让层一样可以对每个图层能够精确定位操作
	层模型有三种形式：
	1、绝对定位(position: absolute) 绝对定位,把图形定义在绝对的位置
	2、相对定位(position: relative) 为元素设置层模型中的相对定位，需要设置position:relative
	（表示相对定位），它通过left、right、top、bottom属性确定元素在正常文档流中的偏移位置。
	3、固定定位(position: fixed) fixed：表示固定定位，与absolute定位类型类似，但它的相对
	  移动的坐标是视图（屏幕内的网页窗口）本身
	
```

### css可见性

```
1.CSS Display(显示) 与 Visibility（可见性）

visibility:hidden:可以隐藏某个元素，但隐藏的元素仍需占用与未隐藏之前一样的空间。
		            也就是说，该元素虽然被隐藏了，但仍然会影响布局。

display:none:可以隐藏某个元素，且隐藏的元素不会占用任何空间。也就是说，该元素不但
	          被隐藏了，而且该元素原本占用的空间也会从页面布局中消失。

```

#### 举例

```
<!DOCTYPE html>
<title>Title</title> <style>
    ul{
        list-style-type: none;
    }
    #ul1{
        /*
        1.把 边框去掉
        2. 把li标签上面的点号去掉
        */
        margin: auto;
        padding: 0;
        width: 400px;
    }
    #ul1>li{
        /*
        给li标签整个增加背景颜色
        给li标签增加下面的分析
        */
        background-color: #8bd400;
        margin-bottom: 2px;
        margin-left: 2px;
        height: 40px;
        width: 80px;
        border-radius: 5px;
        float: left;
    }
    a{
        /**
        把a标签的下划线去掉
         */
        display:block;
        height: 40px;
        text-decoration: none;
        /*
        把文字放在中间
        */
        text-align: center;
        /*
        把文字行间距和整个block一样,那么文字就居中了
        */
        line-height:40px;
        /*
        加上椭圆
        */

        border-radius: 5px;

    }
    #li1{
        position: relative;
    }

    #li1 ul{
        margin: 0;
        padding: 0;
        position: absolute;
        display: none;
    }
    #li1 ul>li{
        margin: 0;
        color: grey;
        text-align: left;
        border: 1px solid;
        background-color: #ffcf41;

    }
    /**
    当数据过去的时候,整体变成深绿色
     */
    a:hover{
        background-color: green;
    }

    /*.c_li1:hover #ul2{*/
        /*display: block;*/
    /*}*/

    #ul1 li:hover >a~ul{
        display: block;
    }

    #ul2 a:hover{
        background-color: blue;
    }

</style>

```








