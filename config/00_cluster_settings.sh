#!/bin/bash

export CLUSTER_NAME="jade"
export CLUSTER_DOMAIN="locondo.jp"

current_dir=`dirname $BASH_ARGV`
source $current_dir/01_ec2_env.sh
source $current_dir/02_instance_settings.sh
source $current_dir/03_create_sshkeys.sh

INSTANCE_TABLE="create table instances (id INTEGER PRIMARY KEY,instance_id TEXT,hostname TEXT);"
CLUSTER_TABLE="create table cluster (id INTEGER PRIMARY KEY,prop TEXT,value TEXT);"
PACKAGE_TABLE="create table torque (id INTEGER PRIMARY KEY,prop TEXT,value TEXT);"
DBNAME=$current_dir/db/${CLUSTER_NAME}_${CLUSTER_DOMAIN}_db

if [ ! -e $DBNAME ]; then
	[ ! -e $current_dir/db ] && mkdir -p $current_dir/db
	cat /dev/null > $DBNAME
	echo $CLUSTER_TABLE | tee -a /tmp/tmpstructure
	echo $INSTANCE_TABLE | tee -a /tmp/tmpstructure
	echo $PACKAGE_TABLE | tee -a /tmp/tmpstructure
	sqlite3 $DBNAME < /tmp/tmpstructure;
	rm -f /tmp/tmpstructure;
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('cluster_name','$CLUSTER_NAME');"
	sqlite3 $DBNAME "insert into cluster (prop,value) values ('cluster_domain','$CLUSTER_DOMAIN');"
fi

