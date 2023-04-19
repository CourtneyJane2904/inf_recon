#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-mysql
host=$1
port=3306
mkdir -p "test_results/mysql/${host}"
mysql_creds="../wordlists/mysql_default_creds.txt"
if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching mySQL scans on ${host}:${port}"
# must download
nmap -sV -p ${port} --script mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-variables,mysql-vuln-cve2012-2122 "${host}" -oA "test_results/mysql/${host}/general_p${port}" &
hydra -C "${mysql_creds}" "${host}" mysql -s "${port}" -o "test_results/mysql/${host}/hydra_brute_p${port}" &
echo "mySQL scans on ${host}:${port} launched."
exit 0
