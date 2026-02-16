FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG DEB_FILE

# Copy the .deb installer
COPY ${DEB_FILE} /tmp/qq.deb

# Install QQ and its dependencies, plus locales and fonts
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      locales \
      dbus \
      libayatana-appindicator3-1 \
      libkeybinder-3.0-0 \
      fonts-wqy-zenhei \
      fonts-wqy-microhei && \
    locale-gen zh_CN.UTF-8 en_US.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    apt-get install -y --no-install-recommends /tmp/qq.deb || true && \
    apt-get install -f -y --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/qq.deb

ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

# Copy the start script
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# Set the application name
RUN set-cont-env APP_NAME "LinuxQQ"

# Expose web access (5800) and VNC (5900)
EXPOSE 5800 5900
