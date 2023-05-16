#!/bin/bash

filename="$1"
mkdir -p scan_results/udp
 # begin top 1000 UDP scans on each chunk, can be adjusted as needed
 # adjust if more than 6400 hosts need to be scanned- e.g. use {0000..9999} if more than 6400 hosts need to be scanned 
nums=({000..999})
total_files=$( find . -type f -name "${filename}.[[:digit:]]" | wc -l )

for ((c=0; c<${total_files}; c++ )); do 
    echo "Launching UDP scan $((c+1))/${total_files}"
    sudo nmap -sU --top-ports=1000 --max-rtt-timeout=150ms --max-retries=3 -iL ${filename}.${nums[c]} -Pn -oA scan_results/udp/udp-popular-ports-${nums[c]} & done; 

echo "UDP scans launched, will notify on completion."
completed_udp=0
sleep 2

# check status of scans every 60 seconds
while true; do
    for ((c=0; c<${total_files}; c++ )); do 
        if [[ $( grep "Nmap done" scan_results/udp/udp-popular-ports-${nums[c]}.nmap ) ]]; then completed_udp=$((completed_udp+1)); fi
    done
    if [[ $completed_udp -eq $total_files ]]; then
        echo "UDP scans complete, now proceeding with analysis."
        ./udp_scan_analysis.sh "${filename}" &
        stty echo
        exit 0
    fi
    echo "${completed_udp}/${total_files} UDP scans complete."
    completed_udp=0
    sleep 60
done
stty echo
exit 0
