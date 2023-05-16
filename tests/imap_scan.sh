#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-imap
host=$1
port=143
dest_dir="svc_scan_results/${host}/imap"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching IMAP scans on ${host}:${port}"
# must download
nc -nv "${host}" "${port}" > "${dest_dir}/banner_p${port}"
nmap -sV --script "imap-ntlm-info" -p ${port} ${host} -oA "${dest_dir}/ntlm_info_p${port}" &
echo "IMAP scans on ${host}:${port} launched."
exit 0