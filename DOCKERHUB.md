# Linux QQ Docker Image

Run Tencent QQ for Linux in a Docker container with a web-accessible GUI. This image is based on `jlesage/baseimage-gui:ubuntu-24.04-v4`.

## Features

- **Web GUI**: Access QQ via browser at `http://localhost:5800`.
- **Chinese Support**: Integrated Chinese fonts (`Noto Sans CJK`, `WenQuanYi`) and `zh_CN.UTF-8` locale.
- **Micro-animations**: Smooth desktop-like experience in browser.
- **Multarch**: Supports `amd64` and `arm64`.

## Quick Start

### Docker Run

```bash
docker run -d \
    --name=linuxqq \
    -p 5800:5800 \
    -v /path/to/config:/config \
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
```

## Configuration

### Environment Variables

| Variable | Description |
| :--- | :--- |
| `TZ` | Time zone (e.g., `Asia/Shanghai`). |
| `KEEP_APP_RUNNING` | When set to `1`, the application will be automatically restarted if it crashes. |

### Volumes

| Volume | Description |
| :--- | :--- |
| `/config` | Where the application settings and user data are stored. |

---

*Disclaimer: This project is for personal use and convenience. All rights to the QQ software belong to Tencent.*
