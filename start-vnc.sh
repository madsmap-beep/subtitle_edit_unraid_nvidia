#!/bin/sh
set -eu

password=${VNC_PASSWORD:-}

if [ -n "${VNC_PASSWORD_FILE:-}" ]; then
    if [ ! -r "$VNC_PASSWORD_FILE" ]; then
        printf '%s\n' "VNC_PASSWORD_FILE is not readable: $VNC_PASSWORD_FILE" >&2
        exit 1
    fi
    password=$(cat "$VNC_PASSWORD_FILE")
fi

if [ -n "$password" ]; then
    export LC_ALL=C
    if [ "${#password}" -gt 8 ]; then
        printf '%s\n' "VNC passwords must be no longer than 8 ASCII characters." >&2
        exit 1
    fi
    case "$password" in
        *[![:print:]]*)
            printf '%s\n' "VNC passwords must contain printable ASCII characters only." >&2
            exit 1
            ;;
    esac

    umask 077
    x11vnc -storepasswd "$password" /tmp/subtitleedit-vnc.pass >/dev/null
    exec x11vnc -display :0 -rfbport 5900 -rfbauth /tmp/subtitleedit-vnc.pass \
        -forever -shared -noxdamage -listen 0.0.0.0
fi

printf '%s\n' "WARNING: VNC has no password; restrict access to trusted networks." >&2
exec x11vnc -display :0 -rfbport 5900 -nopw -forever -shared \
    -noxdamage -listen 0.0.0.0
