## Jenkins配置
1. 解锁jenkins
    * 进入8080端口
    ![解锁jenkins](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/6.png)
    * 复制admin密码
        ```shell script
        ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
        5d68ae15af8046938f546d63b1c84d9c
        ```
2. 安装插件(可以试试先更换下载源)
    * 选择安装推荐的插件
    * 更新时间在太慢，更换下载源
        ```shell script
        ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ sudo /etc/init.d/jenkins stop
        ubuntu@VM-0-8-ubuntu:/var/lib/jenkins/updates# cd /var/lib/jenkins/updates/
        ubuntu@VM-0-8-ubuntu:/var/lib/jenkins/updates$ su root
        Password: 
        root@VM-0-8-ubuntu:/var/lib/jenkins/updates# sed -i 's/http:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' default.json && sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' default.json
        root@VM-0-8-ubuntu:/var/lib/jenkins/updates# su ubuntu
        ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ sudo /etc/init.d/jenkins start
        ```
    * 进去一堆报错。。。
    * 点来点去又好了。找到一个地方重新下载了
    * 安装如下插件
        * Publish Over SSH
        * Maven Integration
        * GitLab Plugin
        * GitLab Hook Plugin
        * GitLab Authentication plugin
        * GitLab API Plugin
        * Git
        * Git client Plugin
        * Git Parameter Plug-In
        * NodeJS
3. maven安装
    * 下载maven  https://maven.apache.org/download.cgi
    * 上传并解压maven
    ```shell script
        ubuntu@VM-0-8-ubuntu:~$ cd /opt/maven/
        ubuntu@VM-0-8-ubuntu:/opt/maven$ ll
        total 9292
        drwxrwxr-x 2 ubuntu ubuntu    4096 Feb 27 14:36 ./
        drwxrwxrwx 6 root   root      4096 Feb 27 14:36 ../
        -rw-rw-r-- 1 ubuntu ubuntu 9506321 Feb 27 14:36 apache-maven-3.6.3-bin.tar.gz
        ubuntu@VM-0-8-ubuntu:/opt/maven$ tar -zxvf apache-maven-3.6.3-bin.tar.gz 
    ```
    * 添加配置文件
        ```shell script
        ubuntu@VM-0-8-ubuntu:/opt/maven$ sudo vim /etc/profile
        #set Maven
        export MAVEN_HOME=/opt/maven/apache-maven-3.6.3
        export PATH=$MAVEN_HOME/bin:$PATH
        ubuntu@VM-0-8-ubuntu:/opt/maven$ source /etc/profile
        ```
4. Jenkins配置maven和jdk
    * ![选择版本](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/7.png)
    * ![选择版本](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/8.png)
5. git 配置
    * 安装git 客户端
    ```shell script
    ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ sudo apt-get install git
    ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ git --version
    git version 2.7.4
    ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ git config --global user.name "jenkins"
    ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ git config --global user.email "jenkins@jianglaiwang.com"
    ubuntu@VM-0-8-ubuntu:/var/log/jenkins$ ssh-keygen -t rsa -C “jenkins@jianglaiwang.com”
    ubuntu@VM-0-8-ubuntu:~/.ssh$ cat /home/ubuntu/.ssh/id_rsa.pub
    复制公钥到gitlab
    测试拉取工程
    ubuntu@VM-0-8-ubuntu:/data/testgit$ git clone git@118.XX.XX.57:XXX-backend-munion/data-transfer-server.git
    ```
    * 创建访问令牌
      <br>这里全部都勾上，可能不勾也可以
      ![选择版本](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/10.png)
    * 保存个人访问令牌：zfWUgQryqU7HrXAtrQLS
    * 在jenkins中配置gitlab，系统管理-系统配置
    ![选择版本](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/11.png)
6. git ssh配置
    * 新建一个job，选择git
    * 选择添加
    <br>![选择添加](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/12.png)
    * 添加凭证
    <br>![添加凭证](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/13.png)
    * 添加完后，没有红色警告，表示配置成功
    <br>![测试](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/14.png)
    
7. 服务器SSH配置
    * 系统配置-SSH Servers,/一定要写，不然jar传不到目标服务器上
    <br>![SSH Servers](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/31.png)