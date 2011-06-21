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

cat <<TEST_TORQUE > /tmp/check_torque.sh
#!/bin/bash
set -e
set -u

if [ -e /tmp/restart.torque ]; then
	sudo rm /tmp/restart.torque
	sudo /etc/init.d/pbs_server restart
fi
if [ -e /tmp/delete_restart_torque ]; then
	sudo rm /tmp/delete_restart_torque
	cronbackup="crontab.input\${RANDOM}"
	crontab -l > \$cronbackup || echo "no old cron jobs"
	sed -i "/check_torque.sh/d" \$cronbackup
	crontab < \$cronbackup
	rm \$cronbackup
fi

TEST_TORQUE
chmod +x /tmp/check_torque.sh

crontab -l > crontab.input || echo "no old cron jobs"
cat <<CRONTAB >> crontab.input
*/1 * * * * bash /tmp/test_vpn.sh
*/1 * * * * bash /tmp/check_torque.sh
CRONTAB

crontab < crontab.input
rm crontab.input

