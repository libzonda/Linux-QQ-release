FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG DEB_FILE

# Copy the .deb installer
COPY ${DEB_FILE} /tmp/qq.deb

# Install QQ and its dependencies
RUN apt-get update && \
    apt-get install -y /tmp/qq.deb || true && \
    apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/qq.deb

# Copy the start script
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# Set the application name
RUN set-cont-env APP_NAME "LinuxQQ"

# Expose web access (5800) and VNC (5900)
EXPOSE 5800 5900
