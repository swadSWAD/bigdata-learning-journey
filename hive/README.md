#  Hive 数据仓库实战项目

本项目记录了基于 Apache Hive 的数据仓库构建过程，包含从数据定义、数据加载到数据分析的完整流程。

##  项目结构

- **data/**
  - 存放测试数据集（商品、省份等维度表数据）。
  - 包含 `README.md` 说明数据字典。
- **sql_scripts/**
  - **01_ddl_create_tables.sql**: 数据定义语言，包含建表语句（内部表、分区表）。
  - **02_dml_load_data.sql**: 数据操作语言，包含数据加载与导入逻辑。
  - **03_dql_analysis.sql**: 数据查询语言，包含聚合分析与窗口函数实战。

##  技术栈

- **Hive**: 数据仓库基础设施
- **HQL**: 类 SQL 查询语言
- **ETL**: 数据抽取、转换、加载流程

##  如何运行

1. 启动 Hadoop 与 Hive 环境。
2. 执行 `source sql_scripts/01_ddl_create_tables.sql;` 建表。
3. 执行 `source sql_scripts/02_dml_load_data.sql;` 加载数据。
4. 执行 `source sql_scripts/03_dql_analysis.sql;` 查看分析结果。
