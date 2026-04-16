-- 1. 窗口函数：求每个班级成绩前两名
SELECT name, score, class,
       RANK() OVER(PARTITION BY class ORDER BY score DESC) as rank_num
FROM score_table;

-- 2. 侧视图展开 (Explode)
SELECT explode(hobby) as my_hobby FROM person;
