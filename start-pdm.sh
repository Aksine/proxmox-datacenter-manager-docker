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
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Ensure required directories exist
mkdir -p /var/lib/pdm /var/log/pdm /run/proxmox-datacenter-manager
chown -R root:root /var/lib/pdm /var/log/pdm /run/proxmox-datacenter-manager

# Start the privileged API service
echo "Starting proxmox-datacenter-privileged-api..."
/usr/libexec/proxmox/proxmox-datacenter-privileged-api &
PRIV_PID=$!

# Give it a moment to start
sleep 2

# Start the main API service
echo "Starting proxmox-datacenter-api..."
/usr/libexec/proxmox/proxmox-datacenter-api &
API_PID=$!

# Wait for either process to exit
wait $API_PID $PRIV_PID