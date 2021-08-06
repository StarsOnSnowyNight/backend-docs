# Explain
> 官方文档：https://dev.mysql.com/doc/refman/5.7/en/innodb-locking.html#innodb-auto-inc-locks

### 什么是Explain？

- 可以通过explain来查询SQL语句的执行计划，比如是否使用索引等，方便我们进行SQL优化
- 使用方法就是在查询sql前加上EXPLAIN就行。
- 对于输出格式，该文档只举例一些常用的类型。对应一些比较生僻的情况，可以看出官方文档

### 输出格式

|  字段名   | 简要概述  | 
|  :----:  | :----:  |
|  id  | 执行顺序 |
|  select_type  | 查询类型 |
|  table  | 表明 |
|  partitions  |  匹配的分区 |
|  type  | 联接类型  |
|  possible_keys  |  可能使用的索引 |
|  key  |  实际使用的索引 |
|  key_len  |  索引使用的长度 |
|  ref  |   |
|  rows  | 估计要检查的行数  |
|  filtered  | 按表条件过滤的行百分比  |
|  Extra  |  附加信息 |

### 用例表
```sql
CREATE TABLE `student` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '学生自增主键id',
  `student_name` VARCHAR(20) NOT NULL COMMENT '学生名字',
  `update_time` DATETIME NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_name`(student_name)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

CREATE TABLE `course` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '课程自增主键id',
  `course_name` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '课程名称',
  `update_time` DATETIME NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='课程信息表';

CREATE TABLE `exam` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '考试记录自增主键id',
  `student_id` INT(11) NOT NULL COMMENT '学生id',
  `course_id` INT(11) NOT NULL COMMENT '课程id',
  `exam_score` INT(11) NOT NULL COMMENT '考试分数',
  `update_time` DATETIME NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  key `idx_exam` (`student_id`,`course_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='考试记录表';

```

### 实操说明输出格式
- **id**

用来表示该行的查询顺序。有可能会出现重复的

- **select_type**  
查询类型

    - **SIMPLE:** 最简单的单表查询，且不使用UNION或子查询
    ```sql
    EXPLAIN SELECT * FROM `student`;
    ```  
    ![1](http://xuye-private.oss-cn-shanghai.aliyuncs.com/mackdown/%E7%9F%A5%E8%AF%86%E7%82%B9/explain/2.png)
    - **PRIMARY:** 查询中若包含任何复杂的子部分，则最外层的为PRIMARY
    ```sql
    EXPLAIN SELECT * FROM `student`;
    ```  
    