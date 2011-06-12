
cd $inters_home/upload
if [ ! -e authorized_keys -o ! -e id_rsa ]; then
	ssh-keygen -t rsa -q -f id_rsa -N ''
	mv id_rsa.pub authorized_keys
fi

