# 数据集说明

本目录存放 Hive 实战用到的测试数据，均为 **制表符（\t）分隔**的文本文件。

## 文件清单

| 文件 | 行数 | 对应表 | 说明 |
|:---|:---:|:---|:---|
| `province_info.txt` | 34 | `province_info` | 全国省份维度 |
| `category_info.txt` | 5 | `category_info` | 商品分类维度 |
| `product_info_sample.txt` | 5000 | `product_info` | 商品信息**样本数据** |
| `student.txt` | 4 | `student` | 学生基础信息 |
| `score.txt` | 8 | `score_table` | 成绩数据，用于窗口函数练习 |
| `person.txt` | 3 | `person` | 含数组字段，用于 explode 练习 |
| `raw_log.txt` | 6 | `raw_log` | 原始日志，用于分区练习 |

## 数据字典

### province_info.txt

| 字段 | 类型 | 说明 |
|:---|:---|:---|
| id | INT | 省份 id |
| name | STRING | 省份名称 |

```
1	北京
2	天津
```

### category_info.txt

| 字段 | 类型 | 说明 |
|:---|:---|:---|
| id | INT | 分类 id |
| name | STRING | 分类名称 |

```
1	手机数码
2	电脑办公
```

### product_info_sample.txt

| 字段 | 类型 | 说明 |
|:---|:---|:---|
| id | INT | 商品 id |
| name | STRING | 商品名称 |
| category_id | INT | 所属分类 id |
| price | DECIMAL(10,2) | 价格 |

```
1000000	XMkwvr	8682	383
1000001	CuisW	4517	219
```

> **关于样本数据**：原始数据集有 100 万行（约 24MB），此处只保留了**前 5000 行**用于演示，避免仓库体积过大。如需完整数据，可自行用脚本生成或从原始数据源获取。

### score.txt

| 字段 | 类型 | 说明 |
|:---|:---|:---|
| name | STRING | 姓名 |
| class | STRING | 班级 |
| score | INT | 成绩 |

### person.txt

| 字段 | 类型 | 说明 |
|:---|:---|:---|
| name | STRING | 姓名 |
| hobby | ARRAY&lt;STRING&gt; | 爱好列表，多个爱好用逗号分隔 |

```
张三	篮球,游泳,编程
```

> 注意：这个文件的字段用制表符分隔，**数组元素之间用逗号分隔**，所以建表时要同时指定 `FIELDS TERMINATED BY '\t'` 和 `COLLECTION ITEMS TERMINATED BY ','`。

### raw_log.txt

| 字段 | 类型 | 说明 |
|:---|:---|:---|
| url | STRING | 访问地址 |
| day | STRING | 访问日期，作为分区字段 |

## 中文乱码说明

数据文件统一使用 **UTF-8 无 BOM** 编码。如果在 Windows 上编辑后出现中文乱码，检查是否被存成了 GBK 编码。
