#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/137-138-139-pentesting-netbios
filename=$1
host=$2
port=139
dest_dir="svc_scan_results/netbios"

echo "Found netbios."
if [ ! -d "${dest_dir}/" ]; then
	echo "Launching nbtstat and nbtscan on all hosts."
	mkdir -p "${dest_dir}/${host}"
	while read host; do
		nbtstat -A "${host}" > "${dest_dir}/${host}/nbtstat" &
		nbtscan "${host}" > "${dest_dir}/${host}/nbtscan" &
	done < "${filename}"
else
	echo "Already launched nbtstat and nbtscan, skipping"
fi
exit 0