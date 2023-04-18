#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ldap
host=$1
port=389
mkdir -p "test_results/ldap/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching LDAP scans on ${host}:${port}"
# must download
nmap -n -sV --script "ldap* and not brute" ${host} -oA "test_results/ldap/${host}/general_p${port}" &
echo "LDAP scans on ${host}:${port} launched."
exit 0

# dump DA user info: ldapdomaindump <IP> [-r <IP>] -u '<domain>\<username>' -p '<password>' [--authtype SIMPLE] --no-json --no-grep -o /path/dir