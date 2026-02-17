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
        squashfs-tools && \
    # Setup locales
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    # Extract AppImage without executing it (to avoid Exec format error on multi-arch)
    # We find the offset of the SquashFS payload (magic bytes 'hsqs')
    # Using dd with skip_bytes for high performance on large files
    OFFSET=$(grep -abo hsqs /tmp/app.AppImage | cut -d: -f1 | head -n 1) && \
    dd if=/tmp/app.AppImage bs=1M skip=$OFFSET iflag=skip_bytes of=/tmp/app.squashfs && \
    unsquashfs -d /opt/QQ -n -li /tmp/app.squashfs && \
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
