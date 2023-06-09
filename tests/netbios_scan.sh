#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/137-138-139-pentesting-netbios
filename=$1
host=$2
port=139
dest_dir="svc_scan_results/netbios"

echo "Found netbios."
if [ ! -d "${dest_dir}/" ]; then
	echo "Launching nbtstat and nbtscan on all hosts."
	while read host_frm_file; do
		dest="${dest_dir}/${host_frm_file}"
		mkdir -p "${dest}/"
		nbtstat -A "${host_frm_file}" > "${dest}/nbtstat" &
		nbtscan "${host_frm_file}" > "${dest}/nbtscan" &
	done < "${filename}"
else
	echo "Already launched nbtstat and nbtscan, skipping"
fi
exit 0