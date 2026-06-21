#!/usr/bin/env bash

DEV="/dev/input/by-path/platform-i8042-serio-0-event-kbd"
PID_FILE="/tmp/laptop-keyboard-grab.pid"

if [[ -f "$PID_FILE" ]] && sudo kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    sudo kill "$(cat "$PID_FILE")"
    rm -f "$PID_FILE"
    notify-send "Laptop keyboard enabled"
else
    sudo evtest --grab "$DEV" >/dev/null 2>&1 &
    echo $! > "$PID_FILE"
    notify-send "Laptop keyboard disabled"
fi
