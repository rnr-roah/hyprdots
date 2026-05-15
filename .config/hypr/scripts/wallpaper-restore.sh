#!/usr/bin/env bash

DEFAULT_WALL="$HOME/Wallpapers/default/background.png"
LIVE_CACHE="$HOME/.local/state/wallpapers/current_live_wallpaper"

MONITOR="${MONITOR:-eDP-1}"
MPV_OPTS="no-audio loop --hwdec=auto --panscan=1.0 --vf-add=fps=30"

# Start fallback static wallpaper
pkill -x swaybg 2>/dev/null
swaybg -i "$DEFAULT_WALL" -m fill &
disown

# Restore live wallpaper if it exists
if [[ -f "$LIVE_CACHE" ]]; then
    LIVE_WALL="$(cat "$LIVE_CACHE")"

    if [[ -f "$LIVE_WALL" ]]; then
        pkill -x mpvpaper 2>/dev/null

        mpvpaper -o "$MPV_OPTS" "$MONITOR" "$LIVE_WALL" &
        disown
    fi
fi
