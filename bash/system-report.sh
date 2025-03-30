#!/bin/bash
# -*- mode: shell -*-

log_dir="/var/log/system_reports"
mkdir -p "$log_dir"
chmod 755 "$log_dir"

log_file="$log_dir/report_$(date +%Y-%m-%d_%H-%M-%S).log"

echo "Rapport système - $(date)" > "$log_file"

echo "Disk Usgae :" >> "$log_file"
df -h >> "$log_file"

echo "Memory usage :" >> "$log_file"
free -h >> "$log_file"

echo "System Operating time :" >> "$log_file"
uptime >> "$log_file"

echo "Rapport enregistré dans $log_dir"