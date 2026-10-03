-- ==========================================================
-- 02 数据操作（DML）：加载与插入数据
-- 执行方式：hive -f hive/sql_scripts/02_dml_load_data.sql
-- 注意：请在仓库根目录执行，脚本中的数据文件为相对路径
-- ==========================================================

USE bigdata;

-- ---------- 1. 加载维度数据 ----------
LOAD DATA LOCAL INPATH 'hive/data/province_info.txt'
    OVERWRITE INTO TABLE province_info;

LOAD DATA LOCAL INPATH 'hive/data/category_info.txt'
    OVERWRITE INTO TABLE category_info;

LOAD DATA LOCAL INPATH 'hive/data/product_info_sample.txt'
    OVERWRITE INTO TABLE product_info;

-- ---------- 2. 加载普通表数据 ----------
LOAD DATA LOCAL INPATH 'hive/data/student.txt'
    OVERWRITE INTO TABLE student;

LOAD DATA LOCAL INPATH 'hive/data/score.txt'
    OVERWRITE INTO TABLE score_table;

LOAD DATA LOCAL INPATH 'hive/data/person.txt'
    OVERWRITE INTO TABLE person;

LOAD DATA LOCAL INPATH 'hive/data/raw_log.txt'
    OVERWRITE INTO TABLE raw_log;

-- ---------- 3. 静态分区插入：明确指定分区值 ----------
INSERT INTO TABLE log_partition PARTITION(day='2026-10-01')
SELECT url FROM raw_log WHERE day = '2026-10-01';

INSERT INTO TABLE log_partition PARTITION(day='2026-10-02')
SELECT url FROM raw_log WHERE day = '2026-10-02';

-- ---------- 4. 动态分区插入（重点） ----------
-- 由 SELECT 结果中的 day 字段自动决定写入哪个分区
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT OVERWRITE TABLE log_partition PARTITION(day)
SELECT url, day FROM raw_log;

-- ---------- 5. 结果校验 ----------
SELECT '省份表' AS 表名, COUNT(*) AS 行数 FROM province_info
UNION ALL
SELECT '商品表', COUNT(*) FROM product_info
UNION ALL
SELECT '分类表', COUNT(*) FROM category_info
UNION ALL
SELECT '学生表', COUNT(*) FROM student
UNION ALL
SELECT '成绩表', COUNT(*) FROM score_table
UNION ALL
SELECT '人员表', COUNT(*) FROM person
UNION ALL
SELECT '日志分区表', COUNT(*) FROM log_partition;
