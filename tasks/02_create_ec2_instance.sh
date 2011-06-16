#!/bin/bash
set -e
set -u

source $temp_env/include
cd $inters_home
echo "use DB: $DBNAME"

max_wait=60
current_dir=`dirname $0`

set +e
while :
do
	echo "create image from $ami_id"
	instance_id=`ec2-run-instances $ami_id -t $inst_type -k $keypair | grep ^INS | awk '{print $2}'`
	echo "allocate new instance: $instance_id"
	
	inst_info=`ec2-describe-instances $instance_id`
	echo "inst_info: $inst_info"
	inst_pubip=`echo $inst_info | awk '{print $18}'`
	echo "inst_pubip: $inst_pubip"
	is_ipaddress=`expr "$inst_pubip" : '\([0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\)'`
	echo "is_ipaddress: $is_ipaddress"
	
	while [ $max_wait -gt 0 -a ${#is_ipaddress} -eq 0 ];
	do
		sleep 1;
		max_wait=$((max_wait-1))
		echo "#left retry: $max_wait"
		inst_info=`ec2-describe-instances $instance_id`
		echo "inst_info: $inst_info"
		inst_pubip=`echo $inst_info | awk '{print $18}'`
		echo "inst_pubip: $inst_pubip"
		is_ipaddress=`expr "$inst_pubip" : '\([0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\)'`
		echo "is_ipaddress: $is_ipaddress"
	done
	
	if [ ${#is_ipaddress} -eq 0 ]; then
		echo "ec2-terminate-instance $instance_id"
		ec2-terminate-instances $instance_id
	else
		break
	fi
done
set -e

hostnum=`ruby $current_dir/02_sqlite3.rb $DBNAME get_hostnum`
echo "hostnum is $hostnum"

vpn_hostaddr=$(($hostnum+20))
vpn_addr=$vpn_netaddr$vpn_hostaddr
hostname="$CLUSTER_NAME$hostnum.$CLUSTER_DOMAIN"

cat <<EOF > $temp_env/host_settings.sh
hostnum="$hostnum"
hostname="$hostname"
instance_id="$instance_id"
inst_pubip="$inst_pubip"
vpn_addr="$vpn_addr"
EOF

ruby $current_dir/02_sqlite3.rb $DBNAME add_hostinfo $temp_env

