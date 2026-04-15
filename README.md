# bigdata-learning-journey
记录大数据技术栈（Hadoop, HDFS, Yarn）的学习过程与实战代码。包含环境搭建脚本、Java API 操作示例及生产调优笔记。
# 大数据学习之旅

> 记录从 0 到 1 掌握大数据技术栈（Hadoop, HDFS, Yarn, MapReduce）的学习过程与实战代码。

##学习路线与笔记

### 1. 大数据概论
- **核心概念**：理解大数据的 4V 特点（大量、高速、多样、价值）。
- **技术生态**：Hadoop 发展史、生态圈组件（HDFS, Yarn, MapReduce, Zookeeper 等）。
- **行业分析**：大数据在“新基建”中的地位及职业发展路径分析。

### 2. HDFS 分布式文件系统
- **架构原理**：NameNode 与 DataNode 工作机制。
- **API 操作**：使用 Java API 进行文件的增删改查。
- **生产调优**：NameNode 内存管理、心跳机制参数调优。

### 3. Yarn 资源调度器
- **调度策略**：FIFO、容量调度器、公平调度器。
- **任务提交流程**：从客户端提交到 Container 分配的全过程解析。

---

## 项目实战
- **自动化运维脚本**：编写 Shell 脚本实现集群的一键启停与分发。
- **MapReduce 案例**：WordCount 词频统计实战。
