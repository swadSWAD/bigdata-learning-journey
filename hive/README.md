# Hive 数据仓库实战

基于 Apache Hive 的数据仓库构建练习，覆盖**建表 → 加载 → 分析**的完整流程。

## 项目结构

| 路径 | 内容 |
|:---|:---|
| `config/hive-site.xml` | Hive 配置（元数据库连接、执行引擎） |
| `data/` | 测试数据集，含[数据字典](data/README.md) |
| `sql_scripts/` | 三段式 SQL 脚本 |

## 脚本说明

| 脚本 | 职责 | 主要内容 |
|:---|:---|:---|
| `01_ddl_create_tables.sql` | **DDL** 建表 | 普通表、分区表、数组字段表 |
| `02_dml_load_data.sql` | **DML** 装载 | 本地加载、静态分区、动态分区插入 |
| `03_dql_analysis.sql` | **DQL** 分析 | 聚合、多表关联、窗口函数、explode |

**为什么按 DDL / DML / DQL 拆成三个文件**：职责分离，改表结构不会影响数据加载逻辑；也便于按需重跑某一阶段。

## 如何运行

**必须在仓库根目录执行**，因为脚本里用的是相对路径引用数据文件：

```bash
hive -f hive/sql_scripts/01_ddl_create_tables.sql
hive -f hive/sql_scripts/02_dml_load_data.sql
hive -f hive/sql_scripts/03_dql_analysis.sql
```

> 注意：HQL 文件要用 `hive -f` 执行，不能像 shell 脚本那样用 `source`。`source` 是 shell 内建命令，会把 SQL 语句当 shell 命令解析从而报错。

## 技术要点

### 1. 分区表

按天分区后，查询时带上 `WHERE day = 'xxx'` 就只扫描对应分区目录，避免全表扫描——这是 Hive 最基础也最有效的优化手段。

### 2. 动态分区

```sql
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT OVERWRITE TABLE log_partition PARTITION(day)
SELECT url, day FROM raw_log;
```

动态分区由 `SELECT` 结果中的字段值自动决定写入哪个分区，省去为每个分区写一条 `INSERT`。

**注意**：默认 `dynamic.partition.mode=strict` 要求至少指定一个静态分区，改为 `nonstrict` 才能全动态。

### 3. 窗口函数

```sql
SELECT name, class, score,
       RANK() OVER (PARTITION BY class ORDER BY score DESC) AS rank_num
FROM score_table;
```

三个排序函数的区别（面试常考）：

| 函数 | 遇并列时 | 示例（100,100,90） |
|:---|:---|:---|
| `ROW_NUMBER()` | 不重复 | 1, 2, 3 |
| `RANK()` | 占位跳号 | 1, 1, 3 |
| `DENSE_RANK()` | 不跳号 | 1, 1, 2 |

### 4. 内部表 vs 外部表

| | 内部表（Managed） | 外部表（External） |
|:---|:---|:---|
| `DROP TABLE` | 删元数据 **+ 数据** | 只删元数据，**数据保留** |
| 适用场景 | 中间结果表 | 原始数据、共享数据 |

生产上 ODS 层一般用外部表，避免误删源数据。

## 环境要求

- Hadoop 集群已启动（HDFS + YARN）
- Hive 3.1.3 + MySQL 元数据库（或 Derby）
- Hive 配置参考 [config/hive-site.xml](config/hive-site.xml)
