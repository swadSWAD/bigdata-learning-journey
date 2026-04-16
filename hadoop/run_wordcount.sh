#!/bin/bash

# 1. 创建 HDFS 输入目录
hadoop fs -mkdir -p /input

# 2. 上传本地文件到 HDFS
# 假设你的本地文件路径是 wordcount/input/word.txt
hadoop fs -put wordcount/input/word.txt /input

# 3. 运行 MapReduce 任务 (WordCount)
# 注意：路径需根据你实际安装的 Hadoop 版本调整
hadoop jar /opt/module/hadoop-3.1.3/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.3.jar wordcount /input /output

# 4. 查看输出结果
echo "----------------- 输出结果 -----------------"
hadoop fs -cat /output/*
