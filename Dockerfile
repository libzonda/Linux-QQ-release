# syntax=docker/dockerfile:1
FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG DEB_FILE

# Set environment
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Install dependencies and QQ in a single layer to minimize size
# We use --mount=type=bind to access the .deb installer without copying it into a layer
RUN --mount=type=bind,source=${DEB_FILE},target=/tmp/qq.deb \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        dbus \
        fonts-wqy-zenhei \
        libayatana-appindicator3-1 \
        libkeybinder-3.0-0 && \
    # Setup locales
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    # Install QQ
    dpkg -i /tmp/qq.deb || apt-get install -y --no-install-recommends -f && \
    # Aggressive cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    # Remove documentation, manpages, and unnecessary locales
    find /usr/share/doc -depth -type f ! -name copyright -delete && \
    find /usr/share/doc -empty -delete && \
    rm -rf /usr/share/man/* /usr/share/info/* /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* && \
    # Prune locales: keep only zh_CN and en_US
    find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'zh_CN' ! -name 'en_US' ! -name 'en' -exec rm -rf {} + && \
    rm -rf /var/lib/apt/lists/* \
           /var/cache/apt/* \
           /tmp/* \
           /var/log/*

# Copy the start script
COPY startapp.sh /startapp.sh

# Set application name and permissions
RUN chmod +x /startapp.sh && \
    set-cont-env APP_NAME "LinuxQQ"

# Expose web access (5800) and VNC (5900)
EXPOSE 5800 5900
