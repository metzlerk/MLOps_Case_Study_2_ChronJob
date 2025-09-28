# Server Security Monitor - ChronJob

Automatically detects when your server has been reset and secures it by replacing the authorized_keys file.

## Quick Setup

1. **Clone this repository:**
   ```bash
   git clone <repository-url>
   cd ChronJob
   ```

2. **Place your SSH key in this directory:**
   ```bash
   # Copy your private key to:
   ./student-admin_key
   
   # Set correct permissions:
   chmod 600 student-admin_key
   ```

3. **Start the persistent daemon:**
   ```bash
   ./start_daemon.sh
   ```

4. **Verify it's running:**
   ```bash
   ps aux | grep continuous_monitor
   ```

## How It Works

- **Every 3 minutes**: Script attempts SSH login to `student-admin@paffenroth-23.dyn.wpi.edu:22002`
- **If login succeeds**: Server was reset → automatically replaces `authorized_keys` with secure version
- **If login fails**: Server is secure → no action needed
- **Runs as daemon**: Survives logout and runs continuously in background
- **All activity logged** to `security_monitor.log`

## Files

- `server_security_monitor.sh` - Main monitoring script
- `student-admin_key` - SSH private key (keep secure!)
- `authorized_keys` - Secure authorized keys file to deploy
- `start_daemon.sh` - Start persistent background daemon (survives logout)
- `stop_daemon.sh` - Stop the background daemon
- `continuous_monitor.sh` - Continuous loop implementation
- `security_monitor.log` - Activity log

## Daemon Management

```bash
# Start daemon (survives logout)
./start_daemon.sh

# Stop daemon
./stop_daemon.sh

# Check if running
ps aux | grep continuous_monitor

# View daemon status
cat monitor.pid  # Shows process ID if running
```

## Monitor Activity

```bash
# View recent activity
tail -f security_monitor.log

# View daemon loop activity
tail -f monitoring_loop.log

# Test manually (while daemon is running)
./server_security_monitor.sh
```

## Alternative: Cron Job Setup

If you prefer cron over daemon (not recommended for logout survival):
```bash
echo "*/3 * * * * $(pwd)/server_security_monitor.sh" | crontab -
```

## Configuration

Edit `server_security_monitor.sh` to change:
- SSH connection details
- Key file path
- Log file location

## Security Notes

- Keep `student-admin_key` secure (600 permissions)
- **The private key is excluded from git** (see `.gitignore`)
- Daemon runs only on your trusted machine
- All security events are logged for audit
- Daemon survives logout and continues monitoring 24/7

## Git Repository

This project uses git for version control. The SSH private key and log files are automatically excluded from commits for security.

**Important**: Always add your own `student-admin_key` after cloning - it's not included in the repository for security reasons.

This project uses git for version control. The SSH private key and log files are automatically excluded from commits for security.