#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-smb
host=$1
port=445
dest_dir="svc_scan_results/${host}/microsoft-ds"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching SMB scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nmap -Pn -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &
nmap -Pn --script "safe or smb-enum-* or smb-vuln*" -p "${port}" "${host}" -oA "${dest_dir}/nmap_enum_p${port}" &
nmap -Pn --script smb-enum-users -p "${port}" "${host}" -oA "${dest_dir}/nmap_users_enum_p${port}" &
timeout 300s enum4linux -a "${host}" > "${dest_dir}/enum4linux_p${port}" &
echo "SMB scans on ${host}:${port} launched."
exit 0