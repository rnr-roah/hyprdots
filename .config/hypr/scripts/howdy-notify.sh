#!/bin/bash
USER_ID=$(id -u roah)
DBUS=$(ls /run/user/$USER_ID/bus 2>/dev/null)

export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-1
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_ID/bus
export XDG_RUNTIME_DIR=/run/user/$USER_ID

if [[ "$PAM_TYPE" == "auth" ]]; then
    /usr/bin/notify-send -u normal -i camera-web "🔴 IR Camera active" "Howdy facial recognition started"
elif [[ "$PAM_TYPE" == "close_session" ]]; then
    /usr/bin/notify-send -u normal -i camera-web "IR Camera stopped" "Howdy facial recognition finished"
fi
