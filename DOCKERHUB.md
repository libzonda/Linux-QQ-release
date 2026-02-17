# Linux QQ Docker Image

Run Tencent QQ for Linux in a Docker container with a web-accessible GUI. Based on `jlesage/baseimage-gui:ubuntu-24.04-v4`.

![Screenshot 1](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot1.jpeg)
![Screenshot 2](https://raw.githubusercontent.com/libzonda/Linux-QQ-Release/main/screenshot2.jpeg)

## Features

- **Web GUI (noVNC)**: Access QQ directly via browser at `http://localhost:5800`.
- **Integrated Browser**: Built-in **Firefox** (non-Snap) ensures external links (Email, Qzone) open correctly.
- **Multi-Instance**: Support running multiple QQ accounts simultaneously in one container via `QQ_INSTANCE_COUNT`.
- **Chinese Support**: Pre-configured `zh_CN.UTF-8` locale and fonts (`Noto Sans CJK`, `WenQuanYi`).
- **Multi-Arch**: Supports `linux/amd64` and `linux/arm64`.

## Quick Start

### Docker Run

```bash
docker run -d \
    --name=linuxqq \
    -p 5800:5800 \
    -v /path/to/config:/config \
    -e QQ_INSTANCE_COUNT=1 \
    libzonda/linux-qq-release:latest-amd64
```

### Docker Compose

```yaml
services:
  linuxqq:
    image: libzonda/linux-qq-release:latest-amd64
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

## Configuration

### Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `TZ` | `UTC` | Time zone (e.g., `Asia/Shanghai`). |
| `QQ_INSTANCE_COUNT` | `1` | Number of QQ instances to run. |
| `KEEP_APP_RUNNING` | `0` | Set to `1` to restart application if it crashes. |
| `VNC_PASSWORD` | (unset) | Password for VNC access. |
| `ENABLE_CJK_FONT` | `1` | Enable Chinese fonts (default: 1). |

### Volumes

| Volume | Description |
| :--- | :--- |
| `/config` | Application data storage. Supports multi-instance isolation (`/config/.config/QQ`, `/config/.config/QQ_2`, etc.). |

---

*Disclaimer: This project is for personal use and convenience. All rights to the QQ software belong to Tencent.*

