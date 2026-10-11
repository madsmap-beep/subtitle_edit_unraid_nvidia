#!/bin/sh
set -eu

config=/var/run/openbox/rc.xml
tmp="${config}.tmp"

if [ ! -s "$config" ]; then
    printf '%s\n' "Openbox config not found: $config" >&2
    exit 1
fi

awk '
    index($0, "</applications>") && !added {
        print "  <application class=\"*\">"
        print "    <maximized>yes</maximized>"
        print "  </application>"
        added = 1
    }
    { print }
    END { if (!added) exit 1 }
' "$config" > "$tmp" || {
    rm -f "$tmp"
    printf '%s\n' 'Unable to add maximize rule to Openbox config.' >&2
    exit 1
}

mv "$tmp" "$config"
