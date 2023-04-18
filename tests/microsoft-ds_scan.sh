#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-smb
host=$1
port=445
mkdir -p "test_results/microsoft-ds/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching SMB scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nmap -p${port} $host -sCV -oA "test_results/microsoft-ds/${host}/general_p${port}" &
nmap --script "safe or smb-enum-*" -p "${port}" "${host}" -oA "test_results/microsoft-ds/${host}/nmap_enum_p${port}" &
timeout 300s enum4linux -a "${ip}" > "test_results/microsoft-ds/${host}/enum4linux_p${port}" &
echo "SMB scans on ${host}:${port} launched."
exit 0