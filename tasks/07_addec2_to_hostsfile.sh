#!/bin/bash

source $temp_env/include

set -e
set -u

temp_hostname=${hostname%%.$CLUSTER_DOMAIN}"-ec2"
sed -i "/$vpn_addr/d" /etc/hosts
sed -i "1i$vpn_addr	$temp_hostname.$CLUSTER_DOMAIN	$temp_hostname" /etc/hosts

