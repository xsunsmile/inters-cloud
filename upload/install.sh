#!/bin/bash

puppet_role="client"
[ $host_num -eq 1 ] && puppet_role="master"
ssh -F $ssh_config "$hosttag_base$host_num" \
"nohup nice -19 sudo ./upload/puppet/00_install-puppet.sh $puppet_role < /dev/null 2>&1 > nohup.out &"
