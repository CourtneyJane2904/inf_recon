#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/nfs-service-pentesting
host=$1
port=2049
dest_dir="svc_scan_results/${host}/nfs"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching NFS scans on ${host}:${port}"
nmap -Pn -p${port} --script=nfs-ls,nfs-showmount,nfs-statfs "${host}" -oA "${dest_dir}/general_p${port}" &
showmount -e "${host}" > "${dest_dir}/showmount_p${port}"
echo "NFS scans on ${host}:${port} launched."
exit 0

# create group with specific GID: groupadd sysadmins -g4200
# create user with specific GID and UID: useradd appadmin1 -u4100 -g4100 -d/home/appadmin1 -s/bin/bash
# set password for created user: passwd appadmin1
# can also just edit gid and uid in /etc/passwd

# mount nfs: mount -t nfs -o ver=2 10.10.10.180:/home /mnt/