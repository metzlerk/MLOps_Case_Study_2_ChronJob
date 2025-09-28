#!/bin/bash

# Stop the monitoring daemon

SCRIPT_DIR="/home/kjmetzler/ChronJob"
cd "$SCRIPT_DIR"

echo "Stopping Server Security Monitor Daemon..."

if [ -f monitor.pid ]; then
    PID=$(cat monitor.pid)
    if ps -p $PID > /dev/null; then
        kill $PID
        echo "✅ Stopped monitoring daemon (PID: $PID)"
        rm monitor.pid
    else
        echo "Process $PID not running, cleaning up pid file"
        rm monitor.pid
    fi
else
    echo "No pid file found, trying to kill by name..."
    pkill -f continuous_monitor.sh
    if [ $? -eq 0 ]; then
        echo "✅ Killed any running monitoring processes"
    else
        echo "No monitoring processes found"
    fi
fi