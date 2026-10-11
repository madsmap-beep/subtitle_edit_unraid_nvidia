#!/bin/sh
set -eu

config=/var/run/openbox/rc.xml
tmp="${config}.tmp"

if [ ! -s "$config" ]; then
    printf '%s\n' "Openbox config not found: $config" >&2
    exit 1
fi

awk '
    !changed && /<decor>no<\/decor>/ {
        sub(/<decor>no<\/decor>/, "<decor>yes</decor>")
        changed = 1
    }
    { print }
    END { if (!changed) exit 1 }
' "$config" > "$tmp" || {
    rm -f "$tmp"
    printf '%s\n' 'Unable to enable the Subtitle Edit window title bar.' >&2
    exit 1
}

mv "$tmp" "$config"
