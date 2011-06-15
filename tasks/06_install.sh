#!/bin/bash
set -e
set -u

source $temp_env/include

sudo_user="ubuntu"
access_ip=$inst_pubip
[ "$hostnum" = 1 ] && access_ip=$elastic_ip

chmod +x $inters_home/upload/install.sh

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=30"
COMMAND="mkdir .ec2"
ssh $SSH_OPTS $sudo_user@$access_ip -i $inters_home/share/$CLUSTER_NAME $COMMAND || true

dest_dir="."
upload_dir="$inters_home/upload";
scp -i $inters_home/share/$CLUSTER_NAME -pr $upload_dir $sudo_user@$access_ip:$dest_dir

dest_dir=".ec2/"
for upload_dir in "$EC2_HOME/cert-$CLUSTER_NAME.pem" "$EC2_HOME/pk-$CLUSTER_NAME.pem" "$EC2_HOME/bin" "$EC2_HOME/lib"
do
	scp -i $inters_home/share/$CLUSTER_NAME -pr $upload_dir $sudo_user@$access_ip:$dest_dir
done

COMMAND="nohup nice -19 bash upload/install.sh </dev/null 2>&1>nohup.out &"
ssh $SSH_OPTS $sudo_user@$access_ip -i $inters_home/share/$CLUSTER_NAME "$COMMAND"

