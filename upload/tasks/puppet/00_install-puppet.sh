#!/bin/bash

echo "inters_start_puppet: `hostname`: `date`"
base_path=`dirname $0`;
gem_opts="--no-ri --no-rdoc"
sudo apt-get update
sudo apt-get install -qq ruby ruby-dev libopenssl-ruby rubygems tinc
./$base_path/gems/fetch.sh

sudo gem1.8 install rubygems-update $gem_opts || sudo gem1.8 install $base_path/gems/rubygems-update*.gem $gem_opts
gembin_path=`gem env | grep "EXECUTABLE DIRECTORY" | awk '{print $4}'`
if [ ! -e /etc/profile.d/gem.sh ]; then
  cat <<EOF > gem.sh
export PATH=\$PATH:$gembin_path
EOF
  sudo mv gem.sh /etc/profile.d/
fi
# sudo $gembin_path/update_rubygems
sudo gem1.8 install facter $gem_opts || sudo gem1.8 install $base_path/gems/facter*.gem $gem_opts
sudo gem1.8 install puppet $gem_opts || sudo gem1.8 install $base_path/gems/puppet*.gem $gem_opts
sudo gem1.8 install mongo $gem_opts
sudo gem1.8 install SystemTimer $gem_opts
sudo gem1.8 install bson_ext $gem_opts
sudo gem1.8 install i18n $gem_opts
sudo gem1.8 install whenever $gem_opts

[ "$1" = "master" ] && sh $base_path/02_start_puppetmaster.sh
sh $base_path/01_update.sh
echo "inters_fin_puppet: `hostname`: `date`"

