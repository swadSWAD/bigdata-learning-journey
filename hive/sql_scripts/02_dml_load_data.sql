-- 1. 从本地加载数据
LOAD DATA LOCAL INPATH 'product_info.txt' INTO TABLE product_info;

-- 2. 动态分区插入 (重点)
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
INSERT OVERWRITE TABLE log_partition PARTITION(day)
SELECT url, day FROM raw_log;

-- 1. 商品信息表 (对应 product_info.txt)
CREATE TABLE IF NOT EXISTS product_info(
    id INT COMMENT '商品id',
    name STRING COMMENT '商品名称',
    category_id INT COMMENT '分类id',
    price DECIMAL(10,2) COMMENT '价格'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

-- 2. 省份信息表 (对应 province_info.txt)
CREATE TABLE IF NOT EXISTS province_info(
    id INT COMMENT '省份id',
    name STRING COMMENT '省份名称'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';
