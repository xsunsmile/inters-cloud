#!/bin/bash

SED=`which gsed`
[ -z "$SED" ] && SED=`which sed`

if [ ! -e $ssh_config ]; then
	cat <<EOF > $ssh_config
ServerAliveInterval 30

user ubuntu
StrictHostKeyChecking no
identityFile $inters_home/share/$keypair
EOF
fi

grep -qFx "identityFile $inters_home/share/$keypair" $ssh_config
if [ $? -ne 0 ]; then
	$SED -i "/identityFile/d" $ssh_config
	$SED -i "4iidentityFile $inters_home/share/$keypair" $ssh_config
fi

$SED -i "/$CLUSTER_NAME$hostnum/{N;d;}" $ssh_config
cat <<EOF >> $ssh_config
host $CLUSTER_NAME$hostnum
hostname $inst_pubip
EOF

