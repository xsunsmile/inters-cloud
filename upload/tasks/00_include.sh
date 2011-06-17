#!/bin/bash
set -e
set -u

current_dir=`dirname $0`
DBNAME="$current_dir/env.db"
sqlite3 $DBNAME < env.sql

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

CLUSTER_NAME=`sqlite3 $DBNAME "select value from cluster where prop='cluster_name'"`;
CLUSTER_DOMAIN=`sqlite3 $DBNAME "select value from cluster where prop='cluster_domain'"`;
hostname_f=`sqlite3 $DBNAME "select value from instances where instance_id='$instance_id' and prop='hostname'"`;
hostnum=`sqlite3 $DBNAME "select value from instances where instance_id='$instance_id' and prop='hostnum'"`;
vpn_addr=`sqlite3 $DBNAME "select value from instances where instance_id='$instance_id' and prop='vpn_address'"`;
elastic_ip=`sqlite3 $DBNAME "select distinct value from cluster where prop='elastic_ip'"`;
vpn_address_master=`sqlite3 $DBNAME "select distinct value from cluster where prop='vpn_address_master'"`;

cat <<ENV > $temp_env/include
#!/bin/bash

temp_env="$temp_env"
for setting in \$(ls \$temp_env/*sh)
do
	source \$setting
done

ENV

cat <<ENV > $temp_env/00_inters_env.sh
#!/bin/bash

export JAVA_HOME="/usr/lib/jvm/java-6-openjdk"
CLUSTER_NAME="$CLUSTER_NAME"
CLUSTER_DOMAIN="$CLUSTER_DOMAIN"
instance_id="$instance_id"
hostname_f="$hostname_f"
hostnum="$hostnum"
elastic_ip="$elastic_ip"
vpn_addr="$vpn_addr"
vpn_address_master="$vpn_address_master"
ENV

