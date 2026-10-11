FROM debian:trixie-slim

ARG SUBTITLEEDIT_VERSION=5.3.0-rc2
ARG SUBTITLEEDIT_SHA256=6615ab68a991331753ed5eff6740000be3fa6aa4df573d9b364784901bb6135e

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/config \
    DISPLAY=:0 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        ffmpeg \
        fluxbox \
        fonts-dejavu-core \
        libasound2t64 \
        libfontconfig1 \
        libfreetype6 \
        libgl1 \
        libglib2.0-0t64 \
        libgtk-3-0t64 \
        libicu76 \
        libmpv2 \
        libnss3 \
        libssl3t64 \
        libx11-6 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxinerama1 \
        libxrandr2 \
        libxrender1 \
        libxtst6 \
        mpv \
        novnc \
        python3-websockify \
        supervisor \
        x11vnc \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --silent --show-error \
        "https://github.com/SubtitleEdit/subtitleedit/releases/download/v${SUBTITLEEDIT_VERSION}/SubtitleEdit-Linux-x64.tar.gz" \
        --output /tmp/subtitleedit.tar.gz \
    && echo "${SUBTITLEEDIT_SHA256}  /tmp/subtitleedit.tar.gz" | sha256sum --check \
    && mkdir -p /opt/subtitleedit /config /data \
    && tar -xzf /tmp/subtitleedit.tar.gz -C /opt/subtitleedit \
    && rm /tmp/subtitleedit.tar.gz \
    && chmod 0755 /opt/subtitleedit/SubtitleEdit \
    && (getent group 100 >/dev/null || groupadd --gid 100 users) \
    && useradd --uid 99 --gid 100 --home-dir /config --no-create-home \
        --shell /usr/sbin/nologin subtitleedit \
    && chown -R 99:100 /config /data

COPY supervisord.conf /etc/supervisor/conf.d/subtitleedit.conf
COPY start-vnc.sh /usr/local/bin/start-vnc
COPY start-app.sh /usr/local/bin/start-app
RUN chmod 0755 /usr/local/bin/start-vnc /usr/local/bin/start-app

EXPOSE 5900/tcp 6080/tcp
VOLUME ["/config", "/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl --fail --silent http://127.0.0.1:6080/vnc.html -o /dev/null || exit 1

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
