# Use Debian Trixie (Debian 13) as required for PDM 0.9 beta
FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes

RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    curl \
    iproute2 \
    debconf-utils \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Force dpkg noninteractive behavior
RUN echo 'DPkg::options { "--force-confdef"; "--force-confnew"; };' > /etc/apt/apt.conf.d/99force-conf

RUN wget http://download.proxmox.com/debian/pbs-client/dists/trixie/main/binary-amd64/proxmox-archive-keyring_4.0_all.deb && \
    dpkg -i proxmox-archive-keyring_4.0_all.deb && \
    rm proxmox-archive-keyring_4.0_all.deb

# Add the PDM beta repository 
COPY pdm-test.sources /etc/apt/sources.list.d/pdm-test.sources

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    proxmox-datacenter-manager \
    proxmox-datacenter-manager-ui && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 8443

# Create volume for persistent data
VOLUME /var/lib/pdm

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/pdm /var/log/pdm /run/proxmox-datacenter-manager && \
    chown -R root:root /var/lib/pdm /var/log/pdm /run/proxmox-datacenter-manager

# Copy the advanced startup script
COPY start-pdm.sh /start-pdm.sh
RUN chmod +x /start-pdm.sh

# Start both PDM services with advanced script
CMD ["/start-pdm.sh"]