#!/bin/bash
set -e
set -u

source $temp_env/include

cat <<TEST_VPN > /tmp/test_vpn.sh
succeed="true"
SED=$(which gsed || which sed)
ping -c1 -t1 $vpn_address_master || succeed="false"
if [ "\$succeed" = "false" ]; then
	sudo /etc/init.d/tinc restart
else
	crontab -l > /tmp/crontab.output
	\$SED -i "/test_vpn.sh/d" /tmp/crontab.output
	crontab < /tmp/crontab.output
fi
TEST_VPN
chmod +x /tmp/test_vpn.sh

crontab -l > crontab.input || echo "no old cron jobs"
cat <<CRONTAB >> crontab.input
*/1 * * * * . /tmp/test_vpn.sh
CRONTAB

crontab < crontab.input

