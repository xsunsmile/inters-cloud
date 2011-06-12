#!/bin/bash

source 00_header.sh

echo "inters_start_$0: $tag_base$host_num: `date`"
instance_tag="$tag_base""$host_num"
node_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "$instance_tag" | tee /etc/hostname
hostname $instance_tag
node_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "/^$node_ip/d" /etc/hosts
echo "" | tee -a /etc/hosts
echo "$node_ip  $instance_tag.$domain_name  $instance_tag" | tee -a /etc/hosts

[ ! -e $HOME/.ssh ] && mkdir $HOME/.ssh
cp $HOME/upload/id_rsa $HOME/.ssh/
cat $HOME/upload/authorized_keys >> $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/*

puppet_site_file="$HOME/upload/puppet/manifests/nodes/inters.pp"
replace=${domain_name//\./\\.}
sed -i "s/__HOSTNAME_BASE__/$replace/" $puppet_site_file

sudo mkdir /root/.ssh
sudo cp $HOME/upload/id_rsa /root/.ssh/
sudo cat $HOME/upload/authorized_keys >> /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/*

sudo sed -i -e "/\/arch/ s/arch/jp.arch/" /etc/apt/sources.list

sudo apt-get update
sudo apt-get install -y git-core

if [ "$host_num" = "1" ]; then
  [ ! -e $HOME/upload/puppet/modules ] && mkdir -p $HOME/upload/puppet/modules
  cd $HOME/upload/puppet/modules/
  git clone https://github.com/duritong/puppet-bridge-utils.git bridge-utils
  git clone https://github.com/xsunsmile/puppet-common.git common
  git clone https://github.com/xsunsmile/puppet-mongodb.git mongodb
  git clone https://github.com/xsunsmile/puppet-tinc.git tinc
  git clone https://github.com/xsunsmile/puppet-torque.git torque
  git clone https://github.com/xsunsmile/puppet-aptget.git apt
  git clone https://github.com/xsunsmile/puppet-inters-mgm.git inters
  git clone https://github.com/xsunsmile/puppet-fpm.git fpm
  git clone https://github.com/xsunsmile/puppet-nginx.git nginx
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
echo "inters_fin_$0: $tag_base$host_num: `date`"
