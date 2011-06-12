import "modules.pp"
import "nodes/*"

Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

$extlookup_datadir = "/etc/puppet/manifests/extdata"
$extlookup_precedence = ["%{fqdn}", "domain_%{domain}", "common"]


node default {}


