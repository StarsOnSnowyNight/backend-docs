## RabbitMQ的安装
1. **查看Erlang 和 RabbitMQ的[版本对应关系](https://www.rabbitmq.com/which-erlang.html)**
2. **此次安装选择最新的版本：Erlang->22.1   RabbitMQ->3.8.1**
   ![版本选择](https://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/rabbitmq/3ef4d568a1276abe30ad78b1309a26c.png)
3. **安装Erlang 22.1**
   * 查看linux内核版本
   ```
    ubuntu@VM-0-8-ubuntu:~$ sudo lsb_release -a
    No LSB modules are available.
    Distributor ID:	Ubuntu
    Description:	Ubuntu 16.04.1 LTS
    Release:	16.04
    Codename:	xenial
   ```
   * 在官网选择对应的版本[下载](https://www.erlang-solutions.com/resources/download.html)
   ![Erlang 22.1](https://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/rabbitmq/2bcf191ee96b7392275a1893e03026f.png)
   * 上传至/opt/erlang目录下
    ```
    ubuntu@VM-0-8-ubuntu:/opt/erlang$ pwd
    /opt/erlang
    ubuntu@VM-0-8-ubuntu:/opt/erlang$ ls
    esl-erlang_22.1-1_ubuntu_xenial_amd64.deb
    ```
   * 安装Erlang
   ```
   ubuntu@VM-0-8-ubuntu:/opt/erlang$ sudo dpkg -i esl-erlang_22.1-1_ubuntu_xenial_amd64.deb
   ```
   提示缺少相关依赖
   ![依赖](https://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/rabbitmq/5ee681c30ebf7affc00fd65453d9ebe.png)
   * 修复安装,解决依赖问题
   ```
   apt-get update
   ubuntu@VM-0-8-ubuntu:/opt/erlang$ sudo apt-get -f install
   ```
   * 再次安装
   ```
   ubuntu@VM-0-8-ubuntu:/opt/erlang$ sudo dpkg -i esl-erlang_22.1-1_ubuntu_xenial_amd64.deb
   ```
   * 输入erl，校验安装结果
   ```
   ubuntu@VM-0-8-ubuntu:/opt/erlang$ erl
   Erlang/OTP 22 [erts-10.5] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]
   ```
4. **安装RabbitMQ 3.8.1**
   * [参考网页](https://www.rabbitmq.com/install-debian.html)
     ![参考安装](https://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/rabbitmq/f3f986b0e50be3b734495097adb2655.png)
   * 在opt目录下创建rabbitmq
   * ``` sudo apt-get update ```
   * ``` sudo apt-get -y install socat logrotate init-system-helpers adduser ```
   * ``` sudo apt-get -y install wget ```
   * ``` wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.1/rabbitmq-server_3.8.1-1_all.deb ```
     * 这个速度太慢，我直接从官网下了。
     ![](https://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/rabbitmq/5264eddea621c8902aa05458f6859a8.png)
   * ``` sudo dpkg -i rabbitmq-server_3.8.1-1_all.deb ```
   * 启动/停止RabbitMQ
     ```
     sudo service rabbitmq-server start
     sudo service rabbitmq-server stop
     sudo service rabbitmq-server restart
     sudo rabbitmqctl status
     ```
5. **使用ctl创建管理员角色。** 默认情况下，RabbitMQ的用户名密码都是guest，这个只能通过localhost访问。所以这里添加一个用户
   * 添加新用户，用户名：root 密码 123456
   ```
   ubuntu@VM-0-8-ubuntu:/opt/rabbitmq$ sudo rabbitmqctl add_user root 123456
   Adding user "root" ...
   ```
   * 为root用户设置所有权限
   ```
   ubuntu@VM-0-8-ubuntu:/opt/rabbitmq$ sudo rabbitmqctl set_permissions -p / root ".*" ".*" ".*"
   Setting permissions for user "root" in vhost "/" ...
   ```
   * 设置root用户为管理员角色
   ```
   ubuntu@VM-0-8-ubuntu:/opt/rabbitmq$ sudo rabbitmqctl set_user_tags root administrator
   Setting tags for user "root" to [administrator] ...
   ```
6. **通过WEB管理**
   + 使用web界面，需要先启用RabbitMQ management 插件。
   + RabbitMQ的插件存放在 /usr/lib/rabbitmq/lib/rabbitmq_server-3.8.1/plugins 目录下，扩展名称为ez的文件，就是RabbitMQ的插件
   + 启用management插件
   ```
   sudo rabbitmq-plugins enable rabbitmq_management
   ```
   + 查看插件启动状态,其中[E*]代表显式启动，[e*]代表隐式启动
   ```
   sudo rabbitmq-plugins list
   ```
   + 重启rabbitmq，让插件生效
   ```
   sudo service rabbitmq-server restart
   ```
   + 打开localhost:15672
   ![](https://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/rabbitmq/3d9d14d8a11f14bab97a25d71ffe5bd.png)
   + 输入 root 123456
7. **安装延迟队列插件**
   + https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases 根据版本对应介绍找到rabbitmq-delayed-message-exchange v3.8.x
   + 下载rabbitmq_delayed_message_exchange-3.8.0.ez  
   ```
   cd /usr/lib/rabbitmq/lib/rabbitmq_server-3.8.1/plugins
   sudo wget https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/v3.8.0/rabbitmq_delayed_message_exchange-3.8.0.ez
   sudo rabbitmq-plugins enable rabbitmq_delayed_message_exchange
   ```
   ![](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/rabbitmq/222.png)