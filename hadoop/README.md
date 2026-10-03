# Hadoop 实战

Hadoop 集群的配置、运维脚本与 MapReduce 实践。

## 集群配置说明

| 配置文件 | 作用 | 关键配置项 |
|:---|:---|:---|
| `core-site.xml` | 全局配置 | `fs.defaultFS` 指定 NameNode 地址 |
| `hdfs-site.xml` | HDFS 配置 | `dfs.replication` 副本数、SecondaryNameNode 地址 |
| `mapred-site.xml` | MR 配置 | `mapreduce.framework.name=yarn` 指定运行在 YARN 上 |
| `yarn-site.xml` | YARN 配置 | ResourceManager 地址、日志聚集 |
| `workers` | 从节点列表 | 列出所有 DataNode / NodeManager 节点 |

### 几点说明

**副本数**：`dfs.replication` 在 3 节点集群中设为 3，保证每个数据块有 3 份。默认值也是 3，但如果节点数少于 3 必须调小，否则会一直报副本不足。

**日志聚集**：`yarn.log-aggregation-enable=true` 开启后，任务结束后日志会上传到 HDFS，可以通过 HistoryServer 网页查看历史任务日志。生产环境必开。

**SecondaryNameNode 不是备份**：它只负责定期合并 `fsimage` 和 `edits`，减轻 NameNode 启动时的压力。NameNode 挂了它并不能顶上，真正的 HA 需要部署两个 NameNode + JournalNode。

## 运维脚本

| 脚本 | 用途 | 用法 |
|:---|:---|:---|
| `myhadoop.sh` | 集群一键启停 | `bash myhadoop.sh {start\|stop\|restart\|status}` |
| `jpsall.sh` | 查看所有节点的 Java 进程 | `bash jpsall.sh` |
| `xcall.sh` | 在所有节点批量执行同一命令 | `bash xcall.sh jps` |
| `xsync.sh` | 把文件分发到所有节点 | `bash xsync.sh /path/to/file` |
| `xsu.sh` | 在所有节点切换到指定用户 | `bash xsu.sh atguigu` |

> `xsync.sh` 依赖 `rsync`，如果没装先执行 `yum install -y rsync`。

## WordCount 实战

```bash
bash wordcount/run_wordcount.sh
```

脚本流程：创建 HDFS 目录 → 上传输入文件 → 清理旧输出目录 → 提交 MapReduce 任务 → 打印结果。

> MapReduce 不允许输出目录已存在，所以重复运行前必须 `hadoop fs -rm -r /output`，脚本里已经处理了。
