#!/bin/bash

log_file="files/apache-logs.log"

# Check if file exist or not
if [ ! -e "$log_file" ]; then
    echo "Log file does not exist"
    exit 1
fi

# initializing required variables
no_of_req=0
declare -A url_count
declare -A response_codes
report_file="Report.txt"


# fetching timestamp, url, response code 
while IFS= read -r log_entry; do
  timestamp=$(echo "$log_entry" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')
  url=$(echo "$log_entry" | grep -oE '"(GET|PROPFIND) [^"]+ HTTP/1\.[01]"')
  response_code=$(echo "$log_entry" | grep -oE ' [0-9]{3} ' | tr -d ' ')
		        
  if [[ -n $timestamp ]]; then
    ((no_of_req++))
  fi
    
  if [[ -n $url ]]; then
    key="${url//[/}"
    key="${key//]/}"
    ((url_count[$key]++))
  fi
											       
  if [[ -n $response_code ]]; then
    ((response_codes[$response_code]++))
  fi

done < "$log_file"


# creating file that contains all information

echo "Total no of request : $no_of_req" > "$report_file"

echo -e "\nAccessed URL's: " >> "$report_file"
for key in "${!url_count[@]}"; do
    echo "URL: $key, Hit-Count: ${url_count[$key]}" >> "$report_file"
done
 
echo -e "\nResponse Code Count" >> "$report_file"
for key in "${!response_codes[@]}"; do
    echo "Response Code: $key, Count: ${response_codes[$key]}" >> "$report_file"
done

echo "Report generated successfully. Check $report_file for the summary."
