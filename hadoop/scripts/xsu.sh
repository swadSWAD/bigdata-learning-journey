#!/bin/bash
# ==========================================================
# 在所有节点切换到指定用户
# 用法: xsu.sh atguigu
# ==========================================================
if [ $# -lt 1 ]; then
    echo "Usage: xsu.sh <username>"
    exit 1
fi

for host in hadoop102 hadoop103 hadoop104
do
    echo "==================== $host ===================="
    ssh $host "su - $1"
done
