#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/ipsec-ike-vpn-pentesting
host=$1
port=500
mkdir -R "test_results/isakmp/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching IKE scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nmap -p${port} $host -sCV -oA "test_results/isakmp/${host}/general_p${port}" &
ike-scan -M "${host}" --dport=${port} > "test_results/isakmp/${host}/ikescan_p${port}" &
ike-scan -M --showbackoff "${host}" --dport=${port} > "test_results/isakmp/${host}/vpn_vendor_p${port}" &

echo "IKE scans on ${host}:${port} launched."
exit 0