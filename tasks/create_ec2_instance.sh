#!/bin/bash

instance_id=`ec2-run-instances $ami_id -t $inst_type -k $keypair | grep ^INS | awk '{print $2}'`
echo "allocate new instance: $instance_id"
hostnum=`sqlite3 $DBNAME "select count(*) from instances"`
vpn_hostaddr=$(($host_num+1))
hostname="$CLUSTER_NAME$hostnum.$CLUSTER_DOMAIN"
sqlite3 $DBNAME "insert into instances (instance_id,prop,value) values ('$instance_id', 'hostname', '$hostname');"
sqlite3 $DBNAME "insert into instances (instance_id,prop,value) values ('$instance_id', 'vpn_address', '$vpn_hostaddr');"
echo $instance_id, $hostnum

