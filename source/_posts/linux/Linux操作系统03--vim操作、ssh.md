---
title: Linux操作系统03--vim操作、ssh
categories: Linux操作系统
tags:
  - vim
  - ssh
top: 9
abbrlink: 2793636500
date: 2019-05-08 18:18:19
password:
---

<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Linux.jpeg" width="1000" height="200" align="middle" />

## 翻墙基础知识

<!--more-->
	
1.海底光缆：CN1（日本）CN2（美国加州） GIA

2.端口 ：一台服务器（一个IP）可有多个程序或功能，每一个程序或功能都会被分配一个不可重复的端口，端口号1024已经被系统应用占据，我们可以使用1024-65535之间的端口号，配置多个端口需写一个配置文件.

3.墙：国家监管，若浏览不正当网站会直接关闭

4.解决“墙”的问题：
	
	              加密      解密
	解决方案： 本地 ----> 墙 ----> 美国服务器
	       （加密软件）          （解密软件）
## SSH

1. ssh:加密登录方式（多用于银行，军队），我们常用的https就是一个加密协议，不会被监控
2. 加密方式：RSA加密  （第一个加密方式：凯撒加密CASER，常见加密方式BASE 64）
3. RSA原理：双方交换公钥，但保留私钥，用私钥加密，公钥解密
4. 查看密钥 ：其保存在～/.ssh/文件夹中 使用less命令拷贝密钥
5. 创建密钥 ：ssh -keygen
6. 交换密钥：ssh-copy-id root@对方ip -p 端口号

		若失败，需要重新创建密钥
		若成功，运行：ssh root@对方ip -p 端口号 可免密码登录
7. 使用ssh远程拷贝文件：scp -P 端口 文件名 root@远程服务器ip:绝对路径

## 实现步骤（简易版单人）

1.登陆远程服务器：ssh root@远程服务器ip地址 -p 端口 （需要输入远程服务器密码，在买服务器网站的个人信息中）

2.安装解密软件： pip install shadowsocks  (远程服务器上)

3.设置端口、密码：ssserver -p 端口 -k 密码 -m 加密方式  （远程服务器）

4.本地下载加密软件： 官网下载shadowsocks-NG 

## Linux文档编辑器（vim）
### vim 基础
1. 安装vim：yum install vim 
2. 确认是否安装：vi   (Shift+q :退出)
3. vim text.txt ：新建txt文件并编辑
4. vim两种模式
		
		输入模式：可以在其中输入文本，与文档编辑器一样，esc键退出该模式，esc+i:进入该模式，esa+a:在光标之后进入该模式
		命令模式：只能进行命令操作，shift+: 进入长命令输入，下方

### vim常用命令
1. x: 消除光标之前字符
2. hjkl:上下左右移动
3. yy:复制光标所在行内容
4. p:粘贴复制内容
5. dd:删除光标所在行内容
6. N（数字键）+ yy/dd:批量复制/删除光标之下的N行
7. u:撤销上一步操作
8. I：将光标移到光标所在行行首，并进入编辑模式
9. A：光标移到行尾
10. shift+:下输入wq:保存并退出（进入直接：vim 文件名）
11. 数字(N) gg：光标移到第N行；gg:跳到首行
12. o:在光标下新开一行并进入编辑模式

## 高级步骤（多人端口版）

1. 端口文件配置shadow.conf，
		
		{
		"server":"93.179.99.149",
		"local_address": "127.0.0.1",
		"local_port":1080,
		"port_password": {
				"55501": "add55555",
				"55502": "add55555",
				"55503": "add55555"（此处无逗号） 
		},
		"timeout":300,
		"method":"aes-256-cfb",
		"fast_open": false     
		
2. 登陆远程服务器并在其中编写该端口文件配置
3. 读取该配置文件：ssserver -c shadow.conf (该命令可先运行，检测成功性) -d start （之后运行完整命令）
4. 运行成功


		小提示：1.su 直接切换到超级用户
				2.sudo 代替执行超级用户的权限