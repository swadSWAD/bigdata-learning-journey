#!/bin/bash
# ==========================================================
# Hadoop 集群一键启停脚本
# 用法: myhadoop.sh {start|stop|restart|status}
# ==========================================================
HADOOP_HOME=/opt/module/hadoop-3.3.4

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

if [ $# -lt 1 ]; then
    echo "Usage: myhadoop.sh {start|stop|restart|status}"
    exit 1
fi

start_all() {
    echo -e "${GREEN}---------- 启动 HDFS ----------${NC}"
    $HADOOP_HOME/sbin/start-dfs.sh

    echo -e "${GREEN}---------- 启动 YARN ----------${NC}"
    $HADOOP_HOME/sbin/start-yarn.sh

    echo -e "${GREEN}---------- 启动 HistoryServer ----------${NC}"
    $HADOOP_HOME/bin/mapred --daemon start historyserver
}

stop_all() {
    echo -e "${RED}---------- 停止 HistoryServer ----------${NC}"
    $HADOOP_HOME/bin/mapred --daemon stop historyserver

    echo -e "${RED}---------- 停止 YARN ----------${NC}"
    $HADOOP_HOME/sbin/stop-yarn.sh

    echo -e "${RED}---------- 停止 HDFS ----------${NC}"
    $HADOOP_HOME/sbin/stop-dfs.sh
}

case $1 in
"start")   start_all ;;
"stop")    stop_all ;;
"restart") stop_all; sleep 3; start_all ;;
"status")  echo -e "${GREEN}---------- 集群进程状态 ----------${NC}"; jpsall ;;
*)         echo "Usage: myhadoop.sh {start|stop|restart|status}"; exit 1 ;;
esac
