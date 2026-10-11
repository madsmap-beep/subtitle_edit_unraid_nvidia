#!/bin/sh
set -eu

attempt=0
while [ ! -S /tmp/.X11-unix/X0 ]; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 30 ]; then
        printf '%s\n' "Xvfb did not create its display socket within 30 seconds." >&2
        exit 1
    fi
    sleep 1
done

mkdir -p "$HOME/.config" "$HOME/.cache"
exec /opt/subtitleedit/SubtitleEdit
