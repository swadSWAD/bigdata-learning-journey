# 02 · HDFS 分布式文件系统

## 架构组成

```
                ┌──────────────┐
   客户端 ────→ │  NameNode    │  管理命名空间与元数据
                │  (hadoop102) │  不存储真实数据
                └──────┬───────┘
                       │ 副本位置信息
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
   ┌─────────┐   ┌─────────┐   ┌─────────┐
   │DataNode │   │DataNode │   │DataNode │  存储真实数据块
   │  102    │   │  103    │   │  104    │  默认 128MB/块
   └─────────┘   └─────────┘   └─────────┘
                                        ↑
                          ┌─────────────────────┐
                          │ SecondaryNameNode   │ 定期合并
                          │      (hadoop104)    │ fsimage + edits
                          └─────────────────────┘
```

### 三个角色的职责

| 角色 | 职责 | 是否单点 |
|:---|:---|:---|
| NameNode | 维护文件系统树、元数据（文件名、权限、块位置） | 是（可做 HA） |
| DataNode | 存储实际数据块，定期向 NameNode 汇报块信息 | 否 |
| SecondaryNameNode | 定期合并 `fsimage` 和 `edits`，**不是热备** | 是 |

**面试高频**：SecondaryNameNode 不是 NameNode 的备份。它只做 checkpoint——把 `edits` 日志合并进 `fsimage`，缩短 NameNode 重启时的恢复时间。NameNode 挂了它顶不上，要做高可用必须部署 NameNode HA。

### 元数据存储

- `fsimage`：元数据的**快照**（某一时刻的全量）
- `edits`：**增量日志**，记录所有写操作
- 合并时机：SecondaryNameNode 定期拉取并合并，或 NameNode 重启时

## 数据块（Block）

- 默认大小：Hadoop 2.x/3.x 为 **128MB**，1.x 为 64MB
- 副本数：默认 **3**
- 为什么块这么大：减少寻址开销，让磁盘传输时间远大于寻道时间

## 读写流程

### 写数据

1. 客户端向 NameNode 请求上传文件
2. NameNode 返回可用的 DataNode 列表
3. 客户端把数据切成块，以 **Pipeline** 方式写入
4. 第一个 DataNode 写完后传给第二个，第二个传给第三个
5. 每个块写完后逐级返回确认（ACK）

### 读数据

1. 客户端向 NameNode 请求读取文件
2. NameNode 返回块的存储位置（按网络距离排序）
3. 客户端就近选择 DataNode 读取

## 常用 Shell 命令

```bash
# 上传 / 下载
hadoop fs -put local.txt /input/
hadoop fs -get /input/local.txt ./

# 查看
hadoop fs -ls /input
hadoop fs -cat /input/local.txt
hadoop fs -du -h /input          # 查看目录大小

# 创建 / 删除
hadoop fs -mkdir -p /input/data
hadoop fs -rm -r /output

# 移动 / 复制
hadoop fs -mv /a.txt /b/
hadoop fs -cp /a.txt /c/

# 权限
hadoop fs -chmod 777 /input
hadoop fs -chown atguigu:atguigu /input

# 查看集群状态
hdfs dfsadmin -report
```

> **注意**：HDFS 的权限校验是基于**用户名**的，不是操作系统权限。用 root 操作 HDFS 时会以 `root` 身份发起请求，如果 HDFS 目录属主是 `atguigu`，就会报 `Permission denied`。解决办法是 `export HADOOP_USER_NAME=atguigu`。

## 生产调优要点

### NameNode 内存

NameNode 把所有元数据放在内存里，**每个文件对象约占 150 字节**。估算公式：

```
NameNode 内存 = (文件数 × 150B) + (块数 × 150B)
```

100 万个文件、每个文件 1 个块，约需 300MB 内存。实际部署要预留 2-3 倍余量。

### 心跳与超时

| 参数 | 默认值 | 说明 |
|:---|:---|:---|
| `dfs.heartbeat.interval` | 3 秒 | DataNode 向 NameNode 汇报的间隔 |
| `dfs.namenode.heartbeat.recheck-interval` | 5 分钟 | 判定 DataNode 失联的检查间隔 |

判定 DataNode 死亡的超时时间：
```
2 × recheck-interval + 10 × heartbeat.interval
= 2 × 300s + 10 × 3s = 630s ≈ 10.5 分钟
```

### 小文件问题

HDFS 不适合存小文件——每个文件无论多小都会占用一个元数据条目。解决办法：

- 写入前做合并（比如 Flume 的 `rollSize` 调大）
- 用 Hive 的 `concatenate` 合并 ORC 小文件
- 归档：`hadoop archive` 打成 HAR 包

## 安全模式

NameNode 启动时会进入安全模式（Safe Mode），此时只读不写。等 DataNode 汇报的块数达到阈值（默认 99.9%）才自动退出。

```bash
hdfs dfsadmin -safemode get      # 查看状态
hdfs dfsadmin -safemode leave    # 手动退出
```
