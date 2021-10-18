---
title: 通用技术01--git
categories: 通用技术
tags: [git]
top: 5
abbrlink: 2499844314
date: 2019-05-03 18:18:19
password:
---


<img src="https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/git.jpeg" width="1000" height="300" align="middle" />

# git基础

<!--more-->

## 认知git


1. git知识库：https://git-scm.com/book/zh/v1/Git-基础
2. 安装git：brew install git 升级：brew update git
3. git: 版本控制，将一个项目（文件）作为一个仓库并对其进行监控（需要进入当前文件或者项目中）

## git常用命令

1. git init: 初始化文件（仓库），启动文件git仓库
2. git status: 监听该文件（项目）发生的变化
3. git add 文件名: 将工作区产生的变化记录并暂存到缓冲区
4. git commit -m "注释内容"：将add 的变化添加注释并提交本次记录（若没有-m，则会进入vim编辑器中进行编译注释）
5. git log :查看其记录，使用 jk 上下移动光标，Q键退出
6. git reset --hard 记录编号：回到该编号所在记录（编号可只截取一部分）
7. git diff:若在add前对文本进行编辑并修改过，则可通过该命令进行显示修改的内容
8. git config --global user,name " "(user.email 邮箱)
9. git merge 分支名：合并分支
10. git log --graph :查看详细分支记录
11. 删除分支：git branch -d 分支名	
12. git rm --cached 缓冲区存在的记录名: 删除加入缓冲区的该记录
13. .gitignore文件：将不想记录其改变的文件名写入该文件，此后将不会产生写入文件夹发生的变化
		注意：若在git管理的文件夹下创建空的文件夹，该变化不会被记录。


## git分支

1. git分支：在mmaster分支上再创建其它分支记录（使用指针head进行移动记录点）
2. git checkout -b '分支名'： 新建并切换到新分支
3. git branch '分支名'： 新建分支
4. git checkout '分支名'： 切换到该分支

		注意：若从某一个记录移到另一个分支的某一编码上时，
		需先切换（checkout）分支再切换(reset --hard)到某一个记录。
		
## git 分支合并

1. 快进合并：只有一条分支记录发生改变，另一个未发生改变的分支合并该分支：只需要将未发生改变的分支指针直接移到另一分支末端，即：先进入未发生改变的分支（checkout） 再合并发生记录的分支（git merge 发生改变的分支）
2. 非冲突合并：与快进合并一样，因其两天分支的记录或者变化互不干扰
3. 冲突合并：与上述操作一样，但需要在发生冲突的地方进行手动确认，并修改，此时产生的新变化也需要进行提交并注释。

# GitHub

## GitHub创建

1. github：远程仓库，还有：code、码云
2. 建立仓库步骤：
		
		(1). 新建远程仓库 （GitHub网站上新建，会产生一个https或者ssh）
		(2). 将https或ssh添加到本地仓库并重命名：
				git remote add 别名 https(ssh) --若不是一个仓库需要进行初始化
		(3). 推送本地仓库到GitHub：git push 链接别名 分支名
		
3. 删除远程仓库链接：git remote rm 链接别名
4. 查看远程仓库：git remote
5. 删除远程地址：git remote remove 别名
6. 查看远程仓库链接：git remote -v(详细信息)
7. 查看所有分支：git branch -a
8. 若A修改文档并推送到远程仓库，B也修改了此文档进行推送则不会成功，后推送的需要在A修改推送后再将远程仓库的先抓取下来，进行冲突合并后再推送
9. 远程仓库抓取：git pull （分支名）
10. 推送到远程仓库：git push （分支名）

## 创建GitHub博客

	1. 安装jeklly :sudo gem install bundler jekyll
	2. 端口输入：Jekyll 确认是否安装成功
	3. 创建本地Jekyll文件：Jekyll new 文件名
	4. 进入该文件（第一次需要初始化仓库）
	5. 安装markdown 并编辑文件（命名与__plot中文档一致）--> 博客内容
	6. 将其推送到GitHub的（learn666-gif.github.io）仓库（需要自己在GitHub网站创建）中去
	7. 进入博客：learn666-gif.github.io



##  …or create a new repository on the command line

```
echo "# python_resources" >> README.md
git init
git add README.md   #可能不成功，使用 touch README.md
git commit -m "first commit"
git remote add origin git@github.com:learn666-gif/python_resources.git
git push -u origin master

```

##  …or push an existing repository from the command line

```
git remote add origin git@github.com:learn666-gif/python_resources.git
git push -u origin master

```