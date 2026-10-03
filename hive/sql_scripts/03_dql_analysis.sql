-- ==========================================================
-- 03 数据查询（DQL）：统计分析练习
-- 执行方式：hive -f hive/sql_scripts/03_dql_analysis.sql
-- ==========================================================

USE bigdata;

-- ---------- 1. 基础查询与过滤 ----------
SELECT id, name, price
FROM product_info
WHERE price > 5000
ORDER BY price DESC
LIMIT 10;

-- ---------- 2. 聚合分析 ----------
SELECT category_id,
       COUNT(*)              AS 商品数,
       ROUND(AVG(price), 2)  AS 平均价格,
       ROUND(MAX(price), 2)  AS 最高价格
FROM product_info
GROUP BY category_id
ORDER BY 商品数 DESC;

-- ---------- 3. 多表关联 ----------
SELECT p.id, p.name, c.name AS category_name, p.price
FROM product_info p
LEFT JOIN category_info c ON p.category_id = c.id
LIMIT 10;

-- ---------- 4. 窗口函数：求每个班级成绩前两名 ----------
SELECT name, class, score, rank_num
FROM (
    SELECT name, class, score,
           RANK() OVER (PARTITION BY class ORDER BY score DESC) AS rank_num
    FROM score_table
) t
WHERE rank_num <= 2;

-- ---------- 5. 窗口函数：聚合与排名 ----------
SELECT class,
       SUM(score)                                          AS 总分,
       ROUND(AVG(score), 2)                                AS 平均分,
       RANK() OVER (ORDER BY SUM(score) DESC)              AS 班级排名
FROM score_table
GROUP BY class;

-- ---------- 6. 侧视图展开（explode）：把数组拆成多行 ----------
SELECT name, hobby_item
FROM person
LATERAL VIEW explode(hobby) tmp AS hobby_item;

-- ---------- 7. 分区裁剪：只扫描指定分区 ----------
SELECT day, COUNT(*) AS 访问量
FROM log_partition
WHERE day = '2026-10-01'
GROUP BY day;
