-- ==========================================================
-- 01 数据定义（DDL）：建库建表
-- 执行方式：hive -f hive/sql_scripts/01_ddl_create_tables.sql
-- ==========================================================

CREATE DATABASE IF NOT EXISTS bigdata;
USE bigdata;

-- ---------- 1. 普通表：学生表 ----------
DROP TABLE IF EXISTS student;
CREATE TABLE student(
    id   INT    COMMENT '学号',
    name STRING COMMENT '姓名',
    age  INT    COMMENT '年龄'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
COMMENT '学生表';

-- ---------- 2. 商品信息表（对应 data/product_info_sample.txt） ----------
DROP TABLE IF EXISTS product_info;
CREATE TABLE product_info(
    id          INT            COMMENT '商品id',
    name        STRING         COMMENT '商品名称',
    category_id INT            COMMENT '分类id',
    price       DECIMAL(10,2)  COMMENT '价格'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
COMMENT '商品信息表';

-- ---------- 3. 省份信息表（对应 data/province_info.txt） ----------
DROP TABLE IF EXISTS province_info;
CREATE TABLE province_info(
    id   INT    COMMENT '省份id',
    name STRING COMMENT '省份名称'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
COMMENT '省份信息表';

-- ---------- 4. 商品分类维度表（对应 data/category_info.txt） ----------
DROP TABLE IF EXISTS category_info;
CREATE TABLE category_info(
    id   INT    COMMENT '分类id',
    name STRING COMMENT '分类名称'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
COMMENT '商品分类维度表';

-- ---------- 4. 原始日志表（分区表的数据来源） ----------
DROP TABLE IF EXISTS raw_log;
CREATE TABLE raw_log(
    url STRING COMMENT '访问地址',
    day STRING COMMENT '日期'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
COMMENT '原始日志表';

-- ---------- 6. 分区表（重点：按天分区，避免全表扫描） ----------
DROP TABLE IF EXISTS log_partition;
CREATE TABLE log_partition(
    url STRING COMMENT '访问地址'
)
PARTITIONED BY (day STRING COMMENT '日期分区')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
COMMENT '日志分区表';

-- ---------- 7. 成绩表（供窗口函数练习使用） ----------
DROP TABLE IF EXISTS score_table;
CREATE TABLE score_table(
    name  STRING COMMENT '姓名',
    class STRING COMMENT '班级',
    score INT    COMMENT '成绩'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
COMMENT '成绩表';

-- ---------- 8. 人员表（含数组字段，供 explode 练习使用） ----------
DROP TABLE IF EXISTS person;
CREATE TABLE person(
    name  STRING        COMMENT '姓名',
    hobby ARRAY<STRING> COMMENT '爱好列表'
)
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '\t'
    COLLECTION ITEMS TERMINATED BY ','
COMMENT '人员表（带数组字段）';
