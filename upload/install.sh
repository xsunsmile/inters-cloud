#!/bin/bash
set -e
set -u

sudo apt-get -qq update
sudo apt-get install -qq sqlite3 openjdk-6-jre-headless

current_dir=`dirname $0`
temp_env="/tmp/$((RANDOM%9999))$((RANDOM%9999))$((RANDOM%9999))"
[ ! -e $temp_env ] && mkdir -p $temp_env
cp $current_dir/ec2_env.sh $temp_env/01_ec2_env.sh

echo "temp_env: $temp_env"

# [ -e $current_dir/blueprints/`hostname -s`.sh ] && \
#	sudo $current_dir/blueprints/`hostname -s`

for task in $(ls $current_dir/tasks/*sh);
do
	start=$SECONDS
	temp_env=$temp_env $task
	echo "inters_fin_$task ($((SECONDS-start)))"
done

set +e
set +u

