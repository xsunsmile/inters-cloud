#!/bin/bash
set -e
set -u

source $temp_env/include

current_dir=`dirname $0`
puppet_role="client"
[ "$hostnum" = "1" ] && puppet_role="master"
$current_dir/puppet/00_install-puppet.sh $puppet_role

