#!/bin/bash
set -e

# Function to handle shutdown signals
cleanup() {
    echo "Shutting down PDM services..."
    if [[ -n "$PRIV_PID" ]]; then
        kill "$PRIV_PID" 2>/dev/null || true
    fi
    if [[ -n "$API_PID" ]]; then
        kill "$API_PID" 2>/dev/null || true
    fi
    if [[ -n "$RSYSLOG_PID" ]]; then
        kill "$RSYSLOG_PID" 2>/dev/null || true
    fi
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Ensure required directories exist with proper permissions
mkdir -p /var/lib/pdm /var/log/pdm /run/proxmox-datacenter-manager /etc/proxmox-datacenter-manager/auth
mkdir -p /var/lib/rrdcached /var/lib/proxmox-datacenter-manager

# Set specific permissions that PDM expects
chown -R www-data:www-data /var/lib/pdm /var/log/pdm /var/lib/rrdcached /var/lib/proxmox-datacenter-manager
chown -R www-data:www-data /etc/proxmox-datacenter-manager
chown -R root:www-data /run/proxmox-datacenter-manager

# PDM expects these exact permissions
chmod 1770 /run/proxmox-datacenter-manager
chmod 1770 /etc/proxmox-datacenter-manager
chmod 755 /etc/proxmox-datacenter-manager/auth

# Generate authentication keys if they don't exist
if [[ ! -f /etc/proxmox-datacenter-manager/auth/authkey.pub ]] || [[ ! -f /etc/proxmox-datacenter-manager/auth/authkey.key ]]; then
    echo "Generating authentication keys..."
    openssl genrsa -out /etc/proxmox-datacenter-manager/auth/authkey.key 2048
    openssl rsa -in /etc/proxmox-datacenter-manager/auth/authkey.key -pubout -out /etc/proxmox-datacenter-manager/auth/authkey.pub
    chown www-data:www-data /etc/proxmox-datacenter-manager/auth/authkey.key /etc/proxmox-datacenter-manager/auth/authkey.pub
    chmod 640 /etc/proxmox-datacenter-manager/auth/authkey.key
    chmod 644 /etc/proxmox-datacenter-manager/auth/authkey.pub
fi

# Generate CSRF key if it doesn't exist
if [[ ! -f /etc/proxmox-datacenter-manager/auth/csrf.key ]]; then
    echo "Generating CSRF key..."
    openssl rand -hex 32 > /etc/proxmox-datacenter-manager/auth/csrf.key
    chown www-data:www-data /etc/proxmox-datacenter-manager/auth/csrf.key
    chmod 640 /etc/proxmox-datacenter-manager/auth/csrf.key
fi

# Start rsyslog in background for container logging (simpler approach)
echo "Starting rsyslog..."
rsyslogd -f /etc/rsyslog.conf -n &
RSYSLOG_PID=$!
sleep 1

# Start the privileged API service (runs as root)
echo "Starting proxmox-datacenter-privileged-api..."
/usr/libexec/proxmox/proxmox-datacenter-privileged-api 2>&1 &
PRIV_PID=$!

# Give it a moment to start
sleep 3

# Start the main API service as www-data user
echo "Starting proxmox-datacenter-api as www-data..."
su -s /bin/bash www-data -c '/usr/libexec/proxmox/proxmox-datacenter-api 2>&1' &
API_PID=$!

# Wait for either process to exit
wait $API_PID $PRIV_PID