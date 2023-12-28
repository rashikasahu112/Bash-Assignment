#!/bin/bash


log_file="files/apache-logs.log"
# Check if file exist or not
if [ ! -e "$log_file" ]; then
    echo "Log file does not exist"
    exit 1
fi

# taking time as user input
echo "Enter timestamp in 24-hr format (e.g., '15:00:00')"
read -p "Enter the start time: " start_time
read -p "Enter the end time: " end_time


# coverting the user input into seconds
start=$(date -d "$start_time" "+%s")
end=$(date -d "$end_time" "+%s")

#checking if startime is greater than endtime
if [[ $start -gt $end ]]
then
  echo "Start time should be less than end time"
  exit 1
fi


# initializing required variables
no_of_req=0
declare -A url_count
declare -A response_codes
most_visited_url=""
most_visited_url_count=0


# fetching timestamp, response code existing in the given time period
while IFS= read -r log_entry;do
  timestamp=$(echo "$log_entry" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')
  url=$(echo "$log_entry" | grep -oE '"(GET|PROPFIND) [^"]+ HTTP/1\.[01]"')
  response_code=$(echo "$log_entry" | grep -oE ' [0-9]{3} ' | tr -d ' ')
  
  
  if [[ -n $timestamp ]]
  then
    time=$(date -d "$timestamp" "+%s")
    if [[ $time -ge $start ]] && [[ $time -le $end ]]
    then
      ((no_of_req++))
      if [[ -n $url ]]; then
        key="${url//[/}"
        key="${key//]/}"
        ((url_count[$key]++))
      fi
    fi
  fi
  
  if [[ -n $response_code ]]
  then
    ((response_codes[$response_code]++))
  fi
  
done < "$log_file"


# calculating most visited URL
for key in "${!url_count[@]}"; do
  if [[ ${url_count[$key]} -gt $most_visited_url_count ]]
  then
    most_visited_url_count=${url_count[$key]}
    most_visited_url="${key}"
  fi
done


# displaying the No of req, Max visited URL, & response codes 

if [[ $most_visited_url_count -ne 0 ]]; then
  echo "Most visited url : $most_visited_url, Hit-Count :  $most_visited_url_count"
else
  echo "There is not accessed URL between $start_time & $end_time"
fi

for key in "${!response_codes[@]}"; do
  echo "Response Code: $key, Count: ${response_codes[$key]}"  
done


