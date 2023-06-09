#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ftp
host=$1
port=21
dest_dir="svc_scan_results/${host}/ftp"
mkdir -p "${dest_dir}"
ftp_creds="wordlists/ftp_default_creds.txt"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching FTP scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nc -vn "${host}" "${port}" > "${dest_dir}/banner_p${port}" 
nmap -Pn -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &

echo "FTP scans on ${host}:${port} launched."
exit 0