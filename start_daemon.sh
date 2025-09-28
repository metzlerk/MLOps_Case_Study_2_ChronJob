#!/bin/bash

# Start the monitoring daemon that survives logout
# This script ensures the monitoring continues even after you disconnect

SCRIPT_DIR="/home/kjmetzler/ChronJob"
cd "$SCRIPT_DIR"

echo "Starting Server Security Monitor Daemon..."

# Stop any existing monitoring process
pkill -f continuous_monitor.sh 2>/dev/null

# Start the monitoring as a proper daemon that survives logout
nohup ./continuous_monitor.sh > /dev/null 2>&1 &

# Get the process ID
PID=$!
echo $PID > monitor.pid

echo "Monitoring daemon started with PID: $PID"

# Verify it's running
sleep 2
if ps -p $PID > /dev/null; then
    echo "✅ Daemon is running successfully and will survive logout"
    echo "Monitor activity: tail -f $SCRIPT_DIR/security_monitor.log"
    echo "Stop daemon: $SCRIPT_DIR/stop_daemon.sh"
else
    echo "❌ Failed to start daemon"
    exit 1
fi