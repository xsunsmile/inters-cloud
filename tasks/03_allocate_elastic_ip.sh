#!/bin/bash
set -e
set -u

source $temp_env/include

[ $hostnum -ne 1 ] && exit 0
pub_ip=`ec2-describe-addresses | awk '{print $2}'`
if [ -z "$pub_ip" ]; then
	pub_ip=`ec2-allocate-address | awk '{print $2}'`
	echo "allocate new ip: $pub_ip"
fi
old_ip=`sqlite3 $DBNAME "select distinct value from cluster where prop='elastic_ip'"`
if [ "$old_ip" != "$pub_ip" ]; then
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('elastic_ip','$pub_ip');"
fi
master_instid=`sqlite3 $DBNAME "select instance_id from instances where prop='hostnum' and value='1';"`
ec2-associate-address $pub_ip -i $master_instid

cat <<IP > $temp_env/ip_settings.sh
elastic_ip='$pub_ip'
IP

