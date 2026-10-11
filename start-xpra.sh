#!/bin/sh
set -eu

if [ -n "${WEB_PASSWORD:-}" ]; then
    export XPRA_PASSWORD=$WEB_PASSWORD
    auth=env
else
    auth=none
    printf '%s\n' "WARNING: Xpra web audio is unauthenticated; restrict access to trusted networks." >&2
fi

exec /usr/bin/xpra shadow :0 \
    --bind-tcp="0.0.0.0:10000,auth=$auth" \
    --speaker=on \
    --daemon=no
