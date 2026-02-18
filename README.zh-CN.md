# Linux QQ Release (简体中文)

[![GitHub Release](https://img.shields.io/github/v/release/libzonda/Linux-QQ-release?style=flat-square)](https://github.com/libzonda/Linux-QQ-release/releases)
[![GitHub Stars](https://img.shields.io/github/stars/libzonda/Linux-QQ-release?style=flat-square)](https://github.com/libzonda/Linux-QQ-release/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/libzonda/Linux-QQ-release?style=flat-square)](https://github.com/libzonda/Linux-QQ-release/network/members)
[![Docker Pulls](https://img.shields.io/docker/pulls/libzonda/linux-qq-release?style=flat-square)](https://hub.docker.com/r/libzonda/linux-qq-release)
[![Docker Image Size](https://img.shields.io/docker/image-size/libzonda/linux-qq-release/latest-amd64?style=flat-square)](https://hub.docker.com/r/libzonda/linux-qq-release)
[![License](https://img.shields.io/github/license/libzonda/Linux-QQ-release?style=flat-square)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux%2Famd64%20%7C%20linux%2Farm64-blue?style=flat-square)](https://hub.docker.com/r/libzonda/linux-qq-release)

[English](./README.md)

## 项目简介

这是一个旨在为 Linux 用户自动同步并归档腾讯 QQ 最新安装包的项目。

### 项目目标

本项目通过自动化流程，确保用户能够及时通过 GitHub 直接获取最新版本的 QQ Linux 客户端。

### 主要功能

*   **自动监控更新**：全天候定时监测腾讯 QQ 官方页面的版本变动。
*   **全架构支持**：自动收集包括 x86 (deb/rpm/AppImage)、arm64、loongarch64 以及 mips64el 在内的所有官方支持架构。
*   **可靠的归档下载**：将所有安装包自动发布至 GitHub Releases。通过 GitHub 提供的 CDN 下载，可以有效避免官方下载链接偶尔速度较慢或无法访问的问题，同时也提供了历史版本的便捷回溯。
*   **Docker 多开支持**：提供强大的 Docker 镜像，支持在单个容器内同时运行多个 QQ 账号，并实现完美的数据隔离与 noVNC 网页访问。

## 命令行下载 (CLI)

你可以使用 `curl` 或 `wget` 下载最新版本的安装包。请将下方链接中的版本号和架构后缀替换为当前最新的版本。

**示例 (x86_64 .deb):**
```bash
# 使用 curl (请务必使用 -L 跟随重定向)
curl -L -O https://github.com/libzonda/Linux-QQ-Release/releases/latest/download/QQ_latest_amd64_01.deb

# 使用 wget
wget https://github.com/libzonda/Linux-QQ-Release/releases/latest/download/QQ_latest_amd64_01.deb
```


## Docker 使用

在 Docker 容器中运行 Linux QQ，并提供基于 Web 的图形界面 (noVNC)。

![Screenshot 1](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot1.jpeg)
![Screenshot 2](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot2.jpeg)

### 特性

- **Web GUI**: 通过浏览器访问 QQ，默认地址 `http://localhost:5800`。
- **内置浏览器**: 集成 **Firefox** (非 Snap 版)，确保能正常打开 QQ 邮箱、空间等外链。
- **多开支持**: 通过 `QQ_INSTANCE_COUNT` 环境变量，支持在同一容器内同时运行多个 QQ 账号。
- **中文支持**: 预置 `zh_CN.UTF-8` 环境及 `Noto Sans CJK`/`文泉驿` 字体，完美支持中文显示与输入。
- **多架构**: 支持 `linux/amd64` 和 `linux/arm64`。

### 快速开始

**从 Docker Hub 运行:**
```bash
docker run -d \
  --name=linuxqq \
  -p 5800:5800 \
  -v /path/to/config:/config \
  -e QQ_INSTANCE_COUNT=1 \
  libzonda/linux-qq-release:latest-amd64
```

**从 GHCR 运行:**
```bash
docker run -d \
  --name=linuxqq \
  -p 5800:5800 \
  -v /path/to/config:/config \
  -e QQ_INSTANCE_COUNT=1 \
  ghcr.io/libzonda/linux-qq-release:latest-amd64
```

打开浏览器访问 `http://localhost:5800` 即可。

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

### 配置说明

#### 环境变量

| 变量名 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `TZ` | `UTC` | 时区设置 (例如 `Asia/Shanghai`)。 |
| `QQ_INSTANCE_COUNT` | `1` | 启动的 QQ 实例数量。 |
| `KEEP_APP_RUNNING` | `0` | 设置为 `1` 可在应用崩溃时自动重启。 |
| `VNC_PASSWORD` | (未设置) | 访问图形界面的密码。**强烈建议**设置此项以保证安全。 |
| `ENABLE_CJK_FONT` | `1` | 启用中文字体 (默认开启)。 |
| `ENABLE_TASKBAR` | `0` | 设置为 `1` 以启用轻量级任务栏 (`tint2`)，方便管理最小化的窗口。 |

#### 存储卷

| 挂载点 | 说明 |
| :--- | :--- |
| `/config` | 应用数据存储目录。支持多开数据隔离 (`/config/.config/QQ`, `/config/.config/QQ_2` 等)。 |

---
*声明：本项目仅用于自动化归档，安装包版权归腾讯公司所有。*
