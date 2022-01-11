#!/bin/bash

DUMP=`cat actionitems.csv`

while IFS= read -r line; do
    # Handle the malformed action item column...
    if [ "${line:0:1}" == '"' ]; then
        # Since the csv is malformed, we need to look for ", before we can grab the rest.
        CURRENT_CHAR=0
        while [ "${line:$CURRENT_CHAR:2}" != '",' ] && [ "${line:$CURRENT_CHAR:1}" != '' ]; do
            ((CURRENT_CHAR=CURRENT_CHAR+1))
        done
        ITEM=`echo "${line:1:$CURRENT_CHAR-1}"`
        echo "Action Item: $ITEM"
        ITEMDATE=`echo "${line:$CURRENT_CHAR+2}" | cut -d ',' -f 1 | cut -d 'T' -f 1`
        echo "    Item Date: $ITEMDATE"
    else
	    ITEM=`echo -n $line | cut -d ',' -f 1`
        echo "Action Item: $ITEM"
        ITEMDATE=`echo -n $line | cut -d ',' -f 2 | cut -d 'T' -f 1`
        echo "    Item Date: $ITEMDATE"
    fi
done <<< "$DUMP"

