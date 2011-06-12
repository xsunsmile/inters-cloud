
host_num="$1"
[ -z "$host_num" ] && host_num=`ec2-describe-instances -F tag:Name=$hosttag_base* | grep "^TAG.*Name" | wc -l | grep -o "[0-9]\{1,10\}$"`
tmp_instid=`ec2-describe-instances -F tag:Name=$hosttag_base$host_num | grep ^INS | awk '{print $2}'`
while [ ${#tmp_instid} -ne 0 ];
do
   host_num=$(($host_num+1))
   tmp_instid=`ec2-describe-instances -F tag:Name=$hosttag_base$host_num | grep ^INS | awk '{print $2}'`
done

if [ -z "$host_num" ]; then
	host_num=1
else
	host_num=$(($host_num+1))
fi
[ ! -z "$1" ] && host_num=$1

