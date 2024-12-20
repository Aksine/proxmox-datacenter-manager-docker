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
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Force dpkg to not prompt
RUN echo 'DPkg::options { "--force-confdef"; "--force-confold"; };' > /etc/apt/apt.conf.d/99force-conf

RUN echo 'deb http://download.proxmox.com/debian/pdm bookworm pdm-test' > /etc/apt/sources.list.d/pdm-test.list && \
    wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    -o Dpkg::Options::="--force-confnew" \
    proxmox-datacenter-manager proxmox-datacenter-manager-ui && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8443
VOLUME /var/lib/pdm
CMD ["/usr/sbin/proxmox-datacenter-manager"]
