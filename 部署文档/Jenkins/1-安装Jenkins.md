## 在Ubuntu系统上安装Jenkins
1. 在系统中添加key
   * ```shell script
     ubuntu@VM-0-8-ubuntu:~$ wget -q -o - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
     gpg: no valid OpenPGP data found. 
     ```
   * 这里因为用了小o所以出现no valid OpenPGP data found.
   ```shell script
     ubuntu@VM-0-8-ubuntu:~$ wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
     OK
     ubuntu@VM-0-8-ubuntu:~$ sudo echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
     -bash: /etc/apt/sources.list.d/jenkins.list: Permission denied
     ubuntu@VM-0-8-ubuntu:~$ su root
     Password: 
     root@VM-0-8-ubuntu:/home/ubuntu# sudo echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
   ```

2. 更新Debian库
   * ```shell script
     root@VM-0-8-ubuntu:/home/ubuntu# sudo aptitude update
     sudo: aptitude: command not found
     root@VM-0-8-ubuntu:/home/ubuntu# sudo apt-get install aptitude
     root@VM-0-8-ubuntu:/home/ubuntu# sudo aptitude update
     ```
3. 安装Jenkins （把jenkins当作一个系统服务来安装）
   * 命令
        ```shell script
         root@VM-0-8-ubuntu:/home/ubuntu# sudo aptitude install -y jenkins
        ```
   * 出现如下错误:找不到java：
     ![安装错误](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/3.png)
   * 查询配置文件
     <br>![查询环境变量配置](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/5.png)
   * 查询环境变量
     ![查询环境变量](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/Jenkins/4.png)
   * 创建一条软链接
        ``` shell script
        ubuntu@VM-0-8-ubuntu:~$ sudo ln -s /opt/jdk1.8.0_231/bin/java /usr/bin/java
        ```

   * 再次安装
        ``` shell script
        ubuntu@VM-0-8-ubuntu:~$ sudo aptitude install -y jenkins
        The following partially installed packages will be configured:
          jenkins 
        No packages will be installed, upgraded, or removed.
        0 packages upgraded, 0 newly installed, 0 to remove and 265 not upgraded.
        Need to get 0 B of archives. After unpacking 0 B will be used.
        Setting up jenkins (2.222) ...           
                                                 
        ubuntu@VM-0-8-ubuntu:~$ 
        ```
4. 安装信息
    * 启动脚本在 /etc/init.d/jenkins
    * war包位置 /user/share/jenkins
    * 主目录 /var/lib/jenkins
    * 日志目录 /var/log/jenkins/jenkins.log
    * 启动 sudo /etc/init.d/jenkins start
    * 停止 sudo /etc/init.d/jenkins stop
    * 默认端口 8080