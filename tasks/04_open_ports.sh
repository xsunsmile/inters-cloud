#!/bin/bash
set -u
set -e

source $temp_env/include

firewall_status=`ec2-describe-group $group | awk '{print $5","$6","$7}'`
sshport_ok=`echo $firewall_status | grep "tcp,22"`
[ -z "$sshport_ok" ] && ec2-authorize $group -P tcp -p 22

mongoport_ok=`echo $firewall_status | grep "tcp,27017"`
[ -z "$mongoport_ok" ] && ec2-authorize $group -P tcp -p 27017

puppetport_ok=`echo $firewall_status | grep "tcp,8140"`
[ -z "$puppetport_ok" ] && ec2-authorize $group -P tcp -p 8140

tincport_ok=`echo $firewall_status | grep "tcp,655"`
[ -z "$tincport_ok" ] && ec2-authorize $group -P tcp -p 655
[ -z "$tincport_ok" ] && ec2-authorize $group -P udp -p 655

echo ""
