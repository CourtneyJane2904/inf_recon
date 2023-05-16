#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-finger
host=$1
port=79
dest_dir="svc_scan_results/${host}/finger"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching finger scans on ${host}:${port}"
nc -vn "${host}" "${port}" > "${dest_dir}/banner_p${port}" 
nmap -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &
finger @${host} > "${dest_dir}/user_list_p${port}"
echo "Finger scans on ${host}:${port} launched."
exit 0
