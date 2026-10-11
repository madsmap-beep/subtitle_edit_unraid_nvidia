FROM jlesage/baseimage-gui:ubuntu-24.04-v4@sha256:e7c54da3446b4c65b6755bf00a874463c640a1f579f25bed99532051e81649ef

ARG SUBTITLEEDIT_VERSION=5.3.0-rc2
ARG SUBTITLEEDIT_SHA256=6615ab68a991331753ed5eff6740000be3fa6aa4df573d9b364784901bb6135e

ENV WEB_AUDIO=1 \
    KEEP_APP_RUNNING=1 \
    DISPLAY_WIDTH=1920 \
    DISPLAY_HEIGHT=1080 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN groupadd --force --system staff \
    && getent passwd root >/dev/null || useradd --system --uid 0 --gid 0 --no-create-home --shell /usr/sbin/nologin root \
    && mkdir -p /config/log

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        ffmpeg \
        fonts-dejavu-core \
        libfontconfig1 \
        libfreetype6 \
        libgl1 \
        libicu74 \
        libmpv2 \
        mpv \
    && mpv_library="$(ldconfig -p | awk '/libmpv\.so\.[0-9]+/{print $NF; exit}')" \
    && test -n "$mpv_library" \
    && ln -s "$(basename "$mpv_library")" "$(dirname "$mpv_library")/libmpv.so" \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --silent --show-error \
        "https://github.com/SubtitleEdit/subtitleedit/releases/download/v${SUBTITLEEDIT_VERSION}/SubtitleEdit-Linux-x64.tar.gz" \
        --output /tmp/subtitleedit.tar.gz \
    && echo "${SUBTITLEEDIT_SHA256}  /tmp/subtitleedit.tar.gz" | sha256sum --check \
    && mkdir -p /opt/subtitleedit \
    && tar -xzf /tmp/subtitleedit.tar.gz -C /opt/subtitleedit \
    && rm /tmp/subtitleedit.tar.gz \
    && chmod 0755 /opt/subtitleedit/SubtitleEdit \
    && ln -s /opt/subtitleedit/SubtitleEdit /usr/local/bin/subtitleedit

COPY startapp.sh /startapp.sh
RUN chmod 0755 /startapp.sh \
    && set-cont-env APP_NAME "Subtitle Edit" \
    && set-cont-env APP_VERSION "${SUBTITLEEDIT_VERSION}"

EXPOSE 5800/tcp 5900/tcp
VOLUME ["/config", "/data"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl --fail --silent http://127.0.0.1:5800/ -o /dev/null || exit 1
