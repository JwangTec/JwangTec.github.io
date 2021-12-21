---
title: hexo快速搭建blog
categories: 通用文章
tags:
  - hexo
  - 博客搭建
top: 2
abbrlink: 327602452
date: 2019-05-05 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/hexo.jpeg" width="1000" height="200" align="middle" />

<meta name="referrer" content="no-referrer" />

版权声明：本文为github博主「_xaoxuu」的原创文章，遵循 CC4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。

[原文链接: ](https://xaoxuu.com/blog/2017-07-05-hexo-blog/)https://xaoxuu.com/blog/2017-07-05-hexo-blog/


## 搭建基于hexo的独立博客

<!--more-->

###  傻瓜式操作(仅限于macos系统)

打开终端，cd 到你想创建博客的地方，执行这一行命令：

```
curl -O 'https://raw.githubusercontent.com/xaoxuu/hexo.sh/master/hexo.sh' -# && chmod 777 hexo.sh && . hexo.sh -i init

```


###  详细操作


####  安装Node.js

Hexo依赖Node.js和git。如果电脑上没有node环境可以去 Nodejs官网 下载。安装完成可以查看版本，在终端输入：

```
npm -v    #出现版本号表示安装成功

```

####  安装git


macOS自带git，可以跳过此步骤。


```
Windows: Download & install git.
Mac: Install it with Homebrew, MacPorts or installer.
Linux (Ubuntu, Debian): sudo apt-get install git-core
Linux (Fedora, Red Hat, CentOS): sudo yum install git-core

```

#### 安装Command Line Tools

macOS需要安装Command Line Tools，Windows可以跳过这一步骤。在终端输入：

```
xcode-select --install

```



点击install 安装


#### 安装hexo 

```
npm install hexo-cli -g

```

安装如图：


若出现下图,则需要以管理员身份运行：

```
sudo npm install hexo-cli -g

```




####  开始运行hexo

```
hexo init blog
cd blog
npm install
hexo server

```

####  选择主题


执行完上面几条命令之后，在浏览器打开地址：http://localhost:4000/就会看到hexo为你提供的默认主题。如果你不喜欢hexo自带的主题，可以去 hexo官网 找个喜欢的主题。下载主题源码到.../你的博客/themes/里面，根据主题的README文档提示，可能需要安装一些依赖包，或者对主题的_config.myl文件进行修改。如果你想使用本站的博客主题的话，只需要打开终端，cd到你博客所在的目录，执行以下这条命令：

```
hexo.sh i x

```

如果提示 command not found ，说明你的电脑上还没有使用过 hexo.sh 脚本，那么可以执行下面这一段命令下载脚本然后应用主题：

```
curl -O 'https://raw.githubusercontent.com/xaoxuu/hexo.sh/master/hexo.sh' -# && chmod 777 hexo.sh && . hexo.sh -i i x

```


#### 博客书写

你可以按照 官方文档 的方法去创建一个具有初始化内容的md文件到.../你的博客/source/_posts/位置，当然也可以通过其他任意方式创建md文件，只要文件开头有如下格式的内容即可：

```
---
layout:     post
date:       2017-07-05
title:      如何搭建基于Hexo的独立博客
categories: [Dev, Cocoa]
tags:
    - Hexo
---

这是预览

<!--more-->

这是正文

```

#### 在文章中添加图片、音乐等

安装图片插件-路径选择你的博客文件夹 即_plot文件夹下

```
npm install hexo-asset-image --save
或者
npm install https://github.com/CodeFalling/hexo-asset-image -- save

```

在_config.yml配置文件中，修改为 post_asset_folder: true， 然后新建一篇文章

```
hexo new post ceshi  #会生成一个附带的相同名字的文件夹放置图片，以及一个.md文件写内容

```

文章引用

```
![图片名](图片完整名字：例如book.png) 即相对路径

当然也可以使用cdn来存储图片，这样速度会相对来说快一点

```

音乐

大家可以看网易云音乐的官网，播放音乐可以生成外链，直接拿来用就行了。iframe插件可以在代码中设置宽高等参数，auto为自动播放。flash不可以自己设置参数。看喜好，随便你。
其他音乐，把插件中的链接替换成要播放的链接就可以了

```
#iframe插件

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="//music.163.com/outchain/player?type=2&id=505820138&auto=0&height=66">
</iframe>

#flash插件

<embed src="//music.163.com/style/swf/widget.swf?sid=40249713&type=2&auto=0&width=320&height=66" width="340" height="86" allowNetworking="all">
</embed>

```

链接

```
[我的微博](http://weibo.com/u/123455)

```

视频

视频链接最好是打开就是视频的链接（支持youku，YouTube）
可以把视频上传到优酷，腾讯视频，生成外链再拿来用。（上传需要注册和实名认证）

```

<iframe
height=498 width=510
src="http://player.youku.com/embed/XMzY0MzgxNDMyOA=="
frameborder=0 allowfullscreen>
</iframe>

```

#### 发布博客


博客发布到服务器才能被外网访问，如果你有服务器更好，可以支持一些有趣的功能，例如 hexo-admin 可以为你的博客增加后台管理功能，在其他地方只要登录管理员账号就可以在线写博文了。但是如果没有自己的服务器的，也可以将博客托管到 GitHub 、 Coding 等网站。他们的优缺点如下：

GitHub
优点：功能最强大，最知名，偏技术性的博客力荐。
缺点：国内访问稍慢（以前是很慢，现在已经好多了，但是仍不及国内的服务快）；GitHub服务器屏蔽了百度爬虫，要想被百度收录，需要去百度站长平台手动提交。

Coding
优点：国内访问速度很快，一键申请并配置好SSL证书，很容易被百度收录。
缺点：只能通过CNAME方式设置域名，也就意味着你不能同时使用域名邮箱等其他域名服务。








