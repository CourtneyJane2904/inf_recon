#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-smtp
host=$1
port=25
dest_dir="svc_scan_results/${host}/smtp"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching SMTP scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nc -vn "${host}" "${port}" > "${dest_dir}/banner_p${port}" 
nmap -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &
nmap -p${port} --script smtp-commands "${host}" -oA "${dest_dir}/commands_p${port}" &
nmap -p${port} --script smtp-open-relay "${host}" -v -oA "${dest_dir}/open_relay_p${port}" &
nmap -p${port} --script smtp-ntlm-info "${host}" -v -oA "${dest_dir}/ntlm_p${port}" &
nmap --script=smtp-vuln-cve2010-4344,smtp-vuln-cve2011-1720,smtp-vuln-cve2011-1764 -p ${port} ${host} -oA "${dest_dir}/cves_p${port}" &
nmap --script=smtp-enum-users -p ${port} ${host} -oA "${dest_dir}/user_enum_p${port}" &

echo "SMTP scans on ${host}:${port} launched."
exit 0

# send email: python3 magicspoofmail.py -d victim.com -t -e destination@gmail.com --subject TEST --sender administrator@victim.com
# send mail with PHP: mail("your_email@gmail.com", "Test Subject!", "hey! This is a test", "From: administrator@victim.com");