#!/bin/bash

DUMP=`cat actionitems.csv`

while IFS= read -r line; do
    echo "${line:0:1}"
    if [ "${line:0:1}" == '"' ]; then
	    echo "Found a quote"
        # Since the csv is malformed, we need to look for ", before we can grab the rest.
        CURRENT_CHAR=0
        while [ "${line:$CURRENT_CHAR:1}" != '' ]; do
            echo -n ${line:$CURRENT_CHAR:1}
            ((CURRENT_CHAR=CURRENT_CHAR+1))
        done
    else
	    echo "Didn't find a quote"
    fi
done <<< "$DUMP"

