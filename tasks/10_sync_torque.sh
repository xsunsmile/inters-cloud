#!/bin/bash

source $temp_env/include
[ "$hostnum" != "1" ] && exit 0

set -e
set -u

RSYNC_OPTS="-avz --exclude=nodes --exclude=*.lock"
sync_to=${hostname%%.$CLUSTER_DOMAIN}"-ec2"
sync_from_dir="/var/spool/torque/server_priv"
sync_to_dir="/var/spool/torque/server_priv"

SED=`which gsed || which sed`
sudo $SED -i "/$elastic_ip/d" /etc/hosts
sudo $SED -i "1i$elastic_ip	$sync_to" /etc/hosts

cat <<SYNC_CRON > /tmp/sync_torque_info.sh
#!/bin/bash
set -e
set -u

ssh-keygen -R kuruwa-gw-ec2
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=30"
ssh \$SSH_OPTS -i $inters_home/upload/id_rsa $sync_to hostname

# QSTAT=\$(which qstat)
online_nodes=\$(/usr/local/bin/qstat -e -n -1 | grep " R " | awk '{print \$12}' | awk -F/ '{print \$1}' | sort | uniq)
online_jobs=\$(/usr/local/bin/qstat -e -n -1 | grep " R " | awk '{print \$1}' | awk -F\. '{print \$1}')

for node in \$online_nodes; do
	echo "\$node is online"
	sudo pbsnodes -o \$node
done
for job in \$online_jobs; do
	echo "\$job is online"
	sudo qrerun \$job
done

rsync $RSYNC_OPTS $sync_from_dir/ $sync_to:$sync_to_dir
ssh \$SSH_OPTS -i $inters_home/upload/id_rsa $sync_to "touch /tmp/restart.torque"
# ssh -i $inters_home/upload/id_rsa $sync_to "touch /tmp/delete_restart_torque"

backup_name="crontab.backup\${RANDOM}"
crontab -l > /tmp/\$backup_name || true
$SED -i "/sync_torque_info.sh/d" /tmp/\$backup_name
crontab < /tmp/\$backup_name
rm /tmp/\$backup_name

SYNC_CRON

chmod +x /tmp/sync_torque_info.sh
backup_name="crontab.backup${RANDOM}"
crontab -l > /tmp/$backup_name || true
echo "*/1 * * * * bash /tmp/sync_torque_info.sh" >> /tmp/$backup_name
crontab < /tmp/$backup_name
rm /tmp/$backup_name

