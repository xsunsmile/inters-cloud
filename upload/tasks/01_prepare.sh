#!/bin/bash
set -e
set -u

source $temp_env/include

instance_tag="${hostname_f%%.$CLUSTER_DOMAIN}"
node_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "$instance_tag" | sudo tee /etc/hostname
sudo hostname $instance_tag
node_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sudo sed -i "/^$node_ip/d" /etc/hosts
echo "" | sudo tee -a /etc/hosts
echo "$node_ip  $instance_tag.$CLUSTER_DOMAIN  $instance_tag" | sudo tee -a /etc/hosts

chmod 600 $HOME/upload/id_rsa
chmod 600 $HOME/upload/authorized_keys
[ ! -e $HOME/.ssh ] && mkdir $HOME/.ssh
cp $HOME/upload/id_rsa $HOME/.ssh/
cat $HOME/upload/authorized_keys >> $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/*
sudo chown -R `whoami`.`whoami` $HOME/.ssh

puppet_site_file="$HOME/upload/tasks/puppet/manifests/nodes/inters.pp"
replace=${CLUSTER_DOMAIN//\./\\.}
sed -i "s/__HOSTNAME_BASE__/$replace/" $puppet_site_file

sudo mkdir /root/.ssh || true
sudo cp $HOME/upload/id_rsa /root/.ssh/
sudo cp $HOME/upload/authorized_keys /root/.ssh/authorized_keys2

sudo sed -i -e "/\/arch/ s/arch/jp.arch/" /etc/apt/sources.list

sudo apt-get update
sudo apt-get install -y git-core

if [ "$hostnum" = "1" ]; then
  [ ! -e $HOME/upload/tasks/puppet/modules ] && mkdir -p $HOME/upload/tasks/puppet/modules
  cd $HOME/upload/tasks/puppet/modules/
  [ ! -e bridge-utils ] && git clone https://github.com/duritong/puppet-bridge-utils.git bridge-utils
  [ ! -e common ] && git clone https://github.com/xsunsmile/puppet-common.git common
  [ ! -e mongodb ] && git clone https://github.com/xsunsmile/puppet-mongodb.git mongodb
  [ ! -e tinc ] && git clone https://github.com/xsunsmile/puppet-tinc.git tinc
  [ ! -e torque ] && git clone https://github.com/xsunsmile/puppet-torque.git torque
  [ ! -e apt ] && git clone https://github.com/xsunsmile/puppet-aptget.git apt
  [ ! -e inters ] && git clone https://github.com/xsunsmile/puppet-inters-mgm.git inters
  [ ! -e fpm ] && git clone https://github.com/xsunsmile/puppet-fpm.git fpm
  [ ! -e nginx ] && git clone https://github.com/xsunsmile/puppet-nginx.git nginx
  [ ! -e mpiexec ] && git clone git://github.com/xsunsmile/puppet-mpiexec-ohio.git mpiexec
  cat <<EOF >update.sh
origin_dir=`pwd`
for funs in fpm common inters mongodb tinc torque apt
do
	cd \$funs;
	git reset --hard HEAD;
	git clean -f -d;
	git pull origin master;
	cd \$origin_dir;
done

# /etc/init.d/apache2 restart

EOF
  chmod +x update.sh
fi

cat <<SSHCONFIG > config
StrictHostKeyChecking no
SSHCONFIG
cp config $HOME/.ssh/
sudo cp config /root/.ssh/
sudo mv config /etc/skel/
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime || true

