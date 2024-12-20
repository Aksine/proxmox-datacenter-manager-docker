FROM debian:bookworm

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

# Add the repository and GPG key
RUN echo 'deb http://download.proxmox.com/debian/pdm bookworm pdm-test' > /etc/apt/sources.list.d/pdm-test.list && \
    wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg && \
    apt-get update && \
    # Remove the file before installing to prevent dpkg prompting
    rm /etc/apt/sources.list.d/pdm-test.list && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y proxmox-datacenter-manager proxmox-datacenter-manager-ui && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 8443
VOLUME /var/lib/pdm

CMD ["/usr/sbin/proxmox-datacenter-manager"]
