
node /^inters-ec2-host\d+/ {
	include 'inters'
	include 'fpm'
	include 'tinc'
	include 'mongodb'
	include 'torque'

	package { mailutils: ensure => installed }

	tinc::vpn_net { inters:
		tinc_interface => 'eth0',
		tinc_internal_interface => 'eth0',
		key_source_path => '/etc/tinc'
	}
}


