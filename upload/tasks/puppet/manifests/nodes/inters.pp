
node /__HOSTNAME_BASE__$/ {
	include 'inters'
	include 'fpm'
	include 'tinc'
	include 'mongodb'
	include 'torque'
	include 'mpiexec'

	package { mailutils: ensure => installed }

	if $hostname == extlookup('torque_master_name') {
		tinc::vpn_net { inters:
			tinc_interface => $tinc_eth,
			tinc_internal_interface => $tinc_eth,
			key_source_path => '/etc/tinc',
			vpn_subnet_ip => regsubst($vpn_ipaddress,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\1.\2.\3.0'),
			vpn_subnet_mask => '255.255.255.0',
			vpn_subnet_mask32bits => '24',
		}
	} else {
		tinc::vpn_net { inters:
			tinc_interface => $tinc_eth,
			tinc_internal_interface => $tinc_eth,
			key_source_path => '/etc/tinc',
			vpn_subnet_ip => $vpn_ipaddress,
			vpn_subnet_mask => '255.255.255.0',
			vpn_subnet_mask32bits => '32',
		}
	}

}


