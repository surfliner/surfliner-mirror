#!/bin/bash

# Just a placeholder for now.
DUMP=`cat actionitems.csv`

while IFS= read -r line; do
    echo "${line:0:1}"
    if [ "${line:0:1}" == '"' ]; then
	echo "Found a quote"
    else
	echo "Didn't find a quote"
    fi
done <<< "$DUMP"

