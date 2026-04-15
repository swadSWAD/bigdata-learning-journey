#!/bin/bash

# 这个脚本用于一键启动/停止 Hadoop 集群 (HDFS + YARN + HistoryServer)
# 使用方式: myhadoop.sh start | stop | status

# 1. 定义颜色变量，让输出更好看（可选，但推荐）
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 2. 判断输入的参数
if [ $# -lt 1 ]
then
    echo "----------------------------------------"
    echo "Error: 参数个数不足，请输入 start, stop 或 status"
    echo "Usage: myhadoop.sh {start|stop|status}"
    echo "----------------------------------------"
    exit 1
fi

# 3. 核心逻辑：根据参数执行不同操作
case $1 in
"start")
    echo -e "${GREEN}---------- 启动 HDFS ----------${NC}"
    # 启动 NameNode, DataNode, SecondaryNameNode
    /opt/module/hadoop-3.1.3/sbin/start-dfs.sh

    echo -e "${GREEN}---------- 启动 YARN ----------${NC}"
    # 启动 ResourceManager, NodeManager
    /opt/module/hadoop-3.1.3/sbin/start-yarn.sh

    echo -e "${GREEN}---------- 启动 HistoryServer ----------${NC}"
    # 启动日志聚合服务（查看运行过的任务日志用）
    /opt/module/hadoop-3.1.3/bin/mapred --daemon start historyserver
    ;;
"stop")
    echo -e "${RED}---------- 停止 HistoryServer ----------${NC}"
    /opt/module/hadoop-3.1.3/bin/mapred --daemon stop historyserver

    echo -e "${RED}---------- 停止 YARN ----------${NC}"
    /opt/module/hadoop-3.1.3/sbin/stop-yarn.sh

    echo -e "${RED}---------- 停止 HDFS ----------${NC}"
    /opt/module/hadoop-3.1.3/sbin/stop-dfs.sh
    ;;
"status")
    echo -e "${GREEN}---------- 查看集群进程状态 ----------${NC}"
    # 这里假设你配置了 jpsall 脚本，如果没有，可以直接写 jps
    # 如果没有 jpsall，建议直接调用 jps 看看本机，或者写一个循环 ssh 查看
    jpsall
    ;;
*)
    echo "----------------------------------------"
    echo "Error: 参数错误，请输入 start, stop 或 status"
    echo "Usage: myhadoop.sh {start|stop|status}"
    echo "----------------------------------------"
    exit 1
    ;;
esac
