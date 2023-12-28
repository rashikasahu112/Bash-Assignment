#!/bin/bash


log_file="files/apache-logs.log"

# Check if file exist or not
if [ ! -e "$log_file" ]; then
    echo "Log file does not exist"
    exit 1
fi

# fetching the required information & displaying
while IFS= read -r logs_entry; do
    ip_address=$(echo "$logs_entry" | grep -oE '\b([0-9,x]{1,3}\.){3}[0-9,x]{1,3}\b') 
    timestamp1=$(echo "$logs_entry" | grep -oE '\[[0-9]{2}/[A-Za-z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2} -[0-9]{4}\]')
    timestamp2=$(echo "$logs_entry" | grep -oE '\[[A-Za-z]{3} [A-Za-z]{3} [0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} [0-9]{4}\]')
    response_code=$(echo "$logs_entry" | grep -oE '(401|200) | head -n1')
    url=$(echo "$logs_entry" | grep -oE '"(GET|PROPFIND) [^"]+ HTTP/1\.[01]"')

    if [ -n "$ip_address" ]; then
        echo "IP Address: $ip_address"
    fi
    
    if [ -n "$timestamp1" ]; then
        echo "Timestamp: $timestamp1"
    elif [ -n "$timestamp2" ]; then
        echo "Timestamp: $timestamp2"
    fi
    
    if [ -n "$url" ]; then
        echo "Url: $url"
    fi
    
    if [ -n "$response_code" ]; then
        echo "Response Code: $response_code"
    fi
    
done < "$log_file"