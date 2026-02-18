# Linux QQ Release

[![GitHub Release](https://img.shields.io/github/v/release/libzonda/Linux-QQ-release?style=flat-square)](https://github.com/libzonda/Linux-QQ-release/releases)
[![GitHub Stars](https://img.shields.io/github/stars/libzonda/Linux-QQ-release?style=flat-square)](https://github.com/libzonda/Linux-QQ-release/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/libzonda/Linux-QQ-release?style=flat-square)](https://github.com/libzonda/Linux-QQ-release/network/members)
[![Docker Pulls](https://img.shields.io/docker/pulls/libzonda/linux-qq-release?style=flat-square)](https://hub.docker.com/r/libzonda/linux-qq-release)
[![Docker Image Size](https://img.shields.io/docker/image-size/libzonda/linux-qq-release/latest-amd64?style=flat-square)](https://hub.docker.com/r/libzonda/linux-qq-release)
[![License](https://img.shields.io/github/license/libzonda/Linux-QQ-release?style=flat-square)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux%2Famd64%20%7C%20linux%2Farm64-blue?style=flat-square)](https://hub.docker.com/r/libzonda/linux-qq-release)

[简体中文](./README.zh-CN.md)

## Overview

This project aims to automatically synchronize and archive the latest Tencent QQ installation packages for Linux users.

### Project Goals

This project uses automated workflows to ensure that users can obtain the latest version of the QQ Linux client directly through GitHub in a timely manner.

### Key Features

*   **Automated Update Monitoring**: Monitors version changes on the official Tencent QQ page around the clock.
*   **Full Architecture Support**: Automatically collects all officially supported architectures, including x86 (deb/rpm/AppImage), arm64, loongarch64, and mips64el.
*   **Reliable Archive Downloads**: Automatically publishes all installation packages to GitHub Releases. Downloading via GitHub's CDN effectively avoids issues where official download links may be slow or inaccessible, and also provides a convenient way to trace back historical versions.
*   **Multi-Instance Support**: Provides a powerful Docker image that supports running multiple QQ accounts simultaneously with full data isolation and noVNC web access.

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

![Main UI Preview](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot_main.jpeg)

### Key Features

- **Web GUI**: Access QQ via browser at `http://localhost:5800`.
- **Integrated Firefox**: Built-in browser for link redirection.
- **Docker Multi-Instance**: Run multiple accounts in one container.
- **Optional Taskbar**: Integrated `tint2` to manage minimized windows.

#### 1. Multi-Instance Support
By setting the `QQ_INSTANCE_COUNT` environment variable, you can launch multiple QQ instances. Each instance has an isolated data directory.

![Multi-Instance Demo](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot_muilt_instance.jpeg)

#### 2. Optional Taskbar (tint2)
Set `ENABLE_TASKBAR=1` to enable the bottom `tint2` taskbar. This is extremely helpful for restoring minimized windows.

![Taskbar Demo](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot_enable_task_bar.jpeg)

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
| `ENABLE_TASKBAR` | `0` | Set to `1` to enable a lightweight taskbar (`tint2`) for managing minimized windows. |

#### Volumes

| Volume | Description |
| :--- | :--- |
| `/config` | Application data storage. Supports multi-instance isolation (`/config/.config/QQ`, `/config/.config/QQ_2`, etc.). |

---
*Disclaimer: This project is for automated archiving purposes only. The copyright of the installation packages belongs to Tencent.*
