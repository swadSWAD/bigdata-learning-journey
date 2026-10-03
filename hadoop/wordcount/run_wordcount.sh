#!/bin/bash
# ==========================================================
# WordCount 示例：把本地文本上传到 HDFS 并运行词频统计
# 用法: bash run_wordcount.sh
# ==========================================================
set -e

HADOOP_HOME=/opt/module/hadoop-3.3.4
HADOOP_VERSION=3.3.4
SCRIPT_DIR=$(cd -P "$(dirname "$0")" && pwd)

# 1. 创建 HDFS 输入目录并上传数据
hadoop fs -mkdir -p /input
hadoop fs -put -f "$SCRIPT_DIR/input/word.txt" /input

# 2. 清理上一次的输出目录（MapReduce 不允许输出目录已存在）
hadoop fs -rm -r -f /output

# 3. 运行官方 WordCount 示例
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-$HADOOP_VERSION.jar \
    wordcount /input /output

# 4. 查看结果
echo "----------------- 输出结果 -----------------"
hadoop fs -cat /output/part-r-*
