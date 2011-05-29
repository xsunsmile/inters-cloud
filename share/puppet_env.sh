
common_csv="$inters_home/share/upload/puppet/manifests/extdata/common.csv"
kuruwa_csv="$inters_home/share/upload/puppet/manifests/extdata/kuruwa-gw.alab.nii.ac.jp.csv"

[ -e $common_csv ] && rm -rf $common_csv
[ -e $kuruwa_csv ] && rm -rf $kuruwa_csv

mongodb_repo="deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
echo "mongodb_repo,$mongodb_repo" | tee -a $common_csv
echo "mongodb_version,1.8.1" | tee -a $common_csv
echo "mongodb_install_src,/tmp/mongodb" | tee -a $common_csv

echo "torque_install_dist,/usr/local" | tee -a $common_csv
echo "torque_install_src,/tmp/torque" | tee -a $common_csv
echo "torque_admin,root" | tee -a $common_csv
echo "torque_master_name,inters-ec2-host1" | tee -a $common_csv
echo "torque_complie_args_extra," | tee -a $common_csv
echo "torque_spool_dir," | tee -a $common_csv
echo "hostname_s," | tee -a $common_csv

echo "hostname_s,kuruwa00" | tee -a $kuruwa_csv

