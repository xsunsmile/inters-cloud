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

cat <<PUPPETD_CONF > puppet.conf
[main]
pluginsync = true
PUPPETD_CONF
[ -e /etc/puppet ] || sudo mkdir /etc/puppet && sudo chown -R puppet.puppet /etc/puppet
[ -e /etc/puppet/puppet.conf ] || sudo mv puppet.conf /etc/puppet/

no_puppetuser=`id puppet`
[ -z "$no_puppetuser" ] && sudo useradd -d /var/lib/puppet -s /bin/false puppet

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
	errnum=\`grep -c "err" /tmp/puppet.log\`
	sudo mv /tmp/puppet.log /tmp/\${errnum}_puppet.\`date +%Y%m%d%H%M%S\`.log
	if [ \$errnum -eq 0 ]; then
		crontab -l > /tmp/crontab.backup || echo "no jobs"
		sed -i "/puppet.cron/d" /tmp/crontab.backup
		crontab < /tmp/crontab.backup
	fi
fi
EOF
	sudo chmod a+x /tmp/puppet.cron
	[ -e /tmp/puppet.log ] && sudo mv /tmp/puppet.log /tmp/first_puppet.`date +%Y%m%d%H%M%S`.log
	crontab -l > /tmp/crontab.backup || echo "no jobs"
	echo "*/1 * * * * cd /tmp && ./puppet.cron" >> /tmp/crontab.backup
	crontab < /tmp/crontab.backup
	cp -pr `dirname $0`/config /tmp/
fi

