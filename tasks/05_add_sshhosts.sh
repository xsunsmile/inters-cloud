#!/bin/bash
set -e
set -u

source $temp_env/include

replace=false
echo "fin 5"
SED=`which gsed || echo ''`
echo "fin 5"
[ -z "$SED" ] && SED=`which sed`

echo "fin 5"
if [ ! -e $ssh_config ]; then
	cat <<EOF > $ssh_config
ServerAliveInterval 30

user ubuntu
StrictHostKeyChecking no
identityFile $inters_home/share/$keypair
EOF
fi

echo "fin 5"
grep -qFx "identityFile $inters_home/share/$keypair" $ssh_config || replace=true
if $replace; then
	$SED -i "/identityFile/d" $ssh_config
	$SED -i "4iidentityFile $inters_home/share/$keypair" $ssh_config
fi

echo "fin 5"
access_ip=$inst_pubip
[ "$hostnum" = "1" ] && access_ip=$elastic_ip

$SED -i "/$CLUSTER_NAME$hostnum/{N;d;}" $ssh_config
cat <<EOF >> $ssh_config
host $CLUSTER_NAME$hostnum
hostname $access_ip
EOF

echo "fin 5"
