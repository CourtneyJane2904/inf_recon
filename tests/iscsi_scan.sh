#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/3260-pentesting-iscsi
host=$1
port=3260
dest_dir="svc_scan_results/${host}/iscsi"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching ISCSI scans on ${host}:${port}"
# must download
nmap -Pn -sV --script=iscsi-info -p "${port}" "${host}" -oA "${dest_dir}/general_p${port}" &
nmap -Pn -sV --script=iscsi-brute "${host}" -p "${port}" -oA "${dest_dir}/bruteforce_p${port}" &
iscsiadm -m discovery -t sendtargets -p "${host}:${port}" > "${dest_dir}/targetname_p${port}" &
echo "ISCSI scans on ${host}:${port} launched."
exit 0