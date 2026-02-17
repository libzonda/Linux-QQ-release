# Linux QQ Release

[简体中文](./README.zh-CN.md)

## Overview

This project aims to automatically synchronize and archive the latest Tencent QQ installation packages for Linux users.

### Project Goals

This project uses automated workflows to ensure that users can obtain the latest version of the QQ Linux client directly through GitHub in a timely manner.

### Key Features

*   **Automated Update Monitoring**: Monitors version changes on the official Tencent QQ page around the clock.
*   **Full Architecture Support**: Automatically collects all officially supported architectures, including x86 (deb/rpm/AppImage), arm64, loongarch64, and mips64el.
*   **Reliable Archive Downloads**: Automatically publishes all installation packages to GitHub Releases. Downloading via GitHub's CDN effectively avoids issues where official download links may be slow or inaccessible, and also provides a convenient way to trace back historical versions.

## Download via CLI

You can download the latest installer using `curl` or `wget`. Replace `<VERSION>` and `<ARCH_EXT>` with the current version and your preferred package format.

**Example (x86_64 .deb):**
```bash
# Using curl (follow redirects with -L)
curl -L -O https://github.com/libzonda/Linux-QQ-release/releases/latest/download/QQ_latest_amd64_01.deb

# Using wget
wget https://github.com/libzonda/Linux-QQ-Release/releases/latest/download/QQ_latest_amd64_01.deb
```

## Docker Usage

Run Tencent QQ for Linux in a Docker container with a web-accessible GUI (noVNC).

![Screenshot 1](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot1.jpeg)
![Screenshot 2](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot2.jpeg)

### Features

- **Web GUI**: Access QQ via browser at `http://localhost:5800`.
- **Integrated Browser**: Built-in **Firefox** (non-Snap) ensures external links (Email, Qzone) open correctly.
- **Multi-Instance**: Support running multiple QQ accounts simultaneously via `QQ_INSTANCE_COUNT`.
- **Chinese Support**: Pre-configured `zh_CN.UTF-8` locale and fonts (`Noto Sans CJK`, `WenQuanYi`).
- **Multi-Arch**: Supports `amd64` and `arm64`.

### Quick Start

**Run from Docker Hub:**
```bash
docker run -d \
  --name=linuxqq \
  -p 5800:5800 \
  -v /path/to/config:/config \
  -e QQ_INSTANCE_COUNT=1 \
  libzonda/linux-qq-release:latest-amd64
```

**Run from GHCR:**
```bash
docker run -d \
  --name=linuxqq \
  -p 5800:5800 \
  -v /path/to/config:/config \
  -e QQ_INSTANCE_COUNT=1 \
  ghcr.io/libzonda/linux-qq-release:latest-amd64
```

Open your browser and visit `http://localhost:5800`.

### Docker Compose

```yaml
services:
  linuxqq:
    image: ghcr.io/libzonda/linux-qq-release:latest-amd64
    container_name: linuxqq
    restart: unless-stopped
    ports:
      - "5800:5800"
    volumes:
      - ./config:/config
    environment:
      - TZ=Asia/Shanghai
      - QQ_INSTANCE_COUNT=1
      - KEEP_APP_RUNNING=1
      # - VNC_PASSWORD=secret
```

### Configuration

#### Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `TZ` | `UTC` | Time zone (e.g., `Asia/Shanghai`). |
| `QQ_INSTANCE_COUNT` | `1` | Number of QQ instances to run. |
| `KEEP_APP_RUNNING` | `0` | Set to `1` to restart application if it crashes. |
| `VNC_PASSWORD` | (unset) | Password for accessing the GUI. **Highly recommended** to set this for security. |
| `ENABLE_CJK_FONT` | `1` | Enable Chinese fonts (default: 1). |

#### Volumes

| Volume | Description |
| :--- | :--- |
| `/config` | Application data storage. Supports multi-instance isolation (`/config/.config/QQ`, `/config/.config/QQ_2`, etc.). |

---
*Disclaimer: This project is for automated archiving purposes only. The copyright of the installation packages belongs to Tencent.*
*   **Multi-Arch**: Supports `amd64` and `arm64`

### Quick Start

**Run from Docker Hub:**
```bash
# Replace <user> with the actual namespace (e.g., libzonda)
docker run -d \
  --name=linuxqq \
  -p 5800:5800 \
  -v /path/to/config:/config \
  libzonda/linux-qq-release:latest-amd64
```

**Run from GHCR:**
```bash
docker run -d \
  --name=linuxqq \
  -p 5800:5800 \
  -v /path/to/config:/config \
  -e QQ_INSTANCE_COUNT=1 \
  ghcr.io/libzonda/linux-qq-release:latest-amd64
```

Open your browser and visit `http://localhost:5800`.

### Using Docker Compose

1. Create a `docker-compose.yml` file:

```yaml
services:
  linuxqq:
    image: ghcr.io/libzonda/linux-qq-release:latest-amd64
    container_name: linuxqq
    restart: unless-stopped
    ports:
      - "5800:5800"
    volumes:
      - ./config:/config
    environment:
      - TZ=Asia/Shanghai
      - KEEP_APP_RUNNING=1
      - ENABLE_CJK_FONT=1
      - QQ_INSTANCE_COUNT=1
```

2. Run with command: `docker-compose up -d`

### Multi-Instance Data Persistence

When running multiple instances (e.g., `QQ_INSTANCE_COUNT=3`), a single volume mount at `/config` is sufficient to persist data for **all** instances.

The data will be organized automatically as follows:
*   **Instance 1 (Main)**: `/config/.config/QQ`
*   **Instance 2**: `/config/.config/QQ_2`
*   **Instance 3**: `/config/.config/QQ_3`
*   ...and so on.

You do **not** need to mount separate volumes for each instance.




---
*Disclaimer: This project is for automated archiving purposes only. The copyright of the installation packages belongs to Tencent.*
