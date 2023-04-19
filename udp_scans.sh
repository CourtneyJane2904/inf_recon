#!/bin/bash

filename="$1"
mkdir -p scan_results/udp
 # begin full TCP scans on each chunk but last
chars=({a..z})
total_files=$( find . -type f -name "${filename}.a*" | wc -l )

for ((c=0; c<${total_files}; c++ )); do 
    echo "Launching UDP scan $((c+1))/${total_files}"
    sudo nmap -sU -Pn --top-ports=1000 --max-rtt-timeout=150ms --max-retries=3 -iL ${filename}.a${chars[c]} -oA scan_results/udp/udp-popular-ports-a${chars[c]} & done; 

echo "UDP scans launched, will notify on completion."
completed_udp=0
sleep 2

while true; do
    for ((c=0; c<${total_files}; c++ )); do 
        if [[ $( grep "Nmap done" scan_results/udp/udp-popular-ports-a${chars[c]}.nmap ) ]]; then completed_udp=$((completed_udp+1)); fi
    done
    if [[ $completed_udp -eq $total_files ]]; then
        echo "UDP scans complete, now proceeding with analysis."
        ./udp_scan_analysis.sh "${filename}"
        stty echo
        exit 0
    fi
    echo "${completed_udp}/${total_files} UDP scans complete."
    completed_udp=0
    sleep 60
done
stty echo
exit 0