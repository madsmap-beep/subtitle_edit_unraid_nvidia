#!/bin/sh
set -eu

runtime_dir="$(mktemp -d /tmp/subtitleedit-portal.XXXXXX)"
export XDG_RUNTIME_DIR="$runtime_dir"
export XDG_CURRENT_DESKTOP=GNOME

if ! getent passwd "$(id -u)" >/dev/null 2>&1; then
    printf 'app:x:%s:%s:app:%s:/usr/sbin/nologin\n' "$(id -u)" "$(id -g)" "${HOME:-/tmp}" > "$runtime_dir/passwd"
    printf 'app:x:%s:\n' "$(id -g)" > "$runtime_dir/group"
    export LD_PRELOAD=libnss_wrapper.so
    export NSS_WRAPPER_PASSWD="$runtime_dir/passwd"
    export NSS_WRAPPER_GROUP="$runtime_dir/group"
fi

eval "$(dbus-launch --sh-syntax)"
/usr/libexec/xdg-desktop-portal-gtk &
gtk_portal_pid=$!
/usr/libexec/xdg-desktop-portal &
portal_pid=$!

cleanup() {
    for pid in "$gtk_portal_pid" "$portal_pid"; do
        kill "$pid" 2>/dev/null || true
    done
    for pid in "$gtk_portal_pid" "$portal_pid"; do
        wait "$pid" 2>/dev/null || true
    done
    if [ -n "${DBUS_SESSION_BUS_PID:-}" ]; then
        kill "$DBUS_SESSION_BUS_PID" 2>/dev/null || true
        wait "$DBUS_SESSION_BUS_PID" 2>/dev/null || true
    fi
    rm -rf "$runtime_dir"
}
trap cleanup EXIT
trap 'exit 0' INT TERM

/opt/subtitleedit/SubtitleEdit &
app_pid=$!
wait "$app_pid"
