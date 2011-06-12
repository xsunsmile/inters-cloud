
ec2-create-tags $instance_id -t Name="$hosttag_base$host_num"
ec2-create-tags $instance_id -t VPN-Role=vpn-slave
ec2-create-tags $instance_id -t VPN-Address="$vpn_netaddr$vpn_hostaddr"
ec2-create-tags $instance_id -t LRM-Role=torque-slave
inst_pubip=`ec2-describe-instances $instance_id | grep running | awk '{print $14}'`

master_instid=`ec2-describe-instances -F tag:LRM-Role=torque-master | grep ^INS | awk '{print $2}'`
[ -z "$master_instid" ] && master_instid=$instance_id
ec2-create-tags $master_instid -t LRM-Role=torque-master
ec2-create-tags $master_instid -t VPN-Role=vpn-master

elastic_ip=`ec2-describe-tags | awk '/ElasticIP/ {print $5}'`
if [ ! -z "$pub_ip" -a -z "$elastic_ip" ]; then
	echo "found master: $master_instid, $pub_ip "
	ec2-associate-address $pub_ip -i $master_instid
	ec2-create-tags $master_instid -t ElasticIP=$pub_ip
	inst_pubip=$pub_ip
fi


