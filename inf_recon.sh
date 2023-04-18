#!/bin/bash

filename="$1"
list_or_subnet="$2"
hosts="${3}"

total_files=$( find . -type f -name "${filename}.a*" | wc -l )
if [[ $total_files -eq 0 ]]; then 
	# get list of ips in subnet
	if [[ $(echo $list_or_subnet | grep -- -l ) ]]; then
		echo "Splitting IPs from ${hosts} into 64-line chunks..."
		# split ip list into chunks of 64 lines
		split -l 64 "${hosts}" ${filename}.
	elif [[ $(echo $list_or_subnet | grep -- -s ) ]]; then
		echo "Getting IP range of ${hosts} from nmap..."
		nmap -sL -n $hosts | cut -d " " -f5 | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > ${filename}
		if [[ $(grep "Failed" ${filename}) ]]; then
			echo "Error generating IP range, please check supplied arguments."
			stty echo
			exit 1
		fi
		# split ip list into chunks of 64 lines
		echo "Splitting IPs from ${filename} into 64-line chunks..."
		split -l 64 ${filename} ${filename}.
	else
		echo "Usage"
		echo "Launch TCP scans from list of IPs: inf_recon.sh <project name> -l <ip list file path>"
		echo "Launch TCP scans on subnet: inf_recon.sh <project name> -s <ip.ip.ip.ip/cidr>"
		stty echo
		exit 0
	fi
fi

echo "Launching TCP and UDP scans"
./tcp_scans.sh "${filename}" &
./udp_scans.sh "${filename}" &
stty echo
exit 0