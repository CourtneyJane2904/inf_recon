#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/ipsec-ike-vpn-pentesting
host=$1
port=500
dest_dir="svc_scan_results/${host}/isakmp"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching IKE scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nmap -Pn -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &
ike-scan -M "${host}" --dport=${port} > "${dest_dir}/ikescan_p${port}" &
ike-scan -M --showbackoff "${host}" --dport=${port} > "${dest_dir}/vpn_vendor_p${port}" &

echo "IKE scans on ${host}:${port} launched."
exit 0