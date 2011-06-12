#!/bin/bash
set -e
set -u

export CLUSTER_NAME="jade"
export CLUSTER_DOMAIN="locondo.jp"

INSTANCE_TABLE="create table instances (id INTEGER PRIMARY KEY,instance_id TEXT,prop TEXT,value TEXT);"
CLUSTER_TABLE="create table cluster (id INTEGER PRIMARY KEY,prop TEXT,value TEXT);"
current_dir=`dirname $BASH_ARGV`
DBPATH=$current_dir/../upload/db
DBNAME=$DBPATH/${CLUSTER_NAME}_${CLUSTER_DOMAIN}_db

if [ ! -e $DBNAME ]; then
	[ ! -e $DBPATH ] && mkdir -p $DBPATH
	cat /dev/null > $DBNAME
	echo $CLUSTER_TABLE | tee -a /tmp/tmpstructure
	echo $INSTANCE_TABLE | tee -a /tmp/tmpstructure
	sqlite3 $DBNAME < /tmp/tmpstructure;
	rm -f /tmp/tmpstructure;
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('cluster_name','$CLUSTER_NAME');"
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('cluster_domain','$CLUSTER_DOMAIN');"
fi

