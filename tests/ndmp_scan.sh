#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/10000-network-data-management-protocol-ndmp
host=$1
port=10000
dest_dir="svc_scan_results/${host}/ndmp"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching NDMP scans on ${host}:${port}"
nmap -Pn -sCV -p "${port}" "${host}" -oA "${dest_dir}/general_p${port}" &
echo "NDMP scans on ${host}:${port} launched."
exit 0

# snmp-check "${host}" -c public
# snmp-check "${host}" -c public -w