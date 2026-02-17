# syntax=docker/dockerfile:1
FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG PACKAGE_FILE

# Set environment
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

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
