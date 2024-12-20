# Use Debian Bookworm as the base image
FROM debian:bookworm

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes

# Install core dependencies and set debconf to noninteractive
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    curl \
    iproute2 \
    debconf-utils \
    --no-install-recommends && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure dpkg to handle configuration files non-interactively
RUN echo 'DPkg::options { "--force-confdef"; "--force-confold"; };' > /etc/apt/apt.conf.d/99force-conf

# Add PDM repository, import GPG key, and install PDM
RUN echo 'deb http://download.proxmox.com/debian/pdm bookworm pdm-test' > /etc/apt/sources.list.d/pdm-test.list && \
    wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      -o Dpkg::Options::="--force-confdef" \
      -o Dpkg::Options::="--force-confold" \
      proxmox-datacenter-manager proxmox-datacenter-manager-ui && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the PDM port
EXPOSE 8443

# Set up a persistent volume for configuration and logs
VOLUME /var/lib/pdm

# Start the PDM service
CMD ["/usr/sbin/proxmox-datacenter-manager"]
