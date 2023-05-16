#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/9100-pjl
host=$1
port=9100
dest_dir="svc_scan_results/${host}/jetdirect"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching raw printing scans on ${host}:${port}"
# must download
nmap -p${port} --script pjl-ready-message "${host}" -oA "${dest_dir}/pjl-ready_p${port}" &
echo "Raw printing scans on ${host}:${port} launched."
exit 0