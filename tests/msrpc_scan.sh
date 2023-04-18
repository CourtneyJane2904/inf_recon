#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/135-pentesting-msrpc
host=$1
port=135
mkdir -R "test_results/msrpc/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching RPC scans on ${host}:${port}"
# must download
rpcdump.py "${host}" -p "${port}" > "test_results/msrpc/${host}/rpcdump_p${port}" &
echo "RPC scans on ${host}:${port} launched."
exit 0