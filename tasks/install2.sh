#!/bin/bash

scp -F $ssh_config -pr $inters_home/upload "$hosttag_base$host_num":.
ssh -F $ssh_config "$hosttag_base$host_num" \
"nohup nice -19 sudo ./upload/install.sh </dev/null 2>&1>nohup.out &"

