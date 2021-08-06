# 事务的隔离级别

### 什么是事务（transaction）？

##### 事务是应用程序中一系列严密的操作，所有操作必须成功完成，否则在每个操作中所作的所有更改都会被撤消。

##### 比如说，在转账系统中，A给B转账100元。那需要有两步操作

- A扣除100元
- B增加100元

##### 如果A扣除完100元后，系统突然崩溃，则会导致B的账户余额错误。

##### 通过事务就可以保证这两步关键的操作，要么都成功，要么都被撤销。

###### Tips：在 MySQL 中只有使用了 Innodb 数据库引擎的数据库或表才支持事务。

### 事务的控制语句
- BEGIN | START TRANSACTION 显式地开启一个事务；
- COMMIT 会提交事务，并使已对数据库进行的所有修改成为永久性的；
- ROLLBACK 回滚会结束用户的事务，并撤销正在进行的所有未提交的修改；
- SET TRANSACTION 用来设置事务的隔离级别。InnoDB 存储引擎提供事务的隔离级别有READ UNCOMMITTED、READ COMMITTED、REPEATABLE READ 和 SERIALIZABLE。
- SELECT @@tx_isolation; 查询数据库事务隔离级别
- SET [SESSION|GLOBAL] TRANSACTION ISOLATION LEVEL [READ UNCOMMITTED|READ COMMITTED|REPEATABLE READ|SERIALIZABLE]; 修改事务隔离级别

### 事务的四大特性(ACID)
- **原子性（Atomicity）：** 一个事务中的所有操作，要么全部完成，要么全部不完成，不会结束在中间某个环节。事务在执行过程中发生错误，会被回滚到事务开始前的状态，就像这个事务从来没有执行过一样。
- **一致性（Correspondence）：** 在事务开始之前和事务结束以后，数据库的完整性没有被破坏。比如上面的例子，无论事务成功还是失败，A+B的总额是不会变的。
- **隔离性（Isolation）：** 数据库在出现多个并发事务时，隔离性可以防止多个事务并发执行时由于交叉执行而导致数据的不一致。事务隔离分为不同级别，包括读未提交（Read uncommitted）、读提交（read committed）、可重复读（repeatable read）和串行化（Serializable）。
- **持久性（Durability）：** 事务处理结束后，对数据的修改就是永久的，即便系统故障也不会丢失。

### 并发事务带来的问题
用例：选票表：活动id，选手id，选手总票数。
- **脏读:** A事务修改了一条数据，但是还未提交，这个时候B事务访问并使用了这条数据，因为这条数据是还没有提交的数据，那么B事务读到的这个数据属于脏数据。脏写也同理。
- **丢失修改:** 一条数据同时间有两个事务访问，并且进行修改，会导致某个事务的修改被丢失。比如有一个增加选票操作，A事务查询出选票为100，同时B事务也查询出选票为100，A事务修改选票=100+1，B事务也修改选票=100+1。实际上两次操作后，选票应为102。但是结果是101，这就是丢失修改。
- **不可重复读:** 指在一个事务内多次读同一数据,在多次读取中间，数据被另一个事务修改。这就导致一个事务内两次读到的数据是不一样的情况，称为不可重复读。
- **幻读:** A事务根据活动id读取选手列表，然后B事务针对这个活动id插入一些数据。随后A事务再次读取时就会发现多了一些原本不存在的记录，就好像发生了幻觉一样，所以称为幻读。

### 事务的隔离级别
- **READ-UNCOMMITTED(读取未提交):**  最低的隔离级别，允许读取尚未提交的数据变更，可能会导致脏读、幻读或不可重复读。
- **READ-COMMITTED(读取已提交):**  允许读取并发事务已经提交的数据，可以阻止脏读，但是幻读或不可重复读仍有可能发生。
- **REPEATABLE-READ(可重复读):**  对同一字段的多次读取结果都是一致的，除非数据是被本身事务自己所修改，可以阻止脏读和不可重复读，但幻读仍有可能发生。
- **SERIALIZABLE(可串行化):**  最高的隔离级别，完全服从ACID的隔离级别。所有的事务依次逐个执行，这样事务之间就完全不可能产生干扰，也就是说，该级别可以防止脏读、不可重复读以及幻读。

|  隔离级别   | 脏读  | 不可重复读  | 幻读  |
|  :----:  | :----:  | :----:  | :----:  |
| READ-UNCOMMITTED  | √ | √ | √ |
| READ-COMMITTED  | X | √ | √ |
| REPEATABLE-READ  | X | X | √ |
| SERIALIZABLE  | X | X | X |

###### Tips：repeatable read 允许幻读，这是ANSI/ISO SQL标准的定义要求。

###### 敲重点！MySQL 的 Innodb 数据库引擎默认使用REPEATABLE-READ隔离级别。并且MySQL的REPEATABLE-READ是可以避免幻读的。

### 实战
- **数据准备**
```sql
CREATE TABLE `product_stock` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `company_id` INT(11) NOT NULL COMMENT '企业id',
  `product_id` INT(11) NOT NULL COMMENT '产品id',
  `stock` INT(11) NOT NULL COMMENT '库存',
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_product(company_id,product_id),
  KEY `idx_stock` (`stock`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='产品库存表';

insert  into `product_stock`(`id`,`company_id`,`product_id`,`stock`) values (1,1,10,100),(2,1,11,100);
```
- **READ-UNCOMMITTED【出现脏读】**

|  事务1   | 事务2  | 
|  :----:  | :----:  |
|  ``` SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;```  |  ``` SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;```  |
|  ``` BEGIN;```  |  |
|  ``` SELECT `stock` FROM `product_stock` WHERE id = 1;``` <br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/2540120D-BCEE-4aaa-B394-09B9E6192098.png) |   |
|  | ``` BEGIN;```  |
|  | ``` UPDATE `product_stock` SET stock = 90 WHERE id = 1;```  |
| ``` SELECT `stock` FROM `product_stock` WHERE id = 1;``` <br>![90](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/957CC49A-F767-4742-8268-7993D3894E70.png) 出现脏读 |   |
|  | ``` ROLLBACK;```  |
|  ``` SELECT `stock` FROM `product_stock` WHERE id = 1;``` <br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/2540120D-BCEE-4aaa-B394-09B9E6192098.png) |   |

- **READ-COMMITTED【避免脏读，出现不可重复读】**

|  事务1   | 事务2  | 
|  :----:  | :----:  |
|   ``` SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; ```   |   ``` SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; ```  |
|   ``` BEGIN; ```  |  |
|   ``` SELECT `stock` FROM `product_stock` WHERE id = 1; ``` <br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/2540120D-BCEE-4aaa-B394-09B9E6192098.png) |   |
|  |  ``` BEGIN; ```  |
|  |  ``` UPDATE `product_stock` SET stock = 90 WHERE id = 1; ```  |
|  ``` SELECT `stock` FROM `product_stock` WHERE id = 1; ``` <br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/2540120D-BCEE-4aaa-B394-09B9E6192098.png) 避免脏读 |   |
|  |  ``` COMMIT; ```  |
|   ``` SELECT `stock` FROM `product_stock` WHERE id = 1; ``` <br>![90](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/957CC49A-F767-4742-8268-7993D3894E70.png) 出现不可重复读|   |

- **REPEATABLE-READ【MySQL版，避免脏读，避免不可重复读，避免幻读】**

|  事务1   | 事务2  | 
|  :----:  | :----:  |
|   ``` SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; ```   |   ``` SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; ```  |
|   ``` BEGIN; ```  |  |
|   ``` SELECT `id`,`stock` FROM `product_stock` WHERE company_id = 1; ``` <br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/62FF8D59-7477-49ca-B2ED-A0C3C7B8838B.png) |   |
|  |  ``` BEGIN; ```  |
|  |  ``` UPDATE `product_stock` SET stock = 90 WHERE id = 1; ```  |
|  ``` SELECT `id`,`stock` FROM `product_stock` WHERE company_id = 1; ``` <br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/62FF8D59-7477-49ca-B2ED-A0C3C7B8838B.png) 避免脏读 |   |
|  |  ``` COMMIT; ```  |
|   ``` SELECT `id`,`stock` FROM `product_stock` WHERE company_id = 1; ``` <br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/62FF8D59-7477-49ca-B2ED-A0C3C7B8838B.png) 避免重复读|   |
|  | ``` SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; ``` |
|  | ``` BEGIN; ``` |
|  | ``` INSERT INTO`product_stock`(`company_id`,`product_id`,`stock`)VALUES(1,12,100); ``` |
|  | ``` COMMIT; ``` |
| ``` SELECT `id`,`stock` FROM `product_stock` WHERE company_id = 1; ```<br>![100](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/62FF8D59-7477-49ca-B2ED-A0C3C7B8838B.png) 避免幻读【MySQL该隔离级别可避免幻读】 |  |
| ``` COMMIT; ``` |  |
| ``` SELECT `id`,`stock` FROM `product_stock` WHERE company_id = 1; ```<br>![结果正常](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/backend-docs/20210803103457.png) |  |

###### Tips：对于丢失修改，我们可以通过数据库锁来解决。