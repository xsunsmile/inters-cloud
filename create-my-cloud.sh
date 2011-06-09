
SED='gsed'

inters_home="$HOME/.mybin"
inters_env="$inters_home/share/upload/inters.sh"
inters_cron="$inters_home/share/upload/inters_crontab"

source $inters_home/share/ec2-env.sh
source $inters_home/share/settings.sh
source $inters_home/share/puppet_env.sh
sh $inters_home/share/common_env_ssh.sh

host_num="$1"
[ -z "$host_num" ] && host_num=`ec2-describe-instances -F tag:Name=$hosttag_base* | grep "^TAG.*Name" | wc -l | grep -o "[0-9]\{1,10\}$"`
if [ -z "$host_num" ]; then
	host_num=1
else
	host_num=$(($host_num+1))
fi
[ ! -z "$1" ] && host_num=$1
vpn_hostaddr=$(($host_num+1))
echo "inters_start_ec2: $hosttag_base$host_num: `date`"

pub_ip=`ec2-describe-addresses | awk '{print $2}'`
if [ -z "$pub_ip" ]; then
	pub_ip=`ec2-allocate-address | awk '{print $2}'`
	echo "allocate new ip: $pub_ip"
fi

oldkey=`ec2-describe-keypairs $keypair | grep ^KEY`
if [ -z "$oldkey" ]; then
	ec2-add-keypair $keypair | tee $inters_home/share/$keypair
else
	chmod 600 $inters_home/share/$keypair
fi

echo "mongodb_host,$pub_ip" | tee -a $common_csv

instance_id=`ec2-run-instances $ami_id -t $inst_type -k $keypair | grep ^INS | awk '{print $2}'`
echo "allocate new instance: $instance_id"
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

echo "inters_fin_ec2: $hosttag_base$host_num: `date`"

sshport_ok=`ec2-describe-group $group | awk '{print $5","$6","$7}' | grep "^tcp,22"`
[ -z "$sshport_ok" ] && ec2-authorize $group -P tcp -p 22

if [ ! -e $ssh_config ]; then
	cat <<EOF > $ssh_config
ServerAliveInterval 30

user ubuntu
StrictHostKeyChecking no
identityFile $inters_home/share/$keypair
EOF
fi

$SED -i "/$hosttag_base$host_num/{N;d;}" $ssh_config
cat <<EOF >> $ssh_config
host $hosttag_base$host_num
hostname $inst_pubip
EOF

elastic_ip=`ec2-describe-tags | awk '/ElasticIP/ {print $5}'`
$SED -i "/^real_master/d" $inters_home/share/upload/puppet/01_update.sh
$SED -i "3ireal_master='$elastic_ip';" $inters_home/share/upload/puppet/01_update.sh

scp -F ~/.ssh/config_inters -pr $inters_home/share/upload "$hosttag_base$host_num":.
ssh -F ~/.ssh/config_inters "$hosttag_base$host_num" sudo ./upload/set.sh $host_num
$SED -i "/^real_master/d" $inters_home/share/upload/puppet/01_update.sh

mongoport_ok=`ec2-describe-group $group | awk '{print $5","$6","$7}' | grep "^tcp,27017"`
[ -z $mongoport_ok ] && ec2-authorize $group -P tcp -p 27017

puppetport_ok=`ec2-describe-group $group | awk '{print $5","$6","$7}' | grep "^tcp,8140"`
[ -z $puppetport_ok ] && ec2-authorize $group -P tcp -p 8140

tincport_ok=`ec2-describe-group $group | awk '{print $5","$6","$7}' | grep "^tcp,655"`
[ -z $tincport_ok ] && ec2-authorize $group -P tcp -p 655
[ -z $tincport_ok ] && ec2-authorize $group -P udp -p 655

puppet_role="client"
[ $host_num -eq 1 ] && puppet_role="master"
ssh -F ~/.ssh/config_inters "$hosttag_base$host_num" \
"nohup nice -19 sudo ./upload/puppet/00_install-puppet.sh $puppet_role < /dev/null 2>&1 > nohup.out &"
