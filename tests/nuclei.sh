#!/bin/bash

host=$1
dest_dir="svc_scan_results/${host}/nuclei"

mkdir -p "${dest_dir}"

echo "Launching Nuclei scan on ${host}:${port}"

# Nuclei with target as IP:port (useful for HTTP/HTTPS services)
nuclei -target "${host}" -o "${dest_dir}/nuclei_scan.txt" -severity medium,high,critical &

echo "Nuclei scan on ${host}:${port} launched."
exit 0
