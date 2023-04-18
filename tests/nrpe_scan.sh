#!/bin/bash

# https://www.exploit-db.com/exploits/32925
host=$1
port=5666
mkdir -p "test_results/nrpe/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching NRPE scans on ${host}:${port}"
# must download
nmap -p${port} --script nrpe-enum "${host}" -oA "test_results/nrpe/${host}/general_p${port}" &
echo "NRPE scans on ${host}:${port} launched."
exit 0