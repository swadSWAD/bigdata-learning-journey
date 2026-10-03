#!/bin/bash
# ==========================================================
# 集群文件同步：把本地文件分发到所有节点的相同路径
# 用法: xsync.sh /opt/module/hadoop-3.3.4/etc/hadoop/
# ==========================================================
if [ $# -lt 1 ]; then
    echo "Usage: xsync.sh <file_or_dir> [...]"
    exit 1
fi

for host in hadoop102 hadoop103 hadoop104
do
    # 跳过本机，避免自己同步给自己
    if [ "$host" = "$(hostname)" ]; then
        continue
    fi
    echo "==================== $host ===================="
    for file in "$@"
    do
        if [ -e "$file" ]; then
            pdir=$(cd -P "$(dirname "$file")" && pwd)
            fname=$(basename "$file")
            ssh $host "mkdir -p $pdir"
            rsync -av "$pdir/$fname" "$host:$pdir"
        else
            echo "$file does not exist!"
        fi
    done
done
