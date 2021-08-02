## RabbitMQ命令大全
|  命令类型   | 命令  |  命令解释  |
|  :----:  |  :----:  | :----:  |
|  Ubuntu  |  sudo service rabbitmq-server start  | 启动  |
|  Ubuntu  |  sudo service rabbitmq-server stop  | 停止  |
|  Ubuntu  |  sudo service rabbitmq-server restart  | 重启  |
|  Ubuntu  |  sudo rabbitmqctl cluster_status  | 查看集群状态  |
|    |   |   |
|  rabbitmqctl  |  sudo rabbitmqctl cluster_status  | 查看集群状态  |
|  rabbitmqctl  |  sudo rabbitmqctl add_user root 123456  |  添加新用户，用户名：root 密码 123456 |
|  rabbitmqctl  |  sudo rabbitmqctl set_permissions -p / root ".*" ".*" ".*"  |  为root用户设置所有权限 |
|  rabbitmqctl  |  sudo rabbitmqctl set_user_tags root administrator  |  设置root用户为管理员角色 |
|    |   |   |
|  rabbitmq-plugins  |  sudo rabbitmq-plugins enable rabbitmq_management  | 启用rabbitmq_management插件  |
|  rabbitmq-plugins  |  sudo rabbitmq-plugins disable rabbitmq_management  | 关闭rabbitmq_management插件  |
|  rabbitmq-plugins  |  sudo rabbitmq-plugins list  | 查看插件启动状态,其中[E*]代表显式启动，[e*]代表隐式启动  |
|    |   |   |
|    |   |   |
