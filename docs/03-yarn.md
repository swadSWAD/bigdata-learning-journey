# 03 · YARN 资源调度

## 为什么要 YARN

Hadoop 1.x 时代，MapReduce 既要管计算又要管资源，导致：

- 单点瓶颈：JobTracker 压力过大
- 资源利用率低：只有 MR 一种计算框架能用集群
- 扩展性差：集群规模上不去

YARN 把**资源管理**和**计算框架**解耦，让 Spark、Flink、MR 都能跑在同一个集群上。

## 架构组成

```
        ┌───────────────────────────────────┐
        │   ResourceManager (hadoop103)     │
        │   全局资源调度 / 分配 Container    │
        └───────────────┬───────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
  ┌───────────┐  ┌───────────┐  ┌───────────┐
  │NodeManager│  │NodeManager│  │NodeManager│  单节点资源管理
  │    102    │  │    103    │  │    104    │  启动/监控 Container
  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
        │              │              │
   ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
   │Container│    │Container│    │Container│  资源容器
   │ (AppMaster)              │  (Task)   │
   └─────────┘    └─────────┘    └─────────┘
```

| 角色 | 职责 |
|:---|:---|
| **ResourceManager** | 全局资源管理，调度集群所有资源 |
| **NodeManager** | 单节点资源管理，启动和监控 Container |
| **ApplicationMaster** | 每个应用一个，负责向 RM 申请资源、与 NM 通信 |
| **Container** | 资源的抽象，封装了 CPU 和内存 |

## 三种调度器

| 调度器 | 策略 | 优点 | 缺点 | 适用场景 |
|:---|:---|:---|:---|:---|
| **FIFO** | 先提交先执行 | 实现简单 | 大任务会阻塞后续所有任务 | 单用户测试 |
| **Capacity** | 多队列，每队列保底资源 | 资源隔离好，保证部门配额 | 队列配置繁琐 | 多部门共享集群 |
| **Fair** | 动态均衡，按需分配 | 小任务不会被饿死 | 调度开销较大 | 多用户混合负载 |

> Apache Hadoop 默认是 **Capacity Scheduler**。

## 任务提交流程

以 `hadoop jar xxx.jar` 提交 MapReduce 任务为例：

1. **提交**：客户端向 ResourceManager 申请一个 Application
2. **启动 AppMaster**：RM 分配一个 Container，在其中启动 ApplicationMaster
3. **申请资源**：AppMaster 根据任务需要，向 RM 申请运行 Task 的 Container
4. **分发任务**：RM 把可用 Container 分配给 AppMaster，AppMaster 通知对应 NodeManager 启动 Task
5. **执行**：Task 在 Container 中运行，向 AppMaster 汇报进度
6. **回收**：所有 Task 完成后，AppMaster 向 RM 注销，Container 回收

## 常用命令

```bash
# 查看正在运行的应用
yarn application -list

# 查看所有应用（含已完成）
yarn application -list -appStates ALL

# 查看应用状态
yarn application -status application_1234567890_0001

# 杀掉应用
yarn application -kill application_1234567890_0001

# 查看日志
yarn logs -applicationId application_1234567890_0001

# 查看节点状态
yarn node -list

# 查看队列
yarn queue -status default
```

## 日志聚集

默认情况下，任务结束后日志保存在各个 NodeManager 的本地磁盘，查看历史任务日志很不方便。开启日志聚集后，日志会集中上传到 HDFS。

```xml
<property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
</property>
<property>
    <name>yarn.log-aggregation.retain-seconds</name>
    <value>604800</value>   <!-- 日志保留 7 天 -->
</property>
```

开启后配合 HistoryServer 使用：

```bash
mapred --daemon start historyserver
# 访问 http://hadoop102:19888 查看历史任务
```

## 常见故障排查

| 现象 | 可能原因 | 排查方向 |
|:---|:---|:---|
| 任务一直卡在 ACCEPTED | 集群资源不足 | `yarn node -list` 看可用资源 |
| 任务卡在 99% | 数据倾斜，个别 task 慢 | 看 Web UI 各 task 耗时 |
| Container 被 kill | 内存超限 | 看 `yarn.nodemanager.resource.memory-mb` |
| 无法提交任务 | RM 未启动 | `jps` 检查 ResourceManager 进程 |
