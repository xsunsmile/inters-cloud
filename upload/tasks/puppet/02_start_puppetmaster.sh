#!/bin/bash
# puppetmasterd --debug --verbose --no-daemonize
set -u

auto_domain=`hostname -d`
[ -z "$auto_domain" ] && auto_domain='inters.com'
base_dir=`dirname $0`
gem_opts="--no-ri --no-rdoc"

sudo apt-get install -qq apache2 apache2-prefork-dev libapr1-dev libaprutil1-dev libcurl4-gnutls-dev locate
sudo apt-get install -qq build-essential zlib1g-dev
gembin_path=`gem1.8 env | grep "EXECUTABLE DIRECTORY" | awk '{print $4}'`
[ ! -e /etc/profile.d/gem.sh ] && echo "PATH=\$PATH:$gembin_path" | tee -a /etc/profile.d/gem.sh

no_puppetuser=`id puppet`
[ -z "$no_puppetuser" ] && sudo useradd -d /var/lib/puppet -s /bin/false puppet
[ ! -e /etc/puppet ] && sudo mkdir /etc/puppet
[ ! -e /var/lib/puppet ] && sudo mkdir /var/lib/puppet
[ ! -e /var/puppet ] && sudo mkdir /var/puppet
sudo chown -R puppet.puppet /etc/puppet
sudo chown -R puppet.puppet /var/lib/puppet
sudo chown -R puppet.puppet /var/puppet
have_puppet_ca=`sudo $gembin_path/puppetca list --all | grep puppet`
[ -z "$have_puppet_ca" ] && sudo $gembin_path/puppetca generate puppet
cat <<EOF > autosign.conf
*.$auto_domain
EOF
sudo mv autosign.conf /etc/puppet/
sudo cp -pr $base_dir/namespaceauth.conf /etc/puppet/
sudo cp -pr $base_dir/modules /etc/puppet/
sudo cp -pr $base_dir/manifests /etc/puppet/
sudo cp -pr $base_dir/rack /etc/puppet/
sudo chown puppet.puppet /etc/puppet/rack/puppetmasterd/config.ru
sudo chown puppet.puppet /etc/puppet/rack/puppetmaster_18140/config.ru
sudo chown puppet.puppet /etc/puppet/rack/puppetmaster_18141/config.ru

hostname_fqdn=`hostname -f`
# sudo sed -i "s/__FQDN__/$hostname_fqdn/" puppetmaster-apache.conf
sudo cp -pr $base_dir/puppetmaster-apache.conf /etc/apache2/sites-enabled/puppetmaster
sudo cp -pr $base_dir/puppetmaster-apache-18140.conf /etc/apache2/sites-enabled/puppetmaster_18140
sudo cp -pr $base_dir/puppetmaster-apache-18141.conf /etc/apache2/sites-enabled/puppetmaster_18141

for pid in $(pgrep puppetmasterd); do
  sudo kill -9 $pid 2>&1 >/dev/null
done

sudo gem1.8 install rack $gem_opts
sudo gem1.8 install passenger $gem_opts

sudo updatedb
mod_passenger_path=`locate mod_passenger.so`
if [ -z "$mod_passenger_path" ]; then
	sudo nice -19 $gembin_path/passenger-install-apache2-module -a
	sudo updatedb
	mod_passenger_path=`locate mod_passenger.so`
fi
passenger_root=${mod_passenger_path%%\/ext\/apache2\/mod_passenger.so}

cat <<EOF > passenger.conf
   LoadModule passenger_module $mod_passenger_path
   PassengerRoot $passenger_root
   PassengerRuby /usr/bin/ruby1.8

   PassengerHighPerformance on
   PassengerUseGlobalQueue on
   PassengerMaxPoolSize 6
   PassengerMaxRequests 4000
   PassengerPoolIdleTime 1800
EOF
sudo mv passenger.conf /etc/apache2/mods-enabled

sudo a2enmod ssl headers
sudo a2enmod proxy_balancer proxy proxy_http

sudo /etc/init.d/apache2 restart
sleep 1

