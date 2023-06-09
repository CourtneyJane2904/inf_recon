#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ldap
host=$1
port=389
dest_dir="svc_scan_results/${host}/ldap"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching LDAP scans on ${host}:${port}"
# must download
nmap -Pn -sV --script "ldap* and not brute" ${host} -oA "${dest_dir}/general_p${port}" &
echo "LDAP scans on ${host}:${port} launched."
exit 0

# dump DA user info: ldapdomaindump <IP> [-r <IP>] -u '<domain>\<username>' -p '<password>' [--authtype SIMPLE] --no-json --no-grep -o /path/dir