# Linux QQ Release Automation (简体中文)

[English](./README.md)

## 项目简介

这是一个旨在为 Linux 用户自动同步并归档腾讯 QQ 最新安装包的项目。

### 项目目标

本项目通过自动化流程，确保用户能够及时通过 GitHub 直接获取最新版本的 QQ Linux 客户端。

### 主要功能

*   **自动监控更新**：全天候定时监测腾讯 QQ 官方页面的版本变动。
*   **全架构支持**：自动收集包括 x86 (deb/rpm/AppImage)、arm64、loongarch64 以及 mips64el 在内的所有官方支持架构。
*   **可靠的归档下载**：将所有安装包自动发布至 GitHub Releases。通过 GitHub 提供的 CDN 下载，可以有效避免官方下载链接偶尔速度较慢或无法访问的问题，同时也提供了历史版本的便捷回溯。

## 命令行下载 (CLI)

你可以使用 `curl` 或 `wget` 下载最新版本的安装包。请将下方链接中的版本号和架构后缀替换为当前最新的版本。

**示例 (x86_64 .deb):**
```bash
# 使用 curl (请务必使用 -L 跟随重定向)
curl -L -O https://github.com/libzonda/Linux-QQ-release/releases/latest/download/QQ_3.2.25_260205_amd64_01.deb

# 使用 wget
wget https://github.com/libzonda/Linux-QQ-release/releases/latest/download/QQ_3.2.25_260205_amd64_01.deb
```


---
*声明：本项目仅用于自动化归档，安装包版权归腾讯公司所有。*
