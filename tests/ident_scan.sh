#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ident
host=$1
port=113
dest_dir="svc_scan_results/${host}/ident"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching IDENT scans on ${host}:${port}"
# must download
ident-user-enum ${host} 22 {port} 139 445 > "${dest_dir}/user_enum" &
echo "IDENT scans on ${host}:${port} launched."
exit 0
