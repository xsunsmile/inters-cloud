#!/bin/bash
set -u
set -e

[ -z "`which sqlite3`" ] && echo "you must install sqlite3 first" && exit 0
inters_home="$HOME/.mybin"

temp_env="/tmp/$((RANDOM%9999))$((RANDOM%9999))$((RANDOM%9999))"
[ ! -e $temp_env ] && mkdir -p $temp_env

for task in $(ls $inters_home/tasks/*sh); do
	echo "execute task: $task"
	temp_env=$temp_env sh $task
done

# [ -e $temp_env ] && rm -rf $temp_env
