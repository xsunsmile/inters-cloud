#!/bin/bash
set -u
set -e

source $temp_env/include

makechanges=false
puppet_master_ip_file="$HOME/upload/tasks/puppet/01_update.sh"
grep -qFx "^real_master='$elastic_ip'" $puppet_master_ip_file || makechanges=true
if $makechanges; then
	sed -i "/^real_master/d" $puppet_master_ip_file
	sed -i "3ireal_master='$elastic_ip';" $puppet_master_ip_file
fi

[ "$hostnum" != 1 ] && exit 0

cluster_csv="$HOME/upload/tasks/puppet/manifests/extdata/common.csv"
[ -e $cluster_csv ] && rm -rf $cluster_csv
mongodb_repo="deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"

echo "mongodb_repo,$mongodb_repo" | tee -a $cluster_csv
echo "mongodb_host,$elastic_ip" | tee -a $cluster_csv
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
echo "tinc_vpn_master,$CLUSTER_NAME$hostnum${CLUSTER_DOMAIN//\./}" | tee -a $cluster_csv

