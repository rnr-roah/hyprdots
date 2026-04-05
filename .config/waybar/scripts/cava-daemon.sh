#!/bin/bash
readonly CAVA_FIFO="/tmp/waybar-cava"
[ -p "$CAVA_FIFO" ] || mkfifo "$CAVA_FIFO"
pkill -f "cava -p.*waybar" 2>/dev/null
cava -p ~/.config/cava/waybar > "$CAVA_FIFO"
