#!/bin/bash

# Server Security Monitor Script
# Checks if server has been reset by attempting SSH login with default credentials
# If successful, replaces authorized_keys file with secure version

# Configuration  
SSH_KEY="/home/kjmetzler/ChronJob/student-admin_key"
SSH_USER="student-admin"
SSH_HOST="paffenroth-23.dyn.wpi.edu"
SSH_PORT="22002"
AUTHORIZED_KEYS_SOURCE="/home/kjmetzler/ChronJob/authorized_keys"
REMOTE_AUTHORIZED_KEYS_PATH="~/.ssh/authorized_keys"
LOG_FILE="/home/kjmetzler/ChronJob/security_monitor.log"

# Function to log messages with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Function to check if SSH key exists and has correct permissions
check_ssh_key() {
    if [ ! -f "$SSH_KEY" ]; then
        log_message "ERROR: SSH key not found at $SSH_KEY"
        return 1
    fi
    
    # Check and fix permissions if needed
    local current_perms=$(stat -c "%a" "$SSH_KEY")
    if [ "$current_perms" != "600" ]; then
        log_message "WARNING: SSH key permissions are $current_perms, fixing to 600"
        chmod 600 "$SSH_KEY"
    fi
    
    return 0
}

# Function to test SSH connection
test_ssh_connection() {
    # Use a timeout and non-interactive mode
    timeout 30 ssh -i "$SSH_KEY" \
                   -p "$SSH_PORT" \
                   -o ConnectTimeout=15 \
                   -o BatchMode=yes \
                   -o StrictHostKeyChecking=no \
                   -o UserKnownHostsFile=/dev/null \
                   -o LogLevel=ERROR \
                   "$SSH_USER@$SSH_HOST" \
                   "echo 'SSH_CONNECTION_SUCCESSFUL'" 2>/dev/null
    
    return $?
}

# Function to replace authorized_keys file
replace_authorized_keys() {
    if [ ! -f "$AUTHORIZED_KEYS_SOURCE" ]; then
        log_message "ERROR: Source authorized_keys file not found at $AUTHORIZED_KEYS_SOURCE"
        return 1
    fi
    
    log_message "SECURITY ALERT: Server appears to be reset. Attempting to secure it..."
    
    # Copy the authorized_keys file to the server
    timeout 60 scp -i "$SSH_KEY" \
                   -P "$SSH_PORT" \
                   -o ConnectTimeout=15 \
                   -o BatchMode=yes \
                   -o StrictHostKeyChecking=no \
                   -o UserKnownHostsFile=/dev/null \
                   -o LogLevel=ERROR \
                   "$AUTHORIZED_KEYS_SOURCE" \
                   "$SSH_USER@$SSH_HOST:$REMOTE_AUTHORIZED_KEYS_PATH" 2>/dev/null
    
    local scp_result=$?
    
    if [ $scp_result -eq 0 ]; then
        log_message "SUCCESS: Authorized keys file has been replaced successfully"
        
        # Verify the file was copied correctly by checking its contents
        timeout 30 ssh -i "$SSH_KEY" \
                       -p "$SSH_PORT" \
                       -o ConnectTimeout=15 \
                       -o BatchMode=yes \
                       -o StrictHostKeyChecking=no \
                       -o UserKnownHostsFile=/dev/null \
                       -o LogLevel=ERROR \
                       "$SSH_USER@$SSH_HOST" \
                       "chmod 600 ~/.ssh/authorized_keys && wc -l ~/.ssh/authorized_keys" >> "$LOG_FILE" 2>&1
        
        return 0
    else
        log_message "ERROR: Failed to replace authorized_keys file (exit code: $scp_result)"
        return 1
    fi
}

# Main execution
main() {
    log_message "Starting security monitor check"
    
    # Check if SSH key exists and has correct permissions
    if ! check_ssh_key; then
        log_message "SSH key check failed, aborting"
        exit 1
    fi
    
    # Test SSH connection
    log_message "Testing SSH connection to $SSH_USER@$SSH_HOST:$SSH_PORT"
    
    if test_ssh_connection; then
        log_message "WARNING: SSH connection successful - server may be unsecured!"
        
        # Replace authorized_keys file
        if replace_authorized_keys; then
            log_message "Server has been secured successfully"
        else
            log_message "CRITICAL: Failed to secure server - manual intervention required"
            exit 1
        fi
    else
        log_message "SSH connection failed - server appears to be secure"
    fi
    
    log_message "Security monitor check completed"
}

# Run main function
main "$@"