domain_name="inters.com"
tag_base="inters-ec2-host"

instance_tag="$tag_base""$1"
node_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "$instance_tag" | tee /etc/hostname
hostname $instance_tag
node_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "/^$node_ip/d" /etc/hosts
echo "" | tee -a /etc/hosts
echo "$node_ip  $instance_tag.$domain_name  $instance_tag" | tee -a /etc/hosts

[ ! -e $HOME/.ssh ] && mkdir $HOME/.ssh
mv $HOME/upload/id_rsa $HOME/.ssh/
cat $HOME/upload/authorized_keys >> $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/*
sudo sed -i -e "/\/arch/ s/arch/jp.arch/" /etc/apt/sources.list

sudo apt-get update
sudo apt-get install -y git-core

if [ "$1" = "1" ]; then
  cd $HOME/upload/puppet/modules/
  git clone https://github.com/duritong/puppet-bridge-utils.git bridge-utils
  git clone https://github.com/xsunsmile/puppet-common.git common
  git clone https://github.com/xsunsmile/puppet-mongodb.git mongodb
  git clone https://github.com/xsunsmile/puppet-tinc.git tinc
  git clone https://github.com/xsunsmile/puppet-torque.git torque
  git clone https://github.com/xsunsmile/puppet-aptget.git apt
  git clone https://github.com/xsunsmile/puppet-inters-mgm.git inters
  git clone https://github.com/xsunsmile/puppet-fpm.git fpm
  cat <<EOF >update.sh
for funs in {fpm,common,inters,mongodb,tinc,torque}; do cd \$funs; git pull origin master; cd -; done
EOF
  chmod +x update.sh
fi
