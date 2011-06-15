#!/bin/bash
set -e
set -u

source $temp_env/include

oldkey=`ec2-describe-keypairs $keypair | grep ^KEY`
if [ -z "$oldkey" ]; then
	ec2-add-keypair $keypair | tee $inters_home/share/$keypair
else
	if [ ! -e $inters_home/share/$keypair ]; then
		ec2-delete-keypair $keypair
		ec2-add-keypair $keypair | tee $inters_home/share/$keypair
	fi
fi
chmod 600 $inters_home/share/$keypair

