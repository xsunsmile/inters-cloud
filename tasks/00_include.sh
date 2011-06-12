#!/bin/bash

cat <<ENV > $temp_env/include
#!/bin/bash

temp_env="$temp_env"
echo "temp_env: \$temp_env"
for setting in \$(ls \$temp_env/*sh)
do
	echo "read setting: \$setting"
	source \$setting
done
ENV

cat <<ENV > $temp_env/env.sh
#!/bin/bash

inters_home="$HOME/.mybin"
inters_config_dir="\$inters_home/config"
for setting in \$(ls \$inters_config_dir/*sh); do
	source \$setting
done
ENV

