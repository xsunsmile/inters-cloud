#!/bin/bash
set -e
set -u

source $temp_env/include

scp -o ConnectTimeout=3 -F $ssh_config -pr $inters_home/upload "$CLUSTER_NAME$hostnum":.
ssh -o ConnectTimeout=3 -F $ssh_config "$CLUSTER_NAME$hostnum" \
"nohup nice -19 sudo ./upload/install.sh </dev/null 2>&1>nohup.out &"

