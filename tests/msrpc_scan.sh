#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/135-pentesting-msrpc
host=$1
port=135
dest_dir="svc_scan_results/${host}/msrpc"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching RPC scans on ${host}:${port}"
# must download
tools/rpcdump.py "${host}" -p "${port}" > "${dest_dir}/rpcdump_p${port}" &
echo "RPC scans on ${host}:${port} launched."
exit 0