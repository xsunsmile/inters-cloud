#!/bin/bash

[ -z "`which sqlite3`"] && echo "you must install sqlite3 first" && exit 0

inters_home="$HOME/.mybin"
source $inters_home/config/00_cluster_settings.sh
sh $inters_home/tasks/00_cluster_settings.sh
sh $inters_home/tasks/01_cluster_settings.sh
sh $inters_home/tasks/02_add_sshhosts.sh
sh $inters_home/tasks/02_add_sshhosts.sh

