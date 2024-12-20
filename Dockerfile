# Use Debian Bookworm as the base image
FROM debian:bookworm

# Metadata
LABEL maintainer="Your Name <your-email@example.com>"
LABEL description="Proxmox Datacenter Manager (PDM) with optional VPN support (WireGuard or Tailscale)"

# Set environment variables for flexibility
ENV PDM_PORT=8443
ENV ENABLE_WIREGUARD=false
ENV ENABLE_TAILSCALE=false

# Install core dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    curl \
    iproute2 \
    --no-install-recommends && \
    apt-get clean

# Add PDM repository and install PDM
RUN echo 'deb http://download.proxmox.com/debian/pdm bookworm pdm-test' > /etc/apt/sources.list.d/pdm-test.list && \
    wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg && \
    apt-get update && \
    apt-get install -y proxmox-datacenter-manager proxmox-datacenter-manager-ui && \
    apt-get clean

# Optional: Install WireGuard and Tailscale
RUN if [ "$ENABLE_WIREGUARD" = "true" ]; then \
        apt-get update && \
        apt-get install -y wireguard-tools && \
        apt-get clean; \
    fi && \
    if [ "$ENABLE_TAILSCALE" = "true" ]; then \
        curl -fsSL https://tailscale.com/install.sh | sh; \
    fi

# Expose the PDM port
EXPOSE ${PDM_PORT}

# Set up a persistent volume for configuration and logs
VOLUME /var/lib/pdm
VOLUME /etc/wireguard
VOLUME /var/lib/tailscale

# Start the PDM service
CMD ["/usr/sbin/proxmox-datacenter-manager"]
