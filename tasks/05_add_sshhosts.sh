#!/bin/bash
set -e
set -u

source $temp_env/include

replace=false
SED=`which gsed || echo ''`
[ -z "$SED" ] && SED=`which sed`

if [ ! -e $ssh_config ]; then
	cat <<EOF > $ssh_config
ServerAliveInterval 30

user ubuntu
StrictHostKeyChecking no
identityFile $inters_home/share/$keypair

EOF
fi

grep -qFx "identityFile $inters_home/share/$keypair" $ssh_config || replace=true
if $replace; then
	$SED -i "/identityFile/d" $ssh_config
	$SED -i "4iidentityFile $inters_home/share/$keypair" $ssh_config
fi

access_ip=$inst_pubip
[ "$hostnum" = "1" ] && access_ip=$elastic_ip

$SED -i "/$CLUSTER_NAME$hostnum/{N;d;}" $ssh_config
cat <<EOF >> $ssh_config
host $CLUSTER_NAME$hostnum
hostname $access_ip
EOF

