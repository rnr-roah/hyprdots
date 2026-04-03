#!/bin/bash

USER_NAME=roah
USER_UID=$(id -u "$USER_NAME")

export XDG_RUNTIME_DIR="/run/user/$USER_UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
export PATH="/usr/bin:/bin"

# only notify if a graphical session exists
[ -S "$XDG_RUNTIME_DIR/bus" ] || exit 0

/usr/bin/notify-send "Howdy 👀" "Scanning your face…" -i camera-photo || true

exit 0

