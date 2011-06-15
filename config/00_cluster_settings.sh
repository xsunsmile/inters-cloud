#!/bin/bash
set -e

export CLUSTER_NAME="kuruwa"
export CLUSTER_DOMAIN="alab.nii.ac.jp"

INSTANCE_TABLE="create table instances (id INTEGER PRIMARY KEY,instance_id TEXT,prop TEXT,value TEXT);"
CLUSTER_TABLE="create table cluster (id INTEGER PRIMARY KEY,prop TEXT,value TEXT);"

current_dir=$(dirname "$BASH_SOURCE")
DBPATH=$current_dir/../upload/db
DBNAME=$DBPATH/${CLUSTER_NAME}_${CLUSTER_DOMAIN}_db

if [ ! -e $DBNAME -a ${#1} -eq 0 ]; then
	[ ! -e $DBPATH ] && mkdir -p $DBPATH
	cat /dev/null > $DBNAME
	echo $CLUSTER_TABLE | tee -a /tmp/tmpstructure
	echo $INSTANCE_TABLE | tee -a /tmp/tmpstructure
	sqlite3 $DBNAME < /tmp/tmpstructure;
	rm -f /tmp/tmpstructure;
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('cluster_name','$CLUSTER_NAME');"
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('cluster_domain','$CLUSTER_DOMAIN');"
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('instances_num','1');"
fi

