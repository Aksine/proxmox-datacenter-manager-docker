# Proxmox Datacenter Manager (PDM) Docker Image

This repository provides a Dockerized version of the Proxmox Datacenter Manager (PDM), enabling centralized management of Proxmox VE nodes or clusters. It includes optional support for VPN integration using **WireGuard** or **Tailscale** for secure communication.

## Features

- Lightweight Debian Bookworm base image.
- Centralized Proxmox VE management through PDM.
- Optional VPN support:
  - **WireGuard**
  - **Tailscale**
- Persistent data storage for configuration and logs.
- Simple deployment using Docker Compose.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [VPN Options](#vpn-options)
5. [Contributing](#contributing)
6. [License](#license)

---

## Getting Started

### Prerequisites

- **Docker** and **Docker Compose** installed.
- Access to your Proxmox VE nodes.

### Clone the Repository

```bash
git clone https://github.com/<your-username>/proxmox-datacenter-manager-docker.git
cd proxmox-datacenter-manager-docker
```
