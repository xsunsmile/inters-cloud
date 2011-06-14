#!/bin/bash
set -e
set -u

source $temp_env/include

ec2-create-tags $instance_id \
	-t Name="$CLUSTER_NAME$hostnum" \
	-t VPN-Role=vpn-slave \
	-t VPN-Address="$vpn_addr" \
	-t LRM-Role=torque-slave

if [ $hostnum -eq 1 ]; then
	master_instid=$instance_id
	echo "found master: $master_instid, $elastic_ip "
	ec2-create-tags $instance_id \
	-t LRM-Role=torque-master \
	-t ElasticIP=$elastic_ip \
	-t VPN-Role=vpn-master
fi


