#!/usr/bin/env bash

DEVICE="at-translated-set-2-keyboard"
STATE_FILE="/tmp/laptop-keyboard-disabled"
LUA_STATE="$HOME/.config/hypr/lua/state/laptop-keyboard.lua"

mkdir -p "$(dirname "$LUA_STATE")"

if [[ -f "$STATE_FILE" ]]; then
    cat > "$LUA_STATE" <<EOF
hl.device({
    name = "$DEVICE",
    enabled = true,
})
EOF

    rm "$STATE_FILE"
    hyprctl reload
    notify-send "Laptop keyboard enabled"
else
    cat > "$LUA_STATE" <<EOF
hl.device({
    name = "$DEVICE",
    enabled = false,
})
EOF

    touch "$STATE_FILE"
    hyprctl reload
    notify-send "Laptop keyboard disabled"
fi
