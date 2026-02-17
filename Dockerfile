# syntax=docker/dockerfile:1
FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG PACKAGE_FILE

# Set environment
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    QQ_INSTANCE_COUNT=1

# Install dependencies and extract AppImage
# Install dependencies (Cached Layer)
RUN apt-get update && \
    # Install base dependencies and Electron/QQ runtime deps
    apt-get install -y --no-install-recommends \
        software-properties-common \
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
        xdg-utils && \
    # Setup PPA for non-snap Firefox
    add-apt-repository ppa:mozillateam/ppa && \
    echo 'Package: firefox*' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y --no-install-recommends firefox && \
    # Setup locales
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    # Cleanup apt cache to reduce layer size
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/*

# Create Firefox wrapper to disable sandbox
# Docker containers often lack the privileges for Firefox's user namespace sandbox
RUN echo '#!/bin/sh' > /usr/local/bin/firefox && \
    echo 'echo "Starting Firefox with sandbox disabled..."' >> /usr/local/bin/firefox && \
    echo 'export MOZ_DISABLE_CONTENT_SANDBOX=1' >> /usr/local/bin/firefox && \
    echo 'export MOZ_DISABLE_GMP_SANDBOX=1' >> /usr/local/bin/firefox && \
    echo 'export MOZ_DISABLE_RDD_SANDBOX=1' >> /usr/local/bin/firefox && \
    echo 'export MOZ_DISABLE_setuid_sandbox=1' >> /usr/local/bin/firefox && \
    echo 'exec /usr/bin/firefox --no-sandbox --disable-setuid-sandbox "$@"' >> /usr/local/bin/firefox && \
    chmod +x /usr/local/bin/firefox

# Install QQ from DEB (Application Layer)
COPY ${PACKAGE_FILE} /tmp/qq.deb
RUN apt-get update && \
    apt-get install -y /tmp/qq.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/qq.deb

# Copy the start script
COPY startapp.sh /startapp.sh

# Set application name and permissions
RUN chmod +x /startapp.sh && \
    set-cont-env APP_NAME "LinuxQQ"

# Expose web access (5800) and VNC (5900)
EXPOSE 5800 5900
