#!/bin/bash
# ==========================================================
# 在集群所有节点批量执行命令
# 用法: xcall.sh jps
# ==========================================================
if [ $# -lt 1 ]; then
    echo "Usage: xcall.sh <command>"
    exit 1
fi

for host in hadoop102 hadoop103 hadoop104
do
    echo "==================== $host ===================="
    ssh $host "$*"
done
