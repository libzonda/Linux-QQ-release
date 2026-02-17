# syntax=docker/dockerfile:1
FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG IMAGE_FILE

# Set environment
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Install dependencies and extract AppImage
# We use --mount to keep the AppImage file out of the image layer
RUN --mount=type=bind,source=${IMAGE_FILE},target=/tmp/app.AppImage \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        dbus \
        fonts-wqy-zenhei \
        libayatana-appindicator3-1 \
        libkeybinder-3.0-0 \
        desktop-file-utils \
        # Electron/QQ runtime deps
        libnss3 \
        libgbm1 \
        libasound2t64 \
        libgtk-3-0 \
        libxss1 \
        libxtst6 \
        # To extract AppImage
        binutils && \
    # Setup locales
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    # Extract AppImage
    chmod +x /tmp/app.AppImage && \
    /tmp/app.AppImage --appimage-extract && \
    mv squashfs-root /opt/QQ && \
    # General cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/log/*

# Copy the start script
COPY startapp.sh /startapp.sh

# Set application name and permissions
RUN chmod +x /startapp.sh && \
    set-cont-env APP_NAME "LinuxQQ"

# Expose web access (5800) and VNC (5900)
EXPOSE 5800 5900
