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

3. **Install the cron job:**
   ```bash
   echo "*/3 * * * * $(pwd)/server_security_monitor.sh >/dev/null 2>&1" | crontab -
   ```

4. **Verify it's running:**
   ```bash
   crontab -l
   ```

## How It Works

- **Every 3 minutes**: Script attempts SSH login to `student-admin@paffenroth-23.dyn.wpi.edu:22002`
- **If login succeeds**: Server was reset → automatically replaces `authorized_keys` with secure version
- **If login fails**: Server is secure → no action needed
- **All activity logged** to `security_monitor.log`

## Files

- `server_security_monitor.sh` - Main monitoring script
- `student-admin_key` - SSH private key (keep secure!)
- `authorized_keys` - Secure authorized keys file to deploy
- `security_monitor.log` - Activity log

## Monitor Activity

```bash
# View recent activity
tail -f security_monitor.log

# Test manually
./server_security_monitor.sh
```

## Configuration

Edit `server_security_monitor.sh` to change:
- SSH connection details
- Key file path
- Log file location

## Security Notes

- Keep `student-admin_key` permissions at 600
- Never share the private key
- **The private key is excluded from git** (see `.gitignore`)
- Monitor the log file for security alerts

## Git Repository

This project uses git for version control. The SSH private key and log files are automatically excluded from commits for security.