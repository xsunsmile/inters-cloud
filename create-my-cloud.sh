#!/bin/bash
set -u
set -e

[ -z "`which sqlite3`" ] && echo "you must install sqlite3 first" && exit 0
inters_home="$HOME/.mybin"

temp_env="/tmp/$((RANDOM%9999))$((RANDOM%9999))$((RANDOM%9999))"
[ ! -e $temp_env ] && mkdir -p $temp_env

for task in $(ls $inters_home/tasks/*sh); do
	start=$SECONDS
	temp_env=$temp_env sh $task
	echo "inters_task_fin: $task ($((SECONDS-start)))"
done

[ -e $temp_env ] && rm -rf $temp_env

set +u
set +e
