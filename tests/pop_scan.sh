#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-pop
host=$1
port=110
dest_dir="svc_scan_results/${host}/pop"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching POP scans on ${host}:${port}"

nc -nv "${host}" "${port}" > "${dest_dir}/banner_p${port}"
nmap -sCV -p ${port} ${host} -oA "${dest_dir}/general_p${port}" &
echo "POP scans on ${host}:${port} launched."
exit 0