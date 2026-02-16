# Linux QQ Release Automation

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
wget https://github.com/libzonda/Linux-QQ-release/releases/latest/download/QQ_latest_amd64_01.deb
```

## Docker Usage

You can also run Linux QQ in a Docker container with a web-based GUI (noVNC).

### Features
*   **Web GUI**: Access QQ via browser at `http://localhost:5800`
*   **Chinese Support**: Built-in Chinese fonts (`Noto Sans CJK`, `WenQuanYi`) and input method support
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
  ghcr.io/libzonda/linux-qq-release:latest-amd64
```

Open your browser and visit `http://localhost:5800`.



---
*Disclaimer: This project is for automated archiving purposes only. The copyright of the installation packages belongs to Tencent.*
