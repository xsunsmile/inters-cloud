#!/bin/bash
set -u

DBNAME=$(basename `ls $HOME/db/*_db`)
CLUSTER_NAME=$(echo $DBNAME | awk -F_ '{print $1}')
CLUSTER_DOMAIN=$(echo $DBNAME | awk -F_ '{print $2}')
DBPATH=$HOME/db/${CLUSTER_NAME}_${CLUSTER_DOMAIN}_db

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
hostname_f=`sqlite3 $DBNAME "select hostname from instances where instance_id=$instance_id"`;

cluters_csv="$HOME/upload/puppet/manifests/extdata/$hostname_f.csv"
[ -e $cluster_csv ] && rm -rf $cluster_csv
mongodb_repo="deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
echo "mongodb_repo,$mongodb_repo" | tee -a $cluster_csv
echo "mongodb_version,1.8.1" | tee -a $cluster_csv
echo "mongodb_install_src,/tmp/mongodb" | tee -a $cluster_csv
echo "torque_install_dist,/usr/local" | tee -a $cluster_csv
echo "torque_install_src,/tmp/torque" | tee -a $cluster_csv
echo "torque_admin,root" | tee -a $cluster_csv
echo "torque_master_name,${CLUSTER_NAME}1" | tee -a $cluster_csv
echo "torque_version,2.5.5" | tee -a $cluster_csv
echo "torque_complie_args_extra," | tee -a $cluster_csv
echo "torque_spool_dir," | tee -a $cluster_csv
echo "torque_user_not_root,ubuntu" | tee -a $cluster_csv
echo "hostname_s," | tee -a $cluster_csv

