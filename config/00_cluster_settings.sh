#!/bin/bash
set +e

export CLUSTER_NAME="kuruwa"
export CLUSTER_DOMAIN="alab.nii.ac.jp"
# export CLUSTER_NAME="jade"
# export CLUSTER_DOMAIN="locondo.co.jp"

current_dir=$(dirname "$BASH_SOURCE")
DBPATH=$current_dir/../db
DBNAME=$DBPATH/${CLUSTER_NAME}_${CLUSTER_DOMAIN}_db

if [ ! -e $DBNAME -a ${#1} -eq 0 ]; then
	sleep 1
	ID=`date +%Y%m%d%H%M%S`"$RANDOM"
	cat <<TEMP_STRUCTURE > /tmp/${ID}_tmpstructure
begin exclusive transaction;
create table if not exists instances (id INTEGER PRIMARY KEY,instance_id TEXT,prop TEXT,value TEXT);
create table if not exists cluster (id INTEGER PRIMARY KEY,prop TEXT,value TEXT);
insert or ignore into cluster (id, prop,value) values (1, 'cluster_name','$CLUSTER_NAME');
insert or ignore into cluster (id, prop,value) values (2, 'cluster_domain','$CLUSTER_DOMAIN');
insert or ignore into cluster (id, prop,value) values (3, 'instances_num','1');
end transaction;
commit;
TEMP_STRUCTURE
	[ ! -e $DBPATH ] && mkdir -p $DBPATH
	touch $DBNAME
	sqlite3 $DBNAME < /tmp/${ID}_tmpstructure 2>&1>/dev/null || true
	rm -f /tmp/${ID}_tmpstructure;
fi

set +e

