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
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    # Install QQ and fix dependencies
    dpkg -i /tmp/qq.deb || apt-get install -y --no-install-recommends -f && \
    # Aggressive cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /var/cache/apt/* \
           /usr/share/doc/* \
           /usr/share/man/* \
           /usr/share/info/* \
           /var/log/* \
           /tmp/*

# Copy the start script
COPY startapp.sh /startapp.sh

# Set application name and permissions
RUN chmod +x /startapp.sh && \
    set-cont-env APP_NAME "LinuxQQ"

# Expose web access (5800) and VNC (5900)
EXPOSE 5800 5900

