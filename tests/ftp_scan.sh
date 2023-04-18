#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ftp
host=$1
port=21
mkdir -p "test_results/ftp/${host}"
ftp_creds="wordlists/ftp_default_creds.txt"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching FTP scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nc -vn "${host}" "${port}" > "test_results/ftp/${host}/banner_p${port}" 
nmap -p${port} $host -sCV -oA "test_results/ftp/${host}/general_p${port}" &

echo "FTP scans on ${host}:${port} launched."
exit 0