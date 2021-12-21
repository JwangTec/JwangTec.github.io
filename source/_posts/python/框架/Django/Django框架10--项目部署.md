---
title: Django框架10--项目部署
categories: python-Django
tags:
  - python
  - Django
top: 8
abbrlink: 3485546001
date: 2019-06-10 18:18:19
password:
---


![](https://jwangtec.oss-cn-chengdu.aliyuncs.com/jwangcloud/index/Django.jpeg)


# 部署基本要求

<!--more-->

1.通过yum安装python3.5以上 使python程序不和系统本身python冲突(宝塔后台使用了默认
python)

2.安装虚拟环境

3.通过git ssh公钥下载部署代码

4.书写supervisord脚本，使用脚本启动项目

5.安装nginx


# app服务器部署

1.安装python3

```bash
mkdir /opt/mypython3
wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz
tar -zxvf Python-3.6.5.tgz
cd Python-3.6.5
./configure --prefix=/opt/mypython3
make && make install
```


2.安装虚拟环境

```
cd /opt/mypython3/bin

./pip3 install virtualenvwrapper

```

配置虚拟环境

```
mkdir ~/Envs
cd ~/Envs
virtualenv movie_online -p /opt/mypython3/bin/python3.6

```

激活虚拟环境

```
source ~/Envs/movie_online/bin/activate

```

3.部署代码

生成ssh公钥

```
ssh-keygen
cat ~/.ssh/id_rsa.pub
```

把公钥放入gitee私人设置

建目录 托代码

```
mkdir /project
cd /project
git clone git@gitee.com:pengmao/MoDuXiXiaAPP.git movie_online
mkdir /project/movie_online/backend/log
mkdir /project/movie_online/backend/log/gunicorn
```

4.安装supervisor并使用

给虚拟环境安装pip 包

```
pip install -r /project/movie_online/backend/requirements.txt
```

使用自带的python2.6安装supervisord
```
deactivate

pip install supervisor

mkdir /project/supervisor
cd /project/supervisor
echo_supervisord_conf > supervisor.conf

mkdir /project/supervisor/movie_online_log
```

supervisord配置文件
```
[program:movie_online]
command=/root/Envs/movie_online/bin/gunicorn -c gunicorn_conf.py movie_1.wsgi
directory=/project/movie_online/backend
startsecs=0
stopwaitsecs=0
autostart=true
autorestart=true
stdout_logfile=/project/supervisor/movie_online_log/gunicorn.log
stderr_logfile=/project/supervisor/movie_online_log/gunicorn.err

```

supervisord启动命令

```
supervisord -c /project/supervisor/supervisor.conf
supervisorctl -c /project/supervisor/supervisor.conf status 察看supervisor的状态
supervisorctl -c /project/supervisor/supervisor.conf reload 重新载入 配置文件
supervisorctl -c supervisor.conf stop 停止
```

#### nginx

新建日志文件夹
```
mkdir /project/logs
mkdir /project/logs/movie_online

```
nginx配置参考

```

        server {
         charset utf-8;
         listen 80;
         #server_name api.coolcity.tangrenapp.com;

         client_max_body_size 5;
         location /static {
                 client_max_body_size 50m;
                 alias /project/movie_online/backend/static;
                 allow all;
         }

        location / {
                 client_max_body_size 50m;
                 proxy_set_header Host $host;
                 proxy_pass http://0.0.0.0:8005;
        }

        #error_log /root/project/logs/modou/error.log;
        error_log /project/logs/movie_online/error.log;
        access_log /project/logs/movie_online/access.log;
        }


```

最后收集静态文件

```
cd /project/movie_online/backend
source ~/Envs/movie_online/bin/activate
python3.6 manage.py collectstatic

```

# 资源服务器

搭建nginx dav服务器

```

wget http://nginx.org/download/nginx-1.12.2.tar.gz
tar -zxvf nginx-1.12.2.tar.gz
cd nginx-1.12.2
mkdir /opt/mynginx
./configure --prefix=/opt/mynginx --with-http_dav_module
make && make install
```

dav配置

10.19.96.0/24; 开放内网网段

```
server{
        listen 30081;
        location / {
            #root /var/www/media;
            root /www/wwwroot/file.coolcity.tangrenapp.com;


         #   client_body_temp_path /data/client_temp;

            dav_methods PUT DELETE MKCOL COPY MOVE;

            create_full_put_path  on;
            dav_access            group:rw  all:r;
            allow 10.19.96.0/24;
            deny all;
         }
        error_log  logs/pic_error.log;
        access_log  logs/pic_access.log;
     }

```

user = 我 or 其他人


发帖人(我) 删除权限  对 我的帖子
看帖子的人(其他人) 没有删除权限 对 我的帖子
小吧主(其他人) 有删除权限 对 我的帖子

权限管理系统 --》 第三方


实现的一种 -> guradian

权限管理系统 -> RBAC-> guradian

1. 赋予权限
2. 查看权限
3. 删除权限

短评:

1.用户发帖的时候 使用 guradian

    1.赋予用户删帖权限
    2.赋予管理员删除权限
    3.赋予用户修改权限

2. 在查看帖子的时候:
    去查看一下你有没有删除的权限

3. 请求删除的时候:
    去查看一下你有没有删除的权限



代码:
    from guardian.shortcuts import assign_perm
    from guardian.shortcuts import check_perm
    from guardian.shortcuts import remove_perm









