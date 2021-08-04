# InnoDB锁机制
> 参考文档：https://dev.mysql.com/doc/refman/5.7/en/innodb-locking.html#innodb-auto-inc-locks
### 什么是数据库锁？

数据库锁定机制简单来说，就是数据库为了保证数据的一致性，而使各种共享资源在被并发访问变得有序所设计的一种规则。

![数据库锁](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/%E7%9F%A5%E8%AF%86%E7%82%B9/0E721D6A-7D0C-4d20-973B-5F2E3E3C441B.png)

### MVCC多版本并发控制

- MySQL InnoDB存储引擎，实现的是基于多版本的并发控制协议——MVCC (Multi-Version Concurrency Control)
- MVCC最大的好处，相信也是耳熟能详：读不加锁，读写不冲突。
- 在MVCC并发控制中，读操作可以分成两类：快照读 (snapshot read)与当前读 (current read)
    - 快照读：不加锁的select操作就是快照读，读取的是记录的可见版本 (有可能是历史版本)。
        ```sql
        select * from table;
        ```
    - 当前读：读取的是记录的最新版本，读取时还要保证其他并发事务不能修改当前记录，会对读取的记录进行加锁。
        ```sql
        select * from table lock in share mode;
        select * from table for update;
        insert into table values (…);
        update table set a = 1;
        delete from table ;
        ```

### 乐观锁

- 乐观锁其实并不是一种锁，只是针对悲观锁而衍生出来的相对概念。
- 乐观锁是乐观的认为数据并发情况下不会造成冲突，所以只在数据进行提交更新的时候，才会对是否冲突进行校验。业务上会在产生冲突后，返回异常信息给用户
- 乐观锁一般通过版本号/时间戳进行校验
- 实战：
    ```sql
    update table set field = x,version = 2 where id = 1 and version = 1; 
    ```
    然后通过update返回的影响行数来判断是否更新成功。
    
**用例表**
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
```
### 悲观锁

- 悲观锁是悲观的认为数据并发情况下，会被其他线程干扰（比如幻读，丢失修改），所以会对需要的数据进行加锁，当其他线程访问被加锁的数据时，都会被阻塞。
- 在InnoDB中，悲观锁的粒度分为表锁和行锁
- 在InnoDB中，悲观锁的具体实现类型包括：共享锁（S锁/读锁），排他锁（X锁/写锁/独占锁），间隙锁，Next-Key锁，AUTO-INC 锁
    - 共享锁（S锁/读锁）：
        - 语法：行锁：```select * from TABLE where ? LOCK IN SHARE MODE;```,表锁：```LOCK TABLE table_name  READ```
        - 共享锁又称读锁 (read lock)，是读取操作创建的锁。其他用户可以并发读取数据，但任何事务都不能对数据进行修改（获取数据上的排他锁），直到已释放所有共享锁。当如果事务对读锁进行修改操作，很可能会造成死锁。<br>
    
        |  事务1   | 事务2  | 
        |  :----:  | :----:  |
        | ```BEGIN;``` | ```BEGIN;``` |
        | ```SELECT * FROM `product_stock` WHERE id = 1 LOCK IN SHARE MODE;``` | ```SELECT * FROM `product_stock` WHERE id = 1 LOCK IN SHARE MODE;``` |
        | ```UPDATE `product_stock` SET stock = 20 WHERE id = 1;```<br>...阻塞 |  |
        | 共 0 行受到影响 | ```UPDATE `product_stock` SET stock = 20 WHERE id = 1;```<br>死锁：Deadlock found when trying to get lock; try restarting transaction<br> |
        | ```commit;``` | `````` |
    
        - Mysql会对查询结果中的每行都加共享锁，当没有其他线程对查询结果集中的任何一行使用排他锁时，可以成功申请共享锁，否则会被阻塞。
      
        |  事务1   | 事务2  | 事务3  | 
        |  :----:  | :----:  | :----:  |
        | ```BEGIN;``` | ```BEGIN;``` | ```BEGIN;``` |
        | ```SELECT * FROM `product_stock` WHERE id = 1 LOCK IN SHARE MODE;``` |  |  |
        |  | ```SELECT * FROM `product_stock` WHERE id = 1 FOR UPDATE```<br>...阻塞 |
        |  |  | ```SELECT * FROM `product_stock` WHERE id = 1 LOCK IN SHARE MODE;```<br>...阻塞 |
        | ```COMMIT;``` | 查出结果 |  |
        |  | ```COMMIT;``` | 查出结果 |
        
        - 加上共享锁后，对于update，insert，delete语句会自动加排它锁（就算不包裹事务也会被阻塞）。
        
        |  事务1   | 事务2  | 
        |  :----:  | :----:  |
        | ```BEGIN;``` |  |
        | ```SELECT * FROM `product_stock` WHERE id = 1 LOCK IN SHARE MODE;``` |  |
        |  | ```UPDATE `product_stock` SET stock = 20 WHERE id = 1;```<br>...阻塞 |
        | ```commit;``` | 执行成功 |
    - 排他锁（X锁/写锁/独占锁）：
        - 语法：行锁：```select * from TABLE where ? FOR UPDATE;```,表锁：```LOCK TABLE table_name  WRITE```
        - 可以防止并发事务带来的丢失修改问题。
        - 若某个事物对某一行加上了排他锁，只能这个事务对其进行读写，在此事务结束之前，其他事务不能对其进行加任何锁，其他进程可以读取,不能进行写操作，需等待其释放。

        |  事务1   | 事务2  | 事务3  | 
        |  :----:  | :----:  | :----:  |
        | ```BEGIN;``` | ```BEGIN;``` |  |
        | ```SELECT * FROM `product_stock` WHERE id = 1 FOR UPDATE;``` |  |  |
        |  | ```SELECT * FROM `product_stock` WHERE id = 1 LOCK IN SHARE MODE;```<br>...阻塞 |
        |  |  | ```UPDATE `product_stock` SET stock = 20 WHERE id = 1;```<br>...阻塞 |
        | ```COMMIT;``` | 查出结果 |  |
        |  | ```COMMIT;``` | 执行成功 |
        
    - 间隙锁（GAP）：
        - 间隙锁是对索引记录之间的间隙的锁，或者是对第一个索引记录之前或最后一个索引记录之后的间隙的锁。例如，SELECT c1 FROM t WHERE c1 BETWEEN 10 and 20 FOR UPDATE;阻止其他事务将 的值插入15到列中t.c1，无论列 中是否已经存在任何此类值，因为该范围内所有现有值之间的间隙被锁定。
        - 这里还值得注意的是，不同的事务可以在间隙上持有冲突的锁。例如，事务 A 可以在间隙上持有共享间隙锁（间隙 S 锁），而事务 B 在同一间隙上持有排他间隙锁（间隙 X 锁）。允许冲突间隙锁的原因是，如果从索引中清除记录，则必须合并不同事务在记录上持有的间隙锁。
        - REPEATABLE READ或以上的隔离级别下的特定操作才会取得gap lock
        - 可以防止并发事务带来的幻读（事务1查询id=1的记录不存在，事务2插入id=1的记录，事务1再插入id=1，就会出现主键冲突）问题。
                
        |  事务1   | 事务2  | 
        |  :----:  | :----:  |
        | ```BEGIN;``` | ```BEGIN;``` |
        | ```SELECT * FROM `product_stock` WHERE id > 5 FOR UPDATE;```<br>id数据只到5过 |  |
        |  | ```INSERT INTO `product_stock` VALUES(6,1,1,1);```<br>...阻塞 |
        | ```commit;``` | 执行成功 |
        
    - Next-Key 锁：
        - next-key 锁是索引记录上的记录锁和索引记录之前的间隙上的间隙锁的组合。
        - > InnoDB执行行级锁定的方式是，当它搜索或扫描表索引时，它会在遇到的索引记录上设置共享锁或排他锁。因此，行级锁实际上是索引记录锁。索引记录上的 next-key 锁也会影响该索引记录之前的“间隙”。也就是说，next-key 锁是一个索引记录锁加上一个在索引记录之前的间隙上的间隙锁。如果一个会话对R索引中的记录具有共享锁或排他锁 ，则另一个会话不能R在索引顺序中紧接在前的间隙中插入新的索引记录 。
        - 假设stock的值包含20,100,200。那么锁定的区域为：(负无穷,20],(20,100],(100,200],(200,正无穷]
          <br>当执行```SELECT * FROM `product_stock` WHERE stock = 20 FOR UPDATE; ```，锁住的区域为(负无穷,100]
        
        |  事务1   | 事务2  | 
        |  :----:  | :----:  |
        | ```BEGIN;``` | ```BEGIN;``` |
        | ```SELECT * FROM `product_stock` ```<br>![1](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/%E7%9F%A5%E8%AF%86%E7%82%B9/E61895B3-E8E2-42cb-A78D-549337C32590.png) |  |
        | ```SELECT * FROM `product_stock` WHERE stock = 20 FOR UPDATE; ``` |  |
        |  | ```INSERT INTO `product_stock` VALUES(7,1,1,19);```<br>...阻塞 |
        | ```commit;``` | 插入成功 |
        |  | ```commit;``` |
        | ```BEGIN;``` | ```BEGIN;``` |
        | ```SELECT * FROM `product_stock` WHERE stock = 20 FOR UPDATE; ``` |  |
        |  | ```INSERT INTO `product_stock` VALUES(7,1,2,21);```<br>...阻塞 |
        | ```commit;``` | 插入成功 |
        |  | ```commit;``` |
        | ```BEGIN;``` | ```BEGIN;``` |
        | ```SELECT * FROM `product_stock` WHERE stock = 20 FOR UPDATE; ``` |  |
        |  | ```INSERT INTO `product_stock` VALUES(7,1,3,101);```<br>插入成功 |
        | ```commit;``` | ```commit;``` |
        
        ###### Tips：共享锁也会有以上情况。实现间隙锁和Next-Key 锁的前提是目标数据where条件有索引，否则直接走表锁了。
        
    - AUTO-INC锁：
        - > 一个AUTO-INC锁是通过交易将与表中取得一个特殊的表级锁 AUTO_INCREMENT列。在最简单的情况下，如果一个事务正在向表中插入值，则任何其他事务都必须等待自己插入到该表中，以便第一个事务插入的行接收连续的主键值。