#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/137-138-139-pentesting-netbios
filename=$1
host=$2
port=139

echo "Found netbios."
if [ ! -d "test_results/netbios/" ]; then
	echo "Launching nbtstat and nbtscan on all hosts."
	mkdir -R "test_results/netbios/nbtstat"
	mkdir -R "test_results/netbios/nbtscan"
	while read host; do
		nbtstat -A "${host}" > "test_results/netbios/nbtstat/${host}" &
		nbtscan "${host}" > "test_results/netbios/nbtscan/${host}" &
	done < "${filename}"
else
	echo "Already launched nbtstat and nbtscan, skipping"
fi
exit 0