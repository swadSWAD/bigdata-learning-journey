# 大数据学习之旅（bigdata-learning-journey）

从 0 到 1 系统学习大数据技术栈的**过程记录 + 实战代码**。包含环境搭建、组件配置、集群运维脚本，以及 HDFS / YARN / MapReduce / Hive 的动手实践。

## 学习路线

| 阶段 | 内容 | 状态 | 对应目录 |
|:---:|:---|:---:|:---|
| 1 | 大数据概论：4V 特点、Hadoop 生态圈、行业分析 | ✅ | [docs/01-bigdata-overview.md](docs/01-bigdata-overview.md) |
| 2 | HDFS：架构原理、Shell 操作、生产调优 | ✅ | [docs/02-hdfs.md](docs/02-hdfs.md) |
| 3 | YARN：调度策略、任务提交流程 | ✅ | [docs/03-yarn.md](docs/03-yarn.md) |
| 4 | HDFS Java API：文件增删改查、用户权限 | ✅ | [hadoop/hdfs-api](hadoop/hdfs-api) |
| 5 | MapReduce：编程模型、WordCount 实战 | ✅ | [hadoop/wordcount](hadoop/wordcount) |
| 6 | 集群运维：一键启停、批量分发脚本 | ✅ | [hadoop/scripts](hadoop/scripts) |
| 7 | Hive：建表、加载、分区、窗口函数 | ✅ | [hive](hive) |

## 目录结构

```
.
├── docs/                      # 学习笔记
│   ├── 01-bigdata-overview.md # 大数据概论
│   ├── 02-hdfs.md             # HDFS 原理与操作
│   └── 03-yarn.md             # YARN 资源调度
├── hadoop/                    # Hadoop 实战
│   ├── README.md
│   ├── config/                # 集群配置文件
│   │   ├── core-site.xml
│   │   ├── hdfs-site.xml
│   │   ├── mapred-site.xml
│   │   ├── yarn-site.xml
│   │   └── workers
│   ├── scripts/               # Shell 运维脚本
│   │   ├── myhadoop.sh        # 集群一键启停
│   │   ├── jpsall.sh          # 查看所有节点进程
│   │   ├── xcall.sh           # 批量执行命令
│   │   ├── xsync.sh           # 批量分发文件
│   │   └── xsu.sh             # 批量切换用户
│   ├── hdfs-api/              # 【Java】HDFS API 示例
│   │   ├── pom.xml
│   │   ├── run_hdfs_api.sh
│   │   ├── README.md
│   │   └── src/main/java/com/atguigu/hdfs/HdfsClient.java
│   └── wordcount/             # 【Java】MapReduce 词频统计
│       ├── pom.xml
│       ├── run_wordcount.sh
│       ├── input/word.txt
│       └── src/main/java/com/atguigu/mapreduce/wordcount/WordCount.java
└── hive/                      # Hive 数据仓库实战
    ├── README.md
    ├── config/hive-site.xml
    ├── data/                  # 测试数据集
    └── sql_scripts/           # DDL / DML / DQL 三段式脚本
        ├── 01_ddl_create_tables.sql
        ├── 02_dml_load_data.sql
        └── 03_dql_analysis.sql
```

## 实验环境

| 项目 | 配置 |
|:---|:---|
| 集群规模 | 3 节点（hadoop102 / hadoop103 / hadoop104） |
| 操作系统 | CentOS 7 |
| JDK | 1.8.0_212 |
| Hadoop | 3.3.4 |
| Hive | 3.1.3 |

节点角色分配：

| 节点 | HDFS | YARN | 其他 |
|:---|:---|:---|:---|
| hadoop102 | NameNode、DataNode | NodeManager | HistoryServer |
| hadoop103 | DataNode | **ResourceManager**、NodeManager | |
| hadoop104 | DataNode、**SecondaryNameNode** | NodeManager | |

## 快速开始

### 1. 部署集群

把 [hadoop/config](hadoop/config) 里的配置文件放到 `$HADOOP_HOME/etc/hadoop/`，然后分发到其他节点：

```bash
bash hadoop/scripts/xsync.sh /opt/module/hadoop-3.3.4/etc/hadoop/
```

### 2. 启动与停止

```bash
# 首次启动前需要格式化 NameNode
hdfs namenode -format

# 一键启动 / 停止 / 重启 / 查看状态
bash hadoop/scripts/myhadoop.sh start
bash hadoop/scripts/myhadoop.sh status
bash hadoop/scripts/myhadoop.sh stop
```

### 3. 运行 HDFS Java API 示例

```bash
cd hadoop/hdfs-api
bash run_hdfs_api.sh
```

脚本会自动取 `hadoop classpath`、编译源码、运行示例。覆盖创建目录、上传下载、重命名、遍历、读写等 10 个操作。

### 4. 运行 WordCount

包含完整的 Mapper / Reducer / Driver 源码，脚本会编译打包后再提交任务：

```bash
cd hadoop/wordcount
bash run_wordcount.sh
```

### 5. 运行 Hive 实战

**在仓库根目录执行**（脚本内使用相对路径引用数据文件）：

```bash
hive -f hive/sql_scripts/01_ddl_create_tables.sql   # 建表
hive -f hive/sql_scripts/02_dml_load_data.sql      # 加载数据
hive -f hive/sql_scripts/03_dql_analysis.sql       # 查询分析
```

## 笔记预览

### HDFS 架构要点

- **NameNode**：管理命名空间和元数据，不存实际数据
- **DataNode**：存储实际数据块，默认 128MB 一块
- **SecondaryNameNode**：定期合并 fsimage 和 edits，**不是 NameNode 的备份**

### YARN 调度器对比

| 调度器 | 特点 | 适用场景 |
|:---|:---|:---|
| FIFO | 先提交先执行，简单 | 单用户测试 |
| Capacity | 多队列，每队列保底资源 | 多部门共享集群 |
| Fair | 动态均衡，按需分配 | 多用户混合负载 |

### Hive 常用优化手段

- **分区裁剪**：`WHERE day = 'xxx'` 只扫描对应分区
- **列裁剪**：避免 `SELECT *`，只取需要的列
- **数据倾斜处理**：加盐打散、map join、过滤无效 key

### HDFS Java API 两个易踩的坑

- **获取 FileSystem 时如果不指定 URI 和用户**，且 classpath 里没有 `core-site.xml`，会**静默连到本地文件系统**——你以为写进了 HDFS，其实写到了本地磁盘
- **HDFS 权限校验基于用户名，不是操作系统权限**。用 root 操作属主为 `atguigu` 的目录会直接报 `AccessControlException`

完整内容见 [docs](docs) 目录和 [hadoop/README.md](hadoop/README.md)。

## 踩坑与说明

- 配置文件中的路径基于 `hadoop-3.3.4`，如果你的版本不同，请全局替换
- `hive/data/product_info_sample.txt` 是 5000 行的**样本数据**，仅用于演示；完整数据集未纳入版本控制
- 所有 shell 脚本使用 LF 换行符，克隆到 Windows 后建议确认换行符设置

## License

MIT
