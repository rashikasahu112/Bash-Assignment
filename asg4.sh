#!/bin/bash


average_success_response_time(){
  log_file=$1
  total_response_time=0
  success_response_count=0
  
  # fetching the response code & time
  while IFS= read -r log_entry; do
    success_response_code=$(echo "$log_entry" | grep -oE ' 2[0-9]{2} ' | tr -d ' ')
    response_time=$(echo "$log_entry" | grep -oE 'HTTP/1\.[01]" 2[0-9]{2} ([0-9]+)' | awk '{print $3}')
      
    if [[ -n $success_response_code ]] && [[ -n $response_time ]]; then
      success_response_count=$((success_response_count + 1))
      total_response_time=$(awk "BEGIN {print $total_response_time + $response_time}")
    fi
  done < "$log_file"
  
  # Calculating average response time & displaying result
  if [ "$success_response_count" -gt 0 ]; then
      average_response_time=$(awk "BEGIN {print $total_response_time / $success_response_count}")
      echo "Average response time for successful requests: $average_response_time milliseconds"
  else
      echo "No successfull requests found in the log file."
  fi
}


# taking file path as user input
read -p "Enter the path to the log file: " log_file

# check if file exist or not
if [ -z "$log_file" ]; then
    echo "Log file path cannot be empty"
    exit 1
elif [ ! -e "$log_file" ]; then
    echo "Log file does not exist"
    exit 1
fi

# determine average response time
average_success_response_time $log_file
