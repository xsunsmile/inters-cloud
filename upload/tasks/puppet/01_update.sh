#!/bin/bash
set -u
set +e

remove_ssl=0
set_cron=0
host_file="/etc/hosts";
master_ip=$(grep puppet $host_file | awk '{print $1}');
if [ "$master_ip" != "$real_master" ]; then
	 sudo sed -i '/puppet/d' $host_file
	 sudo sed -i "1i$real_master puppet" $host_file
fi
[ -e /etc/tinc ] && sudo chmod -R 777 /etc/tinc

gembin_path=`gem1.8 env | grep "EXECUTABLE DIRECTORY" | awk '{print $4}'`

no_puppetuser=`id puppet`
[ -z "$no_puppetuser" ] && sudo useradd -d /var/lib/puppet -s /bin/false puppet

[ -e /tmp/puppet.log ] && sudo chmod 777 /tmp/puppet.log
sudo $gembin_path/puppetd --test --verbose 2>&1 > /tmp/puppet.log
[ -e /tmp/puppet.log ] && sudo chmod 777 /tmp/puppet.log
grep "Retrieved certificate does not match private key" /tmp/puppet.log 2>&1 > /dev/null && remove_ssl='1'
grep "err" /tmp/puppet.log 2>&1 > /dev/null && set_cron='1'
echo "flags: $set_cron, $remove_ssl"
if [ "$set_cron" = "1" ]; then
	[ "$remove_ssl" = "1" ] && sudo rm -rf /etc/puppet/ssl
	[ -e /tmp/puppet.cron ] && sudo rm /tmp/puppet.cron
	cat <<EOF > /tmp/puppet.cron
running=\`ps aux | grep [p]uppetd\`
[ -z "\$running" ] && sudo $gembin_path/puppetd --test --verbose 2>&1 > /tmp/puppet.log
if [ -e /tmp/puppet.log ]; then
	sudo chmod 777 /tmp/puppet.log
	grep "Retrieved certificate does not match private key" /tmp/puppet.log 2>&1 > /dev/null \
		&& sudo rm -rf /etc/puppet/ssl
	grep "err" /tmp/puppet.log || whenever -c 'run puppet periodically'
	sudo rm /tmp/puppet.log
fi
EOF
	sudo chmod a+x /tmp/puppet.cron
	[ -e /tmp/puppet.log ] && sudo rm /tmp/puppet.log
	$gembin_path/whenever -i 'run puppet periodically' -f `dirname $0`/config/schedule.rb
	cp -pr `dirname $0`/config /tmp/
fi

