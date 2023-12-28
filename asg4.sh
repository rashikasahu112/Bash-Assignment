#!/bin/bash

#read -p "Enter the path to the log file: " log_file

log_file="/home/rashikasahu/bash_asg/files/apache-logs.log"
if [ -z "$log_file" ]; then
    echo "Log file path cannot be empty"
    exit 1
elif [ ! -e "$log_file" ]; then
    echo "Log file does not exist"
    exit 1
fi

total_response_time=0
success_response_count=0

while IFS= read -r log_entry; do  
  success_response_code=$(echo "$log_entry" | grep -oE ' 2[0-9]{2} ' | tr -d ' ')
  response_time=$(echo "$log_entry" | grep -oE 'HTTP/1\.[01]" 2[0-9]{2} ([0-9]+)' | awk '{print $3}')
    
  if [[ -n $success_response_code ]] && [[ -n $response_time ]]; then
    success_response_count=$((success_response_count + 1))
    total_response_time=$(awk "BEGIN {print $total_response_time + $response_time}")
  fi
done < "$log_file"

if [ "$success_response_count" -gt 0 ]; then
    average_response_time=$(awk "BEGIN {print $total_response_time / $success_response_count}")
    echo "Average response time for successful requests: $average_response_time milliseconds"
else
    echo "No successful requests found in the log file."
fi