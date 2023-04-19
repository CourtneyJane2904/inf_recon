#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/3260-pentesting-iscsi
host=$1
port=3260
mkdir -p "test_results/iscsi/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching ISCSI scans on ${host}:${port}"
# must download
nmap -sV --script=iscsi-info -p "${port}" "${host}" -oA "test_results/iscsi/${host}/general_p${port}" &
nmap -sV --script=iscsi-brute "${host}" -p "${port}" -oA "test_results/iscsi/${host}/bruteforce_p${port}" &
iscsiadm -m discovery -t sendtargets -p "${host}:${port}" > "test_results/iscsi/${host}/targetname_p${port}" &
echo "ISCSI scans on ${host}:${port} launched."
exit 0

