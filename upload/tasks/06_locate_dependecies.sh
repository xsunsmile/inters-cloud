#!/bin/bash

bin_name="/opt/tinysvm-0.09/bin/svm_classify"
bin_name="/opt/torque/bin/qmgr"

links=`ldd $bin_name | awk -F"=>" '{print $2}' | awk -F"(" '{print $1}'`
for link in $links
do
	name=`dpkg -S $link 2>/dev/null || echo`
	if [ -z "$name" ];
	then
		cpdir="$cpdir,"`dirname $link`
	else
		installpkg="$installpkg,"`echo $name | awk -F":" '{print $1}'`
	fi
done

echo "copy: $cpdir"
echo "install: $installpkg"

# mpicc.mpich2 -show
# gcc -g -O2 -g -Wall -O2 -Wl,-Bsymbolic-functions -I/usr/include/mpich2 -L/usr/lib -L/usr/lib -Wl,-rpath,/usr/lib -lmpich -lopa -lpthread -lrt
