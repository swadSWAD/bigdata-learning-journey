#!/bin/bash
# ==========================================================
# 编译并运行 HDFS Java API 示例
# 用法: bash run_hdfs_api.sh
# 前置条件: 集群已启动，且当前用户对 HDFS 有读写权限
# ==========================================================
set -e

HADOOP_HOME=/opt/module/hadoop-3.3.4
SCRIPT_DIR=$(cd -P "$(dirname "$0")" && pwd)
SRC_DIR=$SCRIPT_DIR/src/main/java
OUT_DIR=$SCRIPT_DIR/target/classes

mkdir -p "$OUT_DIR"

# 1. 取 Hadoop 的依赖 classpath
CP=$(hadoop classpath)

# 2. 编译
echo "---------- 编译 ----------"
javac -encoding UTF-8 -cp "$CP" -d "$OUT_DIR" \
    "$SRC_DIR/com/atguigu/hdfs/HdfsClient.java"

# 3. 运行
echo ""
echo "---------- 运行 ----------"
# 把 core-site.xml / hdfs-site.xml 加入 classpath，便于读取集群配置
CONF_DIR=$HADOOP_HOME/etc/hadoop
java -cp "$OUT_DIR:$CP:$CONF_DIR" com.atguigu.hdfs.HdfsClient

echo ""
echo "---------- 完成 ----------"
