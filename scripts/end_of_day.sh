#!/bin/bash
# end_of_day.sh - Triggers EOD save-down from RDB to HDB

echo "Triggering End of Day (EOD) process..."

# Open IPC handle to TP and execute .u.end for the current date
q -e "h:hopen \`::5010; h(\`.u.end; .z.D); hclose h;"

if [ $? -eq 0 ]; then
    echo "EOD signal sent successfully. RDB is saving down to HDB."
else
    echo "ERROR: Failed to connect to Tickerplant on port 5010."
fi