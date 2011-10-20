#!/bin/bash

source $temp_env/include

set -e
set -u

SED=`which gsed || which sed`
temp_hostname=${hostname%%.$CLUSTER_DOMAIN}"-ec2"
sudo $SED -i "/$vpn_addr/d" /etc/hosts
[ "$hostnum" = "1" ] && exit 0
sudo $SED -i "1i$vpn_addr	$temp_hostname.$CLUSTER_DOMAIN	$temp_hostname" /etc/hosts

