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

# Add the PDM beta repository using new deb822 format
RUN cat > /etc/apt/sources.list.d/pdm-test.sources << EOF
Types: deb
URIs: http://download.proxmox.com/debian/pdm/
Suites: trixie
Components: pdm-test
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF


RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    proxmox-datacenter-manager \
    proxmox-datacenter-manager-ui && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


EXPOSE 8443

# Create volume for persistent data
VOLUME /var/lib/pdm

# Start the Proxmox Datacenter Manager service
CMD ["/usr/sbin/proxmox-datacenter-manager"]