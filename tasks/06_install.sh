#!/bin/bash
set -e
set -u

source $temp_env/include

chmod +x $inters_home/upload/install.sh
scp -F $ssh_config -pr $inters_home/upload "$CLUSTER_NAME$hostnum":.

ssh -o ConnectTimeout=3 -F $ssh_config "$CLUSTER_NAME$hostnum" "[ ! -e .ec2 ] && mkdir .ec2"
scp -F $ssh_config -pr $EC2_HOME/{cert,pk}-$CLUSTER_NAME.pem "$CLUSTER_NAME$hostnum":.ec2/
scp -F $ssh_config -pr $EC2_HOME/{bin,lib} "$CLUSTER_NAME$hostnum":.ec2/

ssh -o ConnectTimeout=3 -F $ssh_config "$CLUSTER_NAME$hostnum" \
"nohup nice -19 sudo bash upload/install.sh </dev/null 2>&1>nohup.out &"

