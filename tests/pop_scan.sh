#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-pop
host=$1
port=110
mkdir -R "test_results/pop/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching POP scans on ${host}:${port}"

nc -nv "${host}" "${port}" > "test_results/pop/${host}/banner_p${port}"
nmap -sCV -p ${port} ${host} -oA "test_results/pop/${host}/general_p${port}" &
echo "POP scans on ${host}:${port} launched."
exit 0