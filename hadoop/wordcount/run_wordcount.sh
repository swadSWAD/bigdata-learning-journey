#!/bin/bash
# ==========================================================
# WordCount 完整流程：编译源码 -> 打包 -> 上传数据 -> 提交任务
# 用法: bash run_wordcount.sh
# ==========================================================
set -e

HADOOP_HOME=/opt/module/hadoop-3.3.4
SCRIPT_DIR=$(cd -P "$(dirname "$0")" && pwd)
SRC_DIR=$SCRIPT_DIR/src/main/java
OUT_DIR=$SCRIPT_DIR/target/classes
JAR_FILE=$SCRIPT_DIR/target/wordcount.jar

mkdir -p "$OUT_DIR" "$SCRIPT_DIR/target"

# ---------- 1. 编译 ----------
echo "---------- 1. 编译 Java 源码 ----------"
CP=$(hadoop classpath)
javac -encoding UTF-8 -cp "$CP" -d "$OUT_DIR" \
    "$SRC_DIR/com/atguigu/mapreduce/wordcount/WordCount.java"

# ---------- 2. 打包 ----------
echo ""
echo "---------- 2. 打包成 jar ----------"
jar -cvf "$JAR_FILE" -C "$OUT_DIR" .

# ---------- 3. 准备 HDFS 输入 ----------
echo ""
echo "---------- 3. 准备 HDFS 输入数据 ----------"
hadoop fs -mkdir -p /input
hadoop fs -put -f "$SCRIPT_DIR/input/word.txt" /input

# MapReduce 不允许输出目录已存在，重复运行前必须清理
hadoop fs -rm -r -f /output

# ---------- 4. 提交任务 ----------
echo ""
echo "---------- 4. 提交 MapReduce 任务 ----------"
hadoop jar "$JAR_FILE" \
    com.atguigu.mapreduce.wordcount.WordCount \
    /input /output

# ---------- 5. 查看结果 ----------
echo ""
echo "---------- 5. 输出结果 ----------"
hadoop fs -cat /output/part-r-*
