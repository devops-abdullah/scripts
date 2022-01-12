#!/bin/bash
set -e
set -o pipefail
echo "Author : Abdullah Manzoor"

num="$1"
value="1024"

echo "Going to increase swap"
echo "Current Memory and SWAP"
free -h
echo
echo
echo
touch /swapfile
echo "Setting file size of swapfile located under (/swapfile)"
if test -z "$num"; then 
echo "This script will Increase 4-GB SWAP for system by Default"
echo "If you can customiz your Sapace press Ctrl + C and run this scrip like this {bash swap.sh 2} value will be consider in GB"
sleep 60
	sudo dd if=/dev/zero of=/swapfile count=4096 bs=1MiB
	else
	size=$(($num*$value))
	sudo dd if=/dev/zero of=/swapfile count=$size bs=1MiB
fi
echo "Setting permission for swapfile"
chmod 600 /swapfile
echo "Making swap"
mkswap /swapfile
blkid -c /dev/null
swapon /swapfile
free -h
