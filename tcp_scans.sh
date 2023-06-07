#!/bin/bash

filename="$1"
mkdir -p scan_results/tcp
# begin full TCP scans on each chunk, may need adjusting in some situations
# adjust if more than 6400 hosts need to be scanned- e.g. use {0000..9999} if more than 6400 hosts need to be scanned 
nums=({000..999})
total_files=$( find . -type f -name "${filename}.[0-9][0-9][0-9]" | wc -l )

for ((c=0; c<${total_files}; c++ )); do 
	echo "Launching TCP scan $((c+1))/${total_files}"
	nmap -sS --max-rtt-timeout=150ms --max-retries=3 -T4 -p- -iL "${filename}".${nums[c]} -Pn -oA scan_results/tcp/tcp-all-ports-${nums[c]} & done; 

echo "TCP scans launched, will notify on completion."
completed_tcp=0
sleep 2

# check status of scans every 60 seconds
while true; do
    for ((ch=0; ch<${total_files}; ch++ )); do 

        if [[ $( grep "Nmap done" scan_results/tcp/tcp-all-ports-${nums[ch]}.nmap ) ]]; then completed_tcp=$((completed_tcp+1)); fi
    done
    if [[ $completed_tcp -eq $total_files ]]; then
        echo "TCP scans complete, now proceeding to analysis."
        ./tcp_scan_analysis.sh "${filename}" &
        stty echo
        exit 0
    fi
    echo "${completed_tcp}/${total_files} TCP scans complete."
    completed_tcp=0
    sleep 60
done
stty echo
exit 0
