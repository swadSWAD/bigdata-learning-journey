-- ==========================================
-- 文件名: 02_load_data.sql
-- 功能: 创建维度表并加载已上传的小文件数据
-- 注意: 大文件加载语句已注释，需在有数据的Linux环境下解开使用
-- ==========================================

-- 1. 创建商品维度表
DROP TABLE IF EXISTS product_info;
CREATE TABLE product_info (
    id STRING COMMENT '商品ID',
    name STRING COMMENT '商品名称',
    price DECIMAL(10,2) COMMENT '价格'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- 2. 创建省份维度表
DROP TABLE IF EXISTS province_info;
CREATE TABLE province_info (
    id STRING COMMENT '省份ID',
    name STRING COMMENT '省份名称'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- 3. 创建支付流水表 (大文件，仅作建表演示)
DROP TABLE IF EXISTS payment_detail;
CREATE TABLE payment_detail (
    id STRING COMMENT '支付ID',
    order_id STRING COMMENT '订单ID',
    user_id STRING COMMENT '用户ID',
    amount DECIMAL(10,2) COMMENT '支付金额',
    payment_type STRING COMMENT '支付类型',
    create_time STRING COMMENT '支付时间'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ==========================================
-- 数据加载部分
-- ==========================================

-- 加载小文件数据 (在 Linux 中执行时，确保文件在当前目录)
LOAD DATA LOCAL INPATH 'product_info.txt' INTO TABLE product_info;
LOAD DATA LOCAL INPATH 'province_info.txt' INTO TABLE province_info;

-- 加载大文件数据 (由于文件未上传，执行会报错，仅作语法参考)
-- LOAD DATA LOCAL INPATH 'payment_detail.txt' INTO TABLE payment_detail;
