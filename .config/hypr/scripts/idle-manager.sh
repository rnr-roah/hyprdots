#!/bin/bash

LOCK_FILE="/tmp/hyprlock_active"
SUSPEND_FILE="/tmp/hypr_suspend_active"

lock() {
    if [ ! -f "$LOCK_FILE" ]; then
        touch "$LOCK_FILE"
        hyprlock
        rm -f "$LOCK_FILE"
    fi
}

suspend() {
    if [ ! -f "$SUSPEND_FILE" ]; then
        touch "$SUSPEND_FILE"
        systemctl suspend
        rm -f "$SUSPEND_FILE"
    fi
}

case "$1" in
    lock) lock ;;
    suspend) suspend ;;
esac

