# syntax=docker/dockerfile:1
FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG IMAGE_FILE

# Set environment
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Install dependencies and extract AppImage
# Install dependencies (Cached Layer)
RUN apt-get update && \
    # Install base dependencies and Electron/QQ runtime deps
    apt-get install -y --no-install-recommends \
        locales \
        dbus \
        fonts-wqy-zenhei \
        libayatana-appindicator3-1 \
        libkeybinder-3.0-0 \
        desktop-file-utils \
        libnss3 \
        libgbm1 \
        libasound2t64 \
        libgtk-3-0t64 \
        libxss1 \
        libxtst6 \
        binutils \
        7zip && \
    # Setup locales
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    # Cleanup apt cache to reduce layer size
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/*

# Extract AppImage (Application Layer)
# We use --mount to keep the AppImage file out of the image layer
RUN --mount=type=bind,source=${IMAGE_FILE},target=/tmp/app.AppImage \
    7z x /tmp/app.AppImage -o/opt/QQ && \
    chmod -R +x /opt/QQ

# Copy the start script
COPY startapp.sh /startapp.sh

# Set application name and permissions
RUN chmod +x /startapp.sh && \
    set-cont-env APP_NAME "LinuxQQ"

# Expose web access (5800) and VNC (5900)
EXPOSE 5800 5900
