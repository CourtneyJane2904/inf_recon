#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ident
host=$1
port=113
mkdir -p "test_results/ident/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching IDENT scans on ${host}:${port}"
# must download
ident-user-enum ${host} 22 {port} 139 445 > "test_results/ident/${host}/user_enum"
echo "IDENT scans on ${host}:${port} launched."
exit 0