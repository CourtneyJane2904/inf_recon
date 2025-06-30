#!/bin/bash

echo "Starting directory cleanup..."

# Remove the specified directories if they exist
rm -rf scan_results
rm -rf analysis
rm -rf svc_scan_results

echo "Directory cleanup complete."
