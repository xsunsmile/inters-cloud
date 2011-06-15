#!/bin/bash
set -u

current_dir=`dirname $BASH_SOURCE`
[ -z "`ls $current_dir/tasks/*sh 2>/dev/null`" ] && exit 0

for task in $(ls $current_dir/tasks/*sh)
do
	echo "execute task: $task"
	download_dir=$current_dir ./$task
done

