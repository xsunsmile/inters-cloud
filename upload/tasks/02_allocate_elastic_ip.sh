
pub_ip=`ec2-describe-addresses | awk '{print $2}'`
if [ -z "$pub_ip" ]; then
	pub_ip=`ec2-allocate-address | awk '{print $2}'`
	echo "allocate new ip: $pub_ip"
fi

echo "mongodb_host,$pub_ip" | tee -a $common_csv

puppet_master_ip_file="$inters_home/share/upload/puppet/01_update.sh"
elastic_ip=`ec2-describe-tags | awk '/ElasticIP/ {print $5}'`
grep -qFx "^real_master='$elastic_ip'" $puppet_master_ip_file
if [ ! $? -eq 0 ]; then
       $SED -i "/^real_master/d" $puppet_master_ip_file
       $SED -i "3ireal_master='$elastic_ip';" $puppet_master_ip_file
fi


