#!/bin/bash

# ChronJob Monitoring Script
# Use this to check if your security monitor is running properly

echo "=== CHRONJOB MONITORING REPORT ==="
echo "Date: $(date)"
echo

# Check if cron job is installed
echo "1. CRON JOB STATUS:"
if crontab -l 2>/dev/null | grep -q "server_security_monitor.sh"; then
    echo "   ✅ Cron job is installed"
    crontab -l | grep "server_security_monitor.sh"
else
    echo "   ❌ Cron job is NOT installed"
fi
echo

# Check if script file exists and is executable
echo "2. SCRIPT STATUS:"
if [ -x "/home/kjmetzler/ChronJob/server_security_monitor.sh" ]; then
    echo "   ✅ Monitoring script exists and is executable"
else
    echo "   ❌ Monitoring script missing or not executable"
fi
echo

# Check recent activity from log
echo "3. RECENT ACTIVITY (last 5 entries):"
if [ -f "/home/kjmetzler/ChronJob/security_monitor.log" ]; then
    tail -5 /home/kjmetzler/ChronJob/security_monitor.log | sed 's/^/   /'
    echo
    
    # Check when last activity occurred
    LAST_RUN=$(tail -1 /home/kjmetzler/ChronJob/security_monitor.log | awk '{print $1, $2}')
    echo "   Last activity: $LAST_RUN"
    
    # Count today's activities
    TODAY=$(date +%Y-%m-%d)
    TODAY_COUNT=$(grep "^$TODAY" /home/kjmetzler/ChronJob/security_monitor.log | wc -l)
    echo "   Activities today: $TODAY_COUNT"
else
    echo "   ❌ No log file found - script may not be running"
fi
echo

# Check if cron service is running
echo "4. CRON SERVICE STATUS:"
if systemctl is-active --quiet cron; then
    echo "   ✅ Cron service is running"
else
    echo "   ❌ Cron service is not running"
fi
echo

echo "=== MONITORING COMMANDS ==="
echo "Watch real-time activity:"
echo "   tail -f /home/kjmetzler/ChronJob/security_monitor.log"
echo
echo "Test manually:"
echo "   /home/kjmetzler/ChronJob/server_security_monitor.sh"
echo
echo "Check cron job:"
echo "   crontab -l"
echo