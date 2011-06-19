#!/bin/bash
set -e
set -u

source $temp_env/include

access_ip=$inst_pubip
if [ "$hostnum" = 1 ]; then 
	access_ip=$elastic_ip
cat <<TINC > /tmp/add_tinchosts
#!/bin/bash
set -e
set -u

success="false"
EIP="$elastic_ip"
cluster_name="$CLUSTER_NAME"
cluster_domain="${CLUSTER_DOMAIN//\./}"
tinc_file="\${cluster_name}1\${cluster_domain}"
dest_dir="/etc/tinc/inters/hosts/\$tinc_file"
scp -i $inters_home/upload/id_rsa root@$access_ip:\$dest_dir /tmp/\$tinc_file && success="true"
if [ "\$success" = "true" ]; then
	sed -i "/Address/d" /tmp/\$tinc_file
	sed -i "1iAddress = $elastic_ip" /tmp/\$tinc_file
	sudo cp /tmp/\$tinc_file \$dest_dir
fi

upload_ok="false"
tinc_file="\${cluster_name}gw\${cluster_domain}"
dest_dir="/etc/tinc/inters/hosts/\$tinc_file"
scp -i $inters_home/upload/id_rsa \$dest_dir root@$access_ip:\$dest_dir && upload_ok="true"
if [ "\$upload_ok" = "true" -a "\$success" = "true" ]; then
	sudo /etc/init.d/tinc restart
	crontab -l > /tmp/crontab.tmp || true
	sed -i "/add_tinchosts/d" /tmp/crontab.tmp
	crontab < /tmp/crontab.tmp
	rm /tmp/crontab.tmp
fi
TINC
	chmod +x /tmp/add_tinchosts
	crontab -l > /tmp/crontab.backup || true
	echo "*/1 * * * * . /tmp/add_tinchosts" > /tmp/crontab.backup
	crontab < /tmp/crontab.backup
	rm /tmp/crontab.backup
fi

