-- 1. 从本地加载数据
LOAD DATA LOCAL INPATH '/opt/module/datas/student.txt' INTO TABLE student;

-- 2. 动态分区插入 (重点)
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
INSERT OVERWRITE TABLE log_partition PARTITION(day)
SELECT url, day FROM raw_log;
