-- 1. 从本地加载数据
LOAD DATA LOCAL INPATH '/opt/module/hive/data/product_info.txt' INTO TABLE product_info;

-- 2. 动态分区插入 (重点)
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
INSERT OVERWRITE TABLE log_partition PARTITION(day)
SELECT url, day FROM raw_log;
