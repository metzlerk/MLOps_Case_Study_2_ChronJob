#!/bin/bash

# Alternative Monitoring Loop - runs continuously instead of via cron
# Use this if cron jobs aren't working in your environment

SCRIPT_DIR="/home/kjmetzler/ChronJob"
MONITOR_SCRIPT="$SCRIPT_DIR/server_security_monitor.sh"
LOOP_LOG="$SCRIPT_DIR/monitoring_loop.log"

echo "[$(date)] Starting continuous monitoring loop..." >> "$LOOP_LOG"

while true; do
    echo "[$(date)] Running security check..." >> "$LOOP_LOG"
    
    # Run the monitoring script
    cd "$SCRIPT_DIR"
    ./server_security_monitor.sh
    
    echo "[$(date)] Security check completed, sleeping for 30 seconds..." >> "$LOOP_LOG"

    # Wait 30 seconds
    sleep 30
done