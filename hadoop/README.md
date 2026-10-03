# Hadoop 实战

Hadoop 集群配置、运维脚本、以及 **HDFS Java API** 与 **MapReduce** 的编码实践。

## 目录结构

```
hadoop/
├── config/                 # 集群配置文件
│   ├── core-site.xml
│   ├── hdfs-site.xml
│   ├── mapred-site.xml
│   ├── yarn-site.xml
│   └── workers
├── scripts/                # Shell 运维脚本
│   ├── myhadoop.sh
│   ├── jpsall.sh
│   ├── xcall.sh
│   ├── xsync.sh
│   └── xsu.sh
├── hdfs-api/               # 【Java】HDFS Java API 示例
│   ├── pom.xml
│   ├── run_hdfs_api.sh
│   ├── README.md
│   └── src/main/java/com/atguigu/hdfs/HdfsClient.java
└── wordcount/              # 【Java】MapReduce 词频统计
    ├── pom.xml
    ├── run_wordcount.sh
    ├── input/word.txt
    └── src/main/java/com/atguigu/mapreduce/wordcount/WordCount.java
```

## 一、集群配置

| 配置文件 | 作用 | 关键配置项 |
|:---|:---|:---|
| `core-site.xml` | 全局配置 | `fs.defaultFS` 指定 NameNode 地址 |
| `hdfs-site.xml` | HDFS 配置 | `dfs.replication` 副本数、SecondaryNameNode 地址 |
| `mapred-site.xml` | MR 配置 | `mapreduce.framework.name=yarn` 指定运行在 YARN 上 |
| `yarn-site.xml` | YARN 配置 | ResourceManager 地址、日志聚集 |
| `workers` | 从节点列表 | 列出所有 DataNode / NodeManager 节点 |

### 几点说明

**副本数**：`dfs.replication` 在 3 节点集群中设为 3，保证每个数据块有 3 份。如果节点数少于 3 必须调小，否则会一直报副本不足。

**日志聚集**：`yarn.log-aggregation-enable=true` 开启后，任务结束后日志会上传到 HDFS，可以通过 HistoryServer 网页查看历史任务日志。生产环境必开。

**SecondaryNameNode 不是备份**：它只负责定期合并 `fsimage` 和 `edits`，减轻 NameNode 启动时的压力。NameNode 挂了它并不能顶上，真正的 HA 需要部署两个 NameNode + JournalNode。

## 二、运维脚本

| 脚本 | 用途 | 用法 |
|:---|:---|:---|
| `myhadoop.sh` | 集群一键启停 | `bash myhadoop.sh {start\|stop\|restart\|status}` |
| `jpsall.sh` | 查看所有节点的 Java 进程 | `bash jpsall.sh` |
| `xcall.sh` | 在所有节点批量执行同一命令 | `bash xcall.sh jps` |
| `xsync.sh` | 把文件分发到所有节点 | `bash xsync.sh /path/to/file` |
| `xsu.sh` | 在所有节点切换到指定用户 | `bash xsu.sh atguigu` |

> `xsync.sh` 依赖 `rsync`，如果没装先执行 `yum install -y rsync`。

## 三、HDFS Java API

用 Java 客户端操作 HDFS，覆盖 10 个常用操作：创建目录、上传、下载、删除、重命名、遍历、读取、获取详情、写入、追加。

```bash
cd hdfs-api
bash run_hdfs_api.sh
```

详细说明见 [hdfs-api/README.md](hdfs-api/README.md)。

### 核心要点

**1. 获取 FileSystem 对象**

```java
// 推荐：显式指定 URI 和用户，不依赖配置文件
FileSystem fs = FileSystem.get(URI.create("hdfs://hadoop102:8020"), conf, "atguigu");

// 依赖 core-site.xml；如果 classpath 里没有该文件，会静默连到本地文件系统
FileSystem fs = FileSystem.get(conf);
```

第二种方式的坑：**不会报错**，你以为写进了 HDFS，其实写到了本地磁盘。

**2. 用户身份必须是 HDFS 超级用户**

HDFS 的权限校验基于**用户名**，不是操作系统权限。用 root 操作属主为 `atguigu` 的目录会直接报：

```
AccessControlException: Permission denied: user=root, access=WRITE, inode="/":atguigu:supergroup:drwxr-xr-x
```

## 四、MapReduce 实战

经典的词频统计，包含完整的 Mapper / Reducer / Driver 三段式代码。

```bash
cd wordcount
bash run_wordcount.sh
```

脚本会依次执行：编译源码 → 打包 jar → 上传输入数据 → 提交任务 → 打印结果。

### 代码结构

| 部分 | 类 | 职责 |
|:---|:---|:---|
| Mapper | `TokenizerMapper` | 把每行文本切成单词，输出 `(word, 1)` |
| Reducer | `IntSumReducer` | 把相同单词的计数累加 |
| Driver | `main` | 配置 Job 并提交 |

### 几个关键点

**为什么用 `Text` 而不是 `String`？**
Hadoop 的序列化框架要求使用 `Writable` 类型。`Text` 是 `String` 的序列化封装，能直接参与网络传输和落盘。

**Combiner 的作用**

```java
job.setCombinerClass(IntSumReducer.class);
```

Combiner 在 **Map 端**先做一次局部聚合，把 `(hello,1) (hello,1) (hello,1)` 合并成 `(hello,3)` 再发给 Reduce，大幅减少网络传输量。

> Combiner 不是必须的，且**不能随便用**——只有当操作满足结合律和交换律（如求和、求最大值）时才能用，求平均值就不行。

**输出目录必须不存在**

MapReduce 不允许输出目录已存在，重复运行会报 `FileAlreadyExistsException`。脚本里已经加了 `hadoop fs -rm -r -f /output`。
