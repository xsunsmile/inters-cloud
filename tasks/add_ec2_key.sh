#!/bin/bash

oldkey=`ec2-describe-keypairs $keypair | grep ^KEY`
if [ -z "$oldkey" ]; then
	if [ ! -e $inters_home/share/$keypair ]; then
		ec2-delete-keypair $keypair
	fi
	ec2-add-keypair $keypair | tee $inters_home/share/$keypair
fi
chmod 600 $inters_home/share/$keypair

